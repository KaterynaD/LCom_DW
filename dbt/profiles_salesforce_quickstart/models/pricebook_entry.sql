select * from {{  ref("pricebook_entry_part_1") }}
union all
select * from {{  ref("pricebook_entry_part_2") }}
union all
select * from {{  ref("pricebook_entry_part_3") }}
union all
select * from {{  ref("pricebook_entry_part_4") }}