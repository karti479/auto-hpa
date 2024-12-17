
<!-- Contact Information -->
<div align="center" style="background-color: #f4f4f4; padding: 10px; border-radius: 5px;">
  <h3>📞 Contact Me</h3>
  <p>
    <strong>Email:</strong> <a href="karti479@gmail.com">karti479@gmail.com | 
    <strong>Phone:</strong> <a href="tel:+1234567890">+91-8742983860</a> <br />
    <strong>GitHub:</strong> <a href="https://github.com/karti479" target="_blank">GitHub Profile</a> | 
    <strong>LinkedIn:</strong> <a href="https://www.linkedin.com/in/product-kartik/" target="_blank">LinkedIn Profile</a>
  </p>
</div>


# Auto-HPA


- The Auto-HPA Metrics Helm Chart provides a production-ready solution to 
- dynamically scale Kubernetes workloads using custom metrics, CPU/memory metrics, and external metrics. 
- It integrates seamlessly with Prometheus, Prometheus Adapter, and Kubernetes(Horizontal Pod Autoscaler).

## Repo
```yaml
https://github.com/karti479/auto-hpa.git
```

## 1. Overview

The Auto-Scale Metrics Helm Chart provides a production-grade solution for scaling Kubernetes workloads dynamically using:

- Kubernetes HPA (Horizontal Pod Autoscaler)
- Prometheus Adapter for custom metrics
- Prometheus for metrics collection and monitoring

It supports scaling based on:

- CPU/Memory Utilization
- Custom Metrics like request rates, latency, or error rates
- External Metrics such as job queues or user-defined indicators

The chart is highly configurable and integrates modularly with existing Prometheus setups.





## 2. Features




| Feature      |                                                            Description |
|---------     |                                                            -------------|
| Dynamic Scaling    | Scale workloads dynamically based on CPU, memory, and custom metrics. |
| Custom Metrics Support | Uses Prometheus Adapter for translating metrics for HPA. |
| Health Monitoring | Liveness and readiness probes for application, Prometheus, and adapter. |
| RBAC Integration | Ensures secure access to Kubernetes API and custom metrics endpoints. |
| Modular Design | Deploy Prometheus, Adapter, and HPA independently or together. |
| Production-Ready | Namespace isolation, robust health checks, and resource configurations. |
| Scalable | Supports multi-metric scaling and advanced configurations. |


## 3. Architecture and Components

The Helm chart consists of the following key components:

### 3.1 Application Deployment
- Deploys the user application
- Exposes a /metrics endpoint compatible with Prometheus

### 3.2 Prometheus
- Scrapes metrics from the /metrics endpoint
- Provides a centralized metrics store for Kubernetes HPA

### 3.3 Prometheus Adapter
- Translates Prometheus metrics into Kubernetes Custom Metrics API
- Enables Kubernetes HPA to use custom metrics for scaling

### 3.4 HPA (Horizontal Pod Autoscaler)
- Queries Kubernetes Metrics API to scale pods dynamically

## 4. Installation Guide

### 4.1 Prerequisites
Ensure the following are available:
1. Kubernetes Cluster (v1.24+)
2. Helm (v3+)
3. Prometheus-compatible Application exposing metrics at /metrics

### 4.2 Steps for Installation

Step 1: Clone the Helm Chart Repository

```yaml
git clone https://github.com/karti479/auto-hpa.git
cd auto-hpa
```

Step 2: Configure values.yaml
Customize your values.yaml file as per your requirements (refer to section 5. User Configuration Guide).

Step 3: Install the Helm Chart
```yaml
helm install auto-scale ./auto-scale-metrics -f values.yaml
```

Step 4: Verify Installation
- Check all resources:
```yaml
kubectl get all -n <namespace>
```
- Validate the Prometheus and Adapter pods:
```yaml
kubectl get pods -n <namespace>
```

## 5. User Configuration Guide

This section provides detailed instructions and examples for configuring the Helm chart via values.yaml.

### 5.1 General Application Configuration

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

### 5.2 Prometheus Configuration

```yaml
prometheus:
  enabled: true
  scrapeInterval: 15s
  scrapeConfigs:
    - job_name: 'auto-scale-app'
      static_configs:
        - targets: ['auto-scale-app:8080']
```

### 5.3 Prometheus Adapter Configuration

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

### 5.4 HPA Configuration

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

## 7. Health Monitoring

```yaml
healthChecks:
  prometheus:
    liveness:
      httpGet:
        path: /-/healthy
        port: 9090
    readiness:
      httpGet:
        path: /-/ready
        port: 9090
  prometheusAdapter:
    liveness:
      httpGet:
        path: /healthz
        port: 6443
    readiness:
      httpGet:
        path: /healthz
        port: 6443
  app:
    liveness:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
    readiness:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
```

## 8. Product Workflow

1. Application exposes metrics
2. Prometheus scrapes metrics
3. Prometheus Adapter translates metrics
4. HPA queries Custom Metrics API
5. HPA makes scaling decisions
6. Kubernetes scales the deployment

## 9. Use Cases

### 9.1 CPU and Memory Scaling

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
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### 9.2 Scaling Based on Requests Per Second

```yaml
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 50
```

### 9.3 Scaling Based on Queue Length

```yaml
hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: External
      external:
        metric:
          name: queue_messages_ready
          selector:
            matchLabels:
              queue: "worker-jobs"
        target:
          type: AverageValue
          averageValue: 30
```

## 10. Troubleshooting Guide

### 10.1 HPA Not Scaling

1. Check HPA status:
```yaml
   kubectl describe hpa <hpa-name> -n <namespace>
```

2. Verify metrics:
 ```yaml
   kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second" | jq .
```

3. Check Prometheus Adapter logs:
```yaml
   kubectl logs -l app=prometheus-adapter -n <namespace>
```

### 10.2 Prometheus Not Scraping Metrics

1. Check Prometheus targets:
```python
   kubectl port-forward svc/prometheus 9090:9090 -n <namespace>
```
Then visit http://localhost:9090/targets

2. Verify scrape config:
```yaml
   kubectl get configmap prometheus-server -n <namespace> -o yaml
```

### 10.3 Application Not Exposing Metrics

1. Check if metrics endpoint is accessible:
```python
   kubectl port-forward svc/<app-service> 8080:8080 -n <namespace>
   curl http://localhost:8080/metrics
```

2. Verify application logs:
```python
   kubectl logs <pod-name> -n <namespace>
```

## 11. Pricing and Licensing

- Free Usage: Helm chart available for free.
- Annual Support Licensing: ₹1,000 INR/year.
- Includes email support and regular updates.
- karti479@gmail.com/ https://www.linkedin.com/in/product-kartik/

## 12. Best Practices

1. Set appropriate resource requests and limits for all components.
2. Use namespaces to isolate the auto-scaling setup.
3. Regularly update the Helm chart and its dependencies.
4. Monitor and alert on the health of Prometheus and Prometheus Adapter.
5. Test scaling behavior in a non-production environment before deploying to production.

## 13. Conclusion

The Auto-Scale Metrics Helm Chart provides a robust, flexible solution for implementing custom metrics-based autoscaling in Kubernetes environments. By leveraging Prometheus and the Prometheus Adapter, it enables fine-grained control over scaling decisions based on application-specific metrics.

## 14. Extended User Guide

### 14.1 Advanced Prometheus Adapter Configuration

```yaml

prometheusAdapter:
  rules:
    - seriesQuery: '{__name__=~"^container_.*",container!="POD",namespace!="",pod!=""}'
      seriesFilters: []
      resources:
        overrides:
          namespace:
            resource: namespace
          pod:
            resource: pod
      name:
        matches: ^container_(.*)_seconds_total$
        as: "${1}_per_second"
      metricsQuery: sum(rate(<<.Series>>{<<.LabelMatchers>>}[1m])) by (<<.GroupBy>>)
```

### 14.2 Implementing Custom Metrics

1. Define the metric in your application
2. Expose the metric via the /metrics endpoint
3. Configure Prometheus to scrape the metric
4. Set up Prometheus Adapter rules to make the metric available to Kubernetes
5. Configure HPA to use the custom metric

## Example workflow for a 'queue_depth' metric:


1. Application code (Python):

```python
   from prometheus_client import Gauge
   
   QUEUE_DEPTH = Gauge('queue_depth', 'Number of items in the queue')
   
   def process_queue():
       depth = get_queue_depth()  # Your queue depth logic here
       QUEUE_DEPTH.set(depth)
```

2. Prometheus scrape config:

```yaml
   scrape_configs:
     - job_name: 'queue-app'
       static_configs:
         - targets: ['queue-app:8080']
```

3. Prometheus Adapter rule:

```yaml
   rules:
     - seriesQuery: 'queue_depth'
       resources:
         overrides:
           namespace: {resource: "namespace"}
           pod: {resource: "pod"}
       name:
         matches: "^(.*)$"
         as: "${1}"
       metricsQuery: 'avg(<<.Series>>{<<.LabelMatchers>>})'
```

4. HPA configuration:

```yaml
   hpa:
     metrics:
       - type: Pods
         pods:
           metric:
             name: queue_depth
           target:
             type: AverageValue
             averageValue: 100
```


This extended guide provides more in-depth examples and configurations to help users implement advanced autoscaling scenarios using the Auto-Scale Metrics Helm Chart.

<!-- Contact Information -->
<div align="center" style="background-color: #f4f4f4; padding: 10px; border-radius: 5px;">
  <h3>📞 Contact Me</h3>
  <p>
    <strong>Email:</strong> <a href="karti479@gmail.com">karti479@gmail.com | 
    <strong>Phone:</strong> <a href="tel:+1234567890">+91-8742983860</a> <br />
    <strong>GitHub:</strong> <a href="https://github.com/karti479" target="_blank">GitHub Profile</a> | 
    <strong>LinkedIn:</strong> <a href="https://www.linkedin.com/in/product-kartik/" target="_blank">LinkedIn Profile</a>
  </p>
</div>
