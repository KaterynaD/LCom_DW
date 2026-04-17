
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source("common","dim_calendar") }}
-- depends_on: {{ source("dbo","fact_assignment_completion") }}
-- depends_on: {{ source("dbo","learning_assessment_set") }}
-- depends_on: {{ source("dbo","learning_object") }}
-- depends_on: {{ source("dbo","learning_object_standard") }}
-- depends_on: {{ source("dbo","organization") }}
-- depends_on: {{ source("dbo","standard") }}
-- depends_on: {{ source("dbo","user_account") }}
-- depends_on: {{ ref("skillscheck_topic_mapping") }}

call {{ target.database }}.{{ schema }}.load_skillscheck_calendaryear_data(cast('{{ var("loaddate") }}' as timestamp));