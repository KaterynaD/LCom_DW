select * from {{  ref("opportunity_line_item_part_1") }}
union all
select * from {{  ref("opportunity_line_item_part_2") }}
union all
select * from {{  ref("opportunity_line_item_part_3") }}
union all
select * from {{  ref("opportunity_line_item_part_4") }}
union all
select * from {{  ref("opportunity_line_item_part_5") }}
union all
select * from {{  ref("opportunity_line_item_part_6") }}
union all
select * from {{  ref("opportunity_line_item_part_7") }}
union all
select * from {{  ref("opportunity_line_item_part_8") }}
union all
select * from {{  ref("opportunity_line_item_part_9") }}