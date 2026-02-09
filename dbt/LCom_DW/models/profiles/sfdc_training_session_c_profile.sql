{{ config(materialized='profiling',
        tags=['sfdc_profile'],
        dist='all',        
        profile_tables = [
        dict(        
        table_name='training_session_c' ,
        schema_name='fivetran_salesforce_quickstart',
        profile_name=var('sfdc_profile_name','current'),
            )                                    
        ],
        exclude_stats_numeric=['placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'],
        exclude_stats_varchar=['placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'],
        exclude_stats_datetime=['placeholder','min','max'],
        num_outliers_columns=[],
        num_distribution_columns=[],
        vc_top3_columns=[],
        loaddate=var('loaddate', '1900-01-01'),
) }}
