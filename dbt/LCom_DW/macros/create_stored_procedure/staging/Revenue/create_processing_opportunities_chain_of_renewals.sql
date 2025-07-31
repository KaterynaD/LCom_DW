{% macro create_processing_opportunities_chain_of_renewals() %}
 {% set create_sp_operation %}


CREATE OR REPLACE PROCEDURE staging.processing_opportunities_chain_of_renewals(ploaddate timestamp)					
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
SELECT distinct					
opportunity_id,					
invoiced_date,					
renewal_opportunity_id					
FROM staging.stg_revenue a					
order by opportunity_id;					
SELECT count(opportunity_id) into record_count from temp_opportunities_ids;					
RAISE INFO 'Count opportunities: %', record_count;					
batch_count := CEIL(record_count / batch::float) ;					
RAISE INFO 'Num of batches: %', batch_count;

truncate table staging.stg_opportunities_chain_of_renewals;		

FOR i IN 1..batch_count LOOP					
RAISE INFO 'Batch: %', i;					
offset_value := (i - 1) * 100;					
RAISE INFO 'offset_value: %', offset_value;			
		
insert into staging.stg_opportunities_chain_of_renewals					
(					
opportunity_id					
,cnt_parents					
,parent_opportunities					
,loaddate					
)					
WITH RECURSIVE orders(opportunity_id, renewal_opportunity_id, invoiced_date, id) AS (					
select distinct					
r.opportunity_id,					
r.renewal_opportunity_id,					
r.invoiced_date,					
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
r1.invoiced_date,					
b.id					
FROM temp_opportunities_ids r1					
INNER JOIN orders b					
On b.opportunity_id = r1.renewal_opportunity_id					
)					
SELECT					
id opportunity_id,					
count(opportunity_id) cnt_parents,					
listagg(opportunity_id, ', ') WITHIN GROUP (ORDER BY case when invoiced_date='1900-01-01' then '3000-01-01' else invoiced_date end, opportunity_id ) parent_opportunities,					
ploaddate loaddate					
FROM orders					
group by id;					
END LOOP;					
drop table if exists temp_opportunities_ids;					
END;					
$$					
;					


{% endset %}

{% do run_query(create_sp_operation) %}

{% endmacro %} 