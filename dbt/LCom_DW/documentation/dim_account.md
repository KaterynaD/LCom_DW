{% docs table_dim_account %}
Conformed DIM_ACCOUNT dimension. Account (districts and schools) data from all source systems.

# DIM_ACCOUNT

It's a conformed dimension and many systems contribute records in this table. 

## Primary and Distribution Key

![Accounts can be created in HubSpot, GainsightCloud or LCom Platform and imported/integrated between the systems or not.](/assets/accounts_created_in_different systems.png)

Accounts can be created in HubSpot, GainsightCloud or LCom Platform and imported/integrated between the systems or not. 
DIM_ACCOUNT is design in a way to join in one record accounts from different systems if they are integrated and have not linked accounts by itself.

![DIM_ACCOUNT is design in a way to join in one record accounts from different systems if they are integrated and have not linked accounts by itself.](/assets/dim_account_populated withaccounts_from-different_systems.png)

There are existing large fact tables with usage data built based on LCom Organization Id as a distribution key. Practically, it is not possible to re-create the tables based on a surrogate key from newly created conformed DIM_ACCOUNT. 

Most of the accounts in Salesforce are updated daily (probably there are no real changes in the object attributes, but last modified date is changed). Incremental load takes longer then full re-reload.

That's why "Table" materialization was choosen for DIM_ACCOUNT (and some other Salesforce based fact tables). 

In this situation **Primary and Distribution Key in DIM_ACCOUNT is changed over the account life**. It is not a usual or best  case but works.

1. A new account is created in Salesforce and the PK (account_id) in DIM_ACCOUNT is **Salesforce Id**. 
2. A correspondent Organization is created in LCom Platform.  The record will have **LCom Organization Id**  as the PK (account_Id) in DIM_ACCOUNT.
3. If it's Salesforce_Id is blank or populated with a wrong/broken Salesforce ID we will have 2 separate records in DIM_ACCOUNT
4. When a proper Salesforce Id is set in LCom Organization table, the 2 records are joined together and the PK is **LCom Organization Id**

The idea is:

**coalesce(Lcom_Organization_Id, Salesforce.Account.Id,Gainsight.Account.Id, HubSpot.Account.Id)**

Practically, only Salesforce accounts and LCom Organizations are in DIM_ACCOUNT now.

- LCom Organization table fields are starts from "lcom_" prefix.
- Salesforce Account object attributes are starts from "sfdc_" prefix.

## Duplicates:

It's up to the source system to clean duplicates, whatever processes exist.
But there are cases, when more then one LCom Organization IDs are linked to the same Salesforce Id.

In this case:
1. account_id (PK) is unique . It's LCom Organization Id.
2. lcom_organization_id is unique. It's LCom Organization Id. (If not take into account "Unknown" values from salesforce accounts not linked to LCom Organization)
3. sfdc_account_id is NOT unique. However, to make it's cleaner I add "dup-" prefix to all but one Salesforce IDs. If there is a district and school LCom Organization have the same Salesforce Id, then a "district" LCom org record will have "clean" Salesforce Id in sfdc_account_id and "school" LCom org  record will have "dup-" prefix in sfdc_account_id. **In this way, "clean" sfdc_account_id (without "dup" prefix) are unique.**

- It's possible to have more then one sfdc_account_id with the same Salesforce Id starting from "dup-" if there are more then one duplicate Salesforce IDs in LCom Organization. 

- If there are no "district" in LCom Org Salesforce Id duplicates, then a random school is selected as "primary" to have "clean" sfdc_account_id.
- If there are more then one "district" in LCom Org Salesforce Id duplicates, then a random district is selected as "primary" to have "clean" sfdc_account_id.

There is LCOM_SFDC_ACCOUNT_MAPPING table in Staging were the described rules are applied and then used in DIM_ACCOUNT transformation.

Most likely, they are "valid" duplicates in LCom Org Salesforce Id. Probably a multi-level account hierarchy in Salesforce is flatten to"district"-"school" levels.

All "SFDC_*" columns in such records are the same as in the "clean" sfdc_account_id. 

## Default

There is one and only one default record in DIM_ACCOUNT. It has account_id (PK) equal "default_ID" which is "00000000-0000-0000-0000-000000000000". It's used if a transformation can not find a corresponding account in DIM_ACCOUNT for whatever reason.

There are no null values in DIM_ACCOUNT (as in all othe dim and fact tables). They are all replaced with default values like "Unknown" or "1900-01-01" etc.
Be aware when you run something like a recursive or hierarchical queries and expect "NULL" ina  parent account as an example.

{% enddocs %}