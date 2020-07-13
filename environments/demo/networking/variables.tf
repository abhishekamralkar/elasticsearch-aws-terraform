variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "Demo"
}

variable "environment" {
  description = "Name of the Environment"
  type        = string
  default     = "Stage"
}

variable "cloud_provider" {
  description = "cloud provider"
  type        = string
  default     = "AWS"
}
