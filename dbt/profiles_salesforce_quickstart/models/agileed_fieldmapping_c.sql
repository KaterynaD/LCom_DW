select * from {{  ref("agileed_fieldmapping_c_part_1") }}
union all
select * from {{  ref("agileed_fieldmapping_c_part_2") }}
union all
select * from {{  ref("agileed_fieldmapping_c_part_3") }}