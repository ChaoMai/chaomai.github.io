{% macro render(post) %}
  <article class="post">
    <header class="post-header">
      <h1 class="post-title">
        <a class="post-link" href="{{ url_for(post.path) }}">{{ post.title }}</a>
      </h1>

      <div class="post-meta">
        <span class="post-time">
          {{ full_date(post.date, 'll') }}
        </span>
      </div>
    </header>

    <div class="post-content">
      {% if post.description %}
        {% set excerpt = post.description %}
      {% elif post.excerpt %}
        {% set excerpt = post.excerpt %}
      {% endif %}

      {% if excerpt %}
        {{ excerpt }}

        <div class="read-more">
          <a href="{{ url_for(post.path) }}" class="read-more-link">Read more</a>
        </div>
      {% else %}
        {{ post.content }}
      {% endif %}

    </div>

  </article>
{% endmacro %}
