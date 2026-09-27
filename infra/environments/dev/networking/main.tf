module "networking" {
  source         = "../../../modules/networking"
  environment    = var.environment
  default_region = var.default_region
}
