

# Makes endpoint {{URL}}/proxyService  :: GET
resource "aws_api_gateway_resource" "proxy_service_root_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
  path_part   = "proxyService"
}

resource "aws_api_gateway_method" "proxy_service_root_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_service_root_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_service_root_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id          = "${aws_api_gateway_resource.proxy_service_root_resource.id}"
  http_method          = "${aws_api_gateway_method.proxy_service_root_method.http_method}"
  type                 = "HTTP"
  integration_http_method = "GET"
  uri                  = "http://$${stageVariables.proxyServiceURL}/"
  request_parameters = {}
}



# Makes endpoint {{URL}}/proxyService/{id}  :: GET
resource "aws_api_gateway_resource" "proxy_service_id_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  parent_id   = "${aws_api_gateway_resource.proxy_service_root_resource.id}"
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "proxy_service_id_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_service_id_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
      "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "proxy_service_id_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id          = "${aws_api_gateway_resource.proxy_service_id_resource.id}"
  http_method          = "${aws_api_gateway_method.proxy_service_id_method.http_method}"
  type                 = "HTTP"
  integration_http_method = "GET"
  uri                  = "http://$${stageVariables.proxyServiceURL}/{id}"
  request_parameters = {
      "integration.request.path.id" = "method.request.path.id"
  }
}