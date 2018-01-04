provider "aws" {
  region = "${var.aws_region}"
}


resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "My API"
  description = "API Gateway"
}


