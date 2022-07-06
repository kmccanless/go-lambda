variable "archive_name" {
  default = "function.zip"
}
variable "region" {
  default = "us-east-1"
}
variable "profile" {
  default = "keith"
}
variable "environment" {
  default = "production"
}
variable "function_name" {
  default = "go-lambda"
}
variable "function_handler" {
  default = "main"
}
variable "function_timeout" {
  default = 900
}
variable "project" {
  default = "go-lambda"
}
variable "build_dir" {
    default = "../../../bin"
}