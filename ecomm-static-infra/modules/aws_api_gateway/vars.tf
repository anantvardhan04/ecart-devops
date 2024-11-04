# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "AWS resource namespace/prefix"
  default = "amcart_dev"
}
variable "env" {
  type = string
}
variable "load_balancer_uri" {
  type = string
}

variable "region" {
  description = "AWS region"
}

variable "resource_tag_name" {
  description = "Resource name for billing purposes"
  default = "v1"
}

# -----------------------------------------------------------------------------
# Variables: API Gateway
# -----------------------------------------------------------------------------
variable "application_name" {
  description = "API Gateway endpoint name"
}
variable "s3_bucket_name" {
  type    = string
}
variable "force_destroy" {
  type = bool
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default = true
}
variable "cognito_user_pool_id" {
  type    = string
  default = ""
}
variable "cognito_user_client_id" {
  type    = string
  default = ""
}


//variable "api_template" {
//  description = "API Gateway OpenAPI 3 template file"
//  default = ""
//}
//
//variable "api_template_vars" {
//  description = "Variables required in the OpenAPI template file"
//  type        = map
//}

variable "api_throttling_rate_limit" {
  description = "API Gateway total requests across all API's within a REST endpoint"
  default = 20
}

variable "api_throttling_burst_limit" {
  description = "API Gateway total concurrent connections allowed for all API's within a REST endpoint"
  default = 40
}

variable "api_metrics_enabled" {
  description = "Enables detailed API Gateway metrics"
  type        = bool
  default     = false
}

variable "api_logging_level" {
  description = " (Optional) Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. The available levels are OFF, ERROR, and INFO."
  type        = string
  default     = "OFF"
}

variable "api_data_trace_enabled" {
  description = "(Optional) Specifies whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = bool
  default     = false
}

variable "xray_tracing_enabled" {
  description = "Enables the XRay tracing and will create the necessary IAM permissions "
  type        = bool
  default     = false
}
variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs."
  type        = any
  default     = {}
}
# authorrizers
variable "authorizers" {
  description = "Map of API gateway authorizers"
  type        = map(any)
  default     = {}
}

# -----------------------------------------------------------------------------
# Variables: Cloudwatch Alarms Latency
# -----------------------------------------------------------------------------
//variable "resources" {
//  description = "Methods that have Cloudwatch alarms enabled"
//  type        = map
//}
//
//variable "latency_threshold_p95" {
//  description = "The value against which the specified statistic is compared"
//  default     = 1000
//}
//
//variable "latency_threshold_p99" {
//  description = "The value against which the specified statistic is compared"
//  default     = 1000
//}
//
//variable "create_latency_alarm" {
//  description = "Enable/disable latency alerts"
//  type        = bool
//  default     = true
//}
//
//variable "latency_evaluationPeriods" {
//  description = "The number of periods over which data is compared to the specified threshold"
//  default     = 5
//}
//
//variable "fourRate_threshold" {
//  description = "Percentage of errors that will trigger an alert"
//  default     = 0.02
//  type        = number
//}
//
//variable "fourRate_evaluationPeriods" {
//  description = "How many periods are evaluated before the alarm is triggered"
//  default     = 5
//  type        = number
//}
//
//variable "fiveRate_threshold" {
//  description = "Percentage of errors that will trigger an alert"
//  default     = 0.02
//  type        = number
//}
//
//variable "fiveRate_evaluationPeriods" {
//  description = "How many periods are evaluated before the alarm is triggered"
//  default     = 5
//  type        = number
//}