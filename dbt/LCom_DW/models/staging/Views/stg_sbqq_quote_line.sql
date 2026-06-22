{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}

with rawdata as (select
     {{ safe_select_list_from_profiles(
        table_name='sbqq_quote_line_c',
        alias='sfdc_quote_line',
        used_columns=[ 
			'Id',
'sbqq_pricing_method_c',
'sbqq_existing_c',
'sbqq_carryover_line_c',
'sbqq_quantity_c',
'sbqq_prior_quantity_c',
'sbqq_upgraded_quantity_c',
'sbqq_allow_asset_refund_c',
'sbqq_subscription_pricing_c',
'sbqq_bundled_c',
'sbqq_prorated_list_price_c',
'sbqq_customer_price_c',
'sbqq_discount_schedule_type_c',
'sbqq_additional_discount_amount_c',
'sbqq_discount_c'
			],
        profile_src=('profiles','vw_sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'

    ) }}
			from {{ source('fivetran_salesforce', 'sbqq_quote_line_c') }} as sfdc_quote_line
where NOT sfdc_quote_line._fivetran_deleted )
select
id
,CASE
WHEN sbqq_discount_schedule_type_c = 'Slab'
OR sbqq_pricing_method_c = 'Block'
THEN
CASE
WHEN (
NOT sbqq_existing_c
AND NOT sbqq_carryover_line_c
AND sbqq_quantity_c = 0
)
OR (
(sbqq_existing_c OR sbqq_carryover_line_c)
AND (
sbqq_quantity_c = sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
OR (
NOT sbqq_allow_asset_refund_c
AND sbqq_subscription_pricing_c = ''
AND sbqq_quantity_c < sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
)
)
)
THEN 0
ELSE 1
END
ELSE
CASE
WHEN NOT sbqq_existing_c
AND NOT sbqq_carryover_line_c
THEN sbqq_quantity_c
WHEN sbqq_quantity_c >= sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
THEN
CASE
WHEN sbqq_subscription_pricing_c = 'Percent Of Total'
THEN sbqq_quantity_c
ELSE sbqq_quantity_c - sbqq_prior_quantity_c + sbqq_upgraded_quantity_c
END
ELSE
CASE
WHEN NOT sbqq_allow_asset_refund_c
AND sbqq_subscription_pricing_c = ''
THEN 0
ELSE sbqq_quantity_c - sbqq_prior_quantity_c + sbqq_upgraded_quantity_c
END
END
end as sbqq_effective_quantity_c,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------ Total Discount (Amt) ----------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
CASE
WHEN SBQQ_Bundled_c THEN 0
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND NOT sbqq_existing_c
THEN
(sbqq_prorated_list_price_c * SBQQ_Quantity_c - sbqq_customer_price_c)
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND sbqq_existing_c
THEN
(sbqq_prorated_list_price_c * (SBQQ_Quantity_c - sbqq_prior_quantity_c) - sbqq_customer_price_c)
ELSE
(sbqq_prorated_list_price_c - sbqq_customer_price_c) * sbqq_effective_quantity_c
end as SBQQ__TotalDiscountAmount_c,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------ Total Discount (%) -----------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
CASE
WHEN sbqq_prorated_list_price_c = 0 THEN 0
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND NOT sbqq_existing_c
THEN
CASE
WHEN sbqq_quantity_c = 0 THEN 0
ELSE
(
sbqq_prorated_list_price_c * sbqq_quantity_c
- sbqq_customer_price_c
)
/
NULLIF(
sbqq_quantity_c * sbqq_prorated_list_price_c,
0
)
END
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND sbqq_existing_c
THEN
CASE
WHEN sbqq_quantity_c = sbqq_prior_quantity_c THEN 0
ELSE
(
sbqq_prorated_list_price_c
* (sbqq_quantity_c - sbqq_prior_quantity_c)
- sbqq_customer_price_c
)
/
NULLIF(
(sbqq_quantity_c - sbqq_prior_quantity_c)
* sbqq_prorated_list_price_c,
0
)
END
ELSE
(sbqq_prorated_list_price_c - sbqq_customer_price_c)
/ NULLIF(sbqq_prorated_list_price_c, 0)
END AS SBQQ__TotalDiscountRate_c,
sbqq_additional_discount_amount_c,
sbqq_discount_c
from rawdata