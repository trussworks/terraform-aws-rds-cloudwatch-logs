variable "env_cloudwatch_logs_group" {
  description = "The CloudWatch Log group name where the RDS logs will be streamed."
  type        = "string"
}

variable "env_db_instance_identifier" {
  description = "The RDS database instance identifier."
  type        = "string"
}

variable "env_start_time" {
  description = "The log file start time. Currently support \"1h\" for the past hour and \"1d\" for the past day."
  type        = "string"
}

variable "cloudwatch_logs_retention_days" {
  default     = 90
  description = "Number of days to keep logs in AWS CloudWatch."
  type        = "string"
}

variable "environment" {
  description = "Environment tag, e.g prod."
}

variable "interval_minutes" {
  default     = 60
  description = "How often to run the Lambda function in minutes."
  type        = "string"
}

variable "lambda_memory_size" {
  default     = 128
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  type        = "string"
}

variable "lambda_timeout" {
  default     = 60
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = "string"
}

variable "s3_bucket" {
  description = "The name of the S3 bucket used to store the Lambda builds."
  type        = "string"
}

variable "version_to_deploy" {
  description = "The version the Lambda function to deploy."
  type        = "string"
}
