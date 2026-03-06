{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source("dbo","fact_assignment_completion") }}  
-- depends_on: {{ ref("dim_calendar") }}
-- depends_on: {{ source("dbo","mv_student_account") }} 
-- depends_on: {{ ref("dim_district") }} 
-- depends_on: {{ ref("dim_learning_object") }} 



call {{ target.database }}.{{ schema }}.lc_load_students_completions_monthly_snapshots(cast('{{ var("loaddate") }}' as timestamp));