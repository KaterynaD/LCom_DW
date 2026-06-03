{% macro create_levenshtein() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Creating levenshtein function in public schema ' , info=True) }}
 
 {% set create_sp_operation %}

CREATE OR REPLACE FUNCTION public.levenshtein(s varchar, t varchar)
	RETURNS int4
	LANGUAGE plpythonu
	STABLE
AS $$
	
    """
    levenshtein(s, t) -> ldist
    ldist is the Levenshtein distance between the strings
    s and t.
    For all i and j, dist[i,j] will contain the Levenshtein
    distance between the first i characters of s and the
    first j characters of t
    """
    if s is None and t is None:
        return 0
    if s is None:
        return len(t)
    if t is None:
        return len(s)

    rows = len(s)+1
    cols = len(t)+1
    dist = [[0 for x in range(cols)] for x in range(rows)]
    # source prefixes can be transformed into empty strings
    # by deletions:
    for i in range(1, rows):
        dist[i][0] = i
    # target prefixes can be created from an empty source string
    # by inserting the characters
    for i in range(1, cols):
        dist[0][i] = i

    for col in range(1, cols):
        for row in range(1, rows):
            if s[row-1] == t[col-1]:
                cost = 0
            else:
                cost = 1
            dist[row][col] = min(dist[row-1][col] + 1,      # deletion
                                 dist[row][col-1] + 1,      # insertion
                                 dist[row-1][col-1] + cost) # substitution

    return dist[rows-1][cols-1]

$$
;

{% endset %}

{% do run_query(create_sp_operation) %}

 {% endif %}

{% endmacro %} 