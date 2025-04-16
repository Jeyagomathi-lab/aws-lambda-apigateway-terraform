module "devServerlessAPI" {
  source = "../../modules/lambda_api"
  environment = "dev"
  aws_region = var.aws_region
}
output "outUri" {
  value = module.devServerlessAPI.api_invoke_url
}
