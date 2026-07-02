# Adding a New Column to an Incremental Model

When adding a new column to an incremental model, use the following
procedure to populate historical data.
This pattern uses the `deployment_pre_tasks` and `deployment_post_tasks`
models.

## Configure the incremental model

Configure the model to automatically append new columns.

``` sql
{{ config(

    materialized='incremental',
    unique_key='mon_year',
    incremental_strategy='delete+insert',
    on_schema_change='append_new_columns',
    dist='even',
    sort='mon_year'

) }}
```

## dbt way to add a new column

Add the new column to the model SQL.

During deployment, dbt automatically adds the column to the existing
table. 

Historical rows remain `NULL`. Use `deployment_post_tasks` model to populate historical rows.

Add an `UPDATE` statement to the `post_deployment_tasks()` macro.

Example:

``` sql
{% set post_deployment_sql %}

UPDATE {{ ref('my_incremental_model') }}
SET new_column_name = src.historical_column_name
FROM ...
WHERE new_column_name IS NULL;


{% endset %}
```

`deployment_post_tasks` model is run in CI/CD after QA and DW modified models run and `post_deployment_tasks` macro is called in `post_hook`.

Do not modify `deployment_post_tasks` model. It must be unchange. 
The change in `post_deployment_tasks` macro adds the model in `modified` state to run in CI/CD.

``This approach does not work if the model's enabled contract has NOT NULL constrains. dbt NOT NULL data tests fail if run before historical rows populating``

## Pre deployment CI/CD activity

Use `deployment_pre_tasks` to add a new column and populate existing rows with historical data

Add both statements to the `pre_deployment_tasks()` macro:

``` sql
{% set pre_deployment_sql %}

ALTER TABLE {{ ref('my_incremental_model') }}
ADD COLUMN new_column_name VARCHAR;
{% set pre_deployment_sql %}

UPDATE {{ ref('my_incremental_model') }}
SET new_column_name = src.historical_column_name
FROM ...
WHERE new_column_name IS NULL;

{% endset %}
```
`deployment_pre_tasks` model is run in CI/CD before QA and DW modified models run and `pre_deployment_tasks` macro is called in `pre_hook`.

Do not modify `deployment_pre_tasks` model. It must be unchange. 
The change in `pre_deployment_tasks` macro adds the model in `modified` state to run in CI/CD.

## Limit updates in QA

When updating large tables, limit the number of rows processed in QA.

Example:

``` sql

{% set pre_deployment_sql %}
{% set target_db = (target.database | string) %}

...

{% if target.database | upper == 'QA' %}

LIMIT 100

{% endif %}

...

{% endset %}

```

Use the full update in Production (DW database).

## Note

You do not need to clean up  `pre_deployment_tasks()` and  `post_deployment_tasks()` macros. If there are no changes, `deployment_pre_tasks` and `deployment_post_tasks` models are ``not in state modified`` and will ne be run in CI/CD.
