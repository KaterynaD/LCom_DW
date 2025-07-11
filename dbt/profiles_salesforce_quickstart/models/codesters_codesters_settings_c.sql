select * from {{  ref("codesters_codesters_settings_c_part_1") }}
union all
select * from {{  ref("codesters_codesters_settings_c_part_2") }}
union all
select * from {{  ref("codesters_codesters_settings_c_part_3") }}