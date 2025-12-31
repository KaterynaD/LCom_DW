{% macro safe_select_list_from_profiles(
    table_name,
    alias,
    used_columns,
    profile_src=('profiles','sfdc_schema_audit'),
    base_profile='base',
    current_profile='current'
) %}
  {# Emits a stable SELECT list in the order of used_columns #}

  {% if not execute %}
    {# during parsing, just emit alias.col placeholders #}
    {{ return(used_columns | map('lower') | join(', ')) }}
  {% endif %}

  {% set missing_map = missing_defaults_map(
      table_name=table_name,
      used_columns=used_columns,
      profile_src=profile_src,
      base_profile=base_profile,
      current_profile=current_profile
  ) %}

  {% set parts = [] %}
  {% for c in used_columns %}
    {% set col = c | lower | trim %}
    {% if missing_map.get(col) is not none %}
      {% do parts.append(missing_map.get(col) ~ ' as ' ~ col) %}
    {% else %}
      {% do parts.append(alias ~ '.' ~ col ~ ' as ' ~ col) %}
    {% endif %}
  {% endfor %}

  {{ return(parts | join(',\n    ')) }}
{% endmacro %}
