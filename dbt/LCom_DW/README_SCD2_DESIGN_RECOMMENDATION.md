# History of Data Changes - Slowly Changing Dimension Type 2 (SCD2) Design Recommendations

## Intermediate model (optional, but recommended)

Create an **ephemeral** intermediate model containing all source transformations required by the SCD2 model.

Example:

```sql
{{ config(materialized='ephemeral') }}

select
    employee_id,
    name,
    user_role,
    case when is_active then 1 else 0 end as is_active,
    department,
    title,
    last_modified_date,
    created_date
from {{ ref('dim_employee') }}
```

The intermediate model has two purposes:

- provide the source data for the SCD2 model;
- provide the same transformed data for the `scd2_current_matches_source` test.

Using the same model in both places guarantees that the current SCD2 version is compared against exactly the same transformed base data.

No need in the intermediate model if you do not plan to use `scd2_current_matches_source` test

---

## SCD2 model

The SCD2 model should reference only the intermediate model.

Example:

```sql
select *
from {{ ref('int_employee_history') }}
```

The model should not contain business transformations. They belong in the intermediate model so they are shared by both the SCD2 materialization and the validation test.

---

## Boolean columns

Boolean columns should be converted to **integer** values in the intermediate model.

Example:

```sql
case when is_active then 1 else 0 end as is_active
```

The `scd2_plus` materialization detects changes by calculating `scd_hash` from all columns configured in `check_cols`.

The hash is generated using the dbt `snapshot_hash_arguments` macro, which creates an MD5 value from concatenated column values cast to `varchar`.

Redshift can not cast Boolean values to `varchar`. Taht's why we need to convert Boolean values to `0` and `1` - produce  hash values.

---

## Numeric columns in check_cols

Use caution when including numeric columns in `check_cols`.

The hash is calculated from the string representation of each value. The same numeric value stored with different precision or scale may produce different text representations and therefore different hash values.

Recommended data types are:

- `numeric(16,2)` for currency values
- `numeric(16,4)` for rates and percentages

Avoid using high precision types such as `numeric(38,10)`, `double precision` or `float8` directly in `check_cols`. 

Currency and rates data types should be normilized (round and cast) in the underlying , base models: dim_account, dim_opportunity_line and fact_opportunity or in the intermediate model for the history table.


### Important

`ROUND` in Redshift does no round numerical values by default. You need to run `SET enable_numeric_rounding TO ON;` to enable it.

Example of normalizing numerical data types in a base dbt model:

```sql
{{
    config(

        materialized='table',        
        dist='account_id', 
        sort='account_id',
        post_hook=['{{ update_DIM_ACCOUNT_HISTORY_changed_UK() }}'],        
		    sql_header = 'SET enable_numeric_rounding TO ON;'                          
        )
}}  


...

round(sfdc_current_renewal_arr::numeric(38,10), 2) :: numeric(16,2) as sfdc_current_renewal_arr,

...

```




---

## dbt schema

Configure the model contract but leave it disabled because dbt does not support contracts for custom materializations.

```yaml
config:
  contract:
    enforced: false
```

Define constraints and tests in the schema.

Example:

```yaml
models:
  - name: dim_employee_history

    data_tests:
      - scd2_plus_validation:
          unique_key: employee_id
          scd_valid_from_col_name: fromdate
          scd_valid_to_col_name: todate

      - scd2_current_matches_source:
          source_model: int_employee_history
          unique_key: employee_id
          scd_valid_to_col_name: todate
          scd_valid_to_max_date: '3000-12-31'
          check_cols:
            - name
            - user_role
            - is_active
            ...

      - no_consecutive_duplicate_scd_hash:
          unique_key: employee_id

    columns:
      - name: employee_hist_id
        constraints:
          - type: not_null
          - type: primary_key
            warn_unenforced: false
        data_tests:
          - unique

      - name: fromdate
        constraints:
          - type: not_null

      ...

      - name: scd_hash
        constraints:
          - type: not_null
```

Although the contract is not enforced, keeping the column definitions, constraints and tests in the schema provides complete model documentation and allows helper macros to generate the required Redshift DDL.

---

## Redshift constraints

Since dbt contracts are not supported for the `scd2_plus` custom materialization, Redshift tables are created without `NOT NULL` and `PRIMARY KEY` constraints.

Redshift does not support adding `NOT NULL constraints to existing columns`. The table must be rebuilt with the required constraints.

The project provides helper macros (see `macros/framework/maintenance/Redshift_constraints.sql`) to rebuild the table with `NOT NULL` columns and create the primary key.

---

## Recommended deployment sequence:

1. Create the intermediate model.
2. Create the SCD2 model.
3. Create the schema with constraints, tests and `contract.enforced: false`.
4. Run `dbt run` to create the history table.
5. Run `dbt test` to test the history table.
6. Run the helper macros from `Redshift_constraints.sql` to:

   - preview the table recreation process with `NOT NULL` columns;

```bash
dbt run-operation generate_not_null_rebuild_sql \
  --args '{model_name: dim_employee_history}' \
```
By default, the macro just generate DDL SQL.

   - rebuild the table with `NOT NULL` columns;

```bash
dbt run-operation generate_not_null_rebuild_sql \
  --args '{model_name: dim_employee_history}' \
  --vars '{dry_run: false}'
```
   - preview the primary-key SQL

```bash
dbt run-operation generate_primary_key_sql \
  --args '{model_name: dim_employee_history}'
```
   - create the primary key.

```bash
dbt run-operation generate_primary_key_sql \
  --args '{model_name: dim_employee_history}' \
  --vars '{dry_run: false}'
```
