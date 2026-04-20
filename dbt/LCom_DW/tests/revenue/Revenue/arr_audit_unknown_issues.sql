select distinct
    a.opportunity_id
from {{ ref("dim_arr_issue") }} i 
join {{ ref("dim_arr_audit") }} a
on i.issue_id = a.issue_id
where i.issue = 'Other'