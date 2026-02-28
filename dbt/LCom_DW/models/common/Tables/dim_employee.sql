{{
    config(

        materialized='table',
        sort='employee_id', 
        dist='all'
 )  
}}

with 
rawdata_user as (
select
{{ safe_select_list_from_profiles(
        table_name='user',
        alias='sfdc_user',
        used_columns=['id','name','alias','community_nickname','username','department','title','email','is_active','last_login_date','created_date','last_modified_date','role_c'],
        profile_src=('profiles','vw_sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'
    ) }}
from {{ source("fivetran_salesforce_quickstart","user") }} sfdc_user
)
,data as 
(
select
stg.id as employee_id,
isnull(stg.name, '{{ var("default_varchar") }}') as name,
isnull(stg.alias, '{{ var("default_varchar") }}') as alias,
isnull(stg.community_nickname, '{{ var("default_varchar") }}') as community_nickname,
isnull(stg.username, '{{ var("default_varchar") }}') as username,
isnull(stg.department, '{{ var("default_varchar") }}') as department,
isnull(stg.title, '{{ var("default_varchar") }}') as title,
isnull(stg.role_c, '{{ var("default_varchar") }}') as user_role,
isnull(stg.email, '{{ var("default_varchar") }}') as email,
isnull(stg.is_active, {{ var("default_boolean") }}) as is_active,
isnull(stg.last_login_date	 AT TIME ZONE 'PST',	 '{{ var("default_date") }}') as last_login_date,
isnull(stg.created_date	 AT TIME ZONE 'PST',	 '{{ var("default_date") }}') as created_date,
isnull(stg.last_modified_date	 AT TIME ZONE 'PST',	 '{{ var("default_date") }}') as last_modified_date
from rawdata_user stg
union all
select 
'{{ var("default_ID") }}' as  employee_id,
'{{ var("default_varchar") }}' as name,
'{{ var("default_varchar") }}' as alias,
'{{ var("default_varchar") }}' as community_nickname,
'{{ var("default_varchar") }}' as username,
'{{ var("default_varchar") }}' as department,
'{{ var("default_varchar") }}' as title,
'{{ var("default_varchar") }}' as user_role,
'{{ var("default_varchar") }}' as email,
{{ var("default_boolean") }} as is_active,
'{{ var("default_date") }}' as last_login_date,
'{{ var("default_date") }}' as created_date,
'{{ var("default_date") }}' as last_modified_date 
from {{ ref('dual') }}
)
select
employee_id::VARCHAR(300),
name::VARCHAR(400),
alias::VARCHAR(25),
community_nickname::VARCHAR(400),
username::VARCHAR(240),
department::VARCHAR(240),
title::VARCHAR(240),
user_role::VARCHAR(240),
email::VARCHAR(400),
is_active::BOOLEAN,
last_login_date::TIMESTAMP WITHOUT TIME ZONE,
created_date::TIMESTAMP WITHOUT TIME ZONE,
last_modified_date::TIMESTAMP WITHOUT TIME ZONE,
'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from data