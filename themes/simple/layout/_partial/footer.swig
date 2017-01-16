<div class="copyright">
  <span class="power-by">
    Powered by <a class="hexo-link" href="https://hexo.io/">Hexo</a>
  </span>

  <span class="copyright-year">
    {% set current = date(Date.now(), "YYYY") %}
    &copy;
    {% if config.since and config.since != current %}
      {{ config.since }} -
    {% endif %}
    {{ current }}

    <span class="author">{{ config.author }}</span>
  </span>
</div>
