with missing as (select table_name, column_name
from {{ source("profiles","vw_sfdc_schema_audit") }}
where profile_name='base'
except 
select table_name, column_name
from {{ source("profiles","vw_sfdc_schema_audit") }}
where profile_name='current')
select
case
 when a.table_name = 'account' then '/models/common/Tables/dim_account.sql'
 when a.table_name = 'product_2' then '/models/common/Tables/dim_sfdc_product.sql'
 when a.table_name = 'user' then '/models/common/Tables/dim_employee.sql'
 when a.table_name = 'opportunity' then '/models/revenue/Tables/fact_opportunity.sql'
 when a.table_name = 'opportunity_line_item' then '/models/revenue/Tables/dim_opportunity_line.sql'
 when a.table_name = 'case' then '/models/support/fact_case.sql'
 when a.table_name = 'training_session_c' then '/models/content_delivery_usage/Tables/Facts/fact_training_session.sql'
end model_name,
a.table_name, 
a.column_name
from {{ source("profiles","vw_sfdc_schema_audit") }} a
join missing m
on a.table_name=m.table_name
and a.column_name=m.column_name
where profile_name='base'
