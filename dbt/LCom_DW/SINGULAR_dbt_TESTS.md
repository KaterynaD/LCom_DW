# Singular dbt tests

The tests are located in tests folder based on a `custom SQL` are very powerful to validate complex business logic in teh transformation. But they are `fragile as late binding view in Redshift`. There is no way in dbt to validate the test SQL except run `dbt test`. 

`dbt test` command output contains for each test `PASS`, `FAIL` or `ERROR` if there are issues with the the test SQL like a wrong column name and a bottom line like this `Done. PASS=8 WARN=0 ERROR=7 SKIP=0 NO-OP=0 TOTAL=15` where `FAIL` is not present. To catch the errors the command output or dbt artifact analysis must be done to separate `FAIL` from `ERROR` because `FAIL` might be a normal state for a test running in QA environment in CI/CD with `-- empty` (dry-run) dbt flag.

It's `recommended` to create a validation view in `models\audit\validation\` folder for a singular test and keep the test SQL as simple as possible.

`vw_v_dim_account_all_organizations_included` validation view in `models\audit\validation\common\dim_account\vw_v_dim_account_all_organizations_included.sql`
```sql
{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select organization_id from {{ source("dbo","organization") }} 
except
select lcom_organization_id from {{ ref("dim_account") }}

```

Singular test
```sql

select * from {{ ref("vw_v_dim_account_all_organizations_included") }}

```

In this way, if `lcom_organization_id` or `organization_id` are changed, CI/CD catch the error in the validation view without analyzing `dbt test` output in QA environment.