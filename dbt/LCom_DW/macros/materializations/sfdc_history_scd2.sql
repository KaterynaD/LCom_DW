{% materialization sfdc_history_scd2, adapter='redshift' %}

{# -------------------------------------------------- #}
{# CONFIGURATION                                     #}
{# -------------------------------------------------- #}

{% set unique_key         = config.get('unique_key') %}
{% set base_relation      = config.get('base_relation') %}
{% set fields_config      = config.get('fields_config') %}
{% set first_fromdate     = config.get('first_fromdate', '1900-01-01') %}
{% set last_todate        = config.get('last_todate', '3000-12-31') %}

{% set target_relation = this %}

{# -------------------------------------------------- #}
{# BUILD FIELD FILTER CONDITION                      #}
{# -------------------------------------------------- #}

{% set field_filters = [] %}

{% for f in fields_config %}
    {% set sf_field = f[0] %}
    {% set data_type = f[1] %}
    {% if data_type %}
        {% do field_filters.append("(field = '" ~ sf_field ~ "' and data_type='" ~ data_type ~ "')") %}
    {% else %}
        {% do field_filters.append("(field = '" ~ sf_field ~ "')") %}
    {% endif %}
{% endfor %}

{% set field_filter_sql = field_filters | join("\nor\n") %}

{# -------------------------------------------------- #}
{# BUILD EXTENDED HISTORY UNION FROM BASE TABLE      #}
{# -------------------------------------------------- #}

{% set extended_unions = [] %}

{% for f in fields_config %}
    {% set sf_field      = f[0] %}
    {% set default_value = f[2] %}
    {% set base_field    = f[3] %}

    {% set union_sql %}
    select
        c.{{ unique_key }},
        '{{ first_fromdate }}'::timestamp as created_timestamp,
        '{{ first_fromdate }}'::date as created_date,
        '{{ sf_field }}' as field,
        c.{{ base_field }} as old_value
    from {{ base_relation }} c
    left join (
        select {{ unique_key }}
        from history_started_from_values
        where field='{{ sf_field }}'
    ) h
    on c.{{ unique_key }} = h.{{ unique_key }}
    where h.{{ unique_key }} is null
    {% endset %}

    {% do extended_unions.append(union_sql) %}

{% endfor %}

{% set extended_union_sql = extended_unions | join("\nunion all\n") %}

{# -------------------------------------------------- #}
{# BUILD ATTRIBUTE SECTIONS                          #}
{# -------------------------------------------------- #}

{% set attribute_sections = [] %}
{% set bounds_sections = [] %}
{% set stitched_joins = [] %}
{% set collapse_checks = [] %}
{% set final_select_fields = [] %}
{% set hash_fields = [] %}

{% for f in fields_config %}
    {% set sf_field      = f[0] %}
    {% set default_value = f[2] %}
    {% set base_field    = f[3] %}

    {% set safe_name = sf_field | replace('__c','') %}

    {# RAW ATTRIBUTE #}
    {% set attr_sql %}
    ,raw_{{ sf_field }} as (
        select
            {{ unique_key }},
            created_date,
            lead(new_value) over(partition by {{ unique_key }} order by created_date) as new_value,
            new_value as value
        from starting_and_daily_rawdata
        where field = '{{ sf_field }}'
    )
    ,{{ sf_field }} as (
        select
            row_number() over(partition by {{ unique_key }} order by created_date) as rn,
            {{ unique_key }},
            case when rn=1 then '{{ first_fromdate }}'::date else created_date end as fromdate,
            isnull(
                lead(created_date) over(partition by {{ unique_key }} order by created_date),
                '{{ last_todate }}'::date
            ) as todate,
            value as {{ sf_field }}
        from raw_{{ sf_field }}
        where isnull(value,'~') != isnull(new_value,'~')
    )
    {% endset %}

    {% do attribute_sections.append(attr_sql) %}

    {% do bounds_sections.append("select " ~ unique_key ~ ", fromdate as dt from " ~ sf_field) %}
    {% do bounds_sections.append("select " ~ unique_key ~ ", todate as dt from " ~ sf_field) %}

    {% do stitched_joins.append(
        "left join " ~ sf_field ~ " on i." ~ unique_key ~ " = " ~ sf_field ~ "." ~ unique_key ~
        " and i.fromdate >= " ~ sf_field ~ ".fromdate and i.fromdate < " ~ sf_field ~ ".todate"
    ) %}

    {% do collapse_checks.append(
        "lag(" ~ sf_field ~ ") over (partition by " ~ unique_key ~ " order by fromdate) is distinct from " ~ sf_field
    ) %}

    {% do final_select_fields.append(
        "isnull(max(" ~ sf_field ~ "),'" ~ default_value ~ "') as " ~ base_field
    ) %}

    {% do hash_fields.append(
        "coalesce(cast(data." ~ sf_field ~ " as varchar),'')"
    ) %}

{% endfor %}

{% set attribute_sql = attribute_sections | join("\n") %}
{% set bounds_sql = bounds_sections | join("\nunion\n") %}
{% set stitched_sql = stitched_joins | join("\n") %}
{% set collapse_sql = collapse_checks | join("\nor\n") %}
{% set final_fields_sql = final_select_fields | join(",\n") %}
{% set hash_concat = hash_fields | join("|| '|' ||") %}

{# -------------------------------------------------- #}
{# BUILD FULL QUERY                                  #}
{# -------------------------------------------------- #}

{% set full_sql %}

with historical_data as (
{{ model.sql }}
)

,rawdata as (
select
{{ unique_key }},
created_date as created_timestamp,
trunc(created_date) created_date,
field,
new_value,
old_value
from historical_data
where isnull(old_value,'Unknowwn') != new_value
and (
{{ field_filter_sql }}
)
)

,history_start_at as (
select
{{ unique_key }},
min(created_timestamp) created_timestamp,
field
from rawdata
group by {{ unique_key }}, field
)

,history_started_from_values as (
select
rawdata.{{ unique_key }},
'{{ first_fromdate }}'::timestamp created_timestamp,
'{{ first_fromdate }}'::date created_date,
rawdata.field,
rawdata.old_value
from rawdata
join history_start_at
on rawdata.{{ unique_key }} = history_start_at.{{ unique_key }}
and rawdata.field = history_start_at.field
and rawdata.created_timestamp = history_start_at.created_timestamp
)

,extended_history_started_from_values as (
select
{{ unique_key }},
created_timestamp,
created_date,
field,
isnull(old_value,'Unknown') as old_value
from history_started_from_values
union all
{{ extended_union_sql }}
)

,latest_field_state_day as (
select
{{ unique_key }},
created_date,
field,
max(created_timestamp) created_timestamp
from rawdata
group by {{ unique_key }}, created_date, field
)

,daily_rawdata as (
select
rawdata.{{ unique_key }},
rawdata.created_timestamp,
rawdata.created_date,
rawdata.field,
rawdata.new_value
from rawdata
join latest_field_state_day
on rawdata.{{ unique_key }} = latest_field_state_day.{{ unique_key }}
and rawdata.field = latest_field_state_day.field
and rawdata.created_timestamp = latest_field_state_day.created_timestamp
)

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
old_value
from extended_history_started_from_values
)

{{ attribute_sql }}

,bounds as (
{{ bounds_sql }}
)

,intervals as (
select
{{ unique_key }},
dt as fromdate,
isnull(
lead(dt) over(partition by {{ unique_key }} order by dt),
'{{ last_todate }}'::date
) as todate
from bounds
where dt < '{{ last_todate }}'
)

,stitched as (
select
i.*
{% for f in fields_config %}
,{{ f[0] }}.{{ f[0] }}
{% endfor %}
from intervals i
{{ stitched_sql }}
)

,collapsed as (
select
*,
case when {{ collapse_sql }} then 1 else 0 end as is_new_segment
from stitched
)

,grp as (
select
*,
sum(is_new_segment) over (partition by {{ unique_key }} order by fromdate rows unbounded preceding) as segment_id
from collapsed
)

,data as (
select
{{ unique_key }},
min(fromdate) as fromdate,
max(todate) as todate,
{{ final_fields_sql }}
from grp
group by {{ unique_key }}, segment_id
)

select * from data

{% endset %}

{# -------------------------------------------------- #}
{# CREATE TABLE                                      #}
{# -------------------------------------------------- #}

{{ adapter.create_table_as(target_relation, full_sql) }}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
