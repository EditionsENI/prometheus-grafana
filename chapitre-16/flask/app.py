#!env python3

from flask import Flask
from healthcheck import HealthCheck, EnvironmentDump
from prometheus_flask_exporter import PrometheusMetrics
from prometheus_client import start_http_server


index = """
<img src='https://prometheus.io/assets/prometheus_logo_grey.svg'/>
<br/><br/>
Access <a href='/healthcheck'>Healthcheck</a><br/>
Access <a href='/environment'>environnement information</a><br/>
Access <a href='/metrics'>metrics</a><br/>
"""

prom = start_http_server(port=5090)
app = Flask(__name__)

app.add_url_rule('/healthcheck', 'healthcheck', view_func=HealthCheck().run)
app.add_url_rule('/environment', 'environment', view_func=EnvironmentDump().run)
PrometheusMetrics(app, path=None)

@app.route('/')
def root():
    return index


if __name__ == "__main__":
    app.run(host="0.0.0.0")
