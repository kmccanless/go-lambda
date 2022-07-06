output "api_gw_endpoint" {
    value = module.lambda_function.api_gateway_endpoint
}
output "lambda_name" {
  value =  module.lambda_function.lambda_name
}
output "lambda_arn" {
  value = module.lambda_function.lambda_arn
}
output "table_id" {
  value = module.lambda_function.table_id
}
