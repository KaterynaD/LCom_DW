# Removing Column from an SCD2 Model

Slowly Changing Dimensions Type 2 in LCom_DW project are materialized as custom scd2_plus materialization.
This materialization does `not` remove a column automatically in the underlying database table.

Below are the simplified steps how to not use a column in scd2_plus materialized model. The process can be extended to physically remove the column from the model and the underlying database table.


In both cases, the process uses the `deployment_pre_tasks` model.

## Modify SCD2 model

- Do NOT remove a column from `check_cols` list.
- Replace the column name from a scd2 base table to a default value in `select` statement. 
- Add "Do Not Use" or similar comment in the model contract

## Before first modified model run in Dev environment

You need manually (in Dev environment) run these SQL statements:

3. Run historical update

```sql

update common.dim_account_history
set sfdc_ultimate_parent_current_renewal_arr=0; -- <- column default value, depends on the data type

```

3. Optional: update `scd_hash`. This update prevents creating new versions of the row when a column is removed. `scd_hash` is used to check if the new version of a row is different from the existing. The order of columns in `scd_hash` is the same as in `check_cols` configuration. It's the `MD5` hash of the concatenated values from the check_cols list, with each value converted to `VARCHAR`. The original update can be found in `target\run\LCom_DW\your_model.sql` file. No need to change the `MD5` columns concatanation if a column not physically removed, but just have a default value now.

```sql

update revenue.fact_opportunity_history
set scd_hash = md5(coalesce(cast(stage_name as varchar ), '')
         ...
         || '|' || coalesce(cast(number_of_students as varchar ), '')
         || '|' || coalesce(cast(multi_year_discount_rate as varchar ), '') 
        );

```

## Run the model in Dev environment

and make sure no errors returned, the new column is populated and no new record versions created if `scd_hash` was updated. 

In some complex models with many `check_cols` few new row versions can appear for other reasons.

## Pre deployment CI/CD activity

Manual steps in Dev environment are automated in  `deployment_pre_tasks` model and `pre_deployment_tasks()` macro

However you need one more step for QA database. It does not have SCD2 table when pre-deployment activity starts. dbt defer flag creates a view , not a table in Redshift. You need a table to validate your pre-deployment script.


```sql

{% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

   create table qa.common.dim_account_history as select * from dw.common.dim_account_history limit 100;

 {% endif %} 
					
update common.dim_account_history
set sfdc_ultimate_parent_current_renewal_arr=0;



update common.dim_account_history
set scd_hash = md5(coalesce(cast(lcom_organization_id as varchar ), '')
         || '|' || coalesce(cast(lcom_trial as varchar ), '')
...
         || '|' || coalesce(cast(lcom_parent_organization_id as varchar ), '')
        );

 {% endset %}

```

`deployment_pre_tasks` model is run in CI/CD before QA and DW modified models run and `pre_deployment_tasks` macro is called in `pre_hook`.

Do not modify `deployment_pre_tasks` model. It must be unchange. 
The change in `pre_deployment_tasks` macro adds the model in `modified` state to run in CI/CD.


## Note

You do not need to clean up  `pre_deployment_tasks()` and  `post_deployment_tasks()` macros. If there are no changes, `deployment_pre_tasks` and `deployment_post_tasks` models are ``not in state modified`` and will ne be run in CI/CD.
