{{ config(materialized='view', bind=False) }}

    with license_school_data as (
        SELECT
            ord.organization_district_id,
            sch.organization_school_id,
            ord.StartDate,
            ord.ExpirationDate,
            ord.enforcedaterestrictions,
            ord.SchoolCount,
            ord.StudentCount
        from
            {{ ref("fact_license_order") }} ord
            join {{ ref("dim_license_order_school") }}  sch on ord.order_id = sch.order_id
        union all
            /*we need to count launches_YTD from unknown schools at the district level*/
        SELECT
            ord.organization_district_id,
            ord.organization_district_id organization_school_id,
            ord.StartDate,
            ord.ExpirationDate,
            ord.enforcedaterestrictions,
            ord.SchoolCount,
            ord.StudentCount
        from
            {{ ref("fact_license_order") }}  ord
    ) --we need licenses active at the start of a week and launches_YTD at the end of a week
,
    cal as (
        select
            distinct schoolyear,
            mon,
            mon_firstday,
            mon_lastday
        from
            {{ source("common","dim_calendar") }}
    ),
    school_data as (
        select
            dist.country_name Country,
            dist.state_province_code State,
            license_school_data.organization_district_id,
            license_school_data.organization_school_id,
            dist.DistrictName,
            sch.SchoolName,
            dist.Salesforce_Id,
            dist.salesforce_DistrictName,
            cal.schoolyear,
            cal.mon,
            cal.mon_firstday mon_firstday,
            cal.mon_lastday mon_lastday,
            isnull(max(active_students_YTD), 0) active_students_YTD,
            isnull(max(launches_YTD), 0) launches_YTD,
            case
            when license_school_data.organization_district_id = license_school_data.organization_school_id
            or sch.SchoolName = '_cloud' then 0
            else CEILING(
                MAX(
                    case
                    when license_school_data.SchoolCount <> 0 then cast(license_school_data.StudentCount as float) / license_school_data.SchoolCount
                    else 0 end
                )
            ) end Licenses_Provisioned_School,
            sum(DISTINCT license_school_data.StudentCount) Licenses_Provisioned_District
        from
            license_school_data --
            join cal on (
                (
                    cal.mon_lastday between license_school_data.StartDate
                    and license_school_data.ExpirationDate
                )
                or license_school_data.enforcedaterestrictions = 'n'
            ) --
            join {{ ref("dim_district") }}  dist on license_school_data.organization_district_id = dist.organization_district_id --
            join {{ ref("dim_school") }}  sch on license_school_data.organization_school_id = sch.organization_school_id --
            left outer join {{ ref("fact_launches_monthly_snapshots") }}  f on license_school_data.organization_district_id = f.organization_district_id
            and cal.mon_lastday = f.mon_lastday
            and (
                sch.organization_school_id = f.organization_school_id
            ) --
        where
            dist.is_demo = false
            and dist.is_trial = false
        group by
            dist.country_name,
            dist.state_province_code,
            license_school_data.organization_district_id,
            license_school_data.organization_school_id,
            dist.DistrictName,
            sch.SchoolName,
            dist.Salesforce_Id,
            dist.salesforce_DistrictName,
            cal.schoolyear,
            cal.mon,
            cal.mon_firstday,
            cal.mon_lastday
    )
    select
        Country,
        State,
        organization_district_id,
        DistrictName,
        Salesforce_Id,
        salesforce_DistrictName,
        schoolyear,
        mon,
        sum(active_students_YTD) active_students_YTD,
        sum(launches_YTD) launches_YTD,
        max(Licenses_Provisioned_District) Licenses_Provisioned_District,
        CASE
        WHEN MAX(Licenses_Provisioned_District) = 0
        OR MAX(Licenses_Provisioned_District) IS NULL THEN NULL
        ELSE CAST(
            SUM(active_students_YTD) * 100.0 / MAX(Licenses_Provisioned_District) AS DECIMAL(10, 2)
        ) END AS Utilization,
        LISTAGG(SchoolName, ', ') WITHIN GROUP (
            ORDER BY
                SchoolName
        ) AS Schools_with_Licenses
    from
        school_data
    group by
        Country,
        State,
        organization_district_id,
        DistrictName,
        Salesforce_Id,
        salesforce_DistrictName,
        schoolyear,
        mon