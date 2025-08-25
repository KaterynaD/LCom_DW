{% macro update_FACT_TRAINING_SESSION_HISTORY_changed_UK() %}


 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting FACT_TRAINING_SESSION_HISTORY unique key before regular run */
/* I do not use "ref" because "Found a cycle" */
/* I assume FACT_TRAINING_SESSION_HISTORY is already exists when the macro runs*/

with accounts_to_adjuste as 
(select account_id from content_delivery_usage.fact_training_session_history
except
select account_id from common.dim_account)
,data as 
(select da.account_id, da.sfdc_account_id
from common.dim_account da 
join accounts_to_adjuste ata
on da.sfdc_account_id=ata.account_id)
update content_delivery_usage.fact_training_session_history
set account_id=data.account_id
from data
where data.sfdc_account_id=content_delivery_usage.fact_training_session_history.account_id;

/*Some training sessions are deleted in SFDC*/
/*and not included in FACT_TRAINING_SESSION next day               */
delete from content_delivery_usage.fact_training_session_history 
where training_session_id not in (select training_session_id from content_delivery_usage.fact_training_session);

 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}