# Welcome to LCom Enterprise DW dbt Project!

### Content

Business Areas:
- LCom platform content, delivery and usage
- Revenue (Salesforce Opportunity)
- Licensing

Objects related to more then one business area are in Common.

Project logs are in Audit (works only in Prod target environment).

Staging is used in some transformations.

### To Do

- Conformed(?) dim_product or few dim_products for each business area with a bridge
- Technical Support business area (Cases and Biz Ops requests)
- LCom platform content, delivery and usage view objects recreate as tables. However, fact tables are huge and may still views. 



### Known issues:

- dbt for Redshift does not create comments from columns descriptions in views. Need a macros.
- dbt does not create FKs. It might be related to table materialization. Need to investigate more.
- dbt can not grant select for Redshift roles. It grants directly to users now, but maybe it makes sense to run a Redshift grant in a hook/macros? Or better ALTER DEFAULT PRIVILEGES?

- The largest tables in the project (fact tables from LCom platform content, delivery and usage) were built when conformed dim_account did not exist and distributed by LCom platform organization id. An account, created in Salesforce, must change it's unique id in Dim_Account when a correspondeing organization created in LCom Platform Organization table to be properly distributed. It prevents from using incremental load in dbt because it requires a stable unique key. Most accounts are updated daily in Salesforce and incremental load does not improve performance anyway.

