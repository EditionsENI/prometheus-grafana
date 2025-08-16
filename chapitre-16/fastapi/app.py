#!env python3

from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import start_http_server


start_http_server(port=8989)
app = FastAPI()

@app.get("/")
def index():
    return "Hello, world!"

Instrumentator().instrument(app)
