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


--SFDC Accounts not linked to LCom Orgs
--always have conformed customer as its SFDC Ultimate Parent Account
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'SFDC Accounts not linked to LCom Orgs always have conformed customer as its SFDC Ultimate Parent Account' as failure
from accounts a
join accounts c
on  a.conformed_customer_id = c.account_id
where a.lcom_organization_id = '{{ var("default_ID") }}'
and a.sfdc_ultimate_parent_id != c.sfdc_account_id

union all 



--Customer of LCom Orgs not linked to SFDC accounts
--BUT! their parent org is linked to SFDC account
--always have customer as its parent org ultimate parent account
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     , 'Customer of LCom Orgs not linked to SFDC accounts BUT! their parent org is linked to SFDC account always have customer as its parent org ultimate parent account' as failure
from common.dim_account a     
join common.dim_account d
on  a.conformed_district_id = d.account_id
join common.dim_account c
--Customer is from district level!
on  d.conformed_customer_id = c.account_id
where a.lcom_organization_id != '{{ var("default_ID") }}'
and a.sfdc_account_id = '{{ var("default_ID") }}'
and a.lcom_parent_organization_id != '{{ var("default_ID") }}'
and d.sfdc_account_id != '{{ var("default_ID") }}'
and d.sfdc_ultimate_parent_id != c.sfdc_ultimate_parent_id


/*
The 2 cases below are not true if:
1. LCom Org District is not linked to Salesforce Account
2. It's child LCom Org school is linked to Salesforce Account
- If there is just one SFDC Ultimate Parent for all such 
child LCom Org schools linked to Salesforce Account
than this SFDC Ultimate Parent becomes a customer for all
LCom Org District  not linked to Salesforce Account
and "Customer of LCom Orgs not linked to SFDC accounts BUT! their parent org is linked to SFDC account always have customer as its parent org ultimate parent account"
rule is violated.

- If there are different SFDC Ultimate Parents for all such 
child LCom Org schools linked to Salesforce Account
than LCom Org District is the Customer for all schools
and  this rule "SFDC Accounts  linked to LCom Orgs always have conformed customer as its SFDC Ultimate Parent Account from district level!"
is violated.

In both cases the goal is to have one and only one Customer for each district

union all

--Customer of LCom Orgs not linked to SFDC accounts
--and their parent org not linked to SFDC account
--always have customer as its LCom Parent Org
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id
     ,'Customer of LCom Orgs not linked to SFDC accounts and their parent org not linked to SFDC account always have customer as its LCom Parent Org' as failure
from common.dim_account a     
join common.dim_account d
on  a.conformed_district_id = d.account_id
join common.dim_account c
--Customer is from district level!
on  d.conformed_customer_id = c.account_id
where a.lcom_organization_id != '{{ var("default_ID") }}'
and a.sfdc_account_id = '{{ var("default_ID") }}'
and a.lcom_parent_organization_id != '{{ var("default_ID") }}'
and d.sfdc_account_id = '{{ var("default_ID") }}'
and a.lcom_parent_organization_id != c.account_id

union all



--SFDC Accounts  linked to LCom Orgs
--always have conformed customer as its SFDC Ultimate Parent Account
--from district level!
--It's possible to have inconsistency in SFDC Ultimate Parent Account
--in from school and district level
--if there is a wrong Org linked to SFDC account
select a.account_id
     , a.conformed_district_id
     , a.conformed_customer_id
     , a.lcom_organization_id
     , a.lcom_parent_organization_id
     , a.sfdc_account_id
     , a.sfdc_parent_id
     , a.sfdc_ultimate_parent_id,
     'SFDC Accounts  linked to LCom Orgs always have conformed customer as its SFDC Ultimate Parent Account from district level!' as failure
from common.dim_account a
join common.dim_account d
on  a.conformed_district_id = d.account_id
join common.dim_account c
--Customer is from district level!
on  d.conformed_customer_id = c.account_id
where a.lcom_organization_id != '{{ var("default_ID") }}'
and a.sfdc_account_id != '{{ var("default_ID") }}'
and d.sfdc_ultimate_parent_id != c.sfdc_ultimate_parent_id
*/

)

select *
from failures