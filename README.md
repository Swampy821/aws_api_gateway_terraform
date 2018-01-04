# Building Basic API Gateway using terraform on AWS

### See Example folder for working code. 

[Docs are always useful](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-create-api.html)


#### Set AWS Provider
```terraform
provider "aws" {
  region = "${var.aws_region}"
}
```


#### Create root API

```terraform
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "My API" 
  description = "API Gateway"
}
```

```
name - (Required) The name of the REST API

description - (Optional) The description of the REST API

binary_media_types - (Optional) The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads.

body - (Optional) An OpenAPI specification that defines the set of routes and integrations to create as part of the REST API.
```

#### Create Resource for Endpoint
A resource defines the endpoint such as /proxyService. Each endpoint will need a resource. A resource can have multiple methods such as `POST`, `GET` and `PUT`, these are defined elsewhere. 

```terraform
# example 1
resource "aws_api_gateway_resource" "proxy_service_root_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}" # This is the id of your api_gateway
  parent_id   = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}" # This gets the id of "/"
  path_part   = "proxyService" # This is {{url}}/proxyService
}
```

A resource can also be a URL parameter. Such as below which will make `{{url}}/proxyService/{id}`

```terraform
# example 2
resource "aws_api_gateway_resource" "proxy_service_id_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  parent_id   = "${aws_api_gateway_resource.proxy_service_root_resource.id}" # This links to the resource in example 1 to make the url.
  path_part   = "{id}" # This can be any variable you would like, it just needs to be surrounded by brackets.
}
```


#### Create Method for Endpoint
Method only defines the http type you will be hitting and the parameters you are passing through. You will define what the method actually done in the integration. 

```terraform
# example 3
resource "aws_api_gateway_method" "proxy_service_id_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_service_id_resource.id}" # This links to the id in example 2.
  http_method   = "GET" # (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)
  authorization = "NONE"
  request_parameters = {
      "method.request.path.id" = true # Since this was linked to example 2 we must define the variable that we used. 
  }
}
```


#### Create integration for Endpoint
The integration defines what is actually going to happen when that endpoint is hit. In this example I am only going over proxying to another endpoint, there are a number of things you can do. This is really the bread butter of what is going on. 

I like to maintain standard of names just with `_integration`, `_method` and `_resource` on the end so it's clear which go to what endpoint. Obviously this is entirely up to you.

```terraform
resource "aws_api_gateway_integration" "proxy_service_id_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id          = "${aws_api_gateway_resource.proxy_service_id_resource.id}" # This is the resource id in example 2
  http_method          = "${aws_api_gateway_method.proxy_service_id_method.http_method}" # This is the method in example 3
  type                 = "HTTP"
  integration_http_method = "GET" # This is how it will hit your proxied endpoint`
  uri                  = "http://$${stageVariables.proxyServiceURL}/{id}" # URL of your endpoint. Stage variables are like environmental variables you can set upon deploy
  request_parameters = {
      "integration.request.path.id" = "method.request.path.id" # This links your url param to your integration. Without it {id} will fail.
  }
}
```




#### Deploy the gateway
Deploying the api does just that, deploys it to a stage. This creates a deployment resource with a "stage". In my opinion the stage can represent a few different things. It can be used to version your API, it can be used as staging/develop/prod environments, or whatever you would like to use it for.

I would recommend breaking this out into a different tf call since it will "deploy" your gateway.

```terraform 

resource "aws_api_gateway_deployment" "stage_deploy" {
  depends_on = ["aws_api_gateway_integration.proxy_service_root_integration"] # I would recommend setting this to multiple integrations to make sure everything is done setting up before trying to deploy. 

  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  stage_name  = "v1" # This is part of the url in the long run. It will show as this "{aws-uri}/v1/proxyService/{id}
  variables = {
      proxyServiceURL = "${var.exampleProxyServiceURL}" # This is where you set up your "environmental" variables.
  }
}

```



This will be a running doc and hopefully will change as I learn more. Any suggestions, issues or PRs are very welcomed! 





## Running the example

You must have these environment variables set before running along with having terraform installed

```
AWS_ACCESS_KEY_ID=key
AWS_SECRET_ACCESS_KEY=secret
AWS_DEFAULT_REGION=region
```

Navigate to the example folder and run 
```
cd ./example
terraform init
```

Once terraform is initialized. Check out the plan, this will show you what is going to happen. 
```
terraform plan
```

If all looks go ahead and apply 
```
terraform apply
```

