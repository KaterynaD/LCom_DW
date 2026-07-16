{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
 
WITH month_context AS (
    SELECT 'actual' AS period, m.*
    FROM {{ ref('dim_month') }} m
    WHERE TRUNC(GETDATE()) BETWEEN m.mon_firstday AND m.mon_lastday

    UNION ALL

    SELECT 'previous' AS period, m.*
    FROM {{ ref('dim_month') }} m
    WHERE DATE_ADD('year', -1, TRUNC(GETDATE())) BETWEEN m.mon_firstday AND m.mon_lastday

    UNION ALL

    SELECT 'previous_previous' AS period, m.*
    FROM {{ ref('dim_month') }} m
    WHERE DATE_ADD('year', -2, TRUNC(GETDATE())) BETWEEN m.mon_firstday AND m.mon_lastday
),

customer_counts AS (
    SELECT
        m.period,
        f.record_type,
        COUNT(DISTINCT f.customer_id) AS cnt_customers
    FROM {{ ref('fact_customer') }} f
    JOIN month_context m
        ON f.mon_year = m.mon_year
    WHERE f.arr_type = 'Preliminary'
      AND f.record_type IN (
          'Contract Active',
          'Net Active',
          'New',
          'Returning',
          'Total Active'
      )
    GROUP BY
        m.period,
        f.record_type
),

scorecard AS (
    SELECT
        m.period,
        m.fiscalyear,
        m.mon_lastday,

        COALESCE(MAX(CASE WHEN c.record_type = 'Contract Active' THEN c.cnt_customers END), 0) AS contract_based_active,
        COALESCE(MAX(CASE WHEN c.record_type = 'Net Active'       THEN c.cnt_customers END), 0) AS net_active,
        COALESCE(MAX(CASE WHEN c.record_type = 'Total Active'     THEN c.cnt_customers END), 0) AS total_active,
        COALESCE(MAX(CASE WHEN c.record_type = 'New'              THEN c.cnt_customers END), 0) AS new_customers,
        COALESCE(MAX(CASE WHEN c.record_type = 'Returning'        THEN c.cnt_customers END), 0) AS returning_customers
    FROM month_context m
    LEFT JOIN customer_counts c
        ON m.period = c.period
    WHERE m.period IN ('actual', 'previous')
    GROUP BY
        m.period,
        m.fiscalyear,
        m.mon_lastday
),

previous_previous_net_active AS (
    SELECT COALESCE(cnt_customers, 0) AS net_active
    FROM customer_counts
    WHERE period = 'previous_previous'
      AND record_type = 'Net Active'
),

last_updated AS (
    SELECT MAX(loaddate) AS last_updated
    FROM {{ ref('fact_customer') }}
    WHERE arr_type = 'Preliminary'
)

SELECT
    'Actual' AS category,
    actual.contract_based_active,
    actual.net_active,
    actual.total_active,
    (
        actual.net_active
        - actual.new_customers
        - actual.returning_customers
    )::FLOAT / NULLIF(previous.net_active, 0) AS retention,
    actual.fiscalyear,
    last_updated.last_updated
FROM scorecard actual
JOIN scorecard previous
    ON previous.period = 'previous'
CROSS JOIN last_updated
WHERE actual.period = 'actual'

UNION ALL

SELECT
    'Previous' AS category,
    previous.contract_based_active,
    previous.net_active,
    previous.total_active,
    (
        previous.net_active
        - previous.new_customers
        - previous.returning_customers
    )::FLOAT / NULLIF(previous_previous.net_active, 0) AS retention,
    previous.fiscalyear,
    previous.mon_lastday AS last_updated
FROM scorecard previous
CROSS JOIN previous_previous_net_active previous_previous
WHERE previous.period = 'previous'

UNION ALL

SELECT
    'Target' AS category,
    0 AS contract_based_active,
    0 AS net_active,
    0 AS total_active,
    0 AS retention,
    'N/A' AS fiscalyear,
    CAST('1900-01-01' AS DATE) AS last_updated