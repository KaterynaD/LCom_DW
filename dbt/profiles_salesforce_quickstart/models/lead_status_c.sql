select * from {{  ref("lead_status_c_part_1") }}
union all
select * from {{  ref("lead_status_c_part_2") }}
union all
select * from {{  ref("lead_status_c_part_3") }}
union all
select * from {{  ref("lead_status_c_part_4") }}