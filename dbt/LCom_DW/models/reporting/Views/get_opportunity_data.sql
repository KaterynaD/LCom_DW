{{ config(materialized='view', bind=False) }}


    WITH license_order_counts AS (
        SELECT
            DISTINCT flo.netsuite_order_id,
            s.sku_id,
            s.sku_name,
            flo.schoolcount AS ord_school_count,
            flo.studentcount AS ord_student_count,
            flo.enforcedaterestrictions,
            sch.lcom_school_name
        FROM
            {{ ref("fact_license_order") }} as flo
            JOIN {{ ref("dim_license_order_school" ) }} as flo_sch ON flo.order_id = flo_sch.order_id
            JOIN {{ ref("dim_school") }} as sch ON flo_sch.organization_school_id = sch.lcom_school_id
            JOIN {{ ref("dim_lcom_sku") }} as s ON flo.sku_id = s.sku_id
    ),
    license_order_summary AS (
        SELECT
            loc.netsuite_order_id,
            loc.sku_id,
            loc.sku_name,
            loc.ord_school_count,
            loc.ord_student_count,
            loc.enforcedaterestrictions AS ord_enforcedaterestrictions,
            LISTAGG(loc.lcom_school_name, ', ') WITHIN GROUP (
                ORDER BY
                    loc.lcom_school_name
            ) AS ord_schools_list
        FROM
            license_order_counts loc
        GROUP BY
            loc.netsuite_order_id,
            loc.sku_id,
            loc.sku_name,
            loc.ord_school_count,
            loc.ord_student_count,
            loc.enforcedaterestrictions
    )
    SELECT
        opp.account_id,
        acc.sfdc_billing_state AS state,
        acc.sfdc_parent_name_proper_case AS account_name,
        CASE
        WHEN acc.sfdc_state_initiative
        OR acc.sfdc_state_initiative_school THEN TRUE
        ELSE FALSE END AS state_initiative,
        acc.sfdc_state_program_eligible,
        acc.sfdc_owner_name_text,
        opp.opportunity_number,
        opp.name AS opportunity_name,
        opp.description,
        opp.subscription_start_date,
        opp.subscription_end_date,
        opp.start_date,
        opp.end_date,
        opp.close_date,
        opp.paid_date,
        opp.license_provisioned_date,
        opp.number_of_students AS opp_student_count,
        opp.number_of_schools AS opp_school_count,
        opp_li.quantity AS opp_li_student_count,
        prod.sfdc_product_name,
        suite.suite_name,
        sku.sku_name AS sold_sku_name,
        los.ord_school_count,
        los.ord_student_count,
        los.ord_enforcedaterestrictions,
        los.ord_schools_list,
        CASE
        WHEN (
            GETDATE() > opp.end_date
            AND los.ord_enforcedaterestrictions = 'n'
        )
        OR (
            GETDATE() BETWEEN opp.start_date
            AND opp.end_date
        ) THEN 'Active'
        ELSE 'Inactive' END AS Active_or_Inactive,
        opp.x_1_st_contact_name,
        opp.x_1_st_contact_email,
        opp.x_2_nd_contact_name,
        opp.x_2_nd_contact_email,
        opp.x_3_rd_contact_name,
        opp.x_3_rd_contact_email
    FROM
        {{ ref("fact_opportunity") }} as opp
        JOIN {{ ref("dim_account") }} as acc ON opp.account_id = acc.account_id
        LEFT JOIN {{ ref("dim_opportunity_line") }} as opp_li ON opp.opportunity_id = opp_li.opportunity_id
        LEFT JOIN {{ ref("dim_sfdc_product") }} as prod ON opp_li.sfdc_product_id = prod.sfdc_product_id
        LEFT JOIN {{ ref("dim_lcom_suite") }} as suite ON prod.lcom_suite = suite.suite_name
        LEFT JOIN {{ ref("dim_lcom_suite_sku") }} as suite_sku ON suite.suite_id = suite_sku.suite_id
        LEFT JOIN {{ ref("dim_lcom_sku") }} as sku ON suite_sku.sku_id = sku.sku_id
        JOIN license_order_summary los ON opp.opportunity_number = los.netsuite_order_id
        AND sku.sku_id = los.sku_id
    WHERE
        opp.stage_name = 'Closed Won'



