# A fully automated pipeline which provisions the infrastructure and deploy the applications
### Contributed by irahulgulati

## Technologies Used
1.  Packer
2.  Ansible
3.  AWS
4.  Terraform
5.  Bash Script
6.  Nginx
7.  Make

## Setup
1.  Install Packer via this [link](https://learn.hashicorp.com/tutorials/packer/getting-started-install).
2.  Install Terraform via this [link](https://learn.hashicorp.com/tutorials/terraform/install-cli).
3.  (Needed by Packer)Set your aws credentials via environment variable with following keynames:
    -   ACCESS_KEY
    -   SECRET_KEY
4.  (Optional)Install Make via this [link](http://gnuwin32.sourceforge.net/packages/make.htm) or use repository for *nix operating system.
5.  Change the current directory to packer and run following commands:
    -   packer validate nginx_web_server.json
    -   packer validate app_server.json
6.  Next step is to build the AMI if the validation is successful
    -   packer build nginx_web_server.json
    -   packer build app_server.json
    Note: This process will take time as it will provision a temporary EC2 instance, install Ansible on it, use Ansible to configure the image and then tag that image and store it in AWS.
7.  (Needed by Terraform) Make sure that your aws cli is installed and is configured with the credentials using "aws configure" command.
8.  Change your directory to terraform and run below command to initiate the terraform:
    -   terraform init
9.  Run below command to plan your infrastructure:
    -   terraform plan
10.  After planning is successful, run the below command to provision the infrastructre:
    -   terraform apply
11. If you want to delete all the provisioned infrastructure run below command:
    -   terraform destroy

#### Note: This terraform configuration saves the terraform state to a remote s3 bucket. Make sure to change the name of bucket in ~/terraform/main.tf file and as well as make sure that you have IAM policy assigned to access the S3/bucket or cross check the bucket policies.

## Alternatively if you have installed Make you can run below command in the root folder:
    -   make build
    Note: Given that you have installed Packer, Terraform and configured the environment keys as well as aws cli.


