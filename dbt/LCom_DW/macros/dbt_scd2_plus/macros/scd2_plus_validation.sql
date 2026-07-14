{% test scd2_plus_validation(model,unique_key='id',scd_valid_from_col_name='valid_from',scd_valid_to_col_name='valid_to') %}





    WITH data AS (
        SELECT
         {{ unique_key }},
         {{ scd_valid_from_col_name }} ,
         {{ scd_valid_to_col_name }} ,
         lag({{ scd_valid_to_col_name }}) over(partition by {{ unique_key }} order by coalesce({{ scd_valid_from_col_name }}, '1900-01-01')) prev_{{ scd_valid_to_col_name }}
        FROM {{ model }}
    ) 
    SELECT * 
    FROM data
    WHERE ({{ scd_valid_from_col_name }}>{{ scd_valid_to_col_name }}) /*valid from must always be less then valid to */
      or  ({{ scd_valid_from_col_name }}<>coalesce(prev_{{ scd_valid_to_col_name }} ,{{ scd_valid_from_col_name }})) /*prev valid to must always be valid from or null (1st record) */

  
 
{% endtest %}



{% test scd2_current_matches_source(
    model,
    source_model,
    unique_key,
    check_cols,
    scd_valid_to_col_name='valid_to',
    scd_valid_to_max_date=none
) %}

    
    {% if not unique_key %}
        {{ exceptions.raise_compiler_error(
            "scd2_current_matches_source requires unique_key."
        ) }}
    {% endif %}

    {% if not check_cols %}
        {{ exceptions.raise_compiler_error(
            "scd2_current_matches_source requires check_cols."
        ) }}
    {% endif %}

    with history_current as (

        select
            {{ unique_key }},
            scd_hash

        from {{ model }}

        where
            {% if scd_valid_to_max_date is not none %}
                {{ scd_valid_to_col_name }}
                    = cast('{{ scd_valid_to_max_date }}' as timestamp)
            {% else %}
                {{ scd_valid_to_col_name }} is null
            {% endif %}

    ),

    active_source as (

        select
            {{ unique_key }},
            {{ snapshot_hash_arguments(check_cols) }} as scd_hash

        from {{ ref(source_model) }}

    ),

    differences as (

        select
            coalesce(
                history_current.{{ unique_key }},
                active_source.{{ unique_key }}
            ) as {{ unique_key }},

            history_current.scd_hash as history_hash,
            active_source.scd_hash as source_hash,

            case
                when history_current.{{ unique_key }} is null
                    then 'missing_from_history'

                when active_source.{{ unique_key }} is null
                    then 'missing_from_active_source'

                when history_current.scd_hash
                     <> active_source.scd_hash
                    then 'hash_mismatch'
            end as failure_reason

        from history_current

        full outer join active_source
            on history_current.{{ unique_key }}
             = active_source.{{ unique_key }}

        where
               history_current.{{ unique_key }} is null
            or active_source.{{ unique_key }} is null
            or history_current.scd_hash
               <> active_source.scd_hash

    )

    select *
    from differences
    where failure_reason!='missing_from_active_source'

{% endtest %}

{% test no_consecutive_duplicate_scd_hash(
    model,
    unique_key,
    record_version_col='record_version'
) %}

    with history as (

        select
            {{ unique_key }},
            {{ record_version_col }},
            scd_hash,

            lag({{ record_version_col }}) over (
                partition by {{ unique_key }}
                order by {{ record_version_col }}
            ) as previous_record_version,

            lag(scd_hash) over (
                partition by {{ unique_key }}
                order by {{ record_version_col }}
            ) as previous_scd_hash

        from {{ model }}

    )

    select
        {{ unique_key }},
        previous_record_version,
        {{ record_version_col }},
        previous_scd_hash,
        scd_hash

    from history

    where scd_hash = previous_scd_hash

{% endtest %}