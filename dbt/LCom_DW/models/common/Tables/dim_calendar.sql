{{ config(
   materialized='sql_runner'
) }}

--do not run this model. Calendar table was createtd once and the model is needed only to be consistent with dbt environment
call {{ target.database }}.{{ schema }}.populating_dim_calendar(to_date('2015-08-01','yyyy-mm-dd'),to_date('2035-06-30','yyyy-mm-dd'));