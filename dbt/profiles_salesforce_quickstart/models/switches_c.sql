select * from {{  ref("switches_c_part_1") }}
union all
select * from {{  ref("switches_c_part_2") }}
union all
select * from {{  ref("switches_c_part_3") }}