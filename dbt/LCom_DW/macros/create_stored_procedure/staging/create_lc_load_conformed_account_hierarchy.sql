{% macro create_lc_load_conformed_account_hierarchy() %}

 {% set custom_schema = deployment_schema() %}
 
 {% set create_sp_operation %}



CREATE OR REPLACE PROCEDURE  {{target.database}}.{{custom_schema}}.lc_load_conformed_account_hierarchy(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
begin
	
/*
 Salesforce ID in content_delivery_usage.dbo.organization is ignored now
 The relation is covered with Salesforce data
 */

--LCom Organizations from SFDC Account: one-to-one
drop table if exists  stg_lcom_sfdc_account_keys;
create temporary table stg_lcom_sfdc_account_keys 
DISTSTYLE KEY
DISTKEY (account_id)
SORTKEY (account_id)
as
select
    id as account_id,
    lcom_organization_c as lcom_organization_c_id,
    parent_id,
    ultimate_parent_id_c
from {{ source('fivetran_salesforce_quickstart', 'account') }};


--one to many SFDC Account to LCom Org in lcom_organization_c
--need one-to-one and priority to the org set in account
--just feel the gaps set in account
drop table if exists  int_lcom_sfdc_account_fallback;
create temporary table int_lcom_sfdc_account_fallback 
DISTSTYLE KEY
DISTKEY (organization_id)
SORTKEY (organization_id) as
select
    lower(lcom_organization.lcom_platform_organization_id_c) as organization_id,
    max(account.account_id) as salesforce_id
from {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }}  lcom_organization
join stg_lcom_sfdc_account_keys account
    on account.lcom_organization_c_id = lcom_organization.id
where lcom_organization.lcom_platform_organization_id_c is not null
group by lower(lcom_organization.lcom_platform_organization_id_c);

--base data for final mapping from one of the too: direct or fallback where direct is missing with org type to resolve priorities
drop table if exists  int_lcom_sfdc_account_mapping_base;
create temporary table int_lcom_sfdc_account_mapping_base 
DISTSTYLE KEY
DISTKEY (organization_id)
SORTKEY (organization_id) as
select
    organization.organization_id,
    organization.organization_type,
    coalesce(direct_account.account_id, fallback_account.salesforce_id) as salesforce_id
from {{ source('dbo', 'organization') }} organization
left outer join stg_lcom_sfdc_account_keys direct_account
    on direct_account.account_id = organization.salesforce_id
left outer join int_lcom_sfdc_account_fallback fallback_account
    on fallback_account.organization_id = organization.organization_id
    and direct_account.account_id is null
where coalesce(direct_account.account_id, fallback_account.salesforce_id) is not null;



--final mapping with resolved sfdc_account_id when one-to-many organizations
--districts have priority
--extra marked as "dup-"
drop table if exists  lcom_sfdc_account_mapping;
create temporary table lcom_sfdc_account_mapping 
DISTSTYLE KEY
DISTKEY (organization_id)
SORTKEY (organization_id) as
with mapping_stats as (
    select
        organization_id,
        organization_type,
        salesforce_id,
        count(*) over (
            partition by salesforce_id
        ) as organization_count,
        sum(case when organization_type = 'district' then 1 else 0 end) over (
            partition by salesforce_id
        ) as district_count,
        sum(case when organization_type = 'school' then 1 else 0 end) over (
            partition by salesforce_id
        ) as school_count,
        max(case when organization_type = 'district' then organization_id end) over (
            partition by salesforce_id
        ) as max_district_organization_id,
        max(case when organization_type = 'school' then organization_id end) over (
            partition by salesforce_id
        ) as max_school_organization_id
    from int_lcom_sfdc_account_mapping_base
), rule_applied as (
    select
        organization_id,
        organization_type,
        salesforce_id,
        case
            when organization_count = 1 then salesforce_id
            when organization_type = 'district' and district_count = 1 then salesforce_id
            when organization_type = 'district'
                and district_count > 1
                and organization_id = max_district_organization_id
                then salesforce_id
            when organization_type = 'school'
                and district_count = 0
                and school_count > 1
                and organization_id = max_school_organization_id
                then salesforce_id
            when organization_type in ('district', 'school') then 'dup-' + salesforce_id
        end as sfdc_account_id,
        case
            when organization_count = 1
                then 'No duplicates by salesforce_id in Organization.'
            when organization_type = 'district' and district_count = 1
                then 'No duplicates by salesforce_id in Districts organizations'
            when organization_type = 'district'
                and district_count > 1
                and organization_id = max_district_organization_id
                then 'More then 1 district with duplicate salesforce_id in Organization. Max organization Id has precedence'
            when organization_type = 'school'
                and district_count = 0
                and school_count > 1
                and organization_id = max_school_organization_id
                then 'More then 1 schools with duplicate salesforce_id in Organization. Max organization Id has precedence'
            when organization_type in ('district', 'school') then 'Marked as duplicate'
        end as applied_rule,
        case when organization_count > 1 then organization_count end
            as cnt_dist_org_id_group_by_salesforce_id,
        case when organization_count > 1 then district_count end
            as cnt_districts_in_dups_by_salesforce_id,
        case when organization_count > 1 then school_count end
            as cnt_schools_in_dups_by_salesforce_id
    from mapping_stats
)
select
    organization_id,
    organization_type,
    salesforce_id,
    sfdc_account_id,
    applied_rule,
    cnt_dist_org_id_group_by_salesforce_id,
    cnt_districts_in_dups_by_salesforce_id,
    cnt_schools_in_dups_by_salesforce_id
from rule_applied
where sfdc_account_id is not null;



drop table if exists  lcom_data;
create temporary table lcom_data
DISTSTYLE KEY
DISTKEY (organization_id)
SORTKEY (organization_id) as
    select
        o.organization_id,
        o.parent_organization_id,
        m.sfdc_account_id,
        m.salesforce_id,
        m.applied_rule,
        m.cnt_dist_org_id_group_by_salesforce_id,
        m.cnt_districts_in_dups_by_salesforce_id,
        m.cnt_schools_in_dups_by_salesforce_id
    from {{ source('dbo', 'organization') }} o
    left outer join lcom_sfdc_account_mapping m
    on o.organization_id = m.organization_id;






truncate table {{target.database}}.{{custom_schema}}.conformed_account_hierarchy;
insert into {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
with 
 account_keys as (
    select
        coalesce(lcom_data.organization_id, sfdc_data.account_id) as account_id,
        isnull(lcom_data.organization_id, '{{ var("default_ID") }}') as lcom_organization_id,
        case
          when len(lcom_data.parent_organization_id) < 1 then '{{ var("default_ID") }}'
          else lcom_data.parent_organization_id
        end as lcom_parent_organization_id,
        coalesce(
            lcom_data.sfdc_account_id,
            sfdc_data.account_id,
            '{{ var("default_ID") }}'
        ) as sfdc_account_id,
        isnull(sfdc_data.parent_id, '{{ var("default_ID") }}') as sfdc_parent_id,
        isnull(sfdc_data.ultimate_parent_id_c, '{{ var("default_ID") }}') as sfdc_ultimate_parent_id,
        lcom_data.salesforce_id,
        lcom_data.applied_rule,
        lcom_data.cnt_dist_org_id_group_by_salesforce_id,
        lcom_data.cnt_districts_in_dups_by_salesforce_id,
        lcom_data.cnt_schools_in_dups_by_salesforce_id
    from lcom_data
    full outer join stg_lcom_sfdc_account_keys as sfdc_data
        on lcom_data.sfdc_account_id = sfdc_data.account_id
    --    

)
, districts as (   
    -- LCom school: use its LCom parent organization as the district.
    select 
        sch.account_id,
        dist.account_id as conformed_district_id,
        sch.sfdc_ultimate_parent_id,
        dist.sfdc_ultimate_parent_id as district_sfdc_ultimate_parent_id
    from account_keys sch
    join account_keys dist
        on dist.lcom_organization_id = sch.lcom_parent_organization_id
    where sch.lcom_parent_organization_id != '{{ var("default_ID") }}'
    --
    union all
    -- LCom district/root: use the account itself as the district.
    select 
        account_id,
        account_id as conformed_district_id,
        sfdc_ultimate_parent_id,
        sfdc_ultimate_parent_id as district_sfdc_ultimate_parent_id
    from account_keys
    where lcom_organization_id != '{{ var("default_ID") }}'
        and lcom_parent_organization_id = '{{ var("default_ID") }}'
    --
    union all
    -- Salesforce-only child: use its Salesforce parent as the district.
    select 
        sch.account_id,
        dist.account_id as conformed_district_id,
        sch.sfdc_ultimate_parent_id,
        dist.sfdc_ultimate_parent_id as district_sfdc_ultimate_parent_id
    from account_keys sch
    join account_keys dist
        on dist.sfdc_account_id = sch.sfdc_parent_id
    where sch.lcom_organization_id = '{{ var("default_ID") }}'
        and sch.sfdc_parent_id != '{{ var("default_ID") }}'
    --
    union all
    -- Salesforce-only root: use the account itself as the district.
    select 
        account_id,
        account_id as conformed_district_id,
        sfdc_ultimate_parent_id,
        sfdc_ultimate_parent_id as district_sfdc_ultimate_parent_id
    from account_keys
    where lcom_organization_id = '{{ var("default_ID") }}'
        and sfdc_parent_id = '{{ var("default_ID") }}'
)
, resolved_hierarchy as (
    select
        districts.account_id,
        districts.conformed_district_id,
        case
            when customer.account_id is not null then customer.account_id
            else districts.conformed_district_id
        end as conformed_customer_id
    from districts
    left join account_keys customer
        on customer.sfdc_account_id = 
        case
            when districts.district_sfdc_ultimate_parent_id != '{{ var("default_ID") }}'
                then districts.district_sfdc_ultimate_parent_id --districts sfdc ultimate parent takes precedence if different from school     
            when districts.sfdc_ultimate_parent_id != '{{ var("default_ID") }}'
                then districts.sfdc_ultimate_parent_id --schools sfdc ultimate parent
        end
)
select
    resolved_hierarchy.account_id::varchar(300) as account_id,
    account.lcom_organization_id::varchar(300),
    case
    when account.salesforce_id is not null then account.salesforce_id
    when account.salesforce_id is null and account.sfdc_account_id is not null then replace(account.sfdc_account_id,'dup-','')
    when account.lcom_organization_id = '{{ var("default_ID") }}' then resolved_hierarchy.account_id
    else'{{ var("default_ID") }}'
    end::varchar(300) as salesforce_id,
    account.sfdc_account_id::varchar(300) as sfdc_account_id,
    resolved_hierarchy.conformed_district_id::varchar(300) as conformed_district_id,
    resolved_hierarchy.conformed_customer_id::varchar(300) as conformed_customer_id,    
        account.applied_rule::varchar(300),
        account.cnt_dist_org_id_group_by_salesforce_id::integer,
        account.cnt_districts_in_dups_by_salesforce_id::integer,
        account.cnt_schools_in_dups_by_salesforce_id::integer ,
        ploaddate::timestamp as loaddate
from resolved_hierarchy
join account_keys account
on account.account_id = resolved_hierarchy.account_id;

/*resolving single customer per district:

1. LCom Org District is not linked to Salesforce Account
2. It's child LCom Org school is linked to a Salesforce Account

- If there is just one SFDC Ultimate Parent for all such 
child LCom Org schools linked to Salesforce Account
than this SFDC Ultimate Parent becomes a customer for all
LCom Org District  not linked to Salesforce Account

- If there are different SFDC Ultimate Parents for all such 
child LCom Org schools linked to Salesforce Account
than LCom Org District is the Customer for all schools


*/


-- 1. If one LCom district has more than one Salesforce-derived customer, LCom-only records should use the LCom district itself as customer.
with ambiguous_districts as (
    select
        conformed_district_id
    from {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
    where  sfdc_account_id <> '{{ var("default_ID") }}'
    group by conformed_district_id    having count(distinct conformed_customer_id) > 1
)
update {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
set conformed_customer_id = ambiguous_districts.conformed_district_id
from ambiguous_districts
where {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.conformed_district_id = ambiguous_districts.conformed_district_id;


-- 2. If one LCom district has only one Salesforce-derived customer

with district_customer as (
    select
        conformed_district_id,
        max(conformed_customer_id) as conformed_customer_id
    from {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
    where sfdc_account_id <> '{{ var("default_ID") }}'
      and conformed_customer_id <> conformed_district_id
    group by conformed_district_id
    having count(distinct conformed_customer_id) = 1
)
,districts_with_issues as (select
conformed_district_id
from {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
group by conformed_district_id
having count(distinct conformed_customer_id)>1)
,data as (
select
    a.account_id
    ,dc.conformed_customer_id as new_customer_id
from {{target.database}}.{{custom_schema}}.conformed_account_hierarchy a
join districts_with_issues dwi
on a.account_id = dwi.conformed_district_id
join district_customer dc
on a.conformed_district_id = dc.conformed_district_id
  )
  update {{target.database}}.{{custom_schema}}.conformed_account_hierarchy
  set conformed_customer_id = data.new_customer_id
  from data 
  where data.account_id = {{target.database}}.{{custom_schema}}.conformed_account_hierarchy.conformed_district_id;

drop table if exists  stg_lcom_sfdc_account_keys;
drop table if exists  int_lcom_sfdc_account_fallback;
drop table if exists  int_lcom_sfdc_account_mapping_base;
drop table if exists  lcom_sfdc_account_mapping;
drop table if exists  lcom_data;

END;

$$
;


{% endset %}

{{ run_DDL('lc_load_conformed_account_hierarchy', create_sp_operation) }}

{% endmacro %} 