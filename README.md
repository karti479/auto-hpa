# Documentation

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

| Feature | Description |
|---------|-------------|
| Dynamic Scaling | Scale workloads dynamically based on CPU, memory, and custom metrics. |
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

- Kubernetes Cluster (v1.24+)
- Helm (v3+)
- Prometheus-compatible Application exposing metrics at /metrics

### 4.2 Steps for Installation

Step 1: Clone the Helm Chart Repository
\`\`\`bash
git clone <repo-url>
cd auto-scale-metrics
\`\`\`

Step 2: Configure values.yaml
Customize your values.yaml file as per your requirements (refer to section 5. User Configuration Guide).

Step 3: Install the Helm Chart
\`\`\`bash
helm install auto-scale ./auto-scale-metrics -f values.yaml
\`\`\`

Step 4: Verify Installation
Check all resources:
\`\`\`bash
kubectl get all -n <namespace>
\`\`\`
Validate the Prometheus and Adapter pods:
\`\`\`bash
kubectl get pods -n <namespace>
\`\`\`

## 5. User Configuration Guide

The values.yaml file is the heart of configuration. Below are detailed sections.

### 5.1 Application Settings

\`\`\`yaml
app:
  name: auto-scale-app
  namespace: default
  image:
    repository: my-docker-repo/auto-scale-app
    tag: latest
    pullPolicy: IfNotPresent
  port: 8080
  metricsPath: /metrics
\`\`\`

### 5.2 Prometheus Configuration

\`\`\`yaml
prometheus:
  enabled: true
  scrapeInterval: 15s
  scrapeConfigs: []  # Add custom scrape jobs if needed.
  existingPrometheusService: ""  # Use existing Prometheus if set.
\`\`\`

### 5.3 Prometheus Adapter

\`\`\`yaml
prometheusAdapter:
  enabled: true
  image: quay.io/prometheus/adapter:v0.9.1
\`\`\`

### 5.4 HPA Configuration

Define scaling rules:

\`\`\`yaml
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
\`\`\`

### 5.5 Health Checks

\`\`\`yaml
healthChecks:
  app:
    liveness:
      path: /metrics
      initialDelaySeconds: 10
      timeoutSeconds: 5
    readiness:
      path: /metrics
      initialDelaySeconds: 5
      timeoutSeconds: 3
  prometheus:
    liveness:
      path: /-/healthy
    readiness:
      path: /-/ready
  prometheusAdapter:
    liveness:
      path: /metrics
\`\`\`

## 6. Metrics Scraping and Handling

- Expose Metrics: Application should expose Prometheus-compatible metrics at /metrics.
- Prometheus Scraping: Prometheus fetches metrics via a scrape job:

\`\`\`yaml
scrape_configs:
  - job_name: 'app-metrics'
    static_configs:
      - targets: ['auto-scale-app:8080']
\`\`\`

- Prometheus Adapter: Prometheus Adapter translates metrics like requests_total into Kubernetes Custom Metrics API.
- HPA Query: HPA queries metrics like:

\`\`\`bash
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1"
\`\`\`

## 7. Health Monitoring

Health probes ensure availability:

- Prometheus: /-/healthy and /-/ready
- Prometheus Adapter: /metrics
- Application: /metrics

## 8. Product Workflow

1. Metrics Exposure: Application exposes metrics
2. Metrics Collection: Prometheus scrapes metrics
3. Metrics Translation: Prometheus Adapter makes metrics available to Kubernetes API
4. HPA Scaling: HPA fetches metrics and adjusts replica counts

## 9. Use Cases

### CPU/Memory Scaling
Ideal for resource-based autoscaling.

### Request Rate Scaling
Handles dynamic traffic spikes.

### Latency-Based Scaling
Scales to meet SLA requirements for response time.

## 10. Troubleshooting Guide

| Issue | Solution |
|-------|----------|
| HPA Not Scaling | Check Prometheus Adapter availability and query custom metrics. |
| Prometheus Not Scraping | Verify the /metrics endpoint of your application. |
| Metrics Not Available in HPA | Run kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1". |

## 11. Pricing and Licensing

- Free Usage: Helm chart available for free.
- Annual Support Licensing: ₹1,000 INR/year.
- Includes email support and regular updates.

## 12. Best Practices

- Expose meaningful metrics for Prometheus.
- Ensure resource requests/limits are defined for HPA to work effectively.
- Monitor Prometheus Adapter health.

## 13. Conclusion

The Auto-Scale Metrics Helm Chart provides an enterprise-grade solution for dynamic scaling using custom and standard metrics. With robust configurations, health checks, and modular integrations, it is ideal for both developers and enterprises seeking to optimize Kubernetes workloads.
`
