{{ config(materialized='view', bind=False) }}

WITH license_order_counts AS (
    SELECT DISTINCT
        flo.netsuite_order_id,
        s.sku_name,
        flo.schoolcount AS ord_school_count,
        flo.studentcount AS ord_student_count,
        flo.enforcedaterestrictions, 
        sch.lcom_school_name
    FROM {{ ref("fact_license_order") }} as flo
    JOIN {{ ref("dim_license_order_school") }} as flo_sch 
        ON flo.order_id = flo_sch.order_id
    JOIN {{ ref("dim_school") }} as sch 
        ON flo_sch.organization_school_id = sch.lcom_school_id
    JOIN {{ ref("dim_lcom_sku") }} as s 
        ON flo.sku_id = s.sku_id
),

license_order_summary AS (
SELECT
    loc.netsuite_order_id,
    loc.sku_name,
    loc.ord_school_count,
    loc.ord_student_count,
    loc.enforcedaterestrictions as ord_enforcedaterestrictions,
    LISTAGG(loc.lcom_school_name, ', ') WITHIN GROUP (ORDER BY loc.lcom_school_name) AS ord_schools_list
FROM license_order_counts loc
GROUP BY
    netsuite_order_id,
    sku_name,
    ord_school_count,
    ord_student_count,
    enforcedaterestrictions
)

SELECT
    opp.account_id,
    acc.sfdc_billing_state AS state,
    acc.sfdc_parent_name_proper_case AS account_name,
    CASE
            WHEN (
                acc.sfdc_state_initiative
                OR acc.sfdc_state_initiative_school
            ) THEN true
            ELSE false END state_initiative,
    acc.sfdc_state_program_eligible,
    acc.sfdc_owner_name_text,
    

    opp.opportunity_number,
    opp.name AS opportunity_name,
    opp.description,
    opp.subscription_start_date AS subscription_start_date,
    opp.subscription_end_date AS subscription_end_date,
    opp.start_date AS start_date,
    opp.end_date as end_date,
    opp.close_date,
    opp.paid_date,
    opp.license_provisioned_date,

    opp.number_of_students AS opp_student_count,
    opp.number_of_schools AS opp_school_count,    

    los.sku_name,
    los.ord_school_count,
    los.ord_student_count,
    los.ord_enforcedaterestrictions,
    case 
    when 
        (GETDATE() > opp.end_date AND ord_enforcedaterestrictions = 'n' ) or 
        (GETDATE() between opp.start_date AND opp.end_date)
    then 'Active' ELSE 'Inactive' END as Active_or_Inactive,
    los.ord_schools_list,

    opp.x_1_st_contact_name,
    opp.x_1_st_contact_email,
    opp.x_2_nd_contact_name,
    opp.x_2_nd_contact_email,
    opp.x_3_rd_contact_name,
    opp.x_3_rd_contact_email
FROM {{ ref("fact_opportunity") }} as opp
JOIN {{ ref("dim_account") }} as acc 
    ON opp.account_id = acc.account_id
LEFT JOIN license_order_summary los 
    ON opp.opportunity_number = los.netsuite_order_id
WHERE opp.stage_name = 'Closed Won'