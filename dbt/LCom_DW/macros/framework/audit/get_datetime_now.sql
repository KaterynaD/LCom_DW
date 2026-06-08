{% macro get_datetime_now() %}



    {% set now = modules.datetime.datetime.now().astimezone(modules.pytz.timezone('America/Los_Angeles')).replace(microsecond=0)  %}

    {% do return(now) %}

{% endmacro %}