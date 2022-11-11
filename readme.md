# Application
This application serves a static "hello world" page. 

Additionally, the application expects an environmental variable `DEPLOYMENT_TYPE` to start. The value of the variable can be set to either `blue` or `green`, to differentiate between two deployments. The value of the `DEPLOYMENT_TYPE` is attached to every response provided by the application via `X-DEPLOYMENT-TYPE` header.

## How to build
Since we have no CICD pipelines in this project it's all manual, for example:
*  `docker build -t test-app .`
*  `docker tag test-app:latest 357390041162.dkr.ecr.eu-west-1.amazonaws.com/test-app:latest`
*  `docker push 357390041162.dkr.ecr.eu-west-1.amazonaws.com/test-app:latest`

# Blue/green test
The purpose of this test is to ensure that the transition from blue to green (and vice-versa) deployment happens smoothly and successfully. The script puts load around 5 rps.

The test scripts expects an environmental variable `APP_URL`, for example `APP_URL=http://test123-562580790.eu-west-1.elb.amazonaws.com`.

# Terraform
On the very high level, this repository describes AWS infrastructure in IaC fashion and provisions resources:
* VPC
* ECS cluster (Fargate)
* ALB
* Blue service
* Green service

## Before you start
* Add remote state configuration. By default, local state is used.
* Adjust name and images used for deployment.
* Ensure that proper AWS access method/credentials are available.
* Usage of Terraform Workspaces is optional, yet recommend.

## How to deploy
* `teraform init`
* `terraform apply --var-file=environments/dev.tfvars`

# Blue/green deployment
* Provision Terraform infrastructure
* Ensure that both blue and green deployments are up and running
* Ensure that application that is accessible via APP_URL returned by Terraform
* Execute test script
* In the separate session, edit tfvars file and change `active_deployment` parameter, then apply changes
* Once apply is completed plus three seconds, you should see a change in the output logs produced by the test script, from `blue` to `green`
* There should be no other responses than 200 