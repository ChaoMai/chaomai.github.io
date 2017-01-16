{% extends "_layout.swig" %}
{% import '_macro/post_content.swig' as post_template %}

{% block title %} {{ page.title }} · {{ config.title }} {% endblock %}

{% block content %}
  {{ post_template.render(page) }}
{% endblock %}
