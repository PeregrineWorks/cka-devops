variable environment {}
variable operator {}

variable gcp_project {}

variable state_bucket {}
variable module {
    type = string
    description = "directory name of the module under modules/ - e.g. 'vms'"
}
variable project_roles {
    type = list(string)
    default = []
}