variable "environment" {}
variable "operator" {}

variable "project_id" {}

variable "state_bucket" {}
variable "stack" {
  type        = string
  description = "directory name of the stack under environments/<env>/ - e.g. 'networking'"
}
variable "project_roles" {
  type    = list(string)
  default = []
}
