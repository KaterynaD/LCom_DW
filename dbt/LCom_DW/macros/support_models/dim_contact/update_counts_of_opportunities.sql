{% macro update_counts_of_opportunities() %}


 {% set run_operation %}

with contact_opportunity_summary AS (
  SELECT
    contact_id,
    COUNT(DISTINCT opportunity_id) AS opportunity_count,
    COUNT(DISTINCT CASE WHEN is_closed = TRUE AND is_won = TRUE THEN opportunity_id END) AS won_count,
    COUNT(DISTINCT CASE WHEN is_closed = TRUE AND is_won = FALSE THEN opportunity_id END) AS lost_count
  FROM {{ this }}
  GROUP BY contact_id
  )
  update {{ ref("dim_contact") }}
  set 
opportunity_count = data.opportunity_count,
won_count = data.won_count,
lost_count = data.lost_count
from contact_opportunity_summary as data
where data.contact_id = common.dim_contact.contact_id;

 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}