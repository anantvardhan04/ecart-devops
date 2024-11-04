variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "application_name" {
  type = string
}
variable "service_name" {
  type = string
}
variable "aws_vpc_id" {
  type = string
}
variable "container_port" {
  type = string
}
variable "memory_reserv" {
  type = string
}
variable "load_balancer_security_group_id" {
  type = string
}
variable "target_group_arn" {
  type = list
}
variable "docker_image_url" {
  type = string
}

variable "elastic_search_domain" {
  default     = "localhost"

}
variable "elastic_search_port" {
  default     = "9200"
}
variable "elastic_search_user_name" {
}
variable "elastic_search_password" {
}

variable "cloudwatch_prefix" {
  default     = ""
  description = "If you want to avoid cloudwatch collision or you don't want to merge all logs to one log group specify a prefix"
}

variable "cluster" {
  description = "The name of the cluster"
  default = "amcart-login-updated"
}

variable "instance_group" {
  default     = "default"
  description = "The name of the instances that you consider as a group"
}

variable "aws_ami" {
  description = "The AWS ami id to use"
  default = "ami-03fb12c1feb7a3bb6"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type to use"
}

variable "max_size" {
  default     = 1
  description = "Maximum size of the nodes in the cluster"
}

variable "min_size" {
  default     = 1
  description = "Minimum size of the nodes in the cluster"
}

variable "desired_capacity" {
  default     = 1
  description = "The desired capacity of the cluster"
}

//variable "iam_instance_profile_id" {
//  description = "The id of the instance profile that should be used for the instances"
//}

variable "public_subnet_ids" {
  type        = list
  description = "The list of private subnets to place the instances in"
}

variable "load_balancers" {
  type        = list
  default     = []
  description = "The load balancers to couple to the instances. Only used when NOT using ALB"
}

//variable "depends_id" {
//  description = "Workaround to wait for the NAT gateway to finish before starting the instances"
//}

//variable "key_name" {
//  description = "SSH key name to be used"
//}

variable "custom_userdata" {
  default     = ""
  description = "Inject extra command in the instance template to be run on boot"
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "ecs_logging" {
  default     = "[\"json-file\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}
variable "health_check" {
  description = "The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)"
  type        = any
  default     = "/product/health-check/"
}

variable "enable_container_insights" {
  type = bool
  default = false
}
variable "xray_cpu" {
  type = number
  default =  256
}
variable "xray_mem" {
  type = number
  default = 256
}



