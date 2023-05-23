variable "aws_account_id" {
  description = "The ID of the AWS account"
}

variable "aws_region" {
  description = "The default AWS region to deploy resources to"
  default     = "eu-central-1"
}

variable "enable_debugging" {
  description = "Whether to enable debugging settings or not"
  default     = false
  type        = bool
}

variable "environment" {
  description = "Prefix to distinguish multiple environments"
}

variable "namespace" {
  description = "Namespace for AWS resources"
  default     = "bitly"
}

variable "project_name" {
  description = "Name of this project"
  default     = "ndogi"
}

variable "project_path" {
  description = "Full, unique path to this project"
  default     = "bitly/ndogi"
}
