# Career Objective

Deploy scalable and secure cloud solutions using DevOps best practices, CI/CD automation, Kubernetes, and cloud technologies. My goal is to improve application reliability, streamline deployments, and build efficient infrastructure that supports business growth.

---

# Stateless Node.js API Production Deployment

## Overview

This project contains the configurations and deployment files required to deploy a stateless Node.js API on AWS EKS. The solution includes a secure Docker image, Jenkins CI/CD pipeline, Kubernetes deployment configurations, and observability setup using Prometheus, Grafana, and ELK Stack.

---

## Architecture Decisions

### Dockerfile Improvements

The Dockerfile provided by the developer works for local development, but it is not suitable for production environments without some improvements.

The following changes were made:

* Replaced `node:latest` with a fixed Node.js version (`node:20-alpine`) to avoid unexpected issues during future deployments.
* Implemented a multi-stage build to reduce image size and remove unnecessary build dependencies from the final image.
* Used `npm ci` instead of `npm install` for consistent dependency installation.
* Configured the container to run as a non-root user for better security.
* Only the required application files are included in the runtime image.

These changes help reduce image size, improve security, and make deployments more predictable.

---

### CI/CD Pipeline Design

A Jenkins pipeline is used to automate the build and deployment process.

Pipeline flow:

1. Checkout source code from Git repository.
2. Build the Node.js application.
3. Run basic validation and security scanning.
4. Build Docker image.
5. Authenticate to Artifactory using Jenkins credential `jarvis-artifactory`.
6. Push image to the artifact registry.
7. Validate Helm templates.
8. Deploy the application to EKS using Helm.
9. Verify deployment status using Kubernetes rollout checks.

Using Jenkins credentials keeps sensitive information outside the source code and prevents accidental exposure of passwords or tokens.

---

### Kubernetes Deployment Decisions

The application is deployed on AWS EKS using Helm charts.

Key deployment considerations:

* Application runs with 3 replicas to improve availability.
* Container port is named `api-web` as requested.
* Liveness and readiness probes are configured for health monitoring.
* Resource requests and limits are defined to avoid resource exhaustion.
* Rolling updates are enabled to minimize downtime during deployments.
* Security context is configured to prevent privilege escalation.
* Container runs as a non-root user.
* Unnecessary Linux capabilities are removed.

These configurations follow common production deployment practices and help improve reliability and security.

---

## Observability Setup

### Monitoring with Prometheus and Grafana

Prometheus is used to collect metrics from the application and Kubernetes resources.

The deployment includes Prometheus annotations:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "3000"
prometheus.io/path: "/metrics"
```

Grafana dashboards can be created to monitor:

* API request count
* Response time
* Error rates
* CPU utilization
* Memory consumption
* Pod availability

This helps operations teams quickly identify performance issues and application failures.

---

### Logging with ELK Stack

Application logs are written to stdout and stderr following container best practices.

Log flow:

Node.js Application → Filebeat/Logstash → Elasticsearch → Kibana

Benefits:

* Centralized log management
* Faster troubleshooting
* Application error tracking
* Searchable logs through Kibana

Structured JSON logging is recommended to improve log parsing and analysis.

---

## Assumptions

The following assumptions were made while creating this solution:

* The Node.js application listens on port 3000.
* The build process generates application artifacts successfully.
* AWS EKS cluster is already available.
* Jenkins has required permissions to access EKS.
* Prometheus, Grafana, and ELK Stack are already deployed.
* An Ingress Controller is available inside the cluster.

---

## Deployment Steps

### Build Docker Image

```bash
docker build -t node-api:latest .
```

### Deploy Using Jenkins

1. Configure Jenkins pipeline.
2. Add Artifactory credentials with ID:

```text
jarvis-artifactory
```

3. Configure Kubernetes access for Jenkins.
4. Trigger the pipeline.

---

### Manual Helm Deployment

Install or upgrade the application:

```bash
helm upgrade --install node-api helm/node-api \
--namespace production \
--create-namespace
```

Verify deployment:

```bash
kubectl get pods -n production
kubectl get svc -n production
kubectl get ingress -n production
```

Check rollout status:

```bash
kubectl rollout status deployment/node-api -n production
```

---
