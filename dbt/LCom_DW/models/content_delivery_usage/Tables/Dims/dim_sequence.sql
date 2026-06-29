{{ config(
        
        materialized='table',
        dist='sequence_id',
        sort='sequence_name'
)
 }}

with data as (
select 
lower(s.SequenceId) Sequence_Id,
CASE
    WHEN s.SequenceName = 'Texas Blended Learning Path' THEN 'Texas Blended Learning Path'
    WHEN s.SequenceName = 'Texas Essentials Blended Learning Path' THEN 'Texas Essentials Blended Learning Path'    
    WHEN s.SequenceName = 'Digital Safety Foundation' THEN 'Digital Safety Foundation'    
    WHEN s.SequenceName = 'Common Sense Education' THEN 'Common Sense Education'          
    WHEN s.SequenceName ILIKE '%Tech Quest%' THEN 'Tech Quest'
    WHEN s.SequenceName ILIKE '%Capstone%' OR s.SequenceName ILIKE '%Certification%' THEN 'Pathways & Certifications'
    WHEN s.SequenceName ILIKE '%Digital Readiness%' THEN 'Digital Readiness'
    WHEN s.SequenceName ILIKE '%EasyTech%' THEN 'EasyTech'
    WHEN s.SequenceName ILIKE '%Project%' THEN 'Project-Based Learning'
    WHEN s.SequenceName ILIKE '%Python%' OR s.SequenceName ILIKE '%Code%' THEN 'Coding'
    WHEN s.SequenceName ILIKE '%AI%' OR s.SequenceName ILIKE '%Artificial Intelligence%' THEN 'AI & Emerging Tech'
    ELSE 'Other'
END AS Sequence_group,
CASE
    --Special
    WHEN s.SequenceName = 'Common Sense Education' THEN 'Common Sense Education'     
    WHEN s.SequenceName = 'Digital Safety Foundation' THEN 'Digital Safety Foundation'        
    -- EasyTech subgroups
    WHEN s.SequenceName = 'EasyTech Student-Driven Learning Path' THEN 'EasyTech Student-Driven Learning Path'
    WHEN s.SequenceName = 'EasyTech Blended Learning Path' THEN 'EasyTech Blended Learning Path'

    -- Tech Quest subgroups
    WHEN s.SequenceName ILIKE '%PreKindergarten%' OR s.SequenceName ILIKE '%Kindergarten%' OR s.SequenceName ILIKE '%1st%' OR s.SequenceName ILIKE '%2nd%' OR s.SequenceName ILIKE '%3rd%' OR s.SequenceName ILIKE '%4th%' OR s.SequenceName ILIKE '%5th%' THEN 'Tech Quest Elementary'
    WHEN s.SequenceName ILIKE '%6th%' OR s.SequenceName ILIKE '%7th%' OR s.SequenceName ILIKE '%8th%' THEN 'Tech Quest Middle School'
    WHEN s.SequenceName ILIKE '%9th%' OR s.SequenceName ILIKE '%10th%' OR s.SequenceName ILIKE '%11th%' OR s.SequenceName ILIKE '%12th%' THEN 'Tech Quest High School'

    -- Pathways & Certifications subgroups
    WHEN s.SequenceName ILIKE '%Capstone%' THEN 'Capstone Pathway'
    WHEN s.SequenceName ILIKE '%Certification%' THEN 'Certification Pathway'
    WHEN s.SequenceName ILIKE '%IT Specialist%' THEN 'IT Specialist'
    WHEN s.SequenceName ILIKE '%PCA%' THEN 'PCA Certification'

    -- Project-Based Learning subgroups
    WHEN s.SequenceName ILIKE '%Math%' THEN 'Projects for Math'
    WHEN s.SequenceName ILIKE '%ELA%' THEN 'Projects for ELA'
    WHEN s.SequenceName ILIKE '%Science%' THEN 'Projects for Science'
    WHEN s.SequenceName ILIKE '%Social Studies%' THEN 'Projects for Social Studies'

    -- Digital Readiness subgroups
    WHEN s.SequenceName ILIKE '%Level K%' THEN 'Level K'
    WHEN s.SequenceName ILIKE '%Level 1%' OR s.SequenceName ILIKE '%Level 2%' OR s.SequenceName ILIKE '%Level 3%' OR s.SequenceName ILIKE '%Level 4%' THEN 'Level 1–4'
    WHEN s.SequenceName ILIKE '%Level 5%' OR s.SequenceName ILIKE '%Level 6%' OR s.SequenceName ILIKE '%Level 7%' OR s.SequenceName ILIKE '%Level 8%' THEN 'Level 5–8'

    -- Coding subgroups
    WHEN s.SequenceName ILIKE '%Python Basics%' THEN 'Python Basics'
    WHEN s.SequenceName ILIKE '%Block-based%' THEN 'Block-based Coding'
    WHEN s.SequenceName ILIKE '%Text-based%' THEN 'Text-based Coding'
    WHEN s.SequenceName ILIKE '%CodeMonkey%' THEN 'CodeMonkey'
    WHEN s.SequenceName ILIKE '%Codesters%' THEN 'Codesters'

    ELSE 'Other'
END AS Sequence_SubGroup,
isnull(s.SequenceName,'{{ var("default_varchar") }}') as Sequence_Name,
isnull(s.SequenceDescription,'{{ var("default_varchar") }}') as Sequence_Description,
isnull(s.Isvalid,{{ var("default_boolean") }}) as is_valid,
isnull(s.IsCustom,{{ var("default_boolean") }}) as is_custom,
isnull(s.auditcreatedate,'{{ var("default_date") }}') as auditcreatedate,
isnull(s.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate
from {{ source("staging","sequence") }} s
union all
select
'{{ var("default_ID") }}' Sequence_Id,
'{{ var("default_varchar") }}' as Sequence_Group,
'{{ var("default_varchar") }}' as Sequence_SubGroup,
'{{ var("default_varchar") }}' as Sequence_name,
'{{ var("default_varchar") }}' as Sequence_description,
{{ var("default_boolean") }} as is_valid,
{{ var("default_boolean") }} as is_custom,
'{{ var("default_date") }}' as auditcreatedate,
 '{{ var("default_date") }}' as auditupdatedate
)
select
 Sequence_Id::VARCHAR(50) as Sequence_Id
,Sequence_Group::VARCHAR(200) as Sequence_Group
,Sequence_SubGroup::VARCHAR(200) as Sequence_SubGroup
,Sequence_name::VARCHAR(150) as Sequence_name
,Sequence_description::VARCHAR(1100) as Sequence_description
,is_valid::BOOLEAN as   is_valid
,is_custom::BOOLEAN as   is_custom
,auditcreatedate::TIMESTAMP as auditcreatedate
,auditupdatedate::TIMESTAMP as auditupdatedate
,'{{ var("loaddate") }}'::timestamp as loaddate
from data