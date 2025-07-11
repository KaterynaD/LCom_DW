# Welcome to LCom Enterprise DW dbt Project!

### Content

Business Areas:
- LCom platform content, delivery and usage
- Revenue (Salesforce Opportunity)
- Licensing

- Objects related to more then one business area are in Common.

- Project logs are in Audit (works only in Prod target environment).

- Staging is used in some transformations.

### Set up - one time operations
- Schemas should exist in the target DB, otherwise the project will create something with not-expected names. No time to adjust out of the box dbt behavour. See schemas.sql in project_setup_scripts folder.
- audit.dbt_run_log is a not part of the transformation models and should be created outside of the project because every run of dbt need the table for logs. See audit_dbt_run_log.sql script in project_setup_scripts folder.

- common.dim_calendar is not a part of the transformation models and can be created with create_common_dim_calendar_table macro:
```
dbt run-operation create_common_dim_calendar_table
```
- common.populating_dim_calendar stored procedure is used to populate common.dim_calendar
```
dbt run-operation create_populating_dim_calendar
```
- to populate common.dim_calendar run the stored procedure once
```
dbt run-operation run_populating_dim_calendar
```

### To Do

- Employees (Sales Reps, Account Owners, Tech Support)
- Technical Support business area (Cases and Biz Ops requests)
- LCom platform content, delivery and usage view objects recreate as tables. However, fact tables are huge and may still views. 



### Known issues:

- dbt for Redshift does not create comments from columns descriptions in views. Need a macro.
- dbt v1.8.4 (the version used in Fivetran) creates FK only referring the exact table name , not using ref JINJA function. 
- dbt does not hide packages in documentation if there are only macros. There is a reported bug for a long time but they do not fix.
``` 
    - type: foreign_key
      expression: common.dim_account(account_id)
      warn_unenforced: false
```
works only if both tables are "table" materialization
If one of the table is incremental - it does not work.
"Table" materialization drops manually created FKs (Add in post-hook?)
I removed constraint declaration from the schema/contract. There is still a test which checks integrity.


- dbt can not grant select for Redshift roles. It grants directly to users now, but maybe it makes sense to run a Redshift grant in a hook/macros? Or better ALTER DEFAULT PRIVILEGES?

- The largest tables in the project (fact tables from LCom platform content, delivery and usage) were built when conformed dim_account did not exist and distributed by LCom platform organization id. An account, created in Salesforce, must change it's unique id in Dim_Account when a correspondeing organization created in LCom Platform Organization table to be properly distributed. It prevents from using incremental load in dbt because it requires a stable unique key. Most accounts are updated daily in Salesforce and incremental load does not improve performance anyway.

