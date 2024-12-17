# User Configuration Guide

This section provides detailed instructions and examples for configuring the Helm chart via values.yaml.


### 1 General Application Configuration

```yaml
app:
  name: auto-scale-app
  namespace: default
  image:
    repository: my-docker-repo/auto-scale-app
    tag: v1.0.0
    pullPolicy: IfNotPresent
  port: 8080
  metricsPath: /metrics
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

### 2 Prometheus Configuration

```yaml
prometheus:
  enabled: true
  scrapeInterval: 15s
  scrapeConfigs:
    - job_name: 'auto-scale-app'
      static_configs:
        - targets: ['auto-scale-app:8080']
```

### 3 Prometheus Adapter Configuration

```yaml
prometheusAdapter:
  enabled: true
  rules:
    - seriesQuery: 'http_requests_total{namespace!="",pod!=""}'
      resources:
        overrides:
          namespace: {resource: "namespace"}
          pod: {resource: "pod"}
      name:
        matches: "^(.*)_total"
        as: "${1}_per_second"
      metricsQuery: 'rate(<<.Series>>{<<.LabelMatchers>>}[2m])'
```

### 4 HPA Configuration

```yaml
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 10
```

## 6. Metrics Scraping and Handling

### 6.1 Metrics Exposure

Python Example:

```python
from prometheus_client import start_http_server, Counter
import time

REQUESTS = Counter('http_requests_total', 'Total HTTP Requests')

def process_request():
    REQUESTS.inc()

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        process_request()
        time.sleep(1)
```

Node.js Example:

```javascript
const express = require('express');
const promClient = require('prom-client');

const app = express();
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestsTotal = new promClient.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests'
});

app.get('/', (req, res) => {
    httpRequestsTotal.inc();
    res.send('Hello World!');
});

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', promClient.register.contentType);
    res.end(await promClient.register.metrics());
});

app.listen(8080, () => console.log('Server running on port 8080'));
```