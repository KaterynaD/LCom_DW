{% docs __overview__ %}
# LCOM Data Warehouse Docs

## High level overview

### WHAT?

- Usage data (LCOM Platform)
- Revenue data (Salesforce)
- Licensing data (LCOM Platform + Salesforce)

### WHERE?

AWS Redshift hosts the data

- prd-data-ware-house-workspace.248725110737.us-west-2.redshift-serverless.amazonaws.com

- **CONTENT_DELIVERY_USAGE** database:
  - **dbo** - LCOM platform transformed tables
  - **staging** - LCOM platform staging data


- **RAWDATA** database:
  - **Fivetran_Salesforce** – Salesforce objects data without formula-based attributes.
  - **Fivetran_Salesforce_Quickstart** – dbt (Fivetran provided project) transformed Salesforce objects data with formula-based attributes (Views).


- **DW database** – final schemas and tables
  - **Audit**\- dbt runs audit logs
  - **Common** – conformed dimensions used in many businesses’ areas
  - **Content_Delivery_Usage** – fact (aggregated snapshots) and dimensional tables related to Usage LCOM data
  - **Licensing** – license orders
  - **Reporting** – views and tables created for specific reports or data feeds
  - **Revenue** – Salesforce opportunities and customers data
  - **Support** – Salesforce Support cases  
  - **Staging** – used for some intermediate tables and views

[Tableau visualizes the data](https://10ay.online.tableau.com/#/site/lcomreporting/explore)

AWS Glue (LCOM Platform) and Fivetran (Salesforce) extractes the data

Dbt, AWS Redshift Stored Procedures Glue transforms and loads the data. (Prod dbt runs in Fivetran)
The code is in [github](https://github.com/learningcom/transformations/tree/master)

### WHEN? 

- End of day (5pm  pst) AWS GLUE jobs started
- Fivetran Salesforce connection starts at 6pm pst
- Fivetran dbt transformation starts at 1:28 am pst next day

[Schedule](https://lcom.sharepoint.com/:x:/s/ReportingandAnalytics/EaLDW75RtPFKmxya5ynKbRUBNO8fRT9WW2FXrweDa8E3Zw?e=uy2trf)

**The schedule can be changed without updating this documentation. Check the specific tool for the actual schedule**


## Conceptual and Logical Diagrams

- [Conceptual](https://learningcom.atlassian.net/wiki/spaces/AC/whiteboard/3427368974) 
- [DW Logical Schema](https://learningcom.atlassian.net/wiki/spaces/AC/whiteboard/3488841816?atl_f=PAGETREE)

## DW Physical Schemas Diagrams

(use this diagram to understand how to join tables): 

### Common

The dimensions in this schema are used in relations with fact tables in other schemas or in transformations.

![Common](diagrams/Common.png)


### Revenue

Snapshot tables may contain all needed information or joined to DIM_ACCOUNT using sfdc_account_id or FACT_OPPORTUNITY.

![Revenue](diagrams/Revenue.png)

### Licensing
![Licensing](diagrams/Licensing.png)

### Training Sessions
![Training Sessions](diagrams/Training Sessions.png)


### Support Cases
![Support Cases](diagrams/Support Cases.png)


### Content Delivery Usage
![Content Delivery Usage](diagrams/Content Delivery Usage.png)

### Content Delivery Usage Dimensions
The dimensions in this schema are used in transformations mosly

![Content Delivery Usage Dimensions](diagrams/Content Delivery Usage Dimensions.png)


## [Column Level Lineage](https://learningcom.github.io/transformations/colibri_index.html)

{% enddocs %}



{% docs __dbt_utils__ %}
# Utility macros
Our dbt project may use this package for surrogate keys, etc.
{% enddocs %}

{% docs __LCom_DW__ %}
# Main dbt project

- Models in top-level models folders (Common, Revenue etc) are created in the database schemas with the same names. (Customized generate_schema_name macros and configuration in dbt_project.yml)
- The schemas are created manually before the start of the project. The scripts are in project_setup_folder in 
[github](https://github.com/learningcom/transformations/tree/master/dbt/LCom_DW/project_setup_scripts)
- Each dbt run in Prod target is logged in audit.dbt_run_log table. It's "dbt run Start/End" operation and "Scheduled Prod run" comment by default but the comment can be customized in run_type variable.
- Each dbt model run in Prod target is logged in audit.dbt_run_log table. It's configured for all models in dbt_project.yml (Pre and Post hooks)
- Null values are replaced with default values from variables in dbt_project.yml Like "Unknown" for varchar columns etc.
- audit.dbt_run_log table is a not part of the transformation models and **must be created outside of the dbt project** because every run of dbt need the table for logs. The table creation statement is project_setup_folder [github](https://github.com/learningcom/transformations/tree/master/dbt/LCom_DW/project_setup_scripts)


## Foreighn Keys

FK are not enforced in Redshift. The relations are tested in dbt except history tables because it's possible to have historical entities deleted and without related data in current data tables. The FK are dropped before transformatioms starts and re-created after. If there is a manual run, a FK can be dropped but not restored automatically. They are added to show how the tables can be join.

# Slowly Changing Dimension Type 2 (scd2) Custom Materialization

It's used to track historical data

The original source of the project is in [github](https://github.com/KaterynaD/dbt_scd2_plus)
but the scripts are part of LCom_DW projects (macros/dbt_scd2_plus) and no need to install the package.

{% enddocs %}


{% docs __dbt_postgres__ %}
# This is a base for dbt Redshift
I can not remove it from the documentation generated by dbt. There is a dbt bug to hide a package with only macros. It's open since 2023 and very little chance they will fix it.

{% enddocs %}
