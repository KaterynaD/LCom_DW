{% macro list_of_main_models() %}
    {% set tables = [] %}
    {% if execute %}
    {% for node_name, node in graph.nodes.items() %}
        {% if  not "_part_" in node.name and node.name not in ["district","school","mapping","all_profiles"] %}
            {% do tables.append(node.name) %}
        {% endif %}
    {% endfor %}
    {% do return(tables) %}
    {% endif %}
{% endmacro %}