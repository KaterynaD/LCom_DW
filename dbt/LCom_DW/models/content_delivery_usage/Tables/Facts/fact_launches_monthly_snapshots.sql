
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_fact_launches_monthly_snapshots_table() }}', 
                    '{{ create_lc_load_launches_monthly_snapshots() }}'
                   ]
) }}

-- depends_on: {{ source("dbo","fact_assignment_launch") }}  
-- depends_on: {{ ref("dim_calendar") }}

call {{ target.database }}.{{ schema }}.lc_load_launches_monthly_snapshots(cast('{{ var("loaddate") }}' as timestamp));