variable environment {}
variable operator {}

variable project_id {}

variable state_bucket {}
variable stack {
    type = string
    description = "directory name of the module under environments/<envs>/ - e.g. 'network'"
}
variable project_roles {
    type = list(string)
    default = []
}