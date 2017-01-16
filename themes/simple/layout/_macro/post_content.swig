{% macro render(post) %}
  <article class="post">
    <header class="post-header">
      <h1 class="post-title">
        {{ post.title }}
      </h1>

      <div class="post-meta">
        <span class="post-time">
          {{ full_date(post.date, 'll') }}
        </span>
      </div>
    </header>

    <div class="post-toc">
      <h2 class="post-toc-title">Contents</h2>
      <div class="post-toc-content">
        {{ toc(page.content, {list_number: false}) }}
      </div>
    </div>

    <div class="post-content">
      {{ post.content }}
    </div>

    <footer class="post-footer">
      <div class="post-tags">
        {% for tag in post.tags %}
          <a href="{{ url_for(tag.path) }}">{{ tag.name }}</a>
        {% endfor %}
      </div>
    </footer>

  </article>
{% endmacro %}
