{% macro create_sfdc_ultimate_parent_accounts_data() %}

{% set custom_schema = deployment_schema() %}

 

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

{{ run_DDL('sfdc_ultimate_parent_accounts_data', create_table_operation) }}

{% endmacro %} 