{% macro Recreating_all_FK()  %}


{% set create_FKs_operation %}



-- TO common.dim_account
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.fact_license_order ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE licensing.fact_license_order_history ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE revenue.fact_opportunity ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
ALTER TABLE revenue.fact_opportunity_history ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE content_delivery_usage.fact_launches_monthly_snapshots ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE content_delivery_usage.fact_launches_weekly_snapshots ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);
ALTER TABLE content_delivery_usage.fact_launches_monthly_snapshots ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
ALTER TABLE content_delivery_usage.fact_launches_weekly_snapshots ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE content_delivery_usage.fact_students_usage_monthly_snapshots ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);   
ALTER TABLE content_delivery_usage.fact_students_usage_monthly_snapshots ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE content_delivery_usage.fact_students_completions_monthly_snapshots ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);   
ALTER TABLE content_delivery_usage.fact_students_completions_monthly_snapshots ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE support.fact_case ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
ALTER TABLE support.fact_case_history ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
--
ALTER TABLE content_delivery_usage.fact_training_session ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);
ALTER TABLE content_delivery_usage.fact_training_session_history ADD FOREIGN KEY (account_id) REFERENCES common.dim_account(account_id);

-- TO common.dim_employee
ALTER TABLE support.fact_case ADD FOREIGN KEY (owner_id) REFERENCES common.dim_employee(employee_id);
ALTER TABLE support.fact_case_history ADD FOREIGN KEY (owner_id) REFERENCES common.dim_employee(employee_id);
--
ALTER TABLE content_delivery_usage.fact_training_session ADD FOREIGN KEY (owner_id) REFERENCES common.dim_employee(employee_id);
ALTER TABLE content_delivery_usage.fact_training_session_history ADD FOREIGN KEY (owner_id) REFERENCES common.dim_employee(employee_id);

-- TO common.dim_lcom_sku
ALTER TABLE licensing.fact_license_order ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);
ALTER TABLE licensing.fact_license_order_history ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);
ALTER TABLE content_delivery_usage.dim_lcom_sku_learning_object ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);
ALTER TABLE common.dim_lcom_suite_sku ADD FOREIGN KEY (sku_id) REFERENCES common.dim_lcom_sku(sku_id);

-- TO content_delivery_usage.dim_learning_object
ALTER TABLE content_delivery_usage.dim_lcom_sku_learning_object ADD FOREIGN KEY (learning_object_id) REFERENCES content_delivery_usage.dim_learning_object(learning_object_id);
ALTER TABLE content_delivery_usage.dim_sequence_learning_object ADD FOREIGN KEY (learning_object_id) REFERENCES content_delivery_usage.dim_learning_object(learning_object_id);
ALTER TABLE content_delivery_usage.dim_product_category_learning_object_monthly ADD FOREIGN KEY (learning_object_id) REFERENCES content_delivery_usage.dim_learning_object(learning_object_id);

-- TO common.dim_lcom_suite
ALTER TABLE common.dim_lcom_suite_sku ADD FOREIGN KEY (suite_id) REFERENCES common.dim_lcom_suite(suite_id);

-- TO support.fact_case
ALTER TABLE support.fact_case_history ADD FOREIGN KEY (case_id) REFERENCES support.fact_case(case_id);

-- TO revenue.fact_opportunity
ALTER TABLE revenue.fact_opportunity_history ADD FOREIGN KEY (opportunity_id) REFERENCES revenue.fact_opportunity(opportunity_id);

-- TO content_delivery_usage.dim_sequence
ALTER TABLE content_delivery_usage.dim_sequence_learning_object ADD FOREIGN KEY (sequence_id) REFERENCES content_delivery_usage.dim_sequence(sequence_id);

-- TO content_delivery_usage.fact_training_session
ALTER TABLE content_delivery_usage.fact_training_session_history ADD FOREIGN KEY (training_session_id) REFERENCES content_delivery_usage.fact_training_session(training_session_id);

--TO common.dim_sfdc_product
ALTER TABLE revenue.dim_opportunity_line ADD FOREIGN KEY (sfdc_product_id) REFERENCES common.dim_sfdc_product(sfdc_product_id);
ALTER TABLE revenue.dim_opportunity_line_history ADD FOREIGN KEY (sfdc_product_id) REFERENCES common.dim_sfdc_product(sfdc_product_id);

-- TO content_delivery_usage.dim_topic
ALTER TABLE content_delivery_usage.dim_training_session_topic_session ADD FOREIGN KEY (topic_id) REFERENCES content_delivery_usage.dim_training_session_topic(topic_id);

-- TO content_delivery_usage.fact_training_session
ALTER TABLE content_delivery_usage.dim_training_session_topic_session ADD FOREIGN KEY (training_session_id) REFERENCES content_delivery_usage.fact_training_session(training_session_id);

--TO revenue.dim_opportunity_line
ALTER TABLE revenue.dim_opportunity_line_history ADD FOREIGN KEY (opportunity_line_id) REFERENCES revenue.dim_opportunity_line(opportunity_line_id);

--TO licensing.fact_license_order
ALTER TABLE licensing.dim_license_order_school ADD FOREIGN KEY (order_id) REFERENCES licensing.fact_license_order(order_id);




{% endset %}

{% do run_query(create_FKs_operation) %}



{% endmacro  %}