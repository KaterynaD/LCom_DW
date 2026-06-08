{{ config(
   materialized='incremental',
   unique_key='deployment_date',
   incremental_strategy='append',
   on_schema_change='append_new_columns',
   pre_hook = [
                    '{{ pre_deployment_tasks() }}'
           ]
) }}


select CURRENT_TIMESTAMP AT TIME ZONE 'America/Los_Angeles'::TIMESTAMP WITHOUT TIME ZONE as deployment_date
where {{ var("deploy_flag", False) }} = True