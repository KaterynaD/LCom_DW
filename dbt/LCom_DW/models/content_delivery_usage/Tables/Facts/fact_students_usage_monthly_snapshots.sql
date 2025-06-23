{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source("dbo","fact_assignment_launch") }}  
-- depends_on: {{ source("common","dim_calendar") }}
-- depends_on: {{ source("dbo","mv_student_account") }} 
-- depends_on: {{ ref("dim_district") }} 
-- depends_on: {{ ref("dim_learning_object") }} 
-- depends_on: {{ ref("dim_lcom_sku") }} 
-- depends_on: {{ ref("dim_lcom_sku_learning_object") }} 
-- depends_on: {{ ref("dim_sequence") }} 
-- depends_on: {{ ref("dim_sequence_learning_object") }} 

call {{ target.database }}.{{ schema }}.lc_load_students_usage_monthly_snapshots(cast('{{ var("loaddate") }}' as timestamp));