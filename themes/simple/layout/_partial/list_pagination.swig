<nav class="pagination">
  {% if page.prev %}
    <a class="prev" href="{{ url_for(page.prev_link) }}">
      <i class="iconfont icon-left"></i>
      <span class="prev-text">prev</span>
    </a>
  {% endif %}
  {% if page.next %}
    <a class="next" href="{{ url_for(page.next_link) }}">
      <span class="next-text">next</span>
      <i class="iconfont icon-right"></i>
    </a>
  {% endif %}
</nav>
