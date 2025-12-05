{% macro update_FACT_CASE_HISTORY_changed_UK() %}


 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting FACT_CASE_HISTORY unique key before regular run */
/* I do not use "ref" because "Found a cycle" */
/* I assume FACT_CASE_HISTORY is already exists when the macro runs*/

with accounts_to_adjust as 
(select account_id from support.fact_case_history
except
select account_id from common.dim_account)
,data as 
(select da.account_id, da.sfdc_account_id
from common.dim_account da 
join accounts_to_adjust ata
on da.sfdc_account_id=ata.account_id)
update support.fact_case_history
set account_id=data.account_id
from data
where data.sfdc_account_id=support.fact_case_history.account_id;

/*Some cases are deleted in SFDC*/
/*and not included in FACT_CASE next day               */
/*delete from support.fact_case_history */
/*where case_id not in (select case_id from support.fact_case);*/

 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}