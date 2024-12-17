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




# What is this Product? 

This product is an Auto-Scaling Solution implemented via a Helm Chart for Kubernetes. It integrates with Prometheus and Kubernetes Horizontal Pod Autoscaler (HPA) to provide automatic, application-aware scaling of your workloads based on metrics.


## The Pain Point It Solves

### Traditional Kubernetes HPA Limitation 🛑:
Kubernetes Horizontal Pod Autoscaler (HPA) natively scales based on CPU and Memory usage only. However, modern applications often require scaling based on:

- 📊 Requests Per Second (RPS)
- ⏱️ Latency (e.g., P95, P99)
- 📥 Queue Backlog or Job Depth

## The Solution: Auto-Scaling Helm Chart

This product provides a Helm Chart that integrates the following components to solve this limitation:

### Custom Metrics Integration:
- The product integrates with Prometheus and Prometheus Adapter to fetch custom application metrics.
- These metrics (e.g., requests per second, latency, queue depth) are exposed by the application and scraped by Prometheus.

### Automatic HPA Configuration:
The Helm Chart configures Kubernetes HPA to use:
- Resource Metrics (CPU/Memory).
- Custom Metrics (application-specific metrics).
- External Metrics (e.g., message queue depth).

### Production-Ready Features:
- **RBAC Support:** Ensures Prometheus Adapter and HPA have proper permissions.
- **Health Checks:** Ensures Prometheus, Prometheus Adapter, and the application are healthy.
- **Modular Deployment:** Allows integration with existing Prometheus setups or installs new Prometheus if needed.
- **Scalability:** Handles scaling of multiple workloads across namespaces.

## Key Pain Points Solved

### Scaling Beyond CPU/Memory:
Applications can now scale based on:
- Requests per second.
- Latency (e.g., P99).
- Queue length or backlog.

### Simplified Deployment:
The Helm Chart provides an automated, production-ready setup:
- Install Prometheus and Prometheus Adapter (if not already available).
- Configure Kubernetes HPA to leverage both default and custom metrics.

### Improved Application Performance:
By scaling based on real application behavior (e.g., high latency or load), the product ensures better performance and availability.

### Flexibility for Any Application:
Works with any application that exposes metrics in Prometheus format on a `/metrics` endpoint.

### Time and Cost Savings:
- Automates the manual scaling of applications.
- Optimizes resource utilization, reducing cloud infrastructure costs.

## Who Needs This Product?

### Developers & DevOps Teams:
Looking for flexible scaling of applications in Kubernetes based on metrics like request load, queue size, or latency.

### Businesses Running Critical Applications:
Ensures the application scales quickly and efficiently during high demand, preventing downtime or degraded performance.

### Organizations Using Microservices:
Microservices often rely on multiple metrics (like request rate and latency) for scaling decisions. This product simplifies scaling for these architectures.

## In Summary
This product addresses the gaps in Kubernetes HPA by enabling application-aware scaling with custom and external metrics. It automates the setup with a Helm Chart, reducing operational overhead and ensuring better resource utilization, cost-efficiency, and performance for Kubernetes workloads. 🚀