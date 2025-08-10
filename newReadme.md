To use this repo
first clone it 
change the origin to your own repo
then push it

you then recommended to havve the following tools on your machine
1- awscli
2- kubectl
3- helm
2- terraform

you need to create a S3 bucket for the remote state of terraform
either through console or through the cli
and note down the bucket name





Step1: Gathering secrets


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



Create IAM user With admin attached policy.
![iam01](specify details)
go to 1am > users > create
![iam02](specify details)
Set admin permissions
![1am03](create)
review and create
![iam03]()
got to security credentials
![iam04]()
choose access cli
![iam05]()
then retrieve access keys

also make sure to copy account ID also as AWS_ACCOUNT_ID  
![accountid]()

Take use access keys you get under access tab save them for use.
AWS_ACCESS_KEY_ID           # AWS access key for ECR and Terraform
AWS_SECRET_ACCESS_KEY       # AWS secret key for ECR and Terraform  
Also copy your Acount ID you can find it on the to right  of console
AWS_ACCOUNT_ID              # Your AWS account ID (for ECR registry URL)

Next Is the Terraform state bucket on s3:
You can either create it using console.
or after configuring your awscli with IAM access keys, you can use this command:

```
BUCKET_NAME="quizapp00tfstate00bucket"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region us-east-1

#oprional
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
```

or theough console:
![bucket01]()


then use the name of created bucket as secret
BUCKET_TF_STATE            # S3 bucket name for storing Terraform state



synk:
signup > got to account settings in the bottom left
![synk01]()
from account settings > general >Auth token (copy it)
![synk02]()

Note down SNYK_TOKEN 


sonarcloud:
signup > create new organization
![sonar01]()
create one manually
![sonar02]()
type name and key and choose free plan
![sonar03]()
In your new organization, click on + and select Analyze new project. Enter name and key. Then clikc on previous version and save
![sonar04]()

In the project interface choose analysis method with github action
![sonar04]()
Copy the secret value as instructed
![sonar05]()
Now type all sonar's secrets needed:
SONAR_TOKEN               # SonarCloud authentication token
SONAR_ORGANIZATION        # Your SonarCloud organization name
SONAR_PROJECT_KEY         # SonarCloud project key
SONAR_URL                 # SonarCloud URL (usually https://sonarcloud.io)



Now you have all needed secrets, you need to enter them into githubs repo secrets:
go to repo settings > secrets and variables >actions
!(secrets)[]


Check helm values and terraform variables for any desired changes

then run the terraform.yaml workflow

after the finish you can access the cluster as metioned in the workflow output and also the service with externelip access will be outputed for you convenience.
You now check prometheus:
![prometheus]()

Grafna (configured with pre-set username and password ):
![grafana01]()
Now, we will create a dashboard to visualize our Kubernetes Cluster Logs. Click on Dashboard.
you can set dashboards you want for instance 

Once you click on Dashboard. You will see a lot of Kubernetes components monitoring.
![grafana03]()

Let’s try to import a type of Kubernetes Dashboard. Click on New and select Import

Provide 6417 ID and click on Load Note: 6417 is a unique ID from Grafana which is used to Monitor and visualize Kubernetes Data
![grafana03]()

Here, you go. You can view your Kubernetes Cluster Data. Feel free to explore the other details of the Kubernetes Cluster.
![grafana04]()


Deploy Quiz Application using ArgoCD:

Argocd, you have to type the command to retrieve the intial password:
```
export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGO_PWD
```
Enter the username admin and password in argoCD and click on SIGN IN.
![argo01]()

You can change it later if you want

Now let's add the project to argo to handel it

![argo02]()

Configure the app_code github repository in ArgoCD. Click on Settings and select Repositories

Screenshot 2024-02-28 at 6 17 56 PM

Click on CONNECT REPO USING HTTPS

Screenshot 2024-02-28 at 6 18 07 PM

Now, provide the repository name where your Manifests files are present. Provide the username and GitHub Personal Access token if your repo is private and click on CONNECT.

Screenshot 2024-02-28 at 6 26 11 PM

If your Connection Status is Successful it means repository connected successfully.

Screenshot 2024-02-28 at 6 26 55 PM

Now, we will create our application which will deploy the frontend, backend. database and ingress Click on CREATE APPLICATION.

Screenshot 2024-03-13 at 2 10 48 PM

Provide the details as it is provided in the below snippet and scroll down.

Screenshot 2024-03-13 at 2 09 55 PM

Select the same repository that you configured in the earlier step. In the Path, provide the path to you helm chart and provide other things as shown in the below screenshot.

Screenshot 2024-03-13 at 2 13 00 PM

Click on CREATE.

Screenshot 2024-03-09 at 7 30 10 PM

ArgoCD will deploy all the application in the kubernetes-manifest folder

Screenshot 2024-03-09 at 7 10 37 PM

Now you need to go to the actions tab in you github repo and run the DECSECOPS CI workflow:
![ci01]()

this workflow will do scan your code build images and push scanned images to ecr then patch the new image tags into the helm value.yaml, Which are detected by Argocd that deploy the new changes into EKS cluster:

Deployment is synced and healthy

Screenshot 2024-03-13 at 2 16 57 PM

Once your Ingress application is deployed. It will create an Application Load Balancer You can check out the load balancer named with k8s-ingress.

Now, Copy the ALB-DNS and go to your Domain Provider in this case AWS Route 53 is the domain provider.

Screenshot 2024-02-28 at 6 42 29 PM

Step 13: Creating an A-Record in AWS Route 53 Using ALB DNS
Create A-records using DNS service in aws [Route53]. Follow these steps to create an A-record in AWS Route 53 that points to your Application Load Balancer (ALB).

1: Open Route 53 Dashboard
In the search bar at the top, type "Route 53" and click on the Route 53 service to open the Route 53 dashboard.

2: Select Hosted Zone
From the Route 53 dashboard, choose "Hosted zones" under the DNS management section. Then select the hosted zone where you want to add the A-record.

3: Creating an A-Record in AWS Route 53 Using ALB DNS

Now steps before creating a recore you need to have a domain name from a domain name provider like NameCheap or GoDaddy:
I had mine from Namecheap.

Go to route 53 and choose create hosts zone:
![dn01]()
Enter your domain name and choose public hosts:
![dn02]()
After creation you will have 4 nameservers which you will copy into your domain settings:
![dn03](../../..)
Choose Custom Servers
![dn04](../../..) 

And done, now the domain will have up to 48 hours to be assigned but in reality it usally takes few hours.

Now back to the main path, 
Create A-records using DNS service in aws [Route53]. Follow these steps to create an A-record in AWS Route 53 that points to your Application Load Balancer (ALB).

1: Open Route 53 Dashboard
In the search bar at the top, type "Route 53" and click on the Route 53 service to open the Route 53 dashboard.

2: Select Hosted Zone
From the Route 53 dashboard, choose "Hosted zones" under the DNS management section. Then select the hosted zone to add the A-record.

Create Record:

Screenshot 2024-02-29 at 4 49 56 AM

Click on the "Create record" button.
In the "Record name" field, enter the subdomain or leave it blank for the root domain.
For "Record type", select "A – Routes traffic to an IPv4 address and some AWS resources".
In the "Value/Route traffic to" section, choose "Alias to Application and Classic Load Balancer".
Select the region where your ALB is located.
Choose the ALB (it's identified by its DNS name) from the dropdown.
(Optional) Adjust the "Routing policy" and "Record ID" as needed.
Screenshot 2024-02-29 at 4 53 37 AM

4: Confirm and Create
Review your configurations and click on the "Create records" button to create your A-record.

By following these steps, you'll successfully create an A-record in AWS Route 53 that points to your Application Load Balancer, allowing you to route traffic from your domain to your ALB.

Share you subdomain


Screenshot 2024-03-13 at 3 12 09 PM

Logged into the simple quiz application

Screenshot 2024-03-13 at 3 12 35 PM

More Grafana dashboard IDs to try


More Grafana dashboard IDs to try

Dashboard	ID
k8s-addons-prometheus.json	19105
k8s-system-api-server.json	15761
k8s-system-coredns.json	15762
k8s-views-global.json	15757
k8s-views-namespaces.json	15758
k8s-views-nodes.json	15759
k8s-views-pods.json	15760
For Global

Screenshot 2024-03-10 at 3 28 42 AM

For Namespaces

Screenshot 2024-03-10 at 3 31 16 AM

For Nodes

Screenshot 2024-03-10 at 3 32 51 AM

Step 14: Clean up
To clean up all you have to do is to run the terraform-destroy.yml workflow.