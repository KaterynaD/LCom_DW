{{
    config(

        materialized='table',        
        dist='account_id', 
        sort='account_id',
        post_hook=['{{ update_DIM_ACCOUNT_HISTORY_changed_UK() }}']                         
        )
}}



with sch as (
select
    parent_id,
    BOOL_OR(state_initiative_c) as school_state_initiative_c,
    BOOL_OR(district_state_initiative_c) as school_district_state_initiative_c
FROM {{ source('fivetran_salesforce_quickstart', 'account') }}
where isnull(record_type_c,'{{ var("default_varchar") }}') != 'L'
group by parent_id
)
, sfdc_data as (
  select 
    --SFDC Account columns
    {{ safe_select_list_from_profiles(
        table_name='account',
        alias='sfdc_account',
        used_columns=[          
    'Id',
'name',
'alt_phone_c',
'billing_country',
'billing_country_code',
'billing_state',
'billing_state_code',
'category_c',
'churn_date_c',
'churned_opportunity_id_c',
'county_name_c',
'created_by_id',
'created_date',
'current_renewal_arr_c',
'customer_type_c',
'customer_level_c',
'customer_level_override_c',
'data_quality_description_c',
'data_quality_score_c',
'de_identified_district_c',
'description',
'district_enrollment_c',
'district_k_8_enrollment_c',
'district_state_initiative_c',
'grade_levels_c',
'k_12_enrollment_c',
'k_5_enrollment_c',
'k_8_enrollment_c',
'kindergarten_enrollment_c',
'last_modified_by_id',
'last_modified_date',
'last_name_c',
'lcom_account_c',
'lcom_account_class_c',
'lcom_account_count_c',
'lcom_organization_c',
'lcom_organization_count_c',
'lcom_organization_has_parent_c',
'name_with_lcom_organization_info_c',
'owner_id',
'parent_account_owner_c',
'parent_churned_c',
'parent_id',
'parent_name_proper_case_c',
'parent_owner_id_c',
'phone',
'pre_k_enrollment_c',
'record_type_c',
'school_enrollment_c',
'state_initiative_c',
'state_program_eligible_c',
'test_account_c',
'ultimate_account_owner_c',
'ultimate_parent_account_c',
'ultimate_parent_billing_state_c',
'ultimate_parent_id_c',
'urban_rural_c'
        ],
        profile_src=('profiles','sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'
    ) }}
    ,sfdc_user."name" as owner_name_text_c,
    --School (some child accounts info)
    sch.school_state_initiative_c as state_initiative_school,
    sch.school_district_state_initiative_c as district_state_initiative_school,
    --District (some parent account info)
    dist.state_initiative_c as state_initiative_district,
    dist.district_state_initiative_c as district_state_initiative_district,
    --
    lower(loc.lcom_platform_organization_id_c) lcom_organization_id,
    --
    sfdc_ultimate_parent.sfdc_current_renewal_arr as sfdc_ultimate_parent_current_renewal_arr
    --
FROM {{ source('fivetran_salesforce_quickstart', 'account') }} sfdc_account
left outer join {{ source('fivetran_salesforce_quickstart', 'user') }} sfdc_user
on sfdc_account.owner_id= sfdc_user.id
left outer join {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }} loc
on sfdc_account.lcom_organization_c = loc.id
left outer join sch 
on sfdc_account.id=sch.parent_id
left outer join {{ source('fivetran_salesforce_quickstart', 'account') }} dist
on sfdc_account.parent_id=dist.id
left outer join {{ ref("sfdc_ultimate_parent_accounts_data")}} sfdc_ultimate_parent
on sfdc_ultimate_parent.sfdc_ultimate_parent_id = sfdc_account.id


)
, LCOM_data as (
  select 
    --LCOM columns
    o.organization_id,
    o.organization_name,
    o.organization_type,
    case when len(o.parent_organization_id)<1 then null else o.parent_organization_id end as parent_organization_id,
    p.organization_name  as parent_organization_name,
    o.is_trial,
    o.is_demo,
    o.postal_code,
    o.state_province_key,
    sp.state_province_code,
    sp.state_province_name,
    o.country_code,
    c.country_name,
    c.alpha3_code,
    c.numeric_code,
    o.external_sis_id,
    o.nces_id,
    o.created_datetime,
    o.modified_datetime,
    o.deleted_datetime,
    m.salesforce_id,
    m.SFDC_Account_Id
FROM {{ source("dbo","organization") }}  o
left outer join {{ source("dbo","organization") }}  p
on o.parent_organization_id = p.organization_id
--
left outer join {{ source("dbo","state_province") }}  sp
on sp.state_province_key=o.state_province_key
--
left outer join {{ source("dbo","country") }}  c
on c.country_code=o.country_code
-- mapping to Salesforce Accounts
left outer join {{ ref("lcom_sfdc_account_mapping") }} m
on o.organization_id=m.organization_id

)

, data as (
select
    coalesce(LCOM_data.organization_id, SFDC_data.Id) as account_id,
--LCOM columns
isnull(LCOM_data.organization_id, '{{ var("default_ID") }}') as  lcom_organization_id,
isnull(LCOM_data.organization_name, '{{ var("default_varchar") }}') as  lcom_organization_name,
isnull(LCOM_data.organization_type, '{{ var("default_varchar") }}') as  lcom_organization_type,
isnull(LCOM_data.parent_organization_id, '{{ var("default_ID") }}') as  lcom_parent_organization_id,
isnull(LCOM_data.parent_organization_name, '{{ var("default_varchar") }}') as  lcom_parent_organization_name,
isnull(LCOM_data.is_trial, {{ var("default_boolean") }}) as  lcom_trial,
isnull(LCOM_data.is_demo, {{ var("default_boolean") }}) as  lcom_demo,
isnull(LCOM_data.postal_code, '{{ var("default_varchar") }}') as  lcom_postal_code,
isnull(LCOM_data.state_province_key, '{{ var("default_varchar") }}') as  lcom_state_province_key,
isnull(LCOM_data.state_province_code, '{{ var("default_varchar") }}') as  lcom_state_province_code,
isnull(LCOM_data.state_province_name, '{{ var("default_varchar") }}') as  lcom_state_province_name,
isnull(LCOM_data.country_code, '{{ var("default_varchar") }}')  as lcom_country_code,
isnull(LCOM_data.country_name, '{{ var("default_varchar") }}') as  lcom_country_name,
isnull(LCOM_data.alpha3_code, '{{ var("default_varchar") }}') as  lcom_alpha3_code,
isnull(LCOM_data.numeric_code, '{{ var("default_varchar") }}') as  lcom_numeric_code,
isnull(LCOM_data.external_sis_id, '{{ var("default_varchar") }}') as  lcom_external_sis_id,
isnull(LCOM_data.nces_id, '{{ var("default_varchar") }}')  as lcom_nces_id,
isnull(LCOM_data.created_datetime, '{{ var("default_date") }}') as  lcom_created_datetime,
isnull(LCOM_data.modified_datetime, '{{ var("default_date") }}')  as lcom_modified_datetime,
isnull(LCOM_data.deleted_datetime, '{{ var("default_date") }}')  as lcom_deleted_datetime,
--SFDC columns
coalesce(LCOM_data.SFDC_account_id, SFDC_data.Id, '{{ var("default_varchar") }}') as SFDC_account_id,
isnull(SFDC_data.name, '{{ var("default_varchar") }}') as SFDC_name,
isnull(SFDC_data.alt_phone_c, '{{ var("default_varchar") }}') as SFDC_alt_phone,
isnull(sfdc_data.billing_country, '{{ var("default_varchar") }}') as SFDC_billing_country,
isnull(sfdc_data.billing_country_code, '{{ var("default_varchar") }}') as SFDC_billing_country_code,
isnull(SFDC_data.billing_state, '{{ var("default_varchar") }}') as SFDC_billing_state,
isnull(SFDC_data.billing_state_code, '{{ var("default_varchar") }}') as SFDC_billing_state_code,
isnull(SFDC_data.category_c, '{{ var("default_varchar") }}') as SFDC_category,
isnull(SFDC_data.churn_date_c, '{{ var("default_date") }}') as SFDC_churn_date,
isnull(SFDC_data.churned_opportunity_id_c, '{{ var("default_varchar") }}') as SFDC_churned_opportunity_id,
isnull(SFDC_data.county_name_c, '{{ var("default_varchar") }}') as SFDC_county_name,
isnull(SFDC_data.created_by_id, '{{ var("default_varchar") }}') as SFDC_created_by_id,
isnull(SFDC_data.created_date AT TIME ZONE 'PST', '{{ var("default_date") }}') as SFDC_created_date,
isnull(SFDC_data.current_renewal_arr_c, {{ var("default_numeric") }}) as SFDC_current_renewal_arr,
isnull(SFDC_data.customer_type_c, '{{ var("default_varchar") }}') as SFDC_customer_type,
isnull(SFDC_data.customer_level_c, '{{ var("default_varchar") }}') as SFDC_customer_level,
isnull(SFDC_data.customer_level_override_c, '{{ var("default_varchar") }}') as SFDC_customer_level_override,
isnull(SFDC_data.grade_levels_c, '{{ var("default_varchar") }}') as SFDC_grade_levels,
isnull(SFDC_data.data_quality_description_c, '{{ var("default_varchar") }}') as SFDC_data_quality_description,
isnull(SFDC_data.data_quality_score_c, {{ var("default_numeric") }}) as SFDC_data_quality_score,
isnull(SFDC_data.de_identified_district_c, {{ var("default_boolean") }}) as SFDC_de_identified_district,
isnull(SFDC_data.description, '{{ var("default_varchar") }}') as SFDC_description,
isnull(SFDC_data.district_enrollment_c, {{ var("default_numeric") }}) as SFDC_district_enrollment,
isnull(SFDC_data.district_state_initiative_c, {{ var("default_boolean") }}) as SFDC_district_state_initiative,
isnull(SFDC_data.k_12_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_12_enrollment,
isnull(SFDC_data.k_5_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_5_enrollment,
isnull(SFDC_data.k_8_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_8_enrollment,
isnull(SFDC_data.kindergarten_enrollment_c, {{ var("default_numeric") }}) as SFDC_kindergarten_enrollment,
isnull(SFDC_data.pre_k_enrollment_c, {{ var("default_numeric") }}) as SFDC_pre_k_enrollment,
isnull(SFDC_data.last_modified_by_id, '{{ var("default_varchar") }}') as SFDC_last_modified_by_id,
isnull(SFDC_data.last_modified_date AT TIME ZONE 'PST', '{{ var("default_date") }}') as SFDC_last_modified_date,
isnull(SFDC_data.last_name_c, '{{ var("default_varchar") }}') as SFDC_last_name,
isnull(SFDC_data.lcom_account_c, '{{ var("default_varchar") }}') as SFDC_lcom_account,
isnull(SFDC_data.lcom_account_class_c, '{{ var("default_varchar") }}') as SFDC_lcom_account_class,
isnull(SFDC_data.lcom_account_count_c, {{ var("default_numeric") }}) as SFDC_lcom_account_count,
isnull(SFDC_data.lcom_organization_c, '{{ var("default_varchar") }}') as SFDC_lcom_organization,
isnull(SFDC_data.lcom_organization_count_c, {{ var("default_numeric") }}) as SFDC_lcom_organization_count,
isnull(SFDC_data.lcom_organization_has_parent_c, {{ var("default_boolean") }}) as SFDC_lcom_organization_has_parent,
isnull(SFDC_data.name_with_lcom_organization_info_c, '{{ var("default_varchar") }}') as SFDC_name_with_lcom_organization_info,
isnull(SFDC_data.owner_id, '{{ var("default_varchar") }}') as SFDC_owner_id,
isnull(SFDC_data.owner_name_text_c, '{{ var("default_varchar") }}') as SFDC_owner_name_text,
isnull(SFDC_data.parent_account_owner_c, '{{ var("default_varchar") }}') as SFDC_parent_account_owner,
isnull(SFDC_data.parent_churned_c, {{ var("default_boolean") }}) as SFDC_parent_churned,
isnull(SFDC_data.parent_id, '{{ var("default_ID") }}') as SFDC_parent_id,
isnull(SFDC_data.parent_name_proper_case_c, '{{ var("default_varchar") }}') as SFDC_parent_name,
isnull(SFDC_data.parent_owner_id_c, '{{ var("default_varchar") }}') as SFDC_parent_owner_id,
isnull(SFDC_data.phone, '{{ var("default_varchar") }}') as SFDC_phone,
isnull(SFDC_data.record_type_c, '{{ var("default_varchar") }}') as SFDC_record_type,
isnull(SFDC_data.school_enrollment_c, {{ var("default_numeric") }}) as SFDC_school_enrollment,
isnull(SFDC_data.state_initiative_c, {{ var("default_boolean") }}) as SFDC_state_initiative,
isnull(SFDC_data.state_program_eligible_c, {{ var("default_boolean") }}) as SFDC_state_program_eligible,
isnull(SFDC_data.ultimate_account_owner_c, '{{ var("default_varchar") }}') as SFDC_ultimate_account_owner,
isnull(SFDC_data.ultimate_parent_account_c, '{{ var("default_varchar") }}') as SFDC_ultimate_parent_account,
isnull(SFDC_data.ultimate_parent_billing_state_c, '{{ var("default_varchar") }}') as SFDC_ultimate_parent_billing_state,
isnull(SFDC_data.ultimate_parent_id_c, '{{ var("default_ID") }}') as SFDC_ultimate_parent_id,
isnull(SFDC_data.urban_rural_c, '{{ var("default_varchar") }}') as SFDC_urban_rural,
isnull(SFDC_data.lcom_organization_id, '{{ var("default_varchar") }}') as  SFDC_lcom_organization_id,
--School (some child accounts info)
isnull(SFDC_data.state_initiative_school, {{ var("default_boolean") }}) as SFDC_state_initiative_school,
isnull(SFDC_data.district_state_initiative_school, {{ var("default_boolean") }}) as SFDC_district_state_initiative_school,
--District (some parent account info)
isnull(SFDC_data.state_initiative_district, {{ var("default_boolean") }}) as SFDC_state_initiative_district,
isnull(SFDC_data.district_state_initiative_district, {{ var("default_boolean") }}) as SFDC_district_state_initiative_district,
--Calculated
case when (SFDC_data.grade_levels_c = 'High School' or (SFDC_data.grade_levels_c is null and  SFDC_data.k_12_enrollment_c>0 and SFDC_data.k_8_enrollment_c=0)) then True else False end as isHighSchool,
isnull(sfdc_ultimate_parent_current_renewal_arr, {{ var("default_numeric") }}) as SFDC_ultimate_parent_current_renewal_arr
--
FROM LCOM_data
--
full outer join SFDC_data
on LCOM_data.salesforce_id = SFDC_data.Id



/*add default values for the first run only*/

union all
/*default*/
select 
--LCOM columns
'{{ var("default_ID") }}' as account_id,
'{{ var("default_ID") }}' as lcom_organization_id,
'{{ var("default_varchar") }}' as  lcom_organization_name,
'{{ var("default_varchar") }}' as  lcom_organization_type,
'{{ var("default_ID") }}' as  lcom_parent_organization_id,
'{{ var("default_varchar") }}' as  lcom_parent_organization_name,
{{ var("default_boolean") }} as  lcom_trial,
{{ var("default_boolean") }} as  lcom_demo,
'{{ var("default_varchar") }}' as  lcom_postal_code,
'{{ var("default_varchar") }}' as  lcom_state_province_key,
'{{ var("default_varchar") }}' as  lcom_state_province_code,
'{{ var("default_varchar") }}' as  lcom_state_province_name,
'{{ var("default_varchar") }}' as  lcom_country_code,
'{{ var("default_varchar") }}' as  lcom_country_name,
'{{ var("default_varchar") }}' as  lcom_alpha3_code,
'{{ var("default_varchar") }}' as  lcom_numeric_code,
'{{ var("default_varchar") }}' as  lcom_external_sis_id,
'{{ var("default_varchar") }}' as  lcom_nces_id,
'{{ var("default_date") }}' lcom_created_datetime,
'{{ var("default_date") }}' lcom_modified_datetime,
'{{ var("default_date") }}' lcom_deleted_datetime,
--SFDC columns
'{{ var("default_ID") }}' as SFDC_account_id,
'{{ var("default_varchar") }}' as SFDC_name,
'{{ var("default_varchar") }}' as SFDC_alt_phone ,
'{{ var("default_varchar") }}' as SFDC_billing_country,
'{{ var("default_varchar") }}' as SFDC_billing_country_code,
'{{ var("default_varchar") }}'  as SFDC_billing_state,
'{{ var("default_varchar") }}'  as SFDC_billing_state_code,
'{{ var("default_varchar") }}' as SFDC_category ,
'{{ var("default_date") }}'    as SFDC_churn_date,
'{{ var("default_varchar") }}' as SFDC_churned_opportunity_id,
'{{ var("default_varchar") }}' as SFDC_county_name ,
'{{ var("default_varchar") }}' as SFDC_created_by_id ,
'{{ var("default_date") }}' as SFDC_created_date ,
{{ var("default_numeric") }}   as   SFDC_current_renewal_arr ,
'{{ var("default_varchar") }}' as SFDC_customer_type ,
'{{ var("default_varchar") }}' as SFDC_customer_level,
'{{ var("default_varchar") }}' as SFDC_customer_level_override,
'{{ var("default_varchar") }}' as SFDC_grade_levels ,
'{{ var("default_varchar") }}' as SFDC_data_quality_description ,
{{ var("default_numeric") }}   as   SFDC_data_quality_score ,
{{ var("default_boolean") }}   as   SFDC_de_identified_district ,
'{{ var("default_varchar") }}' as SFDC_description ,
{{ var("default_numeric") }}   as   SFDC_district_enrollment ,
{{ var("default_boolean") }}   as   SFDC_district_state_initiative ,
{{ var("default_numeric") }}   as   SFDC_k_12_enrollment ,
{{ var("default_numeric") }}   as   SFDC_k_5_enrollment ,
{{ var("default_numeric") }}   as   SFDC_k_8_enrollment ,
{{ var("default_numeric") }}   as   SFDC_kindergarten_enrollment ,
{{ var("default_numeric") }}   as   SFDC_pre_k_enrollment ,
'{{ var("default_varchar") }}' as SFDC_last_modified_by_id ,
'{{ var("default_date") }}' as SFDC_last_modified_date ,
'{{ var("default_varchar") }}' as SFDC_last_name ,
'{{ var("default_varchar") }}' as SFDC_lcom_account ,
'{{ var("default_varchar") }}' as SFDC_lcom_account_class ,
{{ var("default_numeric") }}   as   SFDC_lcom_account_count ,
'{{ var("default_varchar") }}' as SFDC_lcom_organization ,
{{ var("default_numeric") }}   as   SFDC_lcom_organization_count ,
{{ var("default_boolean") }}   as   SFDC_lcom_organization_has_parent ,
'{{ var("default_varchar") }}' as SFDC_name_with_lcom_organization_info ,
'{{ var("default_varchar") }}' as SFDC_owner_id ,
'{{ var("default_varchar") }}' as SFDC_owner_name_text ,
'{{ var("default_varchar") }}' as SFDC_parent_account_owner ,
{{ var("default_boolean") }}   as   SFDC_parent_churned ,
'{{ var("default_ID") }}'      as SFDC_parent_id ,
'{{ var("default_varchar") }}' as SFDC_parent_name ,
'{{ var("default_varchar") }}' as SFDC_parent_owner_id ,
'{{ var("default_varchar") }}' as SFDC_phone ,
'{{ var("default_varchar") }}' as SFDC_record_type ,
{{ var("default_numeric") }}   as   SFDC_school_enrollment ,
{{ var("default_boolean") }}   as   SFDC_state_initiative ,
{{ var("default_boolean") }}   as   SFDC_state_program_eligible ,
'{{ var("default_varchar") }}' as SFDC_ultimate_account_owner ,
'{{ var("default_varchar") }}' as SFDC_ultimate_parent_account ,
'{{ var("default_varchar") }}' as SFDC_ultimate_parent_billing_state ,
'{{ var("default_ID") }}' as SFDC_ultimate_parent_id ,
'{{ var("default_varchar") }}' as SFDC_urban_rural ,
'{{ var("default_varchar") }}'  as   SFDC_lcom_organization_id,
--School (some child accounts info)
{{ var("default_boolean") }} as SFDC_state_initiative_school,
{{ var("default_boolean") }} as SFDC_district_state_initiative_school,
--District (some parent account info)
{{ var("default_boolean") }} as SFDC_state_initiative_district,
{{ var("default_boolean") }} as SFDC_district_state_initiative_district,
--Calculated
{{ var("default_boolean") }} as isHighSchool,
{{ var("default_numeric") }} as SFDC_ultimate_parent_current_renewal_arr

)
select
    account_id::varchar(300),
    lcom_organization_id :: varchar(300),
    lcom_organization_name :: varchar(270),
    lcom_organization_type :: varchar(20),
    lcom_parent_organization_id :: varchar(300),
    lcom_parent_organization_name :: varchar(270),
    lcom_trial :: boolean,
    lcom_demo :: boolean,
    lcom_postal_code :: varchar(20),
    lcom_state_province_key :: varchar(20),
    lcom_state_province_code :: varchar(20),
    lcom_state_province_name :: varchar(50),
    lcom_country_code :: varchar(20),
    lcom_country_name :: varchar(70),
    lcom_alpha3_code :: varchar(20),
    lcom_numeric_code :: varchar(20),
    lcom_external_sis_id :: varchar(270),
    lcom_nces_id :: varchar(30),
    lcom_created_datetime :: timestamp,
    lcom_modified_datetime :: timestamp,
    lcom_deleted_datetime :: timestamp,
    sfdc_account_id :: varchar(300),
    sfdc_name :: varchar(780),
    sfdc_alt_phone :: varchar(130),
    sfdc_billing_country :: varchar(240),
    sfdc_billing_country_code :: varchar(30),
    sfdc_billing_state :: varchar(240),
    sfdc_billing_state_code :: varchar(30),
    sfdc_category :: varchar(780),
    sfdc_churn_date::date,
    sfdc_churned_opportunity_id:: varchar(765),
    sfdc_county_name :: varchar(780),
    sfdc_created_by_id :: varchar(30),
    sfdc_created_date :: timestamp,
    sfdc_current_renewal_arr :: numeric,
    sfdc_customer_type :: varchar(20),
    sfdc_customer_level :: varchar(765),
    sfdc_customer_level_override :: varchar(765),
    sfdc_grade_levels :: varchar(100),
    sfdc_data_quality_description :: varchar(70),
    sfdc_data_quality_score :: integer,
    sfdc_de_identified_district :: boolean,
    sfdc_description :: varchar(max),
    sfdc_district_state_initiative :: boolean,
    sfdc_district_enrollment :: double precision,
    sfdc_k_12_enrollment :: double precision,
    sfdc_k_5_enrollment :: double precision,
    sfdc_k_8_enrollment :: double precision,
    sfdc_kindergarten_enrollment :: double precision,    
    sfdc_pre_k_enrollment :: double precision,
    sfdc_last_modified_by_id :: varchar(30),
    sfdc_last_modified_date :: timestamp,
    sfdc_last_name :: varchar(780),
    sfdc_lcom_account :: varchar(30),
    sfdc_lcom_account_class :: varchar(780),
    sfdc_lcom_account_count :: bigint,
    sfdc_lcom_organization :: varchar(30),
    sfdc_lcom_organization_count :: bigint,
    sfdc_lcom_organization_has_parent :: boolean,
    sfdc_name_with_lcom_organization_info :: varchar(1280),
    sfdc_owner_id :: varchar(30),
    sfdc_owner_name_text :: varchar(380),
    sfdc_parent_account_owner :: varchar(380),
    sfdc_parent_churned :: boolean,
    sfdc_parent_id :: varchar(300),
    sfdc_parent_name :: varchar(370),
    sfdc_parent_owner_id :: varchar(30),
    sfdc_phone :: varchar(130),
    sfdc_record_type :: varchar(780),
    sfdc_school_enrollment :: double precision,
    sfdc_state_initiative :: boolean,
    sfdc_state_program_eligible :: boolean,
    sfdc_ultimate_account_owner :: varchar(380),
    sfdc_ultimate_parent_account :: varchar(780),
    sfdc_ultimate_parent_billing_state :: varchar(250),
    sfdc_ultimate_parent_id :: varchar(300),
    sfdc_urban_rural :: varchar(40),
    SFDC_lcom_organization_id :: varchar(300),
    sfdc_state_initiative_school :: boolean,
    sfdc_district_state_initiative_school :: boolean,
    sfdc_state_initiative_district :: boolean,
    sfdc_district_state_initiative_district :: boolean,
    --Calculated
    isHighSchool:: boolean,
    SFDC_ultimate_parent_current_renewal_arr :: numeric(38,10),
    '{{ var("loaddate") }}'::timestamp as loaddate
FROM data
