{% macro create_stg_opportunities_chain_of_renewals_v2() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

{{ log('Creating stg_opportunities_chain_of_renewals_v2 table in schema ' ~ custom_schema, info=True) }}

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

{% do run_query(create_table_operation) %}

 {% endif %}

{% endmacro %} 