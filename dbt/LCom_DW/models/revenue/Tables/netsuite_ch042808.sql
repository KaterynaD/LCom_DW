{{
    config(

        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='even',
        sort='mon_year'
        
        )
}}

with data as (
select
replace(replace("class"::varchar(500), '> ', '>'), ' >', '>') as business_class,
Primary_Sales_Rep::varchar(500) as primary_sales_rep,
Name_grouped_::varchar(500) as name,
Bill_To::varchar(500) as bill_to,
customer_implementation_target_level::varchar(500) as target_level,
item_name_grouped_::varchar(500) as item,
Progressive_Billing::varchar(500) as progressive_billing,
Memo::varchar(65535) as memo,
rev_rec_start_date::date as start_date,
rev_rec_end_date::date as end_date,
transaction_number::varchar(500) as transaction_number,
date::date as invoiced_date,
replace(replace(replace(replace(sales, '$', ''), ',', ''), '(', '-'), ')', '')::double precision as sales,
Created_From::varchar(100) as created_from,
sf_net_suite_order_id::varchar(500) as sf_netsuite_order_id,
address_billing_address_state::varchar(100) as billing_state
from {{ source('fivetran_email', 'ch_042808') }}
where _modified = (select max(_modified) from {{ source('fivetran_email', 'ch_042808') }})
)
select
to_char(invoiced_date, 'YYYYMM')::int as mon_year,
business_class,
primary_sales_rep,  
name,           
bill_to,
target_level,   
item,
progressive_billing,    
memo,
start_date,
end_date,
transaction_number, 
invoiced_date,
sales,
created_from,
sf_netsuite_order_id,
billing_state,
'{{ var("loaddate") }}'::timestamp as loaddate
from data