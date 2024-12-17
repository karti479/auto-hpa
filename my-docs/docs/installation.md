# Installation Guide

## Connect Author for support 
  - karti479@gmail.com
  - https://www.linkedin.com/in/product-kartik/

### 4.1 Prerequisites
Ensure the following are available:
1. Kubernetes Cluster (v1.24+).
2. Helm (v3+).
3. Prometheus-compatible Application exposing metrics at `/metrics`.

---

### 4.2 Steps for Installation


**Step 1: Clone the Helm Chart Repository**



```bash
git clone https://github.com/karti479/auto-hpa.git
cd auto-scale-metrics

```


**Step 2: Configure values.yaml** Customize your values.yaml file as per your requirements (refer to section 5. User Configuration Guide).

**Step 3: Install the Helm Chart**

```bash
helm install auto-scale ./auto-scale-metrics -f values.yaml
```


**Step 4: Verify Installation**

```bash
kubectl get all -n <namespace>
kubectl get pods -n <namespace>

```
