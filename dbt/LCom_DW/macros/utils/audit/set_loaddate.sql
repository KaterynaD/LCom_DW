{% macro set_loaddate() %}


{% set var_loaddate = get_run_at_date() %}

{{ return(var_loaddate) }}
{% endmacro %}