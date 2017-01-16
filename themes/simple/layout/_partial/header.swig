<div class="site-title">
  <a href="{{ url_for('.') }}" class="title">{{ config.title }}</a>
</div>

<nav class="site-nav">
  {% if theme.menu %}
    <ul class="menu">
      {% for name, path in theme.menu %}
        {% set itemName = name.toLowerCase() %}
        <li class="menu-item">
          <a class="menu-item-link" href="{{ url_for(path) }}">
            {{ itemName }}
          </a>
        </li>
      {% endfor %}
    </ul>
  {% endif %}
</nav>
