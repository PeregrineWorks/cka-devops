module "dns" {
  source         = "../../../modules/dns"
  environment    = var.environment
  project_id     = var.project_id
  default_region = var.default_region
}
