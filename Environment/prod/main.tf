module "ProdServerlessAPI" {
  source = "../../modules/lambda_api"
  environment = "prod"
  aws_region = var.aws_region
}
output "outUri" {
  value = module.ProdServerlessAPI.api_invoke_url
}
