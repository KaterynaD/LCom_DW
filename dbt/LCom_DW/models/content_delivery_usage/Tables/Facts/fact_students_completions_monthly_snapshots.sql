{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_fact_students_completions_monthly_snapshots_table() }}', 
                    '{{ create_lc_load_students_completions_monthly_snapshots() }}'
                   ]
) }}

-- depends_on: {{ source("dbo","fact_assignment_completion") }}  
-- depends_on: {{ ref("dim_month") }}
-- depends_on: {{ source("dbo","mv_student_account") }} 
-- depends_on: {{ ref("dim_district") }} 
-- depends_on: {{ ref("dim_learning_object") }} 
-- depends_on: {{ ref("dim_product_category") }} 
-- depends_on: {{ ref("dim_product_category_learning_object_monthly") }} 



call {{ target.database }}.{{ schema }}.lc_load_students_completions_monthly_snapshots(cast('{{ var("loaddate") }}' as timestamp));