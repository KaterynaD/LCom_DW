# Adding a New Column to an SCD2 Model

Slowly Changing Dimensions Type 2 in LCom_DW project are materialized as custom scd2_plus materialization.
This materialization does `not` add a new column automatically in the database table.

Below are the steps how to add a new column in scd2_plus materialized model.
It uses the `deployment_pre_tasks` and `deployment_post_tasks`
models.

## Modify SCD2 model

Add a new column in `check_cols` list at the end and in `select` statement. The order of the columns does not matter in the select statement.

## Before first modified model run in Dev environment

You need manually (in Dev environment) run these SQL statements:

1. Add new columns in the table

```sql

alter table revenue.fact_opportunity_history add column multi_year_discount_rate numeric(7,2) NOT NULL default 0;

```
2. Run historical update

```sql

update revenue.fact_opportunity_history
set
multi_year_discount_rate = fo.multi_year_discount_rate
from revenue.fact_opportunity fo
where fo.opportunity_id=revenue.fact_opportunity_history.opportunity_id;

```

3. Optional: update `scd_hash`. This update prevents creating new versions of the row when a new column is added. `scd_hash` is used to check if the new version of a row is different from the existing. The order of columns in `scd_hash` is the same as in `check_cols` configuration. It's the `MD5` hash of the concatenated values from the check_cols list, with each value converted to `VARCHAR`. The original update can be found in `target\run\LCom_DW\your_model.sql` file. Just add the new column at the end if you added it as the last one in `check_cols`

```sql

update revenue.fact_opportunity_history
set scd_hash = md5(coalesce(cast(stage_name as varchar ), '')
         ...
         || '|' || coalesce(cast(number_of_students as varchar ), '')
         || '|' || coalesce(cast(multi_year_discount_rate as varchar ), '') -- <--new column
        );

```

or you can run `print_scd_hash` macro to 'scd_hash' formula

```sh

dbt run-operation print_scd_hash --args '{model_name: dim_account_history}'

```

## Run the model in Dev environment

and make sure no errors returned, the new column is populated and no new record versions created if `scd_hash` was updated. 

In some complex models with many `check_cols` few new row versions can appear for other reasons then the new column populating process.

## Pre deployment CI/CD activity

Manual steps in Dev environment are automated in  `deployment_pre_tasks` model and `pre_deployment_tasks()` macro

However you need one more step for QA database. It does not have SCD2 table when pre-deployment activity starts. dbt defer flag creates a view , not a table in Redshift. You need a table to validate your pre-deployment script.

If you add a new column in the base model for SCD2 model and deploy both changes together, the base model does not have the new column at this moment (pre-deployment) and you can not use it to populate historical values in the new column in SCD2 model. The only choise is to use a source table directly in this update or create a temp table or view for complex transformations and drop them after the update historical records in SCD2.

```sql

{% set pre_deployment_sql %}
{% set target_db = (target.database | string) %}

{% if target_db | upper == 'QA' %}

   create table qa.revenue.dim_opportunity_line_history as select * from dw.revenue.dim_opportunity_line_history;

 {% endif %}

alter table revenue.dim_opportunity_line_history add column total_discount_amount  NUMERIC(35,17) NOT NULL default 0;


create or replace view staging.stg_sbqq_quote_line as
with rawdata as (select ....


update revenue.dim_opportunity_line_history
set
additional_discount_type = da.additional_discount_type,
total_discount_rate = da.total_discount_rate,
total_discount_amount = da.total_discount_amount
from revenue.dim_opportunity_line da
from staging.stg_sbqq_quote_line da
where da.opportunity_line_id = revenue.dim_opportunity_line_history.opportunity_line_id;

update revenue.dim_opportunity_line_history								
set scd_hash =md5(coalesce(cast(sfdc_product_id as varchar ), '')

...

drop view staging.stg_sbqq_quote_line;

{% endset %}

```

The `recommended approach` is to separate the changes to `2 deployments`. Deploy the base model first and then deploy SCD2 model change. But the base model is also not available in QA database at this moment. dbt defer flag would help but you need to add ref() in  `deployment_pre_tasks` model and then reomve for a next deployment.

Add all statements to the `pre_deployment_tasks()` macro:

``` sql
{% set pre_deployment_sql %}
{% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

   create table qa.revenue.fact_opportunity_history as select * from dw.revenue.fact_opportunity_history;
   create view qa.revenue.fact_opportunity as select * from dw.revenue.fact_opportunity;

 {% endif %} 
					
alter table revenue.fact_opportunity_history add column multi_year_discount_rate numeric(7,2) NOT NULL default 0;


update revenue.fact_opportunity_history
set
multi_year_discount_rate = fo.multi_year_discount_rate
from revenue.fact_opportunity fo
where fo.opportunity_id=revenue.fact_opportunity_history.opportunity_id;


update revenue.fact_opportunity_history
set scd_hash = md5(coalesce(cast(stage_name as varchar ), '')
...
         || '|' || coalesce(cast(multi_year_discount_rate as varchar ), '') --<-- new column
        );

 {% endset %}



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
