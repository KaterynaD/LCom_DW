select * from {{  ref("rcsfl_admin_setting_c_part_1") }}
union all
select * from {{  ref("rcsfl_admin_setting_c_part_2") }}
union all
select * from {{  ref("rcsfl_admin_setting_c_part_3") }}
union all
select * from {{  ref("rcsfl_admin_setting_c_part_4") }}