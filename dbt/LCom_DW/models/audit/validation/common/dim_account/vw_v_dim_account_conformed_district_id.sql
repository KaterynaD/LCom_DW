{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
 
with accounts as (

    select *
    from {{ ref('dim_account') }}

),

failures as (

--LCom Orgs always have conformed districts as their parent LCom Orgs
--if there is a parent LCom org
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'LCom Orgs always have conformed districts as their parent LCom Orgs if there is a parent LCom org' as failure
from accounts a
where a.lcom_organization_id != '{{ var("default_ID") }}'
and a.lcom_parent_organization_id != '{{ var("default_ID") }}'
and a.conformed_district_id != a.lcom_parent_organization_id

union all

--LCom Orgs always have conformed districts as themselves 
--if there is no parent LCom org (they are districts in LCom Org)
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'LCom Orgs always have conformed districts as themselves if there is no parent LCom org (they are districts in LCom Org)' as failure
from accounts a
where a.lcom_organization_id != '{{ var("default_ID") }}'
and a.lcom_parent_organization_id = '{{ var("default_ID") }}'
and a.conformed_district_id != a.account_id

union all

--SFDC accounts not linked to LCom Org
--SFDC Parent account may or may not linked to LCom Org
--have conformed districts as their immediate parents
--if they are set in Selasforce
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'SFDC accounts not linked to LCom Org SFDC Parent account may or may not linked to LCom Org have conformed districts as their immediate parents if they are set in Selasforce' as failure
from accounts a
join accounts d
on  a.sfdc_parent_id = d.sfdc_account_id
where a.lcom_organization_id = '{{ var("default_ID") }}'
and a.sfdc_parent_id != '{{ var("default_ID") }}'
and a.conformed_district_id != d.account_id

union all

--SFDC accounts not linked to LCom Org
--and do not have SFDC parent
--always have conformed district as conformed customer
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'SFDC accounts not linked to LCom Org and do not have SFDC parent always have conformed district as conformed customer' as failure
from accounts a
where a.lcom_organization_id = '{{ var("default_ID") }}'
and a.sfdc_parent_id = '{{ var("default_ID") }}'
and a.conformed_district_id != a.conformed_customer_id

)

select *
from failures

