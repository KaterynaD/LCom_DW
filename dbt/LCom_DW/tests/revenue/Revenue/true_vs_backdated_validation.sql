select *
from {{ ref("vw_true_to_backdated_arr_validation") }}
/*there is 1.5 - 8.5% difference with negative and replacment opportunities added in 2017/2018 FY*/
where mon_year >= 201807 and pct_diff>1