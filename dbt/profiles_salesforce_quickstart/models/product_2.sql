select * from {{  ref("product_2_part_1") }}
union all
select * from {{  ref("product_2_part_2") }}
union all
select * from {{  ref("product_2_part_3") }}
union all
select * from {{  ref("product_2_part_4") }}
union all
select * from {{  ref("product_2_part_5") }}
union all
select * from {{  ref("product_2_part_6") }}