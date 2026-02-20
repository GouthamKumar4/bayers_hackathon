# Healthcare Microservices Deployment Plan (Azure AKS)

## 1) Delivery Plan (5-hour hackathon)

1. **Architecture and backlog alignment (30 min)**
   - Confirm scope: Patient Service + Appointment Service.
   - Define AKS target architecture, networking, CI/CD, logging, HPA, and gateway pattern.
2. **Containerization (45 min)**
   - Create Dockerfiles for both services.
   - Add `.dockerignore`, image tags, and runtime environment variables.
3. **Infrastructure as Code (90 min)**
   - Create Terraform structure for `dev`, `staging`, `prod`.
   - Provision Azure network, AKS, Azure DNS, ACR, log analytics, application insights.
   - Add remote state backend and environment isolation.
4. **Kubernetes and networking (60 min)**
   - Deploy services into AKS.
   - Configure HPA for both microservices.
   - Configure two edge layers (Azure API Management + Azure Application Gateway/AGIC).
5. **CI/CD and verification (45 min)**
   - GitHub Actions for lint, plan, apply, build/push, deploy.
   - Smoke tests for `/health`, `/patients`, `/appointments`.
6. **Documentation and handoff (30 min)**
   - Architecture diagram, system boundary, runbook, and risks.

---

## 2) System Requirements

### Functional Requirements
- Expose REST endpoints for:
  - `GET /health` on each service.
  - CRUD-lite operations for patients and appointments.
  - `GET /appointments/patient/:patientId` for appointment lookups.
- Support independent deployment and scaling of each service.
- Route external traffic through managed gateway tiers.

### Non-Functional Requirements
- **Availability:** Multi-node AKS across availability zones (where region supports it).
- **Scalability:** Horizontal Pod Autoscaler (HPA) based on CPU/memory and optional custom metrics.
- **Security:**
  - Private AKS node pools.
  - TLS termination at edge.
  - Managed identities for workload-to-Azure access.
  - Secrets in Azure Key Vault.
- **Observability:** Centralized logs/metrics in Azure Monitor + Log Analytics; alerts to on-call channel.
- **Performance:** p95 API latency target under agreed SLO (e.g., < 300 ms for health/read endpoints).
- **Resilience:** Rolling updates, readiness/liveness probes, pod disruption budgets.

### Platform/Tooling Requirements
- Azure subscription with permissions for networking, AKS, ACR, DNS, monitoring, and IAM.
- Terraform >= 1.5 and AzureRM provider.
- Docker and kubectl.
- GitHub Actions with OIDC federation to Azure.
- Container registry (Azure Container Registry).

---

## 3) System Boundary

### Inside the System Boundary
- Azure API Management (public API facade and policy enforcement).
- Azure Application Gateway (WAF + L7 routing) as second gateway tier.
- AKS cluster and namespaces (`patient`, `appointment`, `shared`).
- Kubernetes services, deployments, HPA objects, ingress.
- Observability stack: Azure Monitor, Log Analytics, Application Insights.
- CI/CD assets: GitHub workflows, Terraform, Kubernetes manifests/Helm values.

### Outside the System Boundary
- End users/clients and partner applications.
- Third-party identity providers.
- External hospital systems and EHRs.
- Corporate SIEM/SOC (receives forwarded logs/alerts).

### Boundary Interfaces
- Public DNS zone in **Azure DNS** points domain records to API Management/Application Gateway.
- HTTPS APIs exposed externally; internal east-west service calls stay within AKS virtual network.
- Telemetry exported from AKS/apps to Azure Monitor and optional external SIEM.

---

## 4) Target Architecture (AKS + Azure DNS + HPA + Two Gateways)

```mermaid
flowchart TB
    U[Users / Client Apps] --> D[Azure DNS\napi.health.example.com]
    D --> APIM[API Gateway #1\nAzure API Management]
    APIM --> AGW[Gateway #2\nAzure Application Gateway + WAF]
    AGW --> ING[AKS Ingress Controller\n(AGIC / NGINX)]

    subgraph AZ[Azure Cloud]
      subgraph NET[Virtual Network]
        subgraph AKS[AKS Cluster]
          ING --> PSVC[Patient Service\nDeployment + Service]
          ING --> ASVC[Appointment Service\nDeployment + Service]
          HPA1[HPA - Patient] -. scales .-> PSVC
          HPA2[HPA - Appointment] -. scales .-> ASVC
        end
      end

      PSVC --> MON[Azure Monitor / Log Analytics]
      ASVC --> MON
      APIM --> MON
      AGW --> MON

      ACR[Azure Container Registry] --> AKS
      KV[Azure Key Vault] --> PSVC
      KV --> ASVC
    end

    GH[GitHub Actions CI/CD] --> ACR
    GH --> AKS
    GH --> TF[Terraform IaC]
    TF --> AZ
```

---

## 5) Recommended Gateway Split (Why two?)

- **API Management (Gateway #1):** API productization, auth policies, quotas, request transformation, versioning, developer portal.
- **Application Gateway (Gateway #2):** WAF protections, TLS policy, advanced L7 load balancing to AKS ingress.

This split allows API governance and security controls to evolve independently from runtime ingress/load balancing concerns.

---

## 6) HPA Baseline Settings

- **Patient Service HPA:**
  - `minReplicas: 2`, `maxReplicas: 10`
  - scale at CPU ~60% and memory ~70%
- **Appointment Service HPA:**
  - `minReplicas: 2`, `maxReplicas: 10`
  - scale at CPU ~60% and memory ~70%

Add Cluster Autoscaler for node-level scaling so pod scaling is not blocked by capacity.

---

## 7) Minimal CI/CD Workflow Outline

1. Pull Request:
   - Terraform `fmt`, `validate`, `plan`
   - Application lint/test/build
2. Merge to `main`:
   - Build and push images to ACR
   - Terraform apply (environment-gated)
   - Deploy to AKS via Helm/kubectl
   - Post-deploy smoke tests

