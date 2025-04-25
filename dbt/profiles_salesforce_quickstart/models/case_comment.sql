select * from {{  ref("case_comment_part_1") }}
union all
select * from {{  ref("case_comment_part_2") }}
union all
select * from {{  ref("case_comment_part_3") }}