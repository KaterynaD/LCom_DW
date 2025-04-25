select * from {{  ref("lcom_order_modification_c_part_1") }}
union all
select * from {{  ref("lcom_order_modification_c_part_2") }}
union all
select * from {{  ref("lcom_order_modification_c_part_3") }}
union all
select * from {{  ref("lcom_order_modification_c_part_4") }}