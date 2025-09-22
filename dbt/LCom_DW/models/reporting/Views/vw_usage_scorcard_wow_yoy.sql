{{ config(
    materialized = 'view',
    bind = false
) }}

WITH date_periods AS (
  /* Current year, current week (school year start to today) */
  SELECT
    TRUNC(GETDATE()) AS cal_date,
    TIMEZONE('UTC', GETDATE()) AS end_date,
    SchoolYear_StartDate,
    CASE
      WHEN EXTRACT(MONTH FROM SchoolYear_StartDate) = 7
      THEN CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR) || '/' || CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) + 1
      ) AS VARCHAR)
      ELSE CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) - 1
      ) AS VARCHAR) || '/' || CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR)
    END AS school_year,
    'Current Year' AS year_type,
    'Current Week' AS week_type
  FROM {{ source("common","dim_calendar") }}
  WHERE
    cal_date = TRUNC(GETDATE())
  UNION ALL
  /* Current year, previous week (school year start to today minus 7 days) */
  SELECT
    DATEADD('day', -7, TRUNC(GETDATE())) AS cal_date,
    TIMEZONE('UTC', DATEADD('day', -7, GETDATE())) AS end_date,
    SchoolYear_StartDate,
    CASE
      WHEN EXTRACT(MONTH FROM SchoolYear_StartDate) = 7
      THEN CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR) || '/' || CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) + 1
      ) AS VARCHAR)
      ELSE CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) - 1
      ) AS VARCHAR) || '/' || CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR)
    END AS school_year,
    'Current Year' AS year_type,
    'Previous Week' AS week_type
  FROM {{ source("common","dim_calendar") }}
  WHERE
    cal_date = TRUNC(GETDATE())
  UNION ALL
  /* Previous year, current week (same date range as current year current week, but previous year) */
  SELECT
    DATEADD('year', -1, TRUNC(GETDATE())) AS cal_date,
    TIMEZONE('UTC', DATEADD('year', -1, GETDATE())) AS end_date,
    SchoolYear_StartDate,
    CASE
      WHEN EXTRACT(MONTH FROM SchoolYear_StartDate) = 7
      THEN CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR) || '/' || CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) + 1
      ) AS VARCHAR)
      ELSE CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) - 1
      ) AS VARCHAR) || '/' || CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR)
    END AS school_year,
    'Previous Year' AS year_type,
    'Current Week' AS week_type
  FROM {{ source("common","dim_calendar") }}
  WHERE
    cal_date = DATEADD('year', -1, TRUNC(GETDATE()))
  UNION ALL
  /* Previous year, previous week (same date range as current year previous week, but previous year) */
  SELECT
    DATEADD('day', -7, DATEADD('year', -1, TRUNC(GETDATE()))) AS cal_date,
    TIMEZONE('UTC', DATEADD('day', -7, DATEADD('year', -1, GETDATE()))) AS end_date,
    SchoolYear_StartDate,
    CASE
      WHEN EXTRACT(MONTH FROM SchoolYear_StartDate) = 7
      THEN CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR) || '/' || CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) + 1
      ) AS VARCHAR)
      ELSE CAST((
        EXTRACT(YEAR FROM SchoolYear_StartDate) - 1
      ) AS VARCHAR) || '/' || CAST(EXTRACT(YEAR FROM SchoolYear_StartDate) AS VARCHAR)
    END AS school_year,
    'Previous Year' AS year_type,
    'Previous Week' AS week_type
  FROM {{ source('common', 'dim_calendar') }} AS dim_calendar
  WHERE
    cal_date = DATEADD('year', -1, TRUNC(GETDATE()))
)
SELECT
  TO_CHAR(dp.SchoolYear_StartDate, 'MM/DD/YY') || ' - ' || TO_CHAR(dp.cal_date, 'MM/DD/YY') AS date_range,
  dp.school_year,
  dp.year_type,
  dp.week_type,
  COUNT(DISTINCT fal.user_account_id) AS unique_students,
  COUNT(DISTINCT fal.assignment_launch_id) AS unique_launches,
  MAX(TIMEZONE('UTC', fal.launch_datetime)) AS latest_launch
FROM date_periods AS dp
JOIN {{ source('dbo', 'fact_assignment_launch') }} AS fal
  ON TIMEZONE('UTC', fal.launch_datetime) BETWEEN dp.SchoolYear_StartDate AND dp.end_date
JOIN {{ source('dbo', 'organization') }} AS o
  ON fal.organization_district_id = o.organization_id
JOIN {{ source('dbo', 'mv_student_account') }} AS ua
  ON fal.user_account_id = ua.user_account_id
  AND fal.organization_district_id = ua.organization_district_id
WHERE
  o.is_demo = FALSE AND o.is_trial = FALSE
GROUP BY
  TO_CHAR(dp.SchoolYear_StartDate, 'MM/DD/YY') || ' - ' || TO_CHAR(dp.cal_date, 'MM/DD/YY'),
  dp.school_year,
  dp.year_type,
  dp.week_type,
  dp.SchoolYear_StartDate,
  dp.cal_date
ORDER BY
  dp.year_type DESC NULLS LAST,
  dp.week_type DESC NULLS LAST,
  dp.cal_date DESC NULLS LAST