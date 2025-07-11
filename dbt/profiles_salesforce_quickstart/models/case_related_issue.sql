select * from {{  ref("case_related_issue_part_1") }}
union all
select * from {{  ref("case_related_issue_part_2") }}
union all
select * from {{  ref("case_related_issue_part_3") }}