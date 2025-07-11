select * from {{  ref("record_type_part_1") }}
union all
select * from {{  ref("record_type_part_2") }}
union all
select * from {{  ref("record_type_part_3") }}