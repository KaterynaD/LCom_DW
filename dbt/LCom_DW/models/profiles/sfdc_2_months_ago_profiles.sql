{{ config(materialized='profiling',
        dist='all',
        profile_name='2_months_ago',
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
        where_clause="created_date >= date_trunc('month', add_months(current_date, -2)) AND created_date <  date_trunc('month', add_months(current_date, -1))",
        num_outliers_columns=['auto'],
        num_distribution_columns=['auto'],
        vc_top3_columns=['auto'],
        loaddate=var('loaddate')
) }}

