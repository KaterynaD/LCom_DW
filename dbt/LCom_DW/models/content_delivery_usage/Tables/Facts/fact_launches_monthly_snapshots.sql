
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source("dbo","fact_assignment_launch") }}  
-- depends_on: {{ source("common","dim_calendar") }}

call {{ target.database }}.{{ schema }}.lc_load_launches_monthly_snapshots(cast('{{ var("loaddate") }}' as timestamp));