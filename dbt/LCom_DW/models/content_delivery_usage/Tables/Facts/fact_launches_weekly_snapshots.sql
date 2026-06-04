
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_fact_launches_weekly_snapshots_table() }}', 
                    '{{ create_lc_load_launches_weekly_snapshots() }}'
                   ]
) }}

-- depends_on: {{ source("dbo","fact_assignment_launch") }}  
-- depends_on: {{ ref("dim_calendar") }}
-- depends_on: {{ source("dbo","organization") }}

call {{ target.database }}.{{ schema }}.lc_load_launches_weekly_snapshots(cast('{{ var("loaddate") }}' as timestamp));