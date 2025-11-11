{{ config(materialized='profiling',
        dist='all',
        profile_name='full_profile',
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
        num_outliers_columns=['auto'],
        num_distribution_columns=['auto'],
        vc_top3_columns=['auto'],
        loaddate=var('loaddate')
) }}

