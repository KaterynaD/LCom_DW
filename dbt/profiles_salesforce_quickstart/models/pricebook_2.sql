select * from {{  ref("pricebook_2_part_1") }}
union all
select * from {{  ref("pricebook_2_part_2") }}
union all
select * from {{  ref("pricebook_2_part_3") }}