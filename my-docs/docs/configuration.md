## 5. Configuration Guide

### 5.1 General Configuration
Customize application settings:
```yaml
app:
  name: auto-scale-app
  namespace: default
  image:
    repository: my-docker-repo/auto-scale-app
    tag: latest
    pullPolicy: IfNotPresent
  port: 8080
  metricsPath: /metrics