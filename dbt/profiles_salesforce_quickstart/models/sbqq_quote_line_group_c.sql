select * from {{  ref("sbqq_quote_line_group_c_part_1") }}
union all
select * from {{  ref("sbqq_quote_line_group_c_part_2") }}
union all
select * from {{  ref("sbqq_quote_line_group_c_part_3") }}
union all
select * from {{  ref("sbqq_quote_line_group_c_part_4") }}
union all
select * from {{  ref("sbqq_quote_line_group_c_part_5") }}
union all
select * from {{  ref("sbqq_quote_line_group_c_part_6") }}