{% macro get_run_at_date() %}



    {% set run_at_date = run_started_at.astimezone(modules.pytz.timezone('America/Los_Angeles')).replace(microsecond=0)  %}

    {% do return(run_at_date) %}

{% endmacro %}