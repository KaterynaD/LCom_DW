select * from {{  ref("organization_part_1") }}
union all
select * from {{  ref("organization_part_2") }}
union all
select * from {{  ref("organization_part_3") }}
union all
select * from {{  ref("organization_part_4") }}
union all
select * from {{  ref("organization_part_5") }}