---
title: "Auto-HPA  Documentation"
layout: single
permalink: /
---

# Auto-HPA  Helm Chart Documentation

Welcome to the **Auto-HPA Metrics** Helm Chart documentation. This guide covers everything you need to know for dynamically scaling Kubernetes workloads.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [User Configuration](#user-configuration)
4. [Metrics Scraping](#metrics-scraping)
5. [Use Cases](#use-cases)
6. [Troubleshooting](#troubleshooting)

---

## Overview

The **Auto-HPA Metrics Helm Chart** provides production-ready Kubernetes scaling using:
- **CPU/Memory metrics**.
- **Custom Metrics** (e.g., latency, queue length).
- **Prometheus Adapter** for Kubernetes HPA.

---

## Installation

Follow these steps to install the chart:

Customize Configuration: Edit values.yaml to suit your application.

Install the Chart:

'''bash
helm install auto-scale ./auto-scale-metrics -f values.yaml
'''
## User Configuration

The chart is highly configurable. Update the values.yaml file to:

## Define application settings.
Enable Prometheus and Prometheus Adapter.
Set Horizontal Pod Autoscaler thresholds.
Refer to the detailed guide in the Configuration section.

Use Cases
1. Scaling Based on CPU/Memory
Scale up pods when CPU utilization > 80%.
2. Scaling on Requests Per Second
Autoscale based on incoming API traffic.
3. Latency-Based Scaling
Scale your backend services when latency > 300ms.
Troubleshooting
Issue: HPA Not Scaling
Check if metrics are visible in the Prometheus Adapter.
Run:

bash
Copy code
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1"


1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-github-username>/<repository-name>
   cd <repository-name>
