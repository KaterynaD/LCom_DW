{% macro update_DIM_ACCOUNT_HISTORY_changed_UK() %}

{% if target.name != 'QA' %}
 
 {% set hist_relation = source('common', 'dim_account_history')  %}

 {% set run_operation %}

/* PK (dist key) in DIM_ACCOUNT is changed to LCOM Org Id when available */
/* adjusting DIM_ACCOUNT_HISTORY unique key before regular run */


--delete pre-SFDC history of LCom account form DIM_ACCOUNT_HISTORY
--if a new LCom organization was created before SFDC account and 1 or more historical records exists in DIM_ACCOUNT_HISTORY
--and SFDC account exists with more then 1 records in DIM_ACCOUNT_HISTORY
--then after update account_id in dim_account_history we may have a mess with from - to dates
--let's delete LCom Org history records since there are less info

insert into {{ source('common', 'dim_account_history_deleted') }} 
select * from {{ hist_relation }}
where account_id in (
select 
a.account_id
from (select account_id, lcom_organization_id, sfdc_account_id from {{ hist_relation }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') h
join (select account_id, lcom_organization_id, sfdc_account_id from {{ this }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') a
on h.sfdc_account_id = a.sfdc_account_id 
where h.account_id<>a.account_id --account_id was changed in dim_account but not in the history table
and a.account_id<>a.sfdc_account_id --it's changed from SFDC to LCom
);


delete from {{ hist_relation }}
where account_id in (
select 
a.account_id
from (select account_id, lcom_organization_id, sfdc_account_id from {{ hist_relation }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') h
join (select account_id, lcom_organization_id, sfdc_account_id from {{ this }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') a
on h.sfdc_account_id = a.sfdc_account_id 
where h.account_id<>a.account_id --account_id was changed in dim_account but not in the history table
and a.account_id<>a.sfdc_account_id --it's changed from SFDC to LCom
);

--updating account_id (SFDC) in dim_account_history to account_id (LCom)
with data as (select 
a.account_id,
a.sfdc_account_id 
from (select account_id, lcom_organization_id, sfdc_account_id from {{ hist_relation }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') h
join (select account_id, lcom_organization_id, sfdc_account_id from {{ this }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%') a
on h.sfdc_account_id = a.sfdc_account_id 
where h.account_id<>a.account_id)
update {{ hist_relation }}
set account_id=data.account_id,
account_hist_id=md5(coalesce(cast(data.account_id as varchar ), '') || '|' || coalesce(cast(fromdate as varchar ), ''))
from data
where data.sfdc_account_id={{ hist_relation }}.sfdc_account_id;

/*Some accounts without any relations are deleted in SFDC*/
/*and not included in DIM_ACCOUNT next day               */
delete from {{ hist_relation }}
where account_id in (
select sfdc_account_id from {{ hist_relation }} where sfdc_account_id!='Unknown' and sfdc_account_id not ilike 'dup%'
except 
select distinct id from {{ source('fivetran_salesforce_quickstart', 'account') }} 
);
 {% endset %}

{% do run_query(run_operation) %}

 {% endif %}

{% endmacro %}


{% macro delete_from_DIM_ACCOUNT_HISTORY_from_to_the_same() %}

{% if target.name != 'QA' %}
 
 {% set hist_relation = source('common', 'dim_account_history')  %}

 {% set run_operation %}

 --joining LCom org and SFDC account may create records with the same fromdate and todate
 --if there were no other changes in the account
 --Such records can not be used in the history queries anuway
 
 delete from {{ hist_relation }} where fromdate=todate;

 {% endset %}

{% do run_query(run_operation) %}

 {% endif %}

{% endmacro %}