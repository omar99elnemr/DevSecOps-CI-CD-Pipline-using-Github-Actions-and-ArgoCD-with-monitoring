# DevSecOps Three-Tier Application with ArgoCD on AWS EKS

A complete DevSecOps pipeline for deploying a three-tier quiz application on AWS using Kubernetes (EKS), Terraform for infrastructure provisioning, and ArgoCD for GitOps. This project demonstrates infrastructure as code, application deployment, security scanning, and comprehensive monitoring.

![alt text](imgs/architecture-.gif)

## 🏗️ Architecture Overview

### Infrastructure Layer (Terraform)
- **AWS EKS Cluster**: Managed Kubernetes service 
- **VPC Configuration**: Custom VPC with CIDR 
- **IAM Roles**: Secure permissions for EKS cluster and worker nodes
- **Application Load Balancer**: Ingress traffic management

### Application Layer
- **Frontend**: React.js quiz application
- **Backend**: Node.js API server
- **Database**: MongoDB for data persistence
- **Container Registry**: AWS ECR for image storage

### DevSecOps Pipeline
- **CI/CD**: GitHub Actions workflows
- **Security Scanning**: Snyk, Trivy, SonarCloud integration
- **GitOps**: ArgoCD for declarative deployments
- **Monitoring**: Prometheus and Grafana stack

## 🛠️ Prerequisites

Before starting, ensure you have the following tools installed:

- AWS CLI
- kubectl
- Helm
- Terraform

## 🚀 Getting Started

### 1. Repository Setup

```bash
# Clone the repository
git clone https://github.com/omar99elnemr/DevSecOps-CI-CD-Pipline-using-Github-Actions-and-ArgoCD-with-monitoring.git
cd DevSecOps-CI-CD-Pipline-using-Github-Actions-and-ArgoCD-with-monitoring

# Change origin to your own repository
git remote set-url origin <your-repo-url>
git push -u origin main
```

### 2. Create S3 Bucket for Terraform State

Create an S3 bucket for storing Terraform remote state:

**Option A: Using AWS CLI**
```bash
BUCKET_NAME="quizapp00tfstate00bucket"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region us-east-1

# Optional: Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
```

**Option B: Using AWS Console**
Navigate to S3 service and create a bucket manually.
![Bucket](imgs/image.png)

## 🔐 Secrets Configuration

### Required GitHub Secrets

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for ECR and Terraform |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for ECR and Terraform |
| `AWS_ACCOUNT_ID` | Your AWS account ID (for ECR registry URL) |
| `BUCKET_TF_STATE` | S3 bucket name for storing Terraform state |
| `SNYK_TOKEN` | Snyk authentication token for vulnerability scanning |
| `SONAR_TOKEN` | SonarCloud authentication token |
| `SONAR_ORGANIZATION` | Your SonarCloud organization name |
| `SONAR_PROJECT_KEY` | SonarCloud project key |
| `SONAR_URL` | SonarCloud URL (usually https://sonarcloud.io) |

### Setup Instructions

#### AWS Credentials
1. Create IAM user with Admin policy attached
2. Generate access keys from Security Credentials tab
3. Note down your AWS Account ID (top-right corner of AWS Console)
![alt text](./imgs/Screenshot%202025-08-09%20183045.png)

<br><br>

![alt text](./imgs/Screenshot%202025-08-09%20183112.png)

<br>

![alt text](./imgs/Screenshot%202025-08-09%20183141.png)


#### Snyk Token
1. Sign up at [Snyk](https://snyk.io)
2. Go to Account Settings → General → Auth Token
3. Copy the token
![alt text](./imgs/Screenshot%202025-08-08%20014039.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20014115.png)

#### SonarCloud Setup
1. Sign up at [SonarCloud](https://sonarcloud.io)
2. Create new organization manually
3. Create new project and select "Previous version"
4. Choose "GitHub Actions" as analysis method
5. Copy the provided token and organization details
![alt text](./imgs/Screenshot%202025-08-08%20014338.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20014813.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20014912.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20015904.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20015919.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20015939.png)

<br>

![alt text](./imgs/Screenshot%202025-08-08%20020129.png)

#### Adding Secrets to GitHub
1. Navigate to your repository
2. Go to Settings → Secrets and Variables → Actions
3. Add all required secrets listed above
![alt text](./imgs/Screenshot%202025-08-09%20185946.png)


## 📋 Deployment Steps

### Step 1: Infrastructure Deployment
1. Review and modify Terraform variables and Helm values as needed
2. Run the `terraform.yaml` workflow from GitHub Actions
3. Wait for completion and note the cluster access details from workflow output
![alt text](imgs/terraform-apply.png)

### Step 2: Monitoring Setup

#### Prometheus
Access Prometheus using the external IP provided in the workflow output.
![alt text](./imgs/Screenshot%202025-08-10%20120016.png)

#### Grafana
- **Default Credentials**: Check workflow output for username/password
![alt text](./imgs/Screenshot%202025-08-10%20115912.png)
- **Dashboard Import**: Use ID `6417` for Kubernetes monitoring
![alt text](./imgs/312580938-bdbd0d13-639a-4a32-bfd1-f986f1d5f090.png)
![alt text](./imgs/Screenshot%202025-08-10%20154010.png)

- **Additional Dashboard IDs**:
  - Global View: `15757`
  ![alt text](./imgs/312584310-f32673e0-c9d3-4fc2-8734-365e8c66465d.png)
  - Namespaces: `15758` 
  ![alt text](./imgs/312584681-38cfb038-d8af-42e8-96bd-5a19c4529202.png)
  - Nodes: `15759`
  ![alt text](./imgs/312584786-1f646754-cc07-4175-b5d0-da663fd1249a.png)

### Step 3: ArgoCD Configuration

#### Initial Setup
```bash
# Get ArgoCD initial password
export ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $ARGO_PWD
```

#### Repository Configuration
- Login to ArgoCD with username `admin` and the retrieved password
![alt text](./imgs/Screenshot%202025-08-10%20115250.png)

#### Application Creation
1. Click "CREATE APPLICATION"
![alt text](./imgs/argo-new.png)
2. Configure application details:
   - **Application Name**: Choose a meaningful name
   - **Project**: default
   - **Sync Policy**: Manual or Automatic
   - **Repository URL**: Your application repository
   - **Path**: Path to Helm charts
   - **Cluster URL**: https://kubernetes.default.svc
   - **Namespace**: Target namespace
![alt text](./imgs/Screenshot%202025-08-10%20154231.png)

<br>

![alt text](./imgs/Screenshot%202025-08-10%20154302.png)

### Step 4: Application Deployment
1. Navigate to GitHub Actions in your repository
2. Run the "DevSecOps CI" workflow
3. This workflow will:
   - Scan code for vulnerabilities
   - Build and scan Docker images
   - Push images to ECR
   - Update Helm values with new image tags
   - Trigger ArgoCD sync for deployment
![alt text](./imgs/ci.png)

<br>

![alt text](./imgs/Screenshot%202025-08-10%20154416.png)

<br>

![alt text](./imgs/argo-healthy.png)

<br>

![alt text](./imgs/Screenshot%202025-08-10%20160347.png)

### Step 5: Domain Configuration (Optional)

#### Route 53 Setup
1. Purchase domain from provider (e.g., Namecheap, GoDaddy)
![alt text](./imgs/Screenshot%202025-08-10%20114321.png)
2. Create hosted zone in Route 53
![alt text](./imgs/Screenshot%202025-08-10%20114416.png)

<br>

![alt text](./imgs/Screenshot%202025-08-10%20114511.png)

<br>

![alt text](./imgs/Screenshot%202025-08-10%20114603.png)
3. Update nameservers at your domain provider
![alt text](./imgs/Screenshot%202025-08-10%20114715.png)
4. Create A-record pointing to ALB DNS name
![alt text](./imgs/Screenshot%202025-08-10%20161915.png)
![alt text](./imgs/record.png)

## Working app
![alt text](./imgs/website.png)

## 🧹 Cleanup

To destroy all resources:

1. Run the `terraform-destroy.yml` workflow from **GitHub Actions**.  
   ![Cleanup workflow screenshot](./imgs/cleaanup.png)

2. If the cleanup workflow gets stuck, use the following order to manually destroy AWS resources:  
   - **EKS Node Groups** → **EKS Cluster** → **VPC** *(must be in this exact order)*  
   - Policies, IAM Roles, and ECR repositories can be deleted in any order.  

3. Verify that all AWS resources have been properly removed.

**Note**: Ensure all secrets are properly configured before running any workflows. The deployment process may take 15-30 minutes depending on your AWS region and resource allocation.


