# Auto-Scale Metrics Helm Chart Documentation

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Architecture and Components](#architecture-and-components)
4. [Installation Guide](#installation-guide)
5. [User Configuration Guide](#user-configuration-guide)
6. [Metrics Scraping and Handling](#metrics-scraping-and-handling)
7. [Health Monitoring](#health-monitoring)
8. [Product Workflow](#product-workflow)
9. [Use Cases](#use-cases)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [Pricing and Licensing](#pricing-and-licensing)
12. [Best Practices](#best-practices)
13. [Conclusion](#conclusion)
14. [Extended User Guide](#extended-user-guide)

## Overview

The Auto-Scale Metrics Helm Chart provides a production-grade solution for scaling Kubernetes workloads dynamically using:
- Kubernetes HPA (Horizontal Pod Autoscaler)
- Prometheus Adapter for custom metrics
- Prometheus for metrics collection and monitoring

It supports scaling based on:
1. CPU/Memory Utilization
2. Custom Metrics like request rates, latency, or error rates
3. External Metrics such as job queues or user-defined indicators

The chart is highly configurable and integrates modularly with existing Prometheus setups.

## Features

| Feature | Description |
|---------|-------------|
| Dynamic Scaling | Scale workloads dynamically based on CPU, memory, and custom metrics. |
| Custom Metrics Support | Uses Prometheus Adapter for translating metrics for HPA. |
| Health Monitoring | Liveness and readiness probes for application, Prometheus, and adapter. |
| RBAC Integration | Ensures secure access to Kubernetes API and custom metrics endpoints. |
| Modular Design | Deploy Prometheus, Adapter, and HPA independently or together. |
| Production-Ready | Namespace isolation, robust health checks, and resource configurations. |
| Scalable | Supports multi-metric scaling and advanced configurations. |

## Architecture and Components

The Helm chart consists of the following key components:

### Application Deployment
- Deploys the user application
- Exposes a /metrics endpoint compatible with Prometheus

### Prometheus
- Scrapes metrics from the /metrics endpoint
- Provides a centralized metrics store for Kubernetes HPA

### Prometheus Adapter
- Translates Prometheus metrics into Kubernetes Custom Metrics API
- Enables Kubernetes HPA to use custom metrics for scaling

### HPA (Horizontal Pod Autoscaler)
- Queries Kubernetes Metrics API to scale pods dynamically

## Installation Guide

### Prerequisites
Ensure the following are available:
1. Kubernetes Cluster (v1.24+)
2. Helm (v3+)
3. Prometheus-compatible Application exposing metrics at /metrics

### Steps for Installation

Step 1: Clone the Helm Chart Repository
```bash
git clone <repo-url>
cd auto-scale-metrics
```

Step 2: Configure values.yaml
Customize your values.yaml file as per your requirements (refer to section 5. User Configuration Guide).

Step 3: Install the Helm Chart
```bash
helm install auto-scale ./auto-scale-metrics -f values.yaml
```

Step 4: Verify Installation
- Check all resources:
```bash
kubectl get all -n <namespace>
```
- Validate the Prometheus and Adapter pods:
```bash
kubectl get pods -n <namespace>
```

## User Configuration Guide

This section provides detailed instructions and examples for configuring the Helm chart via values.yaml. The guide covers all user needs and probable conditions for configuring the application, Prometheus, Prometheus Adapter, HPA, and health checks.

### General Application Configuration

This section defines the application's deployment details, including the image, ports, and namespace.

```yaml
app:
  name: auto-scale-app             # Application name
  namespace: default               # Kubernetes namespace
  image:
    repository: my-docker-repo/auto-scale-app
    tag: latest                    # Image tag
    pullPolicy: IfNotPresent       # Image pull policy
  port: 8080                       # Application port
  metricsPath: /metrics            # Path for metrics exposure
```

Probable Conditions:
1. Custom Namespace:
   - Modify namespace to isolate the application.
   ```yaml
   namespace: production
   ```
2. Using Private Docker Registry:
   - Add image pull secrets.
   ```yaml
   image:
     pullPolicy: Always
     pullSecrets: 
       - name: my-docker-secret
   ```
3. Non-Standard Metrics Path:
   - Update metricsPath:
   ```yaml
   metricsPath: /custom-metrics
   ```

### Deployment Configuration

Define how your application pods are deployed, including resource requests, limits, annotations, and replica settings.

```yaml
deployment:
  replicas: 2                      # Number of pod replicas
  annotations:
    "app.kubernetes.io/version": "1.0"
  labels:
    environment: production
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

Probable Conditions:
1. Custom Resource Requests and Limits:
   - Ensure HPA works correctly by defining resource requests.
   ```yaml
   resources:
     requests:
       cpu: 200m
       memory: 256Mi
     limits:
       cpu: 1
       memory: 1Gi
   ```
2. Scaling to Zero:
   - Set replicas to 0 for low-traffic times.
   ```yaml
   replicas: 0
   ```
3. Add Custom Annotations:
   - Include annotations for monitoring or service meshes.
   ```yaml
   annotations:
     sidecar.istio.io/inject: "true"
   ```

### Service Configuration

Configure how the application service is exposed to Prometheus or other consumers.

```yaml
service:
  type: ClusterIP                  # Service type: ClusterIP, NodePort, LoadBalancer
  port: 80                         # Service port
  targetPort: 8080                 # Application port
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
  labels:
    environment: production
```

Probable Conditions:
1. Expose Service via LoadBalancer:
   ```yaml
   service:
     type: LoadBalancer
   ```
2. Custom Service Annotations:
   - Add annotations to allow Prometheus scraping or ingress routing.
   ```yaml
   annotations:
     prometheus.io/scrape: "true"
     prometheus.io/path: "/metrics"
   ```
3. NodePort Configuration:
   - Expose the service on a specific NodePort.
   ```yaml
   service:
     type: NodePort
     nodePort: 30080
   ```

### Prometheus Configuration

Prometheus is responsible for scraping metrics and integrating with the adapter.

```yaml
prometheus:
  enabled: true                     # Deploy Prometheus
  scrapeInterval: 15s               # Scrape interval for metrics
  existingPrometheusService: ""     # Use existing Prometheus service if set
  scrapeConfigs:                    # Additional scrape jobs
    - job_name: 'custom-job'
      static_configs:
        - targets: ['custom-app:9090']
```

Probable Conditions:
1. Use an Existing Prometheus:
   ```yaml
   enabled: false
   existingPrometheusService: "prometheus-service"
   ```
2. Multiple Scrape Jobs:
   - Add additional configurations for multiple targets:
   ```yaml
   scrapeConfigs:
     - job_name: 'app-metrics'
       static_configs:
         - targets: ['auto-scale-app:8080']
     - job_name: 'queue-metrics'
       static_configs:
         - targets: ['queue-service:9090']
   ```
3. Custom Scrape Interval:
   - Change the scrape interval for more frequent monitoring:
   ```yaml
   scrapeInterval: 10s
   ```

### Prometheus Adapter Configuration

Prometheus Adapter translates Prometheus metrics into Kubernetes Custom Metrics API.

```yaml
prometheusAdapter:
  enabled: true
  image: quay.io/prometheus/adapter:v0.9.1
  annotations: {}
  labels: {}
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

Probable Conditions:
1. Custom Adapter Image:
   - Use a specific version or custom-built image:
   ```yaml
   image: quay.io/custom/adapter:v1.0.0
   ```
2. Custom Adapter Resources:
   - Set appropriate limits for high-performance needs.
   ```yaml
   resources:
     requests:
       cpu: 200m
       memory: 256Mi
   ```

### HPA Configuration

Configure Horizontal Pod Autoscaler to scale based on CPU, memory, or external metrics.

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
    - type: External
      external:
        metricName: requests_per_second
        target:
          type: Value
          value: 100
```

Probable Conditions:
1. Scaling Based on Custom Metrics:
   ```yaml
   - type: External
     external:
       metricName: latency_p99
       target:
         type: Value
         value: 300
   ```
2. Disable HPA:
   - Prevent HPA from managing pods:
   ```yaml
   enabled: false
   ```
3. Multiple Scaling Metrics:
   - Combine CPU, memory, and external metrics:
   ```yaml
   metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
     - type: External
       external:
         metricName: queue_length
         target:
           type: Value
           value: 50
   ```

### Health Checks

Health checks ensure that Prometheus, Prometheus Adapter, and the application are functioning correctly.

```yaml
healthChecks:
  prometheus:
    liveness:
      path: /-/healthy
      port: 9090
    readiness:
      path: /-/ready
      port: 9090

  prometheusAdapter:
    liveness:
      path: /metrics
      port: 6443
    readiness:
      path: /metrics
      port: 6443

  app:
    liveness:
      path: /metrics
      initialDelaySeconds: 10
      timeoutSeconds: 5
    readiness:
      path: /metrics
      initialDelaySeconds: 5
      timeoutSeconds: 3
```

Probable Conditions:
1. Adjust Probe Timing:
   - Increase initialDelaySeconds for slow-starting applications.
   ```yaml
   initialDelaySeconds: 30
   ```
2. Disable Health Checks:
   - Temporarily disable health checks for debugging.
   ```yaml
   enabled: false
   ```

## Metrics Scraping and Handling

### Metrics Exposure

The application must expose metrics in a Prometheus-compatible format at the /metrics endpoint.

Example Metrics Exposure:

- Python Example:

```python
from prometheus_client import start_http_server, Counter

REQUESTS = Counter('requests_total', 'Total number of requests')

def handle_request():
    REQUESTS.inc()

if __name__ == "__main__":
    start_http_server(8080)
    while True:
        handle_request()
```

- Node.js Example:

```javascript
const express = require('express');
const client = require('prom-client');

const app = express();
const counter = new client.Counter({ name: 'requests_total', help: 'Total requests' });

app.get('/', (req, res) => {
    counter.inc();
    res.send('Hello, metrics!');
});

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
});

app.listen(8080, () => console.log('Server on port 8080'));
```

### Prometheus Configuration for Metrics Scraping

Prometheus scrapes the /metrics endpoint of your application at regular intervals.

Sample Scrape Configuration in values.yaml:

```yaml
prometheus:
  scrapeConfigs:
    - job_name: 'auto-scale-app'
      static_configs:
        - targets: ['auto-scale-app:8080']
```

- job_name: The logical name for the scrape job.
- targets: IP or service names of the applications exposing /metrics.

### Prometheus Adapter Integration

Prometheus Adapter makes custom metrics available to Kubernetes through the Custom Metrics API.

Example Adapter Rule:

```yaml
rules:
  - seriesQuery: 'http_requests_total{namespace!="",pod!=""}'
    resources:
      overrides:
        namespace: {resource: "namespace"}
        pod: {resource: "pod"}
    name:
      matches: "^(.*)_total"
      as: "${1}"
    metricsQuery: 'sum(rate(<<.Series>>[1m])) by (<<.GroupBy>>)'
```

- seriesQuery: Selects the Prometheus series.
- metricsQuery: Aggregates metrics to a format readable by Kubernetes.

## Product Workflow

### Step-by-Step Flow

1. Metrics Exposure:
   - Application exposes metrics via an endpoint like /metrics.
2. Metrics Collection:
   - Prometheus scrapes the /metrics endpoint based on the defined scrape configuration.
3. Metrics Translation:
   - Prometheus Adapter converts metrics from Prometheus into the Custom Metrics API format.
4. Metrics Query by HPA:
   - Kubernetes HPA queries the Custom Metrics API.
   - Example API query:
     ```bash
     kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/requests_total"
     ```
5. HPA Scaling Decision:
   - Based on defined thresholds in values.yaml, HPA increases or decreases the pod replicas dynamically.
6. Scaling Action:
   - Kubernetes adjusts the deployment replicas to match the defined target values.

## Use Cases

Below are practical scenarios where the Auto-Scale Metrics Helm Chart can be applied:

### CPU and Memory Scaling

Scenario:
A web application experiences spikes in CPU and memory usage during peak hours.

Configuration:
```yaml
hpa:
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
          averageUtilization: 70
