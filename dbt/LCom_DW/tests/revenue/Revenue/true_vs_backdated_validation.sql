select *
from {{ ref("vw_true_to_backdated_arr_validation") }}
where pct_diff>1