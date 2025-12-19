# Helm PrimeDB Chart

Enterprise-grade Helm chart for deploying applications on Kubernetes with advanced features for configuration management, observability, and security.

## Features

- 🚀 **Flexible Workloads**: Support for Deployment, StatefulSet, and CronJob
- 📦 **Dynamic ConfigMaps**: Automatic ConfigMap generation from directory structure
- 🔐 **Advanced Secrets Management**: Integration with External Secrets Operator and SealedSecrets
- 🌐 **Comprehensive Networking**: Ingress, Gateway API, Network Policies
- 📊 **Full Observability**: Prometheus, OpenTelemetry with 8 language auto-instrumentation
- ⚡ **Auto-scaling**: Horizontal Pod Autoscaler with custom metrics
- 🔒 **Security**: RBAC, Pod Security Context, Pod Disruption Budget
- 💾 **Storage**: PVC with support for StatefulSet volume claim templates

## Installation

```bash
helm install my-release ./helm-primedb
```

With custom values:

```bash
helm install my-release ./helm-primedb -f my-values.yaml
```

## Quick Start

### Basic Deployment

```yaml
workload:
  kind: Deployment
  replicaCount: 3
  image:
    repository: nginx
    tag: "1.21"

networking:
  service:
    type: ClusterIP
    port: 80
  ingress:
    enabled: true
    hosts:
      - host: myapp.example.com
        paths:
          - path: /
            pathType: Prefix
```

### With Auto-scaling

```yaml
scaling:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
```

## Configuration

The chart organizes configuration into logical categories:

### Global Settings

```yaml
global:
  nameOverride: ""
  fullnameOverride: "my-app"
  commonLabels:
    team: platform
  commonAnnotations: {}
```

### Workload Configuration

```yaml
workload:
  kind: Deployment  # or StatefulSet
  replicaCount: 3
  
  image:
    repository: myapp
    tag: "v1.0.0"
    pullPolicy: IfNotPresent
  
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  
  probes:
    liveness:
      enabled: true
      httpGet:
        path: /health
        port: http
    readiness:
      enabled: true
      httpGet:
        path: /ready
        port: http
```

### Networking

```yaml
networking:
  service:
    type: ClusterIP
    port: 80
  
  ingress:
    enabled: true
    className: nginx
    hosts:
      - host: app.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      enabled: true
      secretName: app-tls
  
  networkPolicy:
    enabled: true
    policyTypes: ["Ingress", "Egress"]
```

### Configuration Management

#### Dynamic ConfigMaps

Automatically create ConfigMaps from directory structure:

```yaml
config:
  configFilesPath: "files"  # Scans helm/files/
```

Directory structure:
```
files/
├── scripts/
│   ├── init.sh
│   └── backup.sh
└── configs/
    └── app.yaml
```

Results in ConfigMaps:
- `my-app-scripts` with init.sh and backup.sh
- `my-app-configs` with app.yaml

#### Manual ConfigMaps

```yaml
config:
  extraConfigMaps:
    - name: app-config
      mountPath: /etc/config
      data:
        config.yaml: |
          database:
            host: postgres
            port: 5432
    
    - name: scripts
      mountPath: /scripts
      fromFolder: scripts/  # Load from helm/files/scripts/
    
    - name: existing-config
      mountPath: /etc/external
      existingName: my-existing-configmap
```

#### Secrets

```yaml
config:
  extraSecrets:
    - name: db-credentials
      mountPath: /secrets
      data:
        username: admin
        password: secret123
    
    - name: eso-secret
      mountPath: /app/creds
      existingName: api-credentials-eso  # From External Secrets Operator
```

#### Environment Variables from ConfigMaps/Secrets

```yaml
config:
  extraEnvFromConfigMap:
    - my-config-map
    - "{{ .Release.Name }}-dynamic-config"
  
  extraEnvFromSecret:
    - my-secret
    - db-credentials
```

#### External Secrets Operator

```yaml
config:
  externalSecret:
    enabled: true
    secretStoreRef:
      name: vault-backend
      kind: SecretStore
    refreshInterval: "1h"
    data:
      - secretKey: DB_PASSWORD
        remoteRef:
          key: database/prod/password
```

### Security

```yaml
security:
  serviceAccount:
    create: true
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/my-role
  
  pdb:
    enabled: true
    minAvailable: 1
```

### Storage

```yaml
storage:
  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 100Gi
    accessModes: ["ReadWriteOnce"]
    mountPath: "/data"
```

For StatefulSet with multiple volumes:

```yaml
storage:
  volumeClaimTemplates:
    - name: data
      size: 50Gi
      storageClass: "standard"
    - name: logs
      size: 10Gi
      storageClass: "fast"
```

### Observability

#### Prometheus Monitoring

```yaml
observability:
  monitoring:
    serviceMonitor:
      enabled: true
      interval: 30s
      path: /metrics
    
    prometheusRules:
      enabled: true
      groups:
        - name: app-alerts
          rules:
            - alert: HighErrorRate
              expr: rate(http_requests_total{status="500"}[5m]) > 0.05
```

#### OpenTelemetry

```yaml
observability:
  openTelemetry:
    enabled: true
    mode: deployment
    
    instrumentation:
      enabled: true
      sampler:
        type: parentbased_traceidratio
        argument: "1"
      language: java  # java, python, dotnet, nodejs, go, ruby, php, apacheHttpd
      
      # Language-specific configuration
      java:
        env:
          - name: OTEL_LOG_LEVEL
            value: debug
```

Supported languages for auto-instrumentation:
- Java
- Python
- .NET
- Node.js
- Go
- Ruby
- PHP
- Apache HTTPD

## Directory Structure

The chart uses an enterprise-grade organization:

```
templates/
├── workloads/       # Deployment, StatefulSet, CronJob
├── networking/      # Service, Ingress, Gateway, NetworkPolicy
├── config/          # ConfigMaps, Secrets, ExternalSecret
├── security/        # ServiceAccount, PDB, Certificates
├── storage/         # PersistentVolumeClaim
├── scaling/         # HPA
├── observability/   # ServiceMonitor, OpenTelemetry, Prometheus
├── extra/           # Custom resources
└── helpers/         # Helper templates
```

## Advanced Examples

### Complete Production Setup

```yaml
global:
  fullnameOverride: "payment-service"

workload:
  kind: Deployment
  replicaCount: 3
  image:
    repository: myregistry/payment
    tag: "v2.1.0"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
  probes:
    liveness:
      enabled: true
      httpGet:
        path: /health
        port: http
    readiness:
      enabled: true
      httpGet:
        path: /ready
        port: http

networking:
  service:
    type: ClusterIP
    port: 8080
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: payment.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      enabled: true
      secretName: payment-tls

config:
  configFilesPath: "files"
  extraEnvFromSecret:
    - payment-db-credentials
  externalSecret:
    enabled: true
    secretStoreRef:
      name: vault-backend
      kind: SecretStore
    data:
      - secretKey: DB_PASSWORD
        remoteRef:
          key: payment/prod/db-password

security:
  serviceAccount:
    create: true
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::123:role/payment-role
  pdb:
    enabled: true
    minAvailable: 2

storage:
  persistence:
    enabled: true
    size: 50Gi
    storageClass: "gp3"

scaling:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 70

observability:
  monitoring:
    serviceMonitor:
      enabled: true
  openTelemetry:
    enabled: true
    instrumentation:
      enabled: true
      language: java
```

## Testing

Test the chart rendering:

```bash
# Basic test
helm template test . -f tests/values-default.yaml

# Test with extra configs
helm template test . -f tests/values-extra-configs.yaml

# Test with External Secrets
helm template test . -f tests/values-deployment-secrets.yaml

# Test dynamic ConfigMaps
helm template test . -f tests/values-dynamic-configmaps.yaml
```

## Values Reference

See [values.yaml](values.yaml) for the complete list of configurable parameters.

Key categories:
- `global.*` - Global settings
- `workload.*` - Application workload configuration
- `networking.*` - Network resources
- `config.*` - Configuration management
- `security.*` - Security & RBAC
- `storage.*` - Storage resources
- `scaling.*` - Autoscaling
- `observability.*` - Monitoring & tracing

## Contributing

This chart follows enterprise best practices:
- Organized template structure by resource type
- Categorized values for easy navigation
- Comprehensive documentation
- Extensive test coverage

## License

[Your License Here]
