{% macro update_DIM_CONTACT_HISTORY_changed_UK() %}


 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting DIM_CONTACT_HISTORY unique key before regular run */
/* I do not use "ref" because "Found a cycle" */
/* I assume DIM_CONTACT_HISTORY is already exists when the macro runs*/

with accounts_to_adjuste as 
(select account_id from common.dim_contact_history
except
select account_id from common.dim_account)
,data as 
(select da.account_id, da.sfdc_account_id
from common.dim_account da 
join accounts_to_adjuste ata
on da.sfdc_account_id=ata.account_id)
update common.dim_contact_history
set account_id=data.account_id
from data
where data.sfdc_account_id=common.dim_contact_history.account_id;

/*Some contacts are deleted in SFDC*/
/*and not included in FACT_TRAINING_SESSION next day               */
/*delete from common.dim_contact_history */
/*where contact_id not in (select contact_id from common.dim_contact);*/

 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}