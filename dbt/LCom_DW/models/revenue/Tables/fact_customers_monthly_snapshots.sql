{{ config(
        
        materialized='table',
        dist='sfdc_ultimate_parent_id',
        sort='mon_year'
)
 }}
with monthly_rawdata as (
select
	 mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	,record_type
	,include_flg
	,comments
from {{ ref("stg_customers_contract_monthly_snapshots") }}
where include_flg = true
and record_type='Starting'
union all
select
	 mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	,record_type
	,include_flg
	,comments
from {{ ref("stg_customers_churn_monthly_snapshots") }}
where include_flg = true or record_type='Churn'
union all
select
	 mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	,record_type
	,include_flg
	,comments
from {{ ref("stg_customers_new_monthly_snapshots") }}
where include_flg = true
and record_type in ('New','Returning','ReturningFY')
union all
select
	 mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	,record_type
	,include_flg
	,comments
from {{ ref("stg_customers_nonrenewal_monthly_snapshots") }}
where record_type in ('NonRenewal', 'Ghost')
)
,monthly_data as (
select
	 mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	,record_type
	,lead(record_type)	over (partition by sfdc_ultimate_parent_id order by mon_year) as next_record_type
	,include_flg
	,lead(include_flg)	over (partition by sfdc_ultimate_parent_id order by mon_year) as next_include_flg
	,comments
from monthly_rawdata
)
,final_data as (
select
     mon_year
	,mon_lastday
	,opportunity_id
	,sfdc_account_id
	,sfdc_ultimate_parent_id
	--if the next record type is the same as current - Churn and include_flg  is True and the same as current, 
	--then mark the current Churn as NonChurn
	--(the customer was NOT added back after the first Churn and we double substract)
	,case when record_type=next_record_type and record_type='Churn' and include_flg=next_include_flg and include_flg = True
	then 'Not Churn'
		else record_type
	end as record_type
	,case when record_type=next_record_type and record_type='Churn' and include_flg=next_include_flg and include_flg = True
	then False
		else include_flg
	end as include_flg
	,comments
from monthly_data
where 
	case when record_type=next_record_type and record_type='Churn' and include_flg=next_include_flg and include_flg = True
	then 'Not Churn'
		else record_type
	end != 'Not Churn'
)
select
     mon_year::integer
	,mon_lastday::date
	,opportunity_id::varchar(300)
	,sfdc_account_id::varchar(300)
	,sfdc_ultimate_parent_id::varchar(300)
	,include_flg::boolean
	,record_type::varchar(20)
	,comments::varchar(max)
	,'{{ var("loaddate") }}'::timestamp as loaddate
from final_data