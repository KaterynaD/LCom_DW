{% macro create_FKs_set_1() %}
 {% set create_FKs_operation %}


--
ALTER TABLE licensing.fact_license_order ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.fact_license_order ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);
ALTER TABLE licensing.fact_license_order_history ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.fact_license_order_history ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);
ALTER TABLE licensing.fact_license_order_history ADD FOREIGN KEY (order_id) REFERENCES licensing.fact_license_order(order_id);
--
--
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (order_id) REFERENCES licensing.fact_license_order(order_id);
--

ALTER TABLE revenue.fact_opportunity_history ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
ALTER TABLE revenue.fact_opportunity_history ADD FOREIGN KEY (opportunity_id) REFERENCES revenue.fact_opportunity(opportunity_id);



{% endset %}

{% do run_query(create_FKs_operation) %}

{% endmacro %} 