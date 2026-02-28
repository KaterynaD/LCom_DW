{% macro update_FACT_TRAINING_SESSION_HISTORY_changed_UK() %}






{% if target.name != 'QA' %}
 
{% set hist_relation = source('content_delivery_usage', 'fact_training_session_history')  %}

{% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting FACT_TRAINING_SESSION_HISTORY unique key before regular run */

with accounts_to_adjuste as 
(
select account_id from {{ hist_relation }}
except
select account_id from {{ ref('dim_account') }}
)
,data as 
(
select da.account_id, da.sfdc_account_id
from {{ ref('dim_account') }} da 
join accounts_to_adjuste ata
on da.sfdc_account_id=ata.account_id
)
update {{ hist_relation }}
set account_id=data.account_id
from data
where data.sfdc_account_id={{ hist_relation }}.account_id;


 {% endset %}

{% do run_query(run_operation) %}

 {% endif %}

{% endmacro %}