# Troubleshooting Guide

### 1 HPA Not Scaling

1. Check HPA status:

```bash
   kubectl describe hpa <hpa-name> -n <namespace>
```

2. Verify metrics:

```bash
   kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second" | jq .
```

3. Check Prometheus Adapter logs:
```bash
   kubectl logs -l app=prometheus-adapter -n <namespace>
```

### 2 Prometheus Not Scraping Metrics

1. Check Prometheus targets:

```bash
   kubectl port-forward svc/prometheus 9090:9090 -n <namespace>
```
Then visit http://localhost:9090/targets

2. Verify scrape config:
```bash
   kubectl get configmap prometheus-server -n <namespace> -o yaml
```

### .3 Application Not Exposing Metrics

1. Check if metrics endpoint is accessible:
```bash
   kubectl port-forward svc/<app-service> 8080:8080 -n <namespace>
   curl http://localhost:8080/metrics
```

2. Verify application logs:
```bash
   kubectl logs <pod-name> -n <namespace>
```

## 11. Pricing and Licensing

- Free Usage: Helm chart available for free.
- Annual Support Licensing: ₹1,000 INR/year.
  - Includes email support and regular updates.

# Connect 
  - karti479@gmail.com
  - https://www.linkedin.com/in/product-kartik/


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
