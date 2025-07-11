select opportunity_id FROM {{ ref("fact_opportunity") }}
except
select opportunity_id FROM {{ ref("fact_opportunity_history") }}