{% macro create_conformed_account_hierarchy() %}

 {% set custom_schema = deployment_schema() %}

 {% set create_table_operation %}


 CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.stg_opportunities_chain_of_renewals
(
 opportunity_id VARCHAR(300) NOT NULL ENCODE RAW
,cnt_parents int NOT NULL  ENCODE az64
,parent_opportunities VARCHAR(max) NOT NULL  ENCODE lzo
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
)
DISTSTYLE AUTO
DISTKEY (opportunity_id)
SORTKEY (
opportunity_id
)
;


CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
(
	 account_id VARCHAR(300)  not null
	,lcom_organization_id VARCHAR(300)     not null
	,salesforce_id VARCHAR(300)   not null
	,sfdc_account_id VARCHAR(300)     not null
	,conformed_district_id VARCHAR(300)     not null
	,conformed_customer_id VARCHAR(300)     not null
	,applied_rule VARCHAR(300)  
	,cnt_dist_org_id_group_by_salesforce_id INTEGER   
	,cnt_districts_in_dups_by_salesforce_id INTEGER  
	,cnt_schools_in_dups_by_salesforce_id INTEGER  
	,loaddate TIMESTAMP WITHOUT TIME ZONE  
	,PRIMARY KEY (account_id)
)
DISTSTYLE KEY
 DISTKEY (account_id)
 SORTKEY (
	account_id
	)
;

COMMENT ON table  {{target.database}}.{{custom_schema}}.conformed_account_hierarchy is 'Mapping table between content_delivery_usage.dbo.Organization  Salesforce Account tables including conformed hierarchy';

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.account_id IS 'Conformed account_id which is LCom Organization ID or SFDC Account Object Id if no link to LCom Organization.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.lcom_organization_id IS 'LCom organization_id (school or district) from content_delivery_usage.dbo.Organization table. Default value, if no LCom Org linked to a Salesforce Account';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.salesforce_id IS 'SFDC Account Object Id from rawdata.fivetran_salesforce_quickstart.account. Default value, if no Salesforce Account linked to this LCom Org';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.sfdc_account_id IS 'Conformed Salesforce Account Object ID. If there are more than 1 LCom Org linked to the same Salesforce Account a special rule applied and extra LCom Orgs have "dup-" prefix in this column. Default value if no one Salesforce Account linked to Lcom Org.';

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.conformed_district_id is 'Conformed Account District ID. parent_organization_id content_delivery_usage.dbo.Organization is used by first and, if SAlesforce Account is not linked to LCom Org, then immediate Salesforce Account parent is used (parent_id from rawdata.fivetran_salesforce_quickstart.account). It can be the same as account_id if the account is district or customer and does not have parent or set to itself.';

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.conformed_customer_id is 'If there is a link between Salesforce Account and LCom Org or Salesforce Account without a link then Salesforce Ultimate Parent Account from conformed_district_id is used. LCom Orgs without a link to Salesforce Account use immediate parent (district). It can be the same as account_id if the account is ultimate parent account and does not have parent or set to itself.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.applied_rule IS 'The rule, applied to SFDC_Account_Id column, where to add `dup-` prefix: Districts has precedence over Schools. If more then one schools or districts have the same salesforce_id, then the one with the maximum organization_id will be used as a clean one. The others will have `dup-` prefix in SFDC_Account_Id.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.cnt_dist_org_id_group_by_salesforce_id IS 'Indicates duplicates by salesforce_id if not null and more then 1';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.cnt_districts_in_dups_by_salesforce_id IS 'How many Districts are in duplicates by salesforce_id';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.cnt_schools_in_dups_by_salesforce_id IS 'How many Schools are in duplicates by salesforce_id';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.loaddate is 'The datetime the record was loaded in PST';







{% endset %}

{{ run_DDL('conformed_account_hierarchy', create_table_operation) }}

{% endmacro %} 