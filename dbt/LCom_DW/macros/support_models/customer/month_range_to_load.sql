 {% macro month_range_to_load() %}

{%  if var("load_history")==1 %}
 
 mon_year>=202205 and mon_year<=202507

{% else %}


 {%  if get_day_of_month_now()<=5 %}

 --Previous and Current month first 5 days
 mon_year in ( GETDATE(), 'YYYYMM')::int, 
               TO_CHAR(DATEADD(month, -1, GETDATE()), 'YYYYMM')::int)
{% else %}

--Only current month after 5th
 mon_year = TO_CHAR(GETDATE(), 'YYYYMM')::int
 
{% endif %}
{% endif %}

{% endmacro %}