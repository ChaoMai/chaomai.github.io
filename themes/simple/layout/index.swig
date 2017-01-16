{% extends "_layout.swig" %}
{% import '_macro/post_list.swig' as post_list %}

{% block title %} {{ config.title }} {% endblock %}

{% block content %}

  <section id="posts" class="posts">
    {% for post in page.posts %}
      {{ post_list.render(post) }}
    {% endfor %}
  </section>

  {% include "_partial/list_pagination.swig" %}

{% endblock %}
