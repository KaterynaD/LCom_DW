-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_uncalculated_c", "x_5_year_progressive_c", "x_2_year_progressive_c", "print_quote_as_quote_c", "x_3_year_progressive_c", "is_not_discounted_c", "is_discounted_c", "x_4_year_progressive_c", "_fivetran_deleted", "contains_pd_c", "has_premium_service_c", "sbqq_watermark_shown_c", "extension_c", "include_acquisition_cover_sheet_c", "sbqq_line_items_grouped_c", "sbqq_consumption_rate_override_c", "regular_progressive_c", "sbqq_line_items_printed_c", "is_deleted", "no_charge_pilot_or_demo_c", "clear_end_date_c", "gold_service_on_quote_c", "tiered_services_discount_c", "sbqq_unopened_c", "start_date_populated_c", "otc_enabled_c", "include_w_9_c", "watermark_pb_c", "sbqq_primary_c", "include_payment_voucher_c", "nc_bundle_c", "has_coding_discount_c", "sbqq_order_by_quote_line_group_c", "sbqq_ordered_c", "has_enterprise_service_c", "print_quote_as_invoice_c"] ) }}

{% endif %}
