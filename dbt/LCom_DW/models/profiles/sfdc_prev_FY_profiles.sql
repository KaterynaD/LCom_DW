{{ config(materialized='profiling',
        dist='all',
        profile_name='prev_FY_profile',
        schema_name='fivetran_salesforce_quickstart',
        profile_tables = [
        dict(        
        table_name='opportunity' 
            ),
        dict(
        table_name='account' 
            ),   
        dict(
        table_name='opportunity_line_item' 
            ),        
        dict(
        table_name='case' 
            ),     
        dict(
        table_name='training_session_c' 
            ),                                            
        ],
        where_clause="created_date between '2024-07-01' and '2025-06-30'",
        num_outliers_columns=['auto'],
        num_distribution_columns=['auto'],
        vc_top3_columns=['auto'],
        max_columns_per_batch=50,
        loaddate=var('loaddate')
) }}

