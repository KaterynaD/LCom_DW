{{ config(
    materialized = 'view',
    bind = false
) }}

    select
        -- Opportunity
        dc.fiscalyear,
        dc_sy.schoolyear,
        fo.opportunity_id,
        fo.name as opportunity_name,
        fo.opp_record_type    ,
        fo.stage_name   , 
        fo.start_date,
        fo.end_date,
        fo.invoiced_date ,
        fo.close_date,
        -- Owner
        e.name as opportunity_owner_name,

        -- Account
        a.sfdc_account_id,
        a.sfdc_name account_name,
        a.sfdc_customer_level account_customer_level,
        a.sfdc_billing_state account_billing_state,
        case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as account_state_initiative,
        a.sfdc_state_program_eligible as account_state_program_eligible,
        a.sfdc_urban_rural as account_urban_rural,
        case
                when a.sfdc_district_enrollment = 0 then a.sfdc_school_enrollment
                else a.sfdc_district_enrollment 
        end as account_district_enrollment,
        a.sfdc_owner_name_text as account_owner_name,

        -- Product
        p.sfdc_product_name,
        p.sfdc_product_code,

        -- Opp / Line 
        oli.quantity,
        oli.list_price, 
        oli.unit_price,
        oli.total_price
     
    from {{ ref('fact_opportunity') }} fo
    join {{ ref('dim_opportunity_line') }} oli
      on oli.opportunity_id = fo.opportunity_id
    join {{ ref("dim_calendar") }} dc
      on fo.invoiced_date = dc.cal_date
    join {{ ref('dim_sfdc_product') }} p
      on oli.sfdc_product_id = p.sfdc_product_id
    join {{ ref('dim_account') }} a
      on fo.account_id = a.account_id
    join {{ ref('dim_employee') }} e
      on fo.owner_id = e.employee_id
     join {{ ref("dim_calendar") }} dc_sy
      on fo.start_date = dc_sy.cal_date


