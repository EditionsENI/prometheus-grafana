#!env python3

from flask import Flask
from healthcheck import HealthCheck, EnvironmentDump
from prometheus_flask_exporter import PrometheusMetrics


index = """
<img src='https://prometheus.io/assets/prometheus_logo_grey.svg'/>
<br/><br/>
Access <a href='/healthcheck'>Healthcheck</a><br/>
Access <a href='/environment'>environnement information</a><br/>
Access <a href='/metrics'>metrics</a><br/>
"""

app = Flask(__name__)

HealthCheck(app, "/healthcheck")
EnvironmentDump(app, "/environment")
PrometheusMetrics(app, "/metrics")


@app.route('/')
def root():
    return index


if __name__ == "__main__":
    app.run(host="0.0.0.0")
