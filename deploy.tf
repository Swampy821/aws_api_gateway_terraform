
resource "aws_api_gateway_deployment" "stage_deploy" {
  depends_on = ["aws_api_gateway_integration.proxy_service_root_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  stage_name  = "v1"
  variables = {
      proxyServiceURL = "${var.exampleProxyServiceURL}"
  }
}

