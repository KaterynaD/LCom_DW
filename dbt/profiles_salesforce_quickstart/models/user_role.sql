select * from {{  ref("user_role_part_1") }}
union all
select * from {{  ref("user_role_part_2") }}
union all
select * from {{  ref("user_role_part_3") }}