{% macro update_FACT_OPPORTUNITY_HISTORY_changed_UK() %}


 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting FACT_OPPORTUNITY_HISTORY unique key before regular run */
/* I do not use "ref" because "Found a cycle" */
/* I assume FACT_OPPORTUNITY_HISTORY is already exists when the macro runs*/

with accounts_to_adjuste as 
(select account_id from revenue.fact_opportunity_history
except
select account_id from common.dim_account)
,data as 
(select da.account_id, da.sfdc_account_id
from common.dim_account da 
join accounts_to_adjuste ata
on da.sfdc_account_id=ata.account_id)
update revenue.fact_opportunity_history
set account_id=data.account_id
from data
where data.sfdc_account_id=revenue.fact_opportunity_history.account_id;

/*Some opportunities are deleted in SFDC*/
/*and not included in FACT_OPPORTUNITY next day*/
/*delete from revenue.fact_opportunity_history*/ 
/*where opportunity_id not in (select opportunity_id from revenue.fact_opportunity);*/

 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}