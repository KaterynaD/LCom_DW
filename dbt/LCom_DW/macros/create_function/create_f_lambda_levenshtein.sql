{% macro create_f_lambda_levenshtein() %}

{% set create_sp_operation %}

CREATE OR REPLACE EXTERNAL FUNCTION public.f_lambda_levenshtein(varchar, varchar)
RETURNS bool
STABLE
LAMBDA 'redshift-levenshtein'
IAM_ROLE 'arn:aws:iam::248725110737:role/service-role/AmazonRedshift-CommandsAccessRole-20240529T174848';

 {% endset %}

{{ run_DDL('f_lambda_usfederalholidaycalendar', create_sp_operation) }}



{% endmacro %}