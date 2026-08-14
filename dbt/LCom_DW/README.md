# Welcome to LCom Enterprise DW dbt Project!

### Content notes

- Schemas are marts per Business Area (Marketing, Support, Revenue,Licensing etc)

- Objects related to more then one business area are in Common.

- Project logs are in Audit (works only in Prod target environment).

- Staging is used in some transformations.

### Set up - one time operations
- Schemas should exist in the target DB, otherwise the project will create something with not-expected names.  See create_schemas macro in macros/create_schema folder.
- audit.dbt_run_log is a not part of the transformation models and should be created outside of the project because every run of dbt need the table for logs. See audit_dbt_run_log.sql script in project_setup_scripts folder.

### Custom folders:
- **documentation** is for *.md files with extended or templates object descriptions. There is also index.html with adjusted logo and title. This is a template dbt uses to generate documentations. It should re-place existing **index.html** in **".venv\Lib\site-packages\dbt\task\docs"** folder after a new environment created and dbt installed.

- **project_setup_scripts** contains some scripts which should be used if the project is created from scratch in a new data base environment

### Other notes:

- add **ra3_node: true** in dbt profile explicitly to avoide errors in **dbt docs generate --static** command

### Known issues:

- dbt for Redshift does not create comments from columns descriptions in views. Need a macro.
- dbt for Redshift does not create FK constraints when they are declared in a table schema yml file with Contract enabled. 
``` 
    - type: foreign_key
      expression: common.dim_account(account_id)
      warn_unenforced: false
```
works only if both tables are "table" materialization
If one of the table is incremental - it does not work.
"Table" materialization drops manually created FKs (Add in post-hook?)
I removed constraint declarations from the schema/contract. There is still a test which checks integrity.
There is also a macro to drop and re-create constraints before and after the run for all tables 
- dbt does not hide packages in documentation if there are only macros. There is a reported bug for a long time but they do not fix.
- dbt can not grant select for Redshift roles. It grants directly to users now (see dbt_project.yml, model configuration) and there is a grant at the level of Redshift database like 
```
ALTER DEFAULT PRIVILEGES FOR user svcfivetran IN SCHEMA <for each used in dbt ptoject schema name> GRANT SELECT ON TABLES TO role RA_Users

```

- The largest tables in the project (fact tables from LCom platform content, delivery and usage) were built when conformed dim_account did not exist and distributed by LCom platform organization id. An account, created in Salesforce, must change it's unique id in Dim_Account when a correspondeing organization created in LCom Platform Organization table to be properly distributed. It prevents from using incremental load in dbt because it requires a stable unique key. Most accounts are updated daily in Salesforce and incremental load does not improve performance anyway.

## Development Guidelines

- [LCom DW Distribution Key Design](README_DISTRIBUTION_KEY.md)
- [Working with Late-Binding Views](WORKING_WITH_LATE_BINDING_VIEWS.md)
- [Adding New Column Incremental Model](ADDING_NEW_COLUMN_INCREMENTAL_MODEL.md)
- [History of data changes - Slowly Changing Dimension Type 2 (SCD2)](README_SCD2_DESIGN_RECOMMENDATION.md); See also scd2_plus [Readme](macros/dbt_scd2_plus/README.md)  and [dim_account_history](models/common/Tables/dim_account_history.sql) as an example
- [Adding New Column SCD2 Model](ADDING_NEW_COLUMN_SCD2_MODEL.md)
- [Removing Column from SCD2 Model](REMOVING_COLUMN_SCD2_MODEL.md)
- [Stored Procedure Materialization](STORED_PROCEDURES_DBT_GUIDELINES.md): [See fact_launches_weekly_snapshots.sql as an example ](models/content_delivery_usage/Tables/Facts/fact_launches_weekly_snapshots.sql)
- [Singular (Custom SQL) dbt Tests](SINGULAR_dbt_TESTS.md)
- [Load Date Design and Usage](README_LOADDATE.md)
