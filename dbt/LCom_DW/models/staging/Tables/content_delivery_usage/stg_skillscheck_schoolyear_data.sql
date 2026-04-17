
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source("dbo","fact_assignment_completion") }}
-- depends_on: {{ source("dbo","user_account") }}
-- depends_on: {{ source("dbo","standard") }}
-- depends_on: {{ source("dbo","learning_object_standard") }}

call {{ target.database }}.{{ schema }}.load_skillscheck_schoolyear_data(cast('{{ var("loaddate") }}' as timestamp));