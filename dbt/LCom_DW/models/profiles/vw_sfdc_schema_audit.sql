select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_account_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_campaign_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_case_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_contact_profile') }}
union all
select
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_opportunity_line_item_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_opportunity_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_product_2_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_training_session_c_profile') }}
union all
select 
profile_name,
database_name,
schema_name,
table_name, 
column_name,
data_type,
data_type_category,
loaddate
from {{ ref('sfdc_user_profile') }}