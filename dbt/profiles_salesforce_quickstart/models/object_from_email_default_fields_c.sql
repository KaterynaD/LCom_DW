select * from {{  ref("object_from_email_default_fields_c_part_1") }}
union all
select * from {{  ref("object_from_email_default_fields_c_part_2") }}
union all
select * from {{  ref("object_from_email_default_fields_c_part_3") }}
union all
select * from {{  ref("object_from_email_default_fields_c_part_4") }}
union all
select * from {{  ref("object_from_email_default_fields_c_part_5") }}