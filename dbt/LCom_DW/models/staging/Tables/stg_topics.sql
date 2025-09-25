{{
    config(

        materialized='table',        
        sort='training_session_id', 
        dist='all'
        
        )
}}

WITH RECURSIVE
base AS (
  SELECT
      training_session_id,
      implementation_topics
  FROM {{ ref("fact_training_session") }}
  WHERE implementation_topics IS NOT NULL
),
counts AS (
  SELECT
      training_session_id,
      implementation_topics,
      CASE
        WHEN TRIM(implementation_topics) = '' THEN 0
        ELSE REGEXP_COUNT(implementation_topics, ';') + 1
      END AS n_parts
  FROM base
),
max_n AS (
  SELECT COALESCE(MAX(n_parts), 0) AS mx FROM counts
),
seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq, max_n WHERE n < mx
)
SELECT
  c.training_session_id::varchar(300),
  NULLIF(TRIM(SPLIT_PART(c.implementation_topics, ';', seq.n)), '')::varchar(200) AS topic,
  case when topic!='{{ var("default_varchar") }}' then MD5(topic) else '{{ var("default_ID") }}' end::varchar(300) topic_id
,'{{ var("loaddate") }}'::TIMESTAMP as loaddate
FROM counts c
JOIN seq ON seq.n <= c.n_parts
WHERE NULLIF(TRIM(SPLIT_PART(c.implementation_topics, ';', seq.n)), '') IS NOT NULL
ORDER BY c.training_session_id, seq.n