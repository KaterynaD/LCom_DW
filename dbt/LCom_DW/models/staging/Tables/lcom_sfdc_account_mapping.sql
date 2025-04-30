{{
    config(

        materialized='table',  
        dist='organization_id', 
        sort='organization_id'       
        )
}}

with  lcom_data as (
select 
o.organization_id,
a.id salesforce_id, /*only valid Salesforce Id*/
o.organization_type
from {{ source("dbo","organization") }} o
left outer join {{ source('fivetran_salesforce_quickstart', 'account') }} a
on a.id=o.salesforce_id
)
,raw_data as (
select 
 /*valid Salesforce Id*/
lcom_data.organization_id,
lcom_data.organization_type,
lcom_data.salesforce_id
from lcom_data
where lcom_data.salesforce_id is not null
union all
select 
/*no valid Salesforce Id in Organization table but 
 * there is lcom_organization_c populated (an other hierarchy of organizations in LCom used in Licensing) in Salesforce Account table 
 * and it can be related to 1 or MORE lcom_platform_organization_id_c
 * which is organization_id in Organization table*/
lcom_data.organization_id,
lcom_data.organization_type,
max(a.id) salesforce_id /*it's possible the same org rel to 2 different SFDC accounts*/
from lcom_data
join  {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }} loc
on lcom_data.organization_id=lower(loc.lcom_platform_organization_id_c)
join {{ source('fivetran_salesforce_quickstart', 'account') }} a
on a.lcom_organization_c = loc.id
where lcom_data.salesforce_id is null
group by 
lcom_data.organization_id,
lcom_data.organization_type
)
,dup_by_salesforce_id as 
(select
salesforce_id,
count(distinct organization_id) cnt_dist_org_id_group_by_salesforce_id,
count(case when organization_type='district' then organization_id else null end)  cnt_districts_in_dups_by_salesforce_id,
count(case when organization_type='school' then organization_id else null end)  cnt_schools_in_dups_by_salesforce_id,
max(case when organization_type='district' then organization_id else null end)  max_district_in_dups_by_salesforce_id,
max(case when organization_type='school' then organization_id else null end)  max_school_in_dups_by_salesforce_id
from raw_data
group by salesforce_id
having count(distinct organization_id)>1
)
, data as (
select 
raw_data.*,
--
cnt_dist_org_id_group_by_salesforce_id,
cnt_districts_in_dups_by_salesforce_id,
cnt_schools_in_dups_by_salesforce_id,
max_district_in_dups_by_salesforce_id,
max_school_in_dups_by_salesforce_id
from raw_data
left outer join dup_by_salesforce_id on raw_data.salesforce_id=dup_by_salesforce_id.salesforce_id
)
,rule_applied as (
select 
organization_id,
organization_type,
salesforce_id,
case 
when cnt_dist_org_id_group_by_salesforce_id is null  then 
 '004-'+salesforce_id 
when cnt_dist_org_id_group_by_salesforce_id is not null then /*duplicates by salesforce_id*/
 case
  when organization_type='district' then
   case 
	when cnt_districts_in_dups_by_salesforce_id = 1 then /*if there is only 1 district in the duplicates - it has priority, schools do not matter*/
	 '001-'+salesforce_id	
	when cnt_districts_in_dups_by_salesforce_id >1 
	 and organization_id=max_district_in_dups_by_salesforce_id then /*if there are more then 1 district in the duplicates - max(organization_id) has priority, schools do not matter*/
	 '002-'+salesforce_id
    else
     'dup-'+salesforce_id
   end 
  when  organization_type='school' then
   case 
	when cnt_districts_in_dups_by_salesforce_id > 0 then /*if there is a district in the duplicates - it has priority*/
	 'dup-'+salesforce_id
	when cnt_districts_in_dups_by_salesforce_id = 0
	and cnt_schools_in_dups_by_salesforce_id > 1 
	and organization_id=max_school_in_dups_by_salesforce_id then /*if there is no district and more then 1 school in the duplicates - max(organization_id) has priority*/
	 '003-'+salesforce_id
    else
     'dup-'+salesforce_id
   end 
 end
else
     'dup-'+salesforce_id 
end SFDC_account_id,
cnt_dist_org_id_group_by_salesforce_id,
cnt_districts_in_dups_by_salesforce_id,
cnt_schools_in_dups_by_salesforce_id
from data
where SFDC_account_id is not null
)
, final_data as (
select
organization_id,
organization_type,
salesforce_id,
case when left(SFDC_account_id,4) != 'dup-' then substring(SFDC_account_id from 5 for len(SFDC_account_Id)) else SFDC_account_id end SFDC_account_Id,
case 
 when left(SFDC_account_id,4) = '000-' then 'Salesforce account lcom_organization_c'
 when left(SFDC_account_id,4) = '004-' then 'No duplicates by salesforce_id in Organization.'
 when left(SFDC_account_id,4) = '001-' then 'District in Districts and Schools with duplicate salesforce_id in Organization' 
 when left(SFDC_account_id,4) = '002-' then 'More then 1 district with duplicate salesforce_id in Organization. Max organization Id has precedence'  
 when left(SFDC_account_id,4) = '003-' then 'More then 1 schools with duplicate salesforce_id in Organization. Max organization Id has precedence'  
 when left(SFDC_account_id,4) = 'dup-' then 'Marked as duplicate'  
end  as applied_rule,
cnt_dist_org_id_group_by_salesforce_id,
cnt_districts_in_dups_by_salesforce_id,
cnt_schools_in_dups_by_salesforce_id
from rule_applied
)
select
organization_id::varchar(300),
organization_type::varchar(270),
salesforce_id::varchar(300),
SFDC_account_Id::varchar(300),
applied_rule::varchar(150),
cnt_dist_org_id_group_by_salesforce_id::integer,
cnt_districts_in_dups_by_salesforce_id::integer,
cnt_schools_in_dups_by_salesforce_id::integer
from final_data
