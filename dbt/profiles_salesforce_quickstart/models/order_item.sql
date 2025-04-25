select * from {{  ref("order_item_part_1") }}
union all
select * from {{  ref("order_item_part_2") }}
union all
select * from {{  ref("order_item_part_3") }}
union all
select * from {{  ref("order_item_part_4") }}
union all
select * from {{  ref("order_item_part_5") }}
union all
select * from {{  ref("order_item_part_6") }}