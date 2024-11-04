terraform {
  backend "s3" {
    bucket = "promotion-casestudy-state-bucket"
    key    = "static-infra/terraform.state"
    region = "ap-south-1"
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a new Cognito User Pool
module "cognito-user-pool-http-api" {
  source                          = "./modules/aws_cognito"
  cognito_user_pool_name          = var.application_name
  cognito_user_pool_client_name   = "${var.application_name}-angular-frontend"
  cognito_user_pool_callback_urls = ["https://127.0.0.1:3000"] # This is the URL where the user will be redirected after login
}

module "aws_ec2_key_pair" {
  source           = "./modules/aws_key_pair"
  env              = var.env
  public_file_name = var.public_file_name
}

module "aws_ecr" {
  count            = length(local.services-names)
  source           = "./modules/aws_ecr"
  env              = var.env
  region           = var.region
  application_name = var.application_name
  service_name     = local.services-names[count.index]
}

module "aws-api_gateway" {
  source            = "./modules/aws_api_gateway"
  env               = var.env
  region            = var.region
  application_name  = var.application_name
  s3_bucket_name    = "${var.application_name}-${var.env}-api-gateway"
  load_balancer_uri = module.aws_load_balancer_target_group.load_balancer_dns_name
  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
}

module "static_content" {
  source                           = "./modules/aws_s3_cloud_front"
  env                              = var.env
  region                           = var.region
  application_name                 = var.application_name
  bucket_name                      = "${var.env}-amcart-static-content"
  duplicate-content-penalty-secret = "some-secret-password"
  deployer                         = "amcart-terraform-deploy-user"
  acm-certificate-arn              = "arn:aws:acm:us-east-1:730736917320:certificate/ccae6a46-99af-4011-b931-5eaec110f2c1"
}

module "aws_vpc_subnet" {
  source           = "./modules/aws_vpc_subnet"
  region           = var.region
  env              = var.env
  application_name = var.application_name
}

module "aws_load_balancer_target_group" {
  source                     = "./modules/aws_load_balancer_target_group"
  env                        = var.env
  region                     = var.region
  application_name           = var.application_name
  aws_vpc_id                 = module.aws_vpc_subnet.vpc_id
  aws_public_subnet_id       = module.aws_vpc_subnet.public_subnet_id
  public_security_group_port = var.public_security_group_port
}

module "aws_ecs_task" {
  source                          = "./modules/aws_ecs"
  count                           = length(local.services-names)
  service_name                    = local.services-names[count.index]
  env                             = var.env
  region                          = var.region
  application_name                = var.application_name
  aws_vpc_id                      = module.aws_vpc_subnet.vpc_id
  public_subnet_ids               = module.aws_vpc_subnet.public_subnet_id
  container_port                  = lookup(local.services-names-parameter, local.services-names[count.index]).container_port
  memory_reserv                   = lookup(local.services-names-parameter, local.services-names[count.index]).memory_reserv
  load_balancer_security_group_id = module.aws_load_balancer_target_group.load_balancer_security_group_id
  target_group_arn                = module.aws_load_balancer_target_group.target_group_arn
  docker_image_url                = lookup(local.services-names-parameter, local.services-names[count.index]).docker_image_url
  elastic_search_domain           = module.ec2_with_cs.public_ip_ec2_es
  elastic_search_user_name        = module.ec2_with_cs.elastic_search_user_name
  elastic_search_password         = module.ec2_with_cs.elastic_search_password
}

module "ec2_with_cs" {
  source             = "./modules/ec2_with_es"
  region             = var.region
  env                = var.env
  application_name   = var.application_name
  service_name       = "elastic-search-service"
  vpc_id             = module.aws_vpc_subnet.vpc_id
  availability_zones = "${var.region}a"
  private_subnet_ids = module.aws_vpc_subnet.public_subnet_id
  key_name           = "${var.env}_developer_terraform_key"
}

module "sns_pipeline" {
  source     = "./modules/aws-sns-topic"
  attributes = []
  name       = "ci-cd-pipeline"
  namespace  = var.application_name
  stage      = var.env

  subscribers = {
    opsgenie = {
      protocol               = "email"
      endpoint               = "anant.vardhan@nagarro.com"
      raw_message_delivery   = false
      endpoint_auto_confirms = true
    }
  }

  sqs_dlq_enabled = false
}

#    _____ _____     _______ _____  
#   / ____|_   _|   / / ____|  __ \ 
#  | |      | |    / / |    | |  | |
#  | |      | |   / /| |    | |  | |
#  | |____ _| |_ / / | |____| |__| |
#   \_____|_____/_/   \_____|_____/ 


module "aws_code_pipe_line" {
  count                      = length(local.services-names)
  source                     = "./modules/aws_code_pipeline"
  pipe_line_config           = lookup(local.services-names-parameter, local.services-names[count.index])
  env                        = var.env
  region                     = var.region
  application_name           = var.application_name
  load_balancer_listener_arn = module.aws_load_balancer_target_group.load_balancer_listener_arn
  target_group_info          = module.aws_load_balancer_target_group.target_groups_name
  aws_account_id             = var.aws_account_id
  task_definition_family     = "${var.env}-${var.application_name}-${local.services-names[count.index]}"
  ecs_role                   = module.aws_ecs_task[0].aws_ecs_role
  ecs_task_role              = module.aws_ecs_task[0].aws_ecs_task_role
  task_definition_arn        = module.aws_ecs_task[0].aws_ecs_task_definition_arn
  sns_topic_arn              = module.sns_pipeline.sns_topic_arn
}

module "aws_code_pipe_line_frontend" {
  count                       = length(local.frontend-services-names)
  source                      = "./modules/aws_code_pipeline_frontend"
  pipe_line_config            = lookup(local.frontend-services-names-parameter, local.frontend-services-names[count.index])
  env                         = var.env
  region                      = var.region
  application_name            = var.application_name
  aws_account_id              = var.aws_account_id
  apiBaseUrl                  = "${module.aws-api_gateway.api_url}/${var.env}"
  userPoolId                  = module.cognito-user-pool-http-api.user_pool_id
  userPoolWebClientId         = module.cognito-user-pool-http-api.user_pool_client_id
  cloud_front_distribution_id = module.static_content.cloud_front_distribution_id
}