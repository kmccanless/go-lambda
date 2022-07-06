
locals {
  function_name = "${var.environment}-${var.function_name}"
}
data "archive_file" "lambda_zip" {
  type          = "zip"
  output_path   = var.archive_name
  source_dir    = var.build_dir
}

module "lambda_function" {
  # depends_on = [aws_s3_bucket.lambda_bucket,aws_ssm_parameter.bucket_param] 
  region = var.region
  profile = var.profile
  project = var.project
  environment = var.environment
  source = "git@github.com:kmccanless/go-lambda-infrastructure.git//modules/lambda-developer"
  function_handler = var.function_handler
  function_name = local.function_name
  s3_key = local.function_name
  archive_name = var.archive_name
  runtime = "go1.x"
  source_archive = data.archive_file.lambda_zip.output_path
  archive_sha256 = filebase64sha256(data.archive_file.lambda_zip.output_path)
  archive_md5 = filemd5(data.archive_file.lambda_zip.output_path)
  timeout = var.function_timeout
  enable_api_gw = true
  enable_dynamo = {
    name = "Test"
    hash_key = "ISBN"
    attribute = {
      name = "ISBN"
      type = "S"
    }
  }
}

# data "aws_ssm_parameter" "s3_bucket" {
#   provider = aws.legit
#   name = "go-lambda-bucket"
# }

# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket = data.aws_ssm_parameter.s3_bucket.value
# }
# resource "aws_ssm_parameter" "bucket_param" {
#   name  = "go-lambda-bucket"
#   type  = "String"
#   value = data.aws_ssm_parameter.s3_bucket.value
# }