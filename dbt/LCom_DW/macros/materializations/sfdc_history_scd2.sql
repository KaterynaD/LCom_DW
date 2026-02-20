{% materialization sfdc_history_scd2, adapter='redshift' %}

{# ============================================================
   CONFIG
============================================================ #}

{% set unique_key       = config.get('unique_key') %}
{% set fields_config    = config.get('fields_config') %}
{% set first_fromdate   = config.get('first_fromdate', '1900-01-01') %}
{% set last_todate      = config.get('last_todate', '3000-12-31') %}

{% set base_model = config.get('base_model') %}
{% set base_source = config.get('base_source') %}

{% set target_relation  = this %}

{# ============================================================
   VALIDATION
============================================================ #}

{% if not unique_key %}
  {% do exceptions.raise_compiler_error("Missing required config: unique_key") %}
{% endif %}

{% if not fields_config or fields_config | length == 0 %}
  {% do exceptions.raise_compiler_error("fields_config must be a non-empty list") %}
{% endif %}


{# ============================================================
   RECONSTRUCT BASE RELATION 
============================================================ #}


{% if base_model %}
{% set base_relation = ref(base_model) %}
{% endif %}

{% if base_source %}
{% set base_relation = source(base_source['name'], base_source['table']) %}
{% endif %}





{# ============================================================
   BUILD FIELD FILTER
============================================================ #}

{% set field_filters = [] %}

{% for f in fields_config %}
  {% set sf_field  = f["source_field"] %}
  {% set dt        = f.get("type") %}
  {% if dt %}
    {% do field_filters.append("(field = '" ~ sf_field ~ "' and data_type = '" ~ dt ~ "')") %}
  {% else %}
    {% do field_filters.append("(field = '" ~ sf_field ~ "')") %}
  {% endif %}
{% endfor %}

{% set field_filter_sql = field_filters | join("\nor\n") %}


{# ============================================================
   FINAL SQL
============================================================ #}

{% set build_sql %}

with
historical_data as (

    {{ model['compiled_code'] }}

)

/* 1) Source data from a Salesforce history table filtered only to required fields and data types */
,rawdata as (
    select
        {{ unique_key }},
        created_date as created_timestamp,
        trunc(created_date) as created_date,
        field,
        new_value,
        old_value
    from historical_data
    where coalesce(old_value,'Unknown') != coalesce(new_value,'Unknown')
      and ( {{ field_filter_sql }} )
)

/* 2) Start history from old_value very first record for each unique id and field */
,history_start_at as (
    select
        {{ unique_key }},
        min(created_timestamp) as created_timestamp,
        field
    from rawdata
    group by {{ unique_key }}, field
)

/* 2.2) old_value from very first record for each unique id and field */
,history_started_from_values as (
    select
        r.{{ unique_key }},
        '{{ first_fromdate }}'::timestamp as created_timestamp,
        '{{ first_fromdate }}'::date      as created_date,
        r.field,
        r.old_value
    from rawdata r
    join history_start_at s
      on r.{{ unique_key }} = s.{{ unique_key }}
     and r.field = s.field
     and r.created_timestamp = s.created_timestamp
)

/* 2.3) extend history to current attribute values if they were never changed */
,extended_history_started_from_values as (

    select
        {{ unique_key }},
        created_timestamp,
        created_date,
        field,
        coalesce(old_value,'Unknown') as old_value
    from history_started_from_values

{% if base_relation %}

    {% for f in fields_config %}
      {% set sf_field      = f["source_field"] %}
      {% set target_field  = f["target_field"] %}
      {% set default_value = f.get("default", "Unknown") %}

    union all
    select
        c.{{ unique_key }},
        '{{ first_fromdate }}'::timestamp as created_timestamp,
        '{{ first_fromdate }}'::date      as created_date,
        '{{ sf_field }}'                  as field,
        coalesce(c.{{ target_field }}, '{{ default_value }}') as old_value
    from {{ base_relation }} c
    left join (
        select {{ unique_key }}
        from history_started_from_values
        where field = '{{ sf_field }}'
    ) h
      on c.{{ unique_key }} = h.{{ unique_key }}
    where h.{{ unique_key }} is null

    {% endfor %}

{% endif %}

)

/* 3) Skipping daily changes: take latest timestamp per day+field */
,latest_field_state_day as (
    select
        {{ unique_key }},
        created_date,
        field,
        max(created_timestamp) as created_timestamp
    from rawdata
    group by {{ unique_key }}, created_date, field
)

/* 3.2) Attribute valid value at the end of a day */
,daily_rawdata as (
    select
        r.{{ unique_key }},
        r.created_timestamp,
        r.created_date,
        r.field,
        r.new_value
    from rawdata r
    join latest_field_state_day d
      on r.{{ unique_key }} = d.{{ unique_key }}
     and r.field = d.field
     and r.created_timestamp = d.created_timestamp
)

/* 4) Final rawdata with start and only latest day change */
,starting_and_daily_rawdata as (
    select
        {{ unique_key }},
        created_timestamp,
        created_date,
        field,
        new_value
    from daily_rawdata

    union all

    select
        {{ unique_key }},
        created_timestamp,
        created_date,
        field,
        old_value as new_value
    from extended_history_started_from_values
)

/* 5) Individual attributes - skipping the same daily values */
{% for f in fields_config %}
  {% set sf_field      = f["source_field"] %}
  {% set target_field  = f["target_field"] %}
  {% set idx           = loop.index %}

,raw_attr_{{ idx }} as (
    select
        {{ unique_key }},
        created_date,
        lead(new_value) over (
            partition by {{ unique_key }}
            order by created_date
        ) as next_value,
        new_value as value
    from starting_and_daily_rawdata
    where field = '{{ sf_field }}'
)

,attr_{{ idx }} as (
    select
        row_number() over (
            partition by {{ unique_key }}
            order by created_date
        ) as rn,
        {{ unique_key }},
        case
            when rn = 1 then '{{ first_fromdate }}'::date
            else created_date
        end as fromdate,
        coalesce(
            lead(created_date) over (partition by {{ unique_key }} order by created_date),
            '{{ last_todate }}'::date
        ) as todate,
        value as {{ target_field }}
    from raw_attr_{{ idx }}
    where coalesce(value,'~') != coalesce(next_value,'~')
)

{% endfor %}

/* 6) Build all boundary points (from/to) per unique key */
,bounds as (
{% for f in fields_config %}
  {% set idx = loop.index %}
    select {{ unique_key }}, fromdate as dt from attr_{{ idx }}
    union
    select {{ unique_key }}, todate   as dt from attr_{{ idx }}
    {% if not loop.last %}union{% endif %}
{% endfor %}
)

/* 7) Turn boundaries into smallest non-overlapping intervals */
,intervals as (
    select
        {{ unique_key }},
        dt as fromdate,
        coalesce(
            lead(dt) over (partition by {{ unique_key }} order by dt),
            '{{ last_todate }}'::date
        ) as todate
    from bounds
    where dt < '{{ last_todate }}'::date
)

/* 8) For each interval start, pick the attribute value that covers that start date */
,stitched as (
    select
        i.{{ unique_key }},
        i.fromdate,
        i.todate
        {% for f in fields_config %}
          {% set target_field = f["target_field"] %}
          ,attr_{{ loop.index }}.{{ target_field }}
        {% endfor %}
    from intervals i
    {% for f in fields_config %}
      {% set idx = loop.index %}
      {% set target_field = f["target_field"] %}
    left join attr_{{ idx }}
      on i.{{ unique_key }} = attr_{{ idx }}.{{ unique_key }}
     and i.fromdate >= attr_{{ idx }}.fromdate
     and i.fromdate <  attr_{{ idx }}.todate
    {% endfor %}
)

/* 9) Collapse adjacent intervals where nothing changed */
,collapsed as (
    select
        {{ unique_key }},
        fromdate,
        todate
        {% for f in fields_config %}
          {% set target_field = f["target_field"] %}
          ,{{ target_field }}
        {% endfor %}
        ,
        case
            when
            {% for f in fields_config %}
              {% set target_field = f["target_field"] %}
              lag({{ target_field }}) over (partition by {{ unique_key }} order by fromdate) is distinct from {{ target_field }}
              {% if not loop.last %}or{% endif %}
            {% endfor %}
            then 1 else 0
        end as is_new_segment
    from stitched
)

,grp as (
    select
        {{ unique_key }},
        fromdate,
        todate
        {% for f in fields_config %}
          {% set target_field = f["target_field"] %}
          ,{{ target_field }}
        {% endfor %}
        ,
        sum(is_new_segment) over (
            partition by {{ unique_key }}
            order by fromdate
            rows unbounded preceding
        ) as segment_id
    from collapsed
)

,data as (
    select
        {{ unique_key }},
        min(fromdate) as fromdate,
        max(todate)   as todate
        {% for f in fields_config %}
          {% set target_field  = f["target_field"] %}
          {% set default_value = f.get("default", "Unknown") %}
          ,coalesce(max({{ target_field }}), '{{ default_value }}') as {{ target_field }}
        {% endfor %}
    from grp
    group by {{ unique_key }}, segment_id
)

/* 10) Final query in a form of SCD2 */
,final_data as (
    select
        md5(
            coalesce(cast({{ unique_key }} as varchar), '')
            || '|' || coalesce(cast(fromdate as varchar), '')
        ) as {{ unique_key }}_hist_id,

        fromdate::timestamp as fromdate,

        case
            when todate = '{{ last_todate }}'::date then null
            else todate::timestamp
        end as todate,

        row_number() over (
            partition by {{ unique_key }}
            order by fromdate
        ) as record_version,

        {{ unique_key }}

        {% for f in fields_config %}
          {% set target_field = f["target_field"] %}
          ,{{ target_field }}
        {% endfor %}
        ,

        '{{ first_fromdate }}'::timestamp as loaddate,
        '{{ first_fromdate }}'::timestamp as updatedate,

        md5(
            {% for f in fields_config %}
              {% set target_field = f["target_field"] %}
              coalesce(cast({{ target_field }} as varchar), '')
              {% if not loop.last %} || '|' || {% endif %}
            {% endfor %}
        ) as scd_hash

    from data
)

select
    {{ unique_key }}_hist_id::varchar(50) as {{ unique_key }}_hist_id,
    fromdate::timestamp as fromdate,
    coalesce(
        todate::timestamp,
        lead(fromdate) over (partition by {{ unique_key }} order by fromdate)::timestamp,
        '{{ last_todate }}'::timestamp
    ) as todate,
    row_number() over (partition by {{ unique_key }} order by fromdate)::int4 as record_version,
    {{ unique_key }}::varchar(300) as {{ unique_key }}
    {% for f in fields_config %}
      {% set target_field = f["target_field"] %}
      ,{{ target_field }}::varchar(5000) as {{ target_field }}
    {% endfor %}
    ,
    loaddate::timestamp as loaddate,
    updatedate::timestamp as updatedate,
    scd_hash::varchar(50) as scd_hash
from final_data
order by fromdate

{% endset %}

{% set target_table = model.get('alias', model.get('name')) %}

  {% set target_relation_exists, target_relation = get_or_create_relation(
          database=model.database,
          schema=model.schema,
          identifier=target_table,
          type='table') %}

  {% if not target_relation.is_table %}
    {% do exceptions.relation_wrong_type(target_relation, 'table') %}
  {% endif %}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {# Build relation SQL#}

  {% if target_relation_exists %}

   {{ adapter.drop_relation(target_relation) }}

  {% endif %}

  {% set final_sql = create_table_as(False, target_relation, build_sql) %}

  {# Execute SQL to create a new relation or insert/update into existing#}

  {% call statement('main') %}
      {{ final_sql }}
  {% endcall %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {% set should_revoke = should_revoke(target_relation_exists, full_refresh_mode=False) %}
  {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}

  {% do persist_docs(target_relation, model) %}

  -- `COMMIT` happens here

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
