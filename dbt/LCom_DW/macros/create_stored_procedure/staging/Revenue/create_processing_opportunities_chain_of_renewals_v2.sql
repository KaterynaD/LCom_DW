{% macro create_processing_opportunities_chain_of_renewals_v2() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

 {{ log('Creating processing_opportunities_chain_of_renewals_v2 stored procedure in schema ' ~ custom_schema, info=True) }}
 
 {% set create_sp_operation %}


CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.processing_opportunities_chain_of_renewals_v2(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
record_count int;
batch int := 100;
batch_count int;
offset_value int;
BEGIN



RAISE INFO 'Creating temp table with list of renewable opportunities...';
drop table if exists temp_opportunities_ids;
create temporary table temp_opportunities_ids as
SELECT
f.opportunity_id,
max(f.close_date) as close_date,
f.renewal_opportunity_id
FROM {{ ref('stg_valid_opportunities') }} a
join {{ ref('fact_opportunity') }} f
on a.opportunity_id = f.opportunity_id
group by f.opportunity_id, f.renewal_opportunity_id
order by f.opportunity_id;
SELECT count(opportunity_id) into record_count from temp_opportunities_ids;
RAISE INFO 'Count opportunities: %', record_count;
batch_count := CEIL(record_count / batch::float) ;
RAISE INFO 'Num of batches: %', batch_count;


CREATE temporary TABLE temp_opportunities_chain_of_renewals
(
opportunity_id VARCHAR(300) NOT NULL ENCODE RAW
,cnt_parents INTEGER NOT NULL ENCODE az64
,parent_opportunities VARCHAR(65535) NOT NULL ENCODE lzo
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
);

FOR i IN 1..batch_count LOOP
RAISE INFO 'Batch: %', i;
offset_value := (i - 1) * 100;
RAISE INFO 'offset_value: %', offset_value;
insert into temp_opportunities_chain_of_renewals
(
opportunity_id
,cnt_parents
,parent_opportunities
,loaddate
)
WITH RECURSIVE orders(opportunity_id, renewal_opportunity_id, close_date, id) AS (
select distinct
r.opportunity_id,
r.renewal_opportunity_id,
r.close_date,
r.opportunity_id id
FROM temp_opportunities_ids r
where r.opportunity_id in
(
SELECT opportunity_id
FROM temp_opportunities_ids
ORDER BY opportunity_id
LIMIT batch OFFSET offset_value
)
UNION ALL
SELECT
r1.opportunity_id,
r1.renewal_opportunity_id,
r1.close_date,
b.id
FROM temp_opportunities_ids r1
INNER JOIN orders b
On b.opportunity_id = r1.renewal_opportunity_id
)
SELECT
id opportunity_id,
count(opportunity_id) cnt_parents,
listagg(opportunity_id, ', ') WITHIN GROUP (ORDER BY close_date, opportunity_id ) parent_opportunities,
ploaddate loaddate
FROM orders
group by id;
END LOOP;

drop table if exists temp_opportunities_ids;

truncate table {{target.database}}.{{custom_schema}}.stg_opportunities_chain_of_renewals_v2;

insert into {{target.database}}.{{custom_schema}}.stg_opportunities_chain_of_renewals_v2
select distinct * from temp_opportunities_chain_of_renewals ;

drop table if exists temp_opportunities_chain_of_renewals;
END;


$$
;



{% endset %}

{% do run_query(create_sp_operation) %}

{% endif %}

{% endmacro %} 