{% macro create_processing_ultimate_parent_accounts() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

 {{ log('Creating processing_ultimate_parent_accounts stored procedure in schema ' ~ custom_schema, info=True) }}
 
 {% set create_sp_operation %}


CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.processing_ultimate_parent_accounts(ploaddate timestamp)
	LANGUAGE plpgsql
AS $$
	
DECLARE
rec RECORD;
query text;
record_count int;
batch int := 100;
batch_count int;
offset_value int;
BEGIN

RAISE INFO 'Creating temp table with current raw data for processing ultimate parents...';
--Current raw data for processing ultimate parent summarized info
--temp table to make the process faster !!!
drop table if exists tempdata_for_ultimate_parent_accounts;
create temporary table tempdata_for_ultimate_parent_accounts as
SELECT distinct 
a.id                        as sfdc_account_id,
a.parent_id                 as sfdc_parent_id,
a.current_renewal_arr_c     as sfdc_current_renewal_arr,
ultimate_parent_id_c        as sfdc_ultimate_parent_id
FROM {{ source('fivetran_salesforce_quickstart', 'account') }} a;

RAISE INFO 'Creating temp table with list ultimate parents with opportunities...';
--Limit only to the ultimate parent accounts where child opportunities exist
--temp table to make the process faster
drop table if exists temp_ultimate_parent_accounts_ids;
create temporary table temp_ultimate_parent_accounts_ids as
SELECT distinct 
sfdc_ultimate_parent_id
FROM tempdata_for_ultimate_parent_accounts a
join {{ source('fivetran_salesforce_quickstart', 'opportunity') }} fop
on a.sfdc_account_id=fop.account_id
where sfdc_ultimate_parent_id is not null
order by sfdc_ultimate_parent_id;


SELECT count(sfdc_ultimate_parent_id) into record_count from temp_ultimate_parent_accounts_ids;

RAISE INFO 'Count ultimate parents with opportunities: %', record_count;

batch_count := CEIL(record_count / batch::float) ;

RAISE INFO 'Num of batches: %', batch_count;

truncate table {{target.database}}.{{custom_schema}}.sfdc_ultimate_parent_accounts_data;

FOR i IN 1..batch_count LOOP
RAISE INFO 'Batch: %', i;

offset_value := (i - 1) * 100;

RAISE INFO 'offset_value: %', offset_value;

insert into {{target.database}}.{{custom_schema}}.sfdc_ultimate_parent_accounts_data
(
sfdc_ultimate_parent_id
,sfdc_current_renewal_arr
,cnt_childs
,child_accounts
,loaddate
)
WITH RECURSIVE buildings(sfdc_account_id, sfdc_parent_id, sfdc_current_renewal_arr,id) AS (
SELECT
a.sfdc_account_id,
a.sfdc_parent_id,
a.sfdc_current_renewal_arr,
a.sfdc_account_id id
FROM tempdata_for_ultimate_parent_accounts a
where a.sfdc_account_id in
(

SELECT sfdc_ultimate_parent_id
FROM temp_ultimate_parent_accounts_ids
ORDER BY sfdc_ultimate_parent_id
LIMIT batch OFFSET offset_value

)
UNION ALL
SELECT
a1.sfdc_account_id,
a1.sfdc_parent_id,
a1.sfdc_current_renewal_arr,
b.id
FROM tempdata_for_ultimate_parent_accounts a1
INNER JOIN buildings b
On b.sfdc_account_id = a1.sfdc_parent_id
)
SELECT
id sfdc_ultimate_parent_id,
sum(sfdc_current_renewal_arr) sfdc_current_renewal_arr,
count(sfdc_account_id) cnt_childs,
listagg(sfdc_account_id, ', ') WITHIN GROUP (ORDER BY sfdc_account_id) child_accounts,
ploaddate loaddate
FROM buildings
group by id;


END LOOP;

drop table if exists tempdata_for_ultimate_parent_accounts;
drop table if exists temp_ultimate_parent_accounts_ids;

END;

$$
;

{% endset %}

{% do run_query(create_sp_operation) %}

{% endif %}

{% endmacro %} 