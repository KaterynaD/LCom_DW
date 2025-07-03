select account_id FROM {{ ref("dim_account") }}
except
select account_id FROM {{ ref("dim_account_history") }}