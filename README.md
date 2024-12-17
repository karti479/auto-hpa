**Auto-Scale Metrics Helm Chart Documentation**

**Table of Contents**

1.  **Overview**

2.  **Features**

3.  **Architecture and Components**

4.  **Installation Guide**

5.  **User Configuration Guide**

6.  **Metrics Scraping and Handling**

7.  **Health Monitoring**

8.  **Product Workflow**

9.  **Use Cases**

10. **Troubleshooting Guide**

11. **Pricing and Licensing**

12. **Best Practices**

13. **Conclusion**

**1. Overview**

The **Auto-Scale Metrics Helm Chart** provides a production-grade
solution for scaling Kubernetes workloads dynamically using:

-   **Kubernetes HPA** (Horizontal Pod Autoscaler).

-   **Prometheus Adapter** for custom metrics.

-   **Prometheus** for metrics collection and monitoring.

It supports scaling based on:

1.  **CPU/Memory Utilization**.

2.  **Custom Metrics** like request rates, latency, or error rates.

3.  **External Metrics** such as job queues or user-defined indicators.

The chart is **highly configurable** and integrates modularly with
existing Prometheus setups.

**2. Features**

  --------------------------------------------------------------------------
  **Feature**            **Description**
  ---------------------- ---------------------------------------------------
  **Dynamic Scaling**    Scale workloads dynamically based on CPU, memory,
                         and custom metrics.

  **Custom Metrics       Uses Prometheus Adapter for translating metrics for
  Support**              HPA.

  **Health Monitoring**  Liveness and readiness probes for application,
                         Prometheus, and adapter.

  **RBAC Integration**   Ensures secure access to Kubernetes API and custom
                         metrics endpoints.

  **Modular Design**     Deploy Prometheus, Adapter, and HPA independently
                         or together.

  **Production-Ready**   Namespace isolation, robust health checks, and
                         resource configurations.

  **Scalable**           Supports multi-metric scaling and advanced
                         configurations.
  --------------------------------------------------------------------------

**3. Architecture and Components**

The Helm chart consists of the following key components:

**3.1 Application Deployment**

-   Deploys the user application.

-   Exposes a /metrics endpoint compatible with Prometheus.

**3.2 Prometheus**

-   Scrapes metrics from the /metrics endpoint.

-   Provides a centralized metrics store for Kubernetes HPA.

**3.3 Prometheus Adapter**

-   Translates Prometheus metrics into Kubernetes **Custom Metrics
    API**.

-   Enables Kubernetes HPA to use custom metrics for scaling.

**3.4 HPA (Horizontal Pod Autoscaler)**

-   Queries Kubernetes **Metrics API** to scale pods dynamically.

**4. Installation Guide**

**4.1 Prerequisites**

Ensure the following are available:

1.  **Kubernetes Cluster** (v1.24+).

2.  **Helm** (v3+).

3.  **Prometheus-compatible Application** exposing metrics at /metrics.

**4.2 Steps for Installation**

**Step 1: Clone the Helm Chart Repository**

bash

Copy code

git clone \<repo-url\>

cd auto-scale-metrics

**Step 2: Configure values.yaml**

Customize your values.yaml file as per your requirements (refer to
section **5. User Configuration Guide**).

**Step 3: Install the Helm Chart**

bash

Copy code

helm install auto-scale ./auto-scale-metrics -f values.yaml

**Step 4: Verify Installation**

-   Check all resources:

> bash
>
> Copy code
>
> kubectl get all -n \<namespace\>

-   Validate the Prometheus and Adapter pods:

> bash
>
> Copy code
>
> kubectl get pods -n \<namespace\>

**5. User Configuration Guide**

This section provides detailed instructions and examples for configuring
the Helm chart via values.yaml. The guide covers all **user needs and
probable conditions** for configuring the application, Prometheus,
Prometheus Adapter, HPA, and health checks.

**5.1 General Application Configuration**

This section defines the application\'s deployment details, including
the image, ports, and namespace.

yaml

Copy code

app:

name: auto-scale-app \# Application name

namespace: default \# Kubernetes namespace

image:

repository: my-docker-repo/auto-scale-app

tag: latest \# Image tag

pullPolicy: IfNotPresent \# Image pull policy

port: 8080 \# Application port

metricsPath: /metrics \# Path for metrics exposure

**Probable Conditions:**

1.  **Custom Namespace**:

    -   Modify namespace to isolate the application.

> yaml
>
> Copy code
>
> namespace: production

2.  **Using Private Docker Registry**:

    -   Add image pull secrets.

> yaml
>
> Copy code
>
> image:
>
> pullPolicy: Always
>
> pullSecrets:
>
> \- name: my-docker-secret

3.  **Non-Standard Metrics Path**:

    -   Update metricsPath:

> yaml
>
> Copy code
>
> metricsPath: /custom-metrics

**5.2 Deployment Configuration**

Define how your application pods are deployed, including resource
requests, limits, annotations, and replica settings.

yaml

Copy code

deployment:

replicas: 2 \# Number of pod replicas

annotations:

\"app.kubernetes.io/version\": \"1.0\"

labels:

environment: production

resources:

requests:

cpu: 100m

memory: 128Mi

limits:

cpu: 500m

memory: 512Mi

**Probable Conditions:**

1.  **Custom Resource Requests and Limits**:

    -   Ensure HPA works correctly by defining resource requests.

> yaml
>
> Copy code
>
> resources:
>
> requests:
>
> cpu: 200m
>
> memory: 256Mi
>
> limits:
>
> cpu: 1
>
> memory: 1Gi

2.  **Scaling to Zero**:

    -   Set replicas to 0 for low-traffic times.

> yaml
>
> Copy code
>
> replicas: 0

3.  **Add Custom Annotations**:

    -   Include annotations for monitoring or service meshes.

> yaml
>
> Copy code
>
> annotations:
>
> sidecar.istio.io/inject: \"true\"

**5.3 Service Configuration**

Configure how the application service is exposed to Prometheus or other
consumers.

yaml

Copy code

service:

type: ClusterIP \# Service type: ClusterIP, NodePort, LoadBalancer

port: 80 \# Service port

targetPort: 8080 \# Application port

annotations:

prometheus.io/scrape: \"true\"

prometheus.io/port: \"8080\"

labels:

environment: production

**Probable Conditions:**

1.  **Expose Service via LoadBalancer**:

> yaml
>
> Copy code
>
> service:
>
> type: LoadBalancer

2.  **Custom Service Annotations**:

    -   Add annotations to allow Prometheus scraping or ingress routing.

> yaml
>
> Copy code
>
> annotations:
>
> prometheus.io/scrape: \"true\"
>
> prometheus.io/path: \"/metrics\"

3.  **NodePort Configuration**:

    -   Expose the service on a specific NodePort.

> yaml
>
> Copy code
>
> service:
>
> type: NodePort
>
> nodePort: 30080

**5.4 Prometheus Configuration**

Prometheus is responsible for scraping metrics and integrating with the
adapter.

yaml

Copy code

prometheus:

enabled: true \# Deploy Prometheus

scrapeInterval: 15s \# Scrape interval for metrics

existingPrometheusService: \"\" \# Use existing Prometheus service if
set

scrapeConfigs: \# Additional scrape jobs

\- job_name: \'custom-job\'

static_configs:

\- targets: \[\'custom-app:9090\'\]

**Probable Conditions:**

1.  **Use an Existing Prometheus**:

> yaml
>
> Copy code
>
> enabled: false
>
> existingPrometheusService: \"prometheus-service\"

2.  **Multiple Scrape Jobs**:

    -   Add additional configurations for multiple targets:

> yaml
>
> Copy code
>
> scrapeConfigs:
>
> \- job_name: \'app-metrics\'
>
> static_configs:
>
> \- targets: \[\'auto-scale-app:8080\'\]
>
> \- job_name: \'queue-metrics\'
>
> static_configs:
>
> \- targets: \[\'queue-service:9090\'\]

3.  **Custom Scrape Interval**:

    -   Change the scrape interval for more frequent monitoring:

> yaml
>
> Copy code
>
> scrapeInterval: 10s

**5.5 Prometheus Adapter Configuration**

Prometheus Adapter translates Prometheus metrics into Kubernetes
**Custom Metrics API**.

yaml

Copy code

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

**Probable Conditions:**

1.  **Custom Adapter Image**:

    -   Use a specific version or custom-built image:

> yaml
>
> Copy code
>
> image: quay.io/custom/adapter:v1.0.0

2.  **Custom Adapter Resources**:

    -   Set appropriate limits for high-performance needs.

> yaml
>
> Copy code
>
> resources:
>
> requests:
>
> cpu: 200m
>
> memory: 256Mi

**5.6 HPA Configuration**

Configure Horizontal Pod Autoscaler to scale based on **CPU**,
**memory**, or **external metrics**.

yaml

Copy code

hpa:

enabled: true

minReplicas: 2

maxReplicas: 10

metrics:

\- type: Resource

resource:

name: cpu

target:

type: Utilization

averageUtilization: 80

\- type: External

external:

metricName: requests_per_second

target:

type: Value

value: 100

**Probable Conditions:**

1.  **Scaling Based on Custom Metrics**:

> yaml
>
> Copy code
>
> \- type: External
>
> external:
>
> metricName: latency_p99
>
> target:
>
> type: Value
>
> value: 300

2.  **Disable HPA**:

    -   Prevent HPA from managing pods:

> yaml
>
> Copy code
>
> enabled: false

3.  **Multiple Scaling Metrics**:

    -   Combine CPU, memory, and external metrics:

> yaml
>
> Copy code
>
> metrics:
>
> \- type: Resource
>
> resource:
>
> name: cpu
>
> target:
>
> type: Utilization
>
> averageUtilization: 70
>
> \- type: External
>
> external:
>
> metricName: queue_length
>
> target:
>
> type: Value
>
> value: 50

**5.7 Health Checks**

Health checks ensure that Prometheus, Prometheus Adapter, and the
application are functioning correctly.

yaml

Copy code

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

**Probable Conditions:**

1.  **Adjust Probe Timing**:

    -   Increase initialDelaySeconds for slow-starting applications.

> yaml
>
> Copy code
>
> initialDelaySeconds: 30

2.  **Disable Health Checks**:

    -   Temporarily disable health checks for debugging.

> yaml
>
> Copy code
>
> enabled: false

**Summary**

The **User Configuration Guide** in values.yaml is now **fully
comprehensive**, covering:

-   Application settings.

-   Service exposure and annotations.

-   Prometheus and Adapter configurations.

-   HPA rules for multiple scaling conditions.

-   Health checks with customizable probes.

This detailed guide ensures users can handle **all probable scenarios**,
from simple deployments to advanced production-grade configurations. Let
me know if further refinements or specific examples are needed! 🚀

**6. Metrics Scraping and Handling**

**6.1 Metrics Exposure**

The application **must expose metrics** in a Prometheus-compatible
format at the /metrics endpoint.

**Example Metrics Exposure**

-   **Python Example**:

> python
>
> Copy code
>
> from prometheus_client import start_http_server, Counter
>
> REQUESTS = Counter(\'requests_total\', \'Total number of requests\')
>
> def handle_request():
>
> REQUESTS.inc()
>
> if \_\_name\_\_ == \"\_\_main\_\_\":
>
> start_http_server(8080)
>
> while True:
>
> handle_request()

-   **Node.js Example**:

> javascript
>
> Copy code
>
> const express = require(\'express\');
>
> const client = require(\'prom-client\');
>
> const app = express();
>
> const counter = new client.Counter({ name: \'requests_total\', help:
> \'Total requests\' });
>
> app.get(\'/\', (req, res) =\> {
>
> counter.inc();
>
> res.send(\'Hello, metrics!\');
>
> });
>
> app.get(\'/metrics\', async (req, res) =\> {
>
> res.set(\'Content-Type\', client.register.contentType);
>
> res.end(await client.register.metrics());
>
> });
>
> app.listen(8080, () =\> console.log(\'Server on port 8080\'));

**6.2 Prometheus Configuration for Metrics Scraping**

Prometheus scrapes the /metrics endpoint of your application at regular
intervals.

**Sample Scrape Configuration in values.yaml**:

yaml

Copy code

prometheus:

scrapeConfigs:

\- job_name: \'auto-scale-app\'

static_configs:

\- targets: \[\'auto-scale-app:8080\'\]

-   **job_name**: The logical name for the scrape job.

-   **targets**: IP or service names of the applications exposing
    /metrics.

**6.3 Prometheus Adapter Integration**

Prometheus Adapter makes custom metrics available to Kubernetes through
the **Custom Metrics API**.

**Example Adapter Rule**:

yaml

Copy code

rules:

\- seriesQuery: \'http_requests_total{namespace!=\"\",pod!=\"\"}\'

resources:

overrides:

namespace: {resource: \"namespace\"}

pod: {resource: \"pod\"}

name:

matches: \"\^(.\*)\_total\"

as: \"\${1}\"

metricsQuery: \'sum(rate(\<\<.Series\>\>\[1m\])) by (\<\<.GroupBy\>\>)\'

-   **seriesQuery**: Selects the Prometheus series.

-   **metricsQuery**: Aggregates metrics to a format readable by
    Kubernetes.

**8. Product Workflow**

**8.1 Step-by-Step Flow**

1.  **Metrics Exposure**:

    -   Application exposes metrics via an endpoint like /metrics.

2.  **Metrics Collection**:

    -   Prometheus scrapes the /metrics endpoint based on the defined
        scrape configuration.

3.  **Metrics Translation**:

    -   Prometheus Adapter converts metrics from Prometheus into the
        **Custom Metrics API** format.

4.  **Metrics Query by HPA**:

    -   Kubernetes HPA queries the **Custom Metrics API**.

    -   Example API query:

> bash
>
> Copy code
>
> kubectl get \--raw
> \"/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/\*/requests_total\"

5.  **HPA Scaling Decision**:

    -   Based on defined thresholds in values.yaml, HPA increases or
        decreases the pod replicas dynamically.

6.  **Scaling Action**:

    -   Kubernetes adjusts the deployment replicas to match the defined
        target values.

**9. Use Cases**

Below are **practical scenarios** where the Auto-Scale Metrics Helm
Chart can be applied:

**9.1 CPU and Memory Scaling**

**Scenario:**

A web application experiences spikes in CPU and memory usage during peak
hours.

**Configuration**:

yaml

Copy code

hpa:

metrics:

\- type: Resource

resource:

name: cpu

target:

type: Utilization

averageUtilization: 80

\- type: Resource

resource:

name: memory

target:

type: Utilization

averageUtilization: 70

**Outcome**:

-   HPA scales up pods when CPU utilization exceeds 80% or memory usage
    exceeds 70%.

**9.2 Scaling Based on Requests Per Second**

**Scenario:**

An API service receives heavy request loads during specific hours,
requiring automatic scaling to meet the traffic demands.

**Configuration**:

yaml

Copy code

hpa:

metrics:

\- type: External

external:

metricName: requests_per_second

target:

type: Value

value: 100

**Outcome**:

-   HPA scales pods dynamically when the request rate exceeds 100 RPS.

**9.3 Scaling Based on Latency**

**Scenario:**

A backend service needs to meet a **latency SLA** (e.g., P99 latency
should not exceed 300ms).

**Configuration**:

yaml

Copy code

hpa:

metrics:

\- type: External

external:

metricName: latency_p99

target:

type: Value

value: 300

**Outcome**:

-   HPA scales pods when latency metrics exceed the threshold of 300ms.

**9.4 Queue-Based Scaling**

**Scenario:**

A job-processing application scales based on the length of a job queue.

**Configuration**:

yaml

Copy code

hpa:

metrics:

\- type: External

external:

metricName: queue_length

target:

type: Value

value: 50

**Outcome**:

-   HPA adds more workers when the queue length exceeds 50.

**10. Troubleshooting Guide**

**10.1 Issue: HPA Not Scaling**

**Cause**:

-   Metrics are not available to HPA.

**Solution**:

1.  **Verify Prometheus Adapter**:

> bash
>
> Copy code
>
> kubectl get pods -n \<namespace\>
>
> Ensure Prometheus Adapter is running.

2.  **Check Metrics API**:

> bash
>
> Copy code
>
> kubectl get \--raw \"/apis/custom.metrics.k8s.io/v1beta1\"

3.  **Validate Scrape Configuration**:

    -   Ensure Prometheus is scraping the /metrics endpoint:

> bash
>
> Copy code
>
> kubectl port-forward svc/prometheus 9090 -n \<namespace\>
>
> Query the metrics on Prometheus UI.

**10.2 Issue: Prometheus Not Scraping Metrics**

**Cause**:

-   Scrape job misconfiguration.

-   Application not exposing metrics.

**Solution**:

1.  Verify /metrics endpoint:

> bash
>
> Copy code
>
> curl http://\<application-service\>:8080/metrics

2.  Check Prometheus scrape configuration:

> yaml
>
> Copy code
>
> prometheus:
>
> scrapeConfigs:
>
> \- job_name: \'auto-scale-app\'
>
> static_configs:
>
> \- targets: \[\'auto-scale-app:8080\'\]

3.  Restart Prometheus if required:

> bash
>
> Copy code
>
> kubectl rollout restart deployment prometheus -n \<namespace\>

**10.3 Issue: Prometheus Adapter Not Exposing Metrics**

**Cause**:

-   Adapter configuration issue.

**Solution**:

1.  Verify Prometheus Adapter pod:

> bash
>
> Copy code
>
> kubectl logs \<adapter-pod\> -n \<namespace\>

2.  Ensure Prometheus Adapter ConfigMap is correct:

> yaml
>
> Copy code
>
> rules:
>
> \- seriesQuery: \'http_requests_total{namespace!=\"\",pod!=\"\"}\'
>
> name:
>
> matches: \"\^(.\*)\_total\"

3.  Restart Prometheus Adapter:

> bash
>
> Copy code
>
> kubectl rollout restart deployment prometheus-adapter -n \<namespace\>

**11. Pricing and Licensing**

-   **Free Usage**: Helm chart available for free.

-   **Annual Support Licensing**: ₹1,000 INR/year.

    -   Includes email support and regular updates.

**12. Best Practices**

-   **Expose meaningful metrics** for Prometheus.

-   Ensure **resource requests/limits** are defined for HPA to work
    effectively.

-   Monitor **Prometheus Adapter** health.

**13. Conclusion**

The **Auto-Scale Metrics Helm Chart** provides an enterprise-grade
solution for dynamic scaling using custom and standard metrics. With
robust configurations, health checks, and modular integrations, it is
ideal for both developers and enterprises seeking to optimize Kubernetes
workloads.

**14.Extended User Guide**

The auto-scale-metrics Helm chart automates application deployment with
Horizontal Pod Autoscaling (HPA) based on **custom metrics**, Kubernetes
resources, or external metrics. A critical component of this chart is
ensuring your application exposes metrics via an HTTP /metrics endpoint
in Prometheus format.

**Features**

-   **Highly Configurable**: Supports customizable values for
    Prometheus, HPA, deployment, and service configurations.

-   **Multiple Use Cases**:

    -   Scaling based on CPU and memory utilization.

    -   Application-specific metrics like requests per second or
        latency.

    -   External metrics (e.g., queue length).

-   **Production-Grade**:

    -   RBAC support for Prometheus Adapter.

    -   Namespace isolation and health checks.

-   **Modular**:

    -   Works with any application exposing Prometheus metrics.

    -   Can reuse existing Prometheus and Prometheus Adapter setups.

**Use Cases**

**1. Scaling Based on CPU/Memory Utilization**

-   Scale when CPU exceeds 80% or memory usage exceeds 70%.

**Example Configuration in values.yaml:**

yaml

Copy code

hpa:

enabled: true

minReplicas: 2

maxReplicas: 10

metrics:

\- type: Resource

resource:

name: cpu

target:

type: Utilization

averageUtilization: 80

\- type: Resource

resource:

name: memory

target:

type: Utilization

averageUtilization: 70

**2. Scaling Based on Requests Per Second**

-   Increase pods when requests per second exceed 100.

**Example Configuration in values.yaml:**

yaml

Copy code

hpa:

enabled: true

minReplicas: 2

maxReplicas: 10

metrics:

\- type: External

external:

metricName: requests_per_second

target:

type: Value

value: 100

**3. Scaling Based on Queue Length**

-   Scale pods based on the backlog of jobs in a queue.

**Example Configuration in values.yaml:**

yaml

Copy code

hpa:

enabled: true

minReplicas: 1

maxReplicas: 20

metrics:

\- type: External

external:

metricName: queue_length

target:

type: Value

value: 50

**4. Scaling Based on Application Latency (P99)**

-   Scale pods when latency exceeds 300ms.

**Example Configuration in values.yaml:**

yaml

Copy code

hpa:

enabled: true

minReplicas: 2

maxReplicas: 15

metrics:

\- type: External

external:

metricName: latency_p99

target:

type: Value

value: 300

**Metrics Exposure by Application**

**1. Why Metrics Are Required**

Metrics are the foundation of HPA decisions. Kubernetes HPA leverages:

-   **Resource Metrics**: CPU and memory usage (from Kubernetes Metrics
    Server).

-   **Custom Metrics**: Application-specific metrics (from Prometheus
    via Prometheus Adapter).

-   **External Metrics**: Metrics exposed outside Kubernetes (e.g.,
    queue length).

This Helm chart assumes the application exposes custom metrics at a
/metrics endpoint.

**2. Adding Metrics to Your Application**

You need to ensure the application exposes Prometheus-compatible metrics
at /metrics. Below are examples for popular frameworks/languages.

**Python Example (Using prometheus_client)**

python

Copy code

from prometheus_client import start_http_server, Counter

\# Define a metric

REQUESTS = Counter(\'requests_total\', \'Total number of requests\')

\# Simulate a metric increment

def handle_request():

REQUESTS.inc()

if \_\_name\_\_ == \"\_\_main\_\_\":

\# Start the metrics server on port 8080

start_http_server(8080)

while True:

handle_request()

Metrics exposed at: http://\<application-service\>:8080/metrics

**Node.js Example (Using prom-client)**

javascript

Copy code

const express = require(\'express\');

const client = require(\'prom-client\');

const app = express();

const counter = new client.Counter({

name: \'requests_total\',

help: \'Total number of requests\'

});

// Increment the counter on every request

app.get(\'/\', (req, res) =\> {

counter.inc();

res.send(\'Hello, metrics!\');

});

// Expose the metrics

app.get(\'/metrics\', async (req, res) =\> {

res.set(\'Content-Type\', client.register.contentType);

res.end(await client.register.metrics());

});

app.listen(8080, () =\> console.log(\'Server listening on port 8080\'));

**Java Example (Using micrometer)**

java

Copy code

import io.micrometer.core.instrument.MeterRegistry;

import io.micrometer.core.instrument.Counter;

import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RestController;

\@RestController

public class MetricsController {

private final Counter requestCounter;

public MetricsController(MeterRegistry registry) {

this.requestCounter = registry.counter(\"requests_total\");

}

\@GetMapping(\"/\")

public String handleRequest() {

requestCounter.increment();

return \"Hello, metrics!\";

}

}

Metrics exposed at: http://\<application-service\>:8080/metrics

**3. Testing Your Application's Metrics**

1.  **Run the Application Locally**:

    -   Start the application and confirm metrics are exposed:

> bash
>
> Copy code
>
> curl http://localhost:8080/metrics

-   Example output:

> plaintext
>
> Copy code
>
> \# HELP requests_total Total number of requests
>
> \# TYPE requests_total counter
>
> requests_total 42

2.  **Deploy the Application to Kubernetes**:

    -   Confirm /metrics is reachable via the Kubernetes service:

> bash
>
> Copy code
>
> kubectl port-forward svc/\<application-service\> 8080:8080
>
> curl http://localhost:8080/metrics

**Installation Guide**

**Expanded Steps for Metrics Configuration**

**Step 1: Prepare the Application**

1.  Modify your application to expose /metrics in Prometheus format.

2.  Add any relevant metrics:

    -   Throughput (requests_per_second).

    -   Latency (latency_p99).

    -   Errors (error_rate).

**Step 2: Configure the Chart**

Set the application details in values.yaml:

yaml

Copy code

app:

name: auto-scale-app

image:

repository: my-docker-repo/auto-scale-app

tag: latest

port: 8080

metricsPath: /metrics

**Post-Installation Steps**

**1. Verify Metrics Exposure**

-   Confirm that Prometheus is scraping the /metrics endpoint:

    1.  Port-forward the Prometheus service:

> bash
>
> Copy code
>
> kubectl port-forward svc/prometheus 9090:9090 -n \<namespace\>

2.  Visit http://localhost:9090.

3.  Query metrics:

> plaintext
>
> Copy code
>
> requests_total

**2. Confirm Metrics in Kubernetes**

-   Verify custom metrics are available via Prometheus Adapter:

> bash
>
> Copy code
>
> kubectl get \--raw \"/apis/custom.metrics.k8s.io/v1beta1\" \| jq .
>
> Expected output:
>
> json
>
> Copy code
>
> {
>
> \"kind\": \"MetricList\",
>
> \"items\": \[
>
> {
>
> \"name\": \"requests_per_second\",
>
> \"value\": 100
>
> }
>
> \]
>
> }

**Testing HPA**

**Traffic Simulation**

Generate load to simulate scaling:

1.  Deploy a traffic generator:

> bash
>
> Copy code
>
> kubectl run traffic-generator \--image=busybox \--restart=Never \-- sh
> -c \"while true; do wget -q -O- http://\<application-service\>; done\"

2.  Observe HPA:

> bash
>
> Copy code
>
> kubectl get hpa -n \<namespace\>
>
> Expected result: Pod count should increase.

**Troubleshooting**

**Issue: Metrics Not Available**

1.  Confirm /metrics endpoint is accessible:

> bash
>
> Copy code
>
> curl http://\<application-service\>:8080/metrics

2.  Check Prometheus scrape configurations:

> yaml
>
> Copy code
>
> prometheus:
>
> scrapeConfigs:
>
> \- job_name: \'my-app\'
>
> static_configs:
>
> \- targets: \[\'auto-scale-app:8080\'\]

**Issue: HPA Not Scaling**

1.  Confirm custom metrics are available:

> bash
>
> Copy code
>
> kubectl get \--raw \"/apis/custom.metrics.k8s.io/v1beta1\" \| jq .

2.  Inspect HPA status:

> bash
>
> Copy code
>
> kubectl describe hpa \<hpa-name\> -n \<namespace\>
