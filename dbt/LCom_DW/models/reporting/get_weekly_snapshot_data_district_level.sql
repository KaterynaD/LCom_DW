{{ config(materialized='view', bind=False) }}

with raw_license_data as (
        select
            case
            when (
                dist.sfdc_state_initiative
                or dist.sfdc_state_initiative_school
            ) then true
            else false end state_initiative,
            dist.lcom_country_name district_country,
            dist.lcom_state_province_code district_state,
            dist.lcom_district_name district_name,
            dist.SFDC_owner_name_text district_owner,
            flo.organization_district_id,
            flo.order_id,
            flo.startdate,
            flo.expirationdate,
            flo.enforcedaterestrictions,
            s.sku_name skuname,
            flo.studentcount,
            sum(
                case
                when sch.ishighschool then 1
                else 0 end
            ) HighSchools_Num,
            count(lcom_school_name) Schools_Num --,LISTAGG(distinct lcom_school_name,',' ) WITHIN GROUP (ORDER BY lcom_school_name) schools
        from
            {{ ref("fact_license_order") }} flo
            join {{ ref("dim_district") }} dist on flo.organization_district_id = dist.district_id --
            join {{ ref("dim_lcom_sku") }} s on flo.sku_id = s.sku_id --
            join {{ ref("dim_license_order_school") }} dlos on flo.order_id = dlos.order_id
            join {{ ref("dim_school") }} sch on dlos.organization_school_id = sch.lcom_school_id --
            --
        where dist.lcom_trial = false
        and dist.lcom_demo= false
        group by
            case
            when (
                dist.sfdc_state_initiative
                or dist.sfdc_state_initiative_school
            ) then true
            else false end,
            dist.lcom_country_name,
            dist.lcom_state_province_code,
            dist.lcom_district_name,
            dist.SFDC_owner_name_text,
            flo.organization_district_id,
            flo.order_id,
            flo.startdate,
            flo.expirationdate,
            flo.enforcedaterestrictions,
            s.sku_name,
            flo.studentcount
    ),
    cal as (
        select
            distinct Mon_WeekStart,
            Sun_WeekEnd
        from
            dw.common.dim_calendar
    ),
    district_sku_license_data as (
        select
            cal.Mon_WeekStart,
            cal.Sun_WeekEnd,
            state_initiative,
            district_country,
            district_state,
            district_owner,
            district_name,
            organization_district_id,
            skuname,
            sum(
                case
                when district_state in ('NC', 'MI', 'SC', 'WV')
                and skuname ilike '%easy%tech%'
                and HighSchools_Num != Schools_Num then studentcount
                when district_state in ('MS', 'FL')
                and skuname ilike '%easy%tech%' then studentcount
                else 0 end
            ) state_initiative_studentcount,
            sum(studentcount) sum_studentcount
        from
            raw_license_data d
            join cal on (
                (
                    cal.Sun_WeekEnd between d.StartDate
                    and d.ExpirationDate
                )
                or d.enforcedaterestrictions = 'n'
            ) --
        group by
            cal.Mon_WeekStart,
            cal.Sun_WeekEnd,
            state_initiative,
            district_country,
            district_state,
            district_owner,
            district_name,
            organization_district_id,
            skuname
    ),
    district_license_data as (
        select
            Mon_WeekStart,
            Sun_WeekEnd,
            district_country,
            district_state,
            state_initiative,
            district_owner,
            district_name,
            organization_district_id,
            case
            when state_initiative then sum(state_initiative_studentcount)
            else 0 end State_Initiative_License_Provisioned,
            max(sum_studentcount) Number_Of_Students
        from
            district_sku_license_data data
        group by
            Mon_WeekStart,
            Sun_WeekEnd,
            district_country,
            district_state,
            state_initiative,
            district_owner,
            district_name,
            organization_district_id
    ),
    usage_data as (
        select
            flo.weekend,
            flo.organization_district_id,
            sum(flo.active_students_YTD) active_students_YTD,
            sum(flo.launches_YTD) launches_YTD
        from
            {{ ref("fact_launches_weekly_snapshots") }} flo
            join {{ ref("dim_district") }} dist on flo.organization_district_id = dist.district_id
        where
            lcom_trial = false
            and lcom_demo = false
        group by
            flo.weekend,
            flo.organization_district_id
    )
    select
        ld.Sun_WeekEnd as Weekend,
        ld.district_country Country,
        ld.district_state State,
        ld.state_initiative,
        ld.district_owner DistrictOwner,
        ld.district_name DistrictName,
        ld.organization_district_id,
        ld.State_Initiative_License_Provisioned Licenses_Provisioned_District,
        ld.Number_Of_Students,
        isnull(ud.active_students_YTD, 0) active_students_YTD,
        isnull(ud.launches_YTD, 0) launches_YTD,
        null Salesforce_Id,
        null salesforce_DistrictName,
        null Utilization,
        'N/A' Schools_with_Licenses
    from
        district_license_data ld
        left outer join usage_data ud on ld.organization_district_id = ud.organization_district_id
        and ld.Sun_WeekEnd = ud.weekend