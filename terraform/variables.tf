variable "my_name" {
  description = "The name of the student"
  type        = "string"
}

variable "service_name" {
  description = "The name of the student"
  type        = "string"
  default     = "production-ready-serverless"
}

variable "stage" {
  description = "The name of the stage, e.g. dev, staging, prod"
  type        = "string"
  default     = "dev"
}

variable "file_name" {
  description = "The name of the deployment package"
  type        = "string"
}

variable "log_level" {
  description = "The level functions should log at"
  type        = "string"
  default     = "INFO"
}