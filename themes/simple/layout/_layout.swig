<!DOCTYPE html>
<html lang="{{ config.language }}">
  <head>
    {% include '_partial/head.swig' %}
    <title>{% block title %}{% endblock %}</title>
  </head>

  <body>

    <div class="container">
      <header class="header">
        {%- include '_partial/header.swig' %}
      </header>

      <div class="content-wrapper">
        <main class="main">
          <div class="content">
            {% block content %}{% endblock %}
          </div>

          {% include '_partial/comments.swig' %}
        </main>

       <footer class="footer">
        {%- include '_partial/footer.swig' %}
       </footer>
      </div>
    </div>

    {% include '_script/comments.swig' %}
    {% include '_script/mathjax.swig' %}

  </body>
</html>
