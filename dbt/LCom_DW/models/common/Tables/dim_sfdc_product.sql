{{
    config(

        materialized='incremental',
        unique_key=['sfdc_product_id'],
        incremental_strategy='merge',
        on_schema_change='append_new_columns',     
        sort='sfdc_product_id', 
        dist='all'
 )  
}}

with data as 
(select
stg.id as sfdc_product_id,
isnull(stg.name, '{{ var("default_varchar") }}') as sfdc_product_name,
isnull(stg.is_active, {{ var("default_boolean") }}) as is_active,
isnull(stg.active_in_platform_c, {{ var("default_boolean") }}) as active_in_platform,
isnull(stg.sbqq_component_c, {{ var("default_boolean") }}) as sbqq_component,
isnull(stg.sbqq_cost_editable_c, {{ var("default_boolean") }}) as sbqq_cost_editable,
isnull(stg.created_date	 AT TIME ZONE 'PST',	 '{{ var("default_date") }}') as created_date,
isnull(stg.does_not_prorate_c, {{ var("default_boolean") }}) as does_not_prorate,
isnull(stg.sbqq_exclude_from_maintenance_c, {{ var("default_boolean") }}) as sbqq_exclude_from_maintenance,
isnull(stg.sbqq_hidden_c, {{ var("default_boolean") }}) as sbqq_hidden,
isnull(stg.sbqq_include_in_maintenance_c, {{ var("default_boolean") }}) as sbqq_include_in_maintenance,
isnull(stg.is_not_provisioned_c, {{ var("default_boolean") }}) as is_not_provisioned,
isnull(stg.last_modified_date	 AT TIME ZONE 'PST',	 '{{ var("default_date") }}') as last_modified_date,
isnull(stg.lcom_suite_c, '{{ var("default_varchar") }}') as lcom_suite_id,
isnull(lcom_suite.suite_name, '{{ var("default_varchar") }}') as lcom_suite,
isnull(stg.multiplier_c, {{ var("default_numeric") }}) as multiplier,
isnull(stg.netsuite_link_c, '{{ var("default_varchar") }}') as netsuite_link,
isnull(stg.net_suite_sku_c, '{{ var("default_varchar") }}') as net_suite_sku,
isnull(stg.sbqq_non_discountable_c, {{ var("default_boolean") }}) as sbqq_non_discountable,
isnull(stg.nyc_license_quantity_c, {{ var("default_numeric") }}) as nyc_license_quantity,
isnull(stg.price_dimensions_c, '{{ var("default_varchar") }}') as price_dimensions,
isnull(stg.sbqq_price_editable_c, {{ var("default_boolean") }}) as sbqq_price_editable,
isnull(stg.sbqq_pricing_method_c, '{{ var("default_varchar") }}') as sbqq_pricing_method,
isnull(stg.product_code, '{{ var("default_varchar") }}') as sfdc_product_code,
isnull(stg.description, '{{ var("default_varchar") }}') as sfdc_product_description,
isnull(stg.family, '{{ var("default_varchar") }}') as sfdc_product_family,
isnull(stg.product_sub_family_c, '{{ var("default_varchar") }}') as sfdc_product_sub_family,
isnull(stg.sbqq_quantity_editable_c, {{ var("default_boolean") }}) as sbqq_quantity_editable,
isnull(stg.sbqq_subscription_term_c, {{ var("default_numeric") }}) as sbqq_subscription_term,
isnull(stg.sbqq_subscription_type_c, '{{ var("default_varchar") }}') as sbqq_subscription_type,
isnull(stg.vidcode_org_id_c, '{{ var("default_varchar") }}') as vidcode_org_id
from {{ source("fivetran_salesforce_quickstart","product_2") }} stg
left outer join {{ ref("dim_lcom_suite") }} lcom_suite
on stg.lcom_suite_c = lcom_suite.sfdc_suite_id
{% if is_incremental() %}
where coalesce(stg.last_modified_date,'1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }}  t)
{% endif %}
{% if not is_incremental() %}
union all
select 
 '{{ var("default_ID") }}' as sfdc_product_id,
 '{{ var("default_varchar") }}' as sfdc_product_name,
 {{ var("default_boolean") }} as is_active,
 {{ var("default_boolean") }} as active_in_platform,
 {{ var("default_boolean") }} as sbqq_component,
 {{ var("default_boolean") }} as sbqq_cost_editable,
 '{{ var("default_date") }}' as created_date,
 {{ var("default_boolean") }} as does_not_prorate,
 {{ var("default_boolean") }} as sbqq_exclude_from_maintenance,
 {{ var("default_boolean") }} as sbqq_hidden,
 {{ var("default_boolean") }} as sbqq_include_in_maintenance,
 {{ var("default_boolean") }} as is_not_provisioned,
 '{{ var("default_date") }}' as last_modified_date,
 '{{ var("default_varchar") }}' as lcom_suite_id, 
 '{{ var("default_varchar") }}' as lcom_suite,
 {{ var("default_numeric") }} as multiplier,
 '{{ var("default_varchar") }}' as netsuite_link,
 '{{ var("default_varchar") }}' as net_suite_sku,
 {{ var("default_boolean") }} as sbqq_non_discountable,
 {{ var("default_numeric") }} as nyc_license_quantity,
 '{{ var("default_varchar") }}' as price_dimensions,
 {{ var("default_boolean") }} as sbqq_price_editable,
 '{{ var("default_varchar") }}' as sbqq_pricing_method,
 '{{ var("default_varchar") }}' as sfdc_product_code,
 '{{ var("default_varchar") }}' as sfdc_product_description,
 '{{ var("default_varchar") }}' as sfdc_product_family,
 '{{ var("default_varchar") }}' as sfdc_product_sub_family,
 {{ var("default_boolean") }} as sbqq_quantity_editable,
 {{ var("default_numeric") }} as sbqq_subscription_term,
 '{{ var("default_varchar") }}' as sbqq_subscription_type,
 '{{ var("default_varchar") }}' as vidcode_org_id
 {% endif %}
)
select
     sfdc_product_id::VARCHAR(50)
	,sfdc_product_name::VARCHAR(765)
	,is_active::BOOLEAN
	,active_in_platform::BOOLEAN
	,sbqq_component::BOOLEAN
	,sbqq_cost_editable::BOOLEAN
	,created_date::TIMESTAMP
	,does_not_prorate::BOOLEAN
	,sbqq_exclude_from_maintenance::BOOLEAN
	,sbqq_hidden::BOOLEAN
	,sbqq_include_in_maintenance::BOOLEAN
	,is_not_provisioned::BOOLEAN
	,last_modified_date::TIMESTAMP
	,lcom_suite_id::VARCHAR(50)
	,lcom_suite::VARCHAR(250)
	,multiplier::DOUBLE PRECISION
	,netsuite_link::VARCHAR(190)
	,net_suite_sku::VARCHAR(90)
	,sbqq_non_discountable::BOOLEAN
	,nyc_license_quantity::DOUBLE PRECISION
	,price_dimensions::VARCHAR(765)
	,sbqq_price_editable::BOOLEAN
	,sbqq_pricing_method::VARCHAR(765)
	,sfdc_product_code::VARCHAR(765)
	,sfdc_product_description::VARCHAR(4000)
	,sfdc_product_family::VARCHAR(765)
	,sfdc_product_sub_family::VARCHAR(765)
	,sbqq_quantity_editable::BOOLEAN
	,sbqq_subscription_term::DOUBLE PRECISION
	,sbqq_subscription_type::VARCHAR(765)
	,vidcode_org_id::VARCHAR(75),
'{{ var("loaddate") }}'::timestamp as loaddate
from data