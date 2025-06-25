{% macro get_day_of_month_now() %}



    {% set day_now = modules.datetime.datetime.now().astimezone(modules.pytz.timezone('America/Los_Angeles')).day  %}

    {% do return(day_now) %}

{% endmacro %}