variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "acl" {
  type        = string
  description = "ACL for the S3 bucket"
  default     = "private"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to resources"
  default     = {}
}
