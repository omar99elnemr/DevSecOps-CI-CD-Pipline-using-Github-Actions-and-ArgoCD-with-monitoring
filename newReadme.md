To use this repo
first clone it 
change the origin to your own repo
then push it

you then recommended to havve the following tools on your machine
1- awscli
2- terraform

you need to create a S3 bucket for the remote state of terraform
eaither through console or through the cli
and note down the bucket name

Here are  Required GitHub Secrets:
AWS_ACCESS_KEY_ID           # AWS access key for ECR and Terraform
AWS_SECRET_ACCESS_KEY       # AWS secret key for ECR and Terraform  
AWS_ACCOUNT_ID              # Your AWS account ID (for ECR registry URL)
BUCKET_TF_STATE            # S3 bucket name for storing Terraform state
SNYK_TOKEN                 # Snyk authentication token for vulnerability scanning
SONAR_TOKEN               # SonarCloud authentication token
SONAR_ORGANIZATION        # Your SonarCloud organization name
SONAR_PROJECT_KEY         # SonarCloud project key
SONAR_URL                 # SonarCloud URL (usually https://sonarcloud.io)
GITHUB_TOKEN              # Automatically provided by GitHub Actions


First run the IaC workflow
It will provision 2 ecr repos Frontend image and backend Image
An EKS cluster with ArgoCD, Prometheus, Grafana and AWS loadbalancer Controller installed through helm provider. Also patched The monitoring stack to have a loadblancer service type.

![alt text](image.png)

```
aws s3api create-bucket \
  --bucket quizapp00state00bucket \
  --region us-east-1 \
 #if not us-east-1
 # --create-bucket-configuration LocationConstraint=<your-region> 
```
