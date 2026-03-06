-- This is a SQL to create slowly changing dimension type 2 table for product categories. But it's based on IDs and too complex to maintain as a query.
-- A spreadsheet (seed file) is used to maintain the product categories dimension.
with data as (
--SKU Groups
select
 ltrim(rtrim(sku_name)) product_name,
'EasyCode' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
auditcreatedate startdate
from
{{ ref("dim_lcom_sku") }}
where 
sku_id in
(
'78280278-838d-4886-ad55-969cf7eb8410'  --EasyCode Foundations Suite + Python
,'462e4303-59cd-4db4-9a1d-7334981d5432' --EasyCode Pillars Coding Fundamentals
,'359c7fcc-f048-4502-91fb-756f79e2ef39' --EasyCode Pillars: Python Suitev
)
--
union all
--
select
'EasyTech' product_name,
'EasyTech+' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='4801cdad-c7d2-4312-8ae9-3138629abe21' -- EasyTech
--
union all 
--
select
'EasyTech' product_name,
'EasyTech+' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='034d0380-d1a7-4fc2-8c5d-634bef7170d2' -- EasyTech Curriculum
--
union all
--
select
'TechApps for Texas' product_name,
'EasyTech+' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='67d69942-9f60-4203-a793-0fe7da6d8567' -- EasyTech Texas Edition
union all 
select
'TechApps for Texas' product_name,
'EasyTech+' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='087a6038-716e-439f-9795-a7f5371c5d6b' --  TechApps for Texas
union all 
select
 ltrim(rtrim(sku_name)) product_name,
'EasyTech+' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
auditcreatedate
from
{{ ref("dim_lcom_sku") }}
where 
sku_id in
(
'e2faa5e0-68c6-44be-b82b-c523be5b3567'  --Online Safety & Digital Citizenship
,'e0829418-578f-4fcb-b066-4c8202dc8932' --EasyTech Keyboarding & Word Processing
)
--Subgroups
union all
--
select
 ltrim(rtrim(sku_name)) product_name,
case 
when sku_name ilike '%pillars%' then 'EasyCode Pillars'
when sku_name ilike '%foundations%'  then 'EasyCode Foundations'
end as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
auditcreatedate
from
{{ ref("dim_lcom_sku") }}
where 
sku_id in
(
'78280278-838d-4886-ad55-969cf7eb8410'  --EasyCode Foundations Suite + Python
,'462e4303-59cd-4db4-9a1d-7334981d5432' --EasyCode Pillars Coding Fundamentals
,'359c7fcc-f048-4502-91fb-756f79e2ef39' --EasyCode Pillars: Python Suitev
)
--
union all
--
select
'EasyTech' product_name,
'EasyTech' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='4801cdad-c7d2-4312-8ae9-3138629abe21' -- EasyTech
--
union all 
--
select
'EasyTech' product_name,
'EasyTech' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='034d0380-d1a7-4fc2-8c5d-634bef7170d2' -- EasyTech Curriculum
--
--
union all
--
select
'TechApps for Texas' product_name,
'TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='67d69942-9f60-4203-a793-0fe7da6d8567' -- EasyTech Texas Edition
union all 
select
'TechApps for Texas' product_name,
'TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='087a6038-716e-439f-9795-a7f5371c5d6b' --  TechApps for Texas
--
union all
--
select
 ltrim(rtrim(sku_name)) product_name,
case 
when sku_name = 'Online Safety & Digital Citizenship' then 'Online Safety & Digital Citizenship'
when sku_name = 'EasyTech Keyboarding & Word Processing' then 'Keyboarding & Word Processing'
end  as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
auditcreatedate
from
{{ ref("dim_lcom_sku") }}
where 
sku_id in
(
'e2faa5e0-68c6-44be-b82b-c523be5b3567'  --Online Safety & Digital Citizenship
,'e0829418-578f-4fcb-b066-4c8202dc8932' --EasyTech Keyboarding & Word Processing
)
--EasyTech and TechApps for Texas
union all 
--
select
'EasyTech' product_name,
'EasyTech & TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='4801cdad-c7d2-4312-8ae9-3138629abe21' -- EasyTech
--
union all 
--
select
'EasyTech' product_name,
'EasyTech & TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='034d0380-d1a7-4fc2-8c5d-634bef7170d2' -- EasyTech Curriculum
--
union all
--
select
'TechApps for Texas' product_name,
'EasyTech & TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2023/2024') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='67d69942-9f60-4203-a793-0fe7da6d8567' -- EasyTech Texas Edition
union all 
select
'TechApps for Texas' product_name,
'EasyTech & TechApps for Texas' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
(select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }} where SchoolYear='2024/2025') startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='087a6038-716e-439f-9795-a7f5371c5d6b' --  TechApps for Texas
--
union all
--
select
'Digital Literacy Assessments' product_name,
'Assessments' as product_category,
'sku' product_type,
sku_name product_original_name,
sku_id product_original_id,
auditcreatedate startdate
from
{{ ref("dim_lcom_sku") }}
where sku_id='7ff89407-6fb0-4943-9cac-ac63e35df034' -- Digital Literacy Assessments
--
--Sequences
--
union all 
--
select
ltrim(rtrim(sequence_name)) as product_name,
ltrim(rtrim(sequence_name)) as product_category,
'seq'as product_type,
sequence_name as product_original_name,
sequence_id as product_original_id,
auditcreatedate as startdate
from {{ ref("dim_sequence") }} seq
where 
(sequence_name = 'Texas Blended Learning Path'  or
sequence_name = 'Texas Essentials Blended Learning Path'  or  
sequence_name = 'Common Sense Education'  or  
sequence_name = 'Digital Safety Foundation' )   
and sequence_id!='f348ada8-2c25-42a9-bca5-e911ef34f1c0' --(2 Digital Safety Foundation, only one, first by creation time included)
and is_custom=false
--Digital Readiness
union all
--
select
ltrim(rtrim(sequence_name)) as product_name,
'Digital Readiness' as product_category,
'seq' as product_type,
sequence_name as product_original_name,
sequence_id as product_original_id,
dim_school_year.SchoolYear_StartDate as startdate
from {{ ref("dim_sequence") }} seq
join (select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }}) dim_school_year
on to_char(auditcreatedate,'yyyy') = to_char(dim_school_year.SchoolYear_StartDate,'yyyy')
where sequence_name ILIKE '%Digital Readiness%'
and is_custom=false
--Tech Quest
union all
--
select
ltrim(rtrim(replace(replace(sequence_name, '2023-2024',''), '2024-2025',''))) as product_name,
'Tech Quest' as product_category,
'seq' as product_type,
sequence_name as product_original_name,
sequence_id as product_original_id,
dim_school_year.SchoolYear_StartDate as startdate
from {{ ref("dim_sequence") }} seq
join (select distinct SchoolYear_StartDate from {{ ref("dim_calendar") }}) dim_school_year
on to_char(auditcreatedate,'yyyy') = to_char(dim_school_year.SchoolYear_StartDate,'yyyy')
where sequence_name ILIKE '%Tech Quest%' 
and is_custom=false
and auditcreatedate>'2023-01-01'::date
--Sub Groups
union all
--
select
ltrim(rtrim(sequence_name)) as product_name,
'EasyTech Student-Driven Learning Path' as product_category, 
'seq' as product_type,
sequence_name as product_original_name,
sequence_id as product_original_id,
auditcreatedate as startdate
from {{ ref("dim_sequence") }} seq
where sequence_name='EasyTech Student-Driven Learning Path'
and auditcreatedate>'2023-01-01'::date
and is_custom=false
--
union all
--
select
ltrim(rtrim(sequence_name)) as product_name,
'EasyTech Blended Learning Path' as product_category, 
'seq' as product_type,
sequence_name as product_original_name,
sequence_id as product_original_id,
auditcreatedate as startdate
from {{ ref("dim_sequence") }} seq
where sequence_name='EasyTech Blended Learning Path'
and is_custom=false
)
select 
md5(product_category+'-'+product_name) product_category_id,
product_name,
product_category,
product_type,
product_original_name,
product_original_id,
startdate
from data
order by product_category



