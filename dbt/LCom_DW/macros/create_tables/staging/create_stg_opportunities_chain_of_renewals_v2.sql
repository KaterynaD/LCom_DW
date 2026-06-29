{% macro create_stg_opportunities_chain_of_renewals_v2() %}

 {% set custom_schema = deployment_schema() %}

 {% set create_table_operation %}


 CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.stg_opportunities_chain_of_renewals_v2
(
 opportunity_id VARCHAR(300) NOT NULL ENCODE RAW
,cnt_parents int NOT NULL  ENCODE az64
,parent_opportunities VARCHAR(max) NOT NULL  ENCODE lzo
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
)
DISTSTYLE AUTO
DISTKEY (opportunity_id)
SORTKEY (
opportunity_id
)
;



COMMENT ON TABLE {{target.database}}.{{custom_schema}}.stg_opportunities_chain_of_renewals_v2 IS 'Staging table to keep opportunities chain of renewals IDs starting from the first (New or whatever) using recursive query in staging.processing_opportunities_chain_of_renewals_v2';

{% endset %}

{{ run_DDL('stg_opportunities_chain_of_renewals_v2', create_table_operation) }}

{% endmacro %} 