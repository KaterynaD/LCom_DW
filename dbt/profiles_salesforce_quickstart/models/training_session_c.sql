select * from {{  ref("training_session_part_1") }}
union all
select * from {{  ref("training_session_part_2") }}
union all
select * from {{  ref("training_session_part_3") }}
union all
select * from {{  ref("training_session_part_4") }}
union all
select * from {{  ref("training_session_part_5") }}