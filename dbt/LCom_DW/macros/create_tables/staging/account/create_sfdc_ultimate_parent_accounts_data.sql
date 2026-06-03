{% macro create_sfdc_ultimate_parent_accounts_data() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

{{ log('Creating sfdc_ultimate_parent_accounts_data table in schema ' ~ custom_schema, info=True) }}

 

 {% set create_table_operation %}

CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.sfdc_ultimate_parent_accounts_data
(
 sfdc_ultimate_parent_id VARCHAR(300) NOT NULL ENCODE RAW
,sfdc_current_renewal_arr NUMERIC(38,10) NOT NULL ENCODE az64
,cnt_childs INT NOT NULL ENCODE az64
,child_accounts VARCHAR(max)  NOT NULL ENCODE lzo
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
)
DISTSTYLE AUTO
DISTKEY (sfdc_ultimate_parent_id)
SORTKEY (
sfdc_ultimate_parent_id
)
;


COMMENT ON TABLE {{target.database}}.{{custom_schema}}.sfdc_ultimate_parent_accounts_data IS 'Staging table to keep ultimate parent accounts aggregated from childs info using recursive query in staging.processing_ultimate_parent_accounts';

{% endset %}

{% do run_query(create_table_operation) %}

{% endif %}

{% endmacro %} 