{% macro create_sfdc_ultimate_parent_accounts_data() %}
 {% set create_table_operation %}

DROP TABLE if exists staging.sfdc_ultimate_parent_accounts_data;
CREATE TABLE staging.sfdc_ultimate_parent_accounts_data
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


COMMENT ON TABLE staging.sfdc_ultimate_parent_accounts_data IS 'Staging table to keep ultimate parent accounts aggregated from childs info using recursive query in staging.processing_ultimate_parent_accounts';

{% endset %}

{% do run_query(create_table_operation) %}

{% endmacro %} 