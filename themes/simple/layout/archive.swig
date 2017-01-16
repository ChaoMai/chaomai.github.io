{% extends "_layout.swig" %}
{% import '_macro/archive_list.swig' as archive_template %}

{% block title %}
  {% if page.archive %}
    Archives · {{ config.title }}
  {% elif page.tag %}
    {{ page.tag }} · {{ config.title }}
  {% elif page.category %}
    {{ page.category }} · {{ config.title }}
  {% endif %}
{% endblock %}

{% block content %}
  {{ archive_template.render() }}
{% endblock %}
