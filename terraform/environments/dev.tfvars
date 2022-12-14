name            = "test123"
region          = "eu-west-1"
cidr            = "10.0.0.0/16"
azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

active_deployment = "blue"
deployments       = {
  "blue"  = "357390041162.dkr.ecr.eu-west-1.amazonaws.com/test-app:latest",
  "green" = "357390041162.dkr.ecr.eu-west-1.amazonaws.com/test-app:latest"
}

tags = {
  "environment": "dev"
}
