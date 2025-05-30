{% macro update_DIM_ACCOUNT_HISTORY_changed_UK() %}


 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting DIM_ACCOUNT_HISTORY unique key before regular run */
/* I do not use "ref" because "Found a cycle" */
/* I assume DIM_ACCOUNT_HISTORY is already exists when the macro runs*/

with data as (select 
a.account_id,
a.sfdc_account_id 
from (select account_id, lcom_organization_id, sfdc_account_id from common.dim_account_history where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') h
join (select account_id, lcom_organization_id, sfdc_account_id from common.dim_account where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') a
on h.sfdc_account_id = a.sfdc_account_id 
where h.account_id<>a.account_id)
update common.dim_account_history
set account_id=data.account_id
from data
where data.sfdc_account_id=common.dim_account_history.sfdc_account_id;

/*Some accounts without any relations are deleted in SFDC*/
/*and not included in DIM_ACCOUNT next day               */
delete from common.dim_account_history
where account_id in (
select sfdc_account_id from common.dim_account_history where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%'
except 
select distinct id from rawdata.fivetran_salesforce_quickstart.account
);
 {% endset %}

{% do run_query(run_operation) %}


{% endmacro %}