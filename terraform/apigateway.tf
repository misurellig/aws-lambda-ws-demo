resource "aws_api_gateway_rest_api" "api" {
  name        = "production-ready-serverless-${var.my_name}"
}

resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    "aws_api_gateway_integration.get_index_lambda",
    "aws_api_gateway_integration.get_restaurants_lambda",
    "aws_api_gateway_integration.search_restaurants_lambda",
    "aws_api_gateway_integration.place_order_lambda"
  ]

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = ""

  variables {
    deployed_at = "${timestamp()}"
  }
}

resource "aws_api_gateway_stage" "stage" {
  stage_name           = "${var.stage}"
  rest_api_id          = "${aws_api_gateway_rest_api.api.id}"
  deployment_id        = "${aws_api_gateway_deployment.api.id}"
  xray_tracing_enabled = true
}

# GET-INDEX
resource "aws_api_gateway_method" "get_index_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_index_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.get_index_get.resource_id}"
  http_method = "${aws_api_gateway_method.get_index_get.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.get_index.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_get_index" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_index.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_stage.stage.execution_arn}/*/*"
}

# GET-RESTAURANTS
resource "aws_api_gateway_resource" "get_restaurants" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "restaurants"
}

resource "aws_api_gateway_method" "get_restaurants_get" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.get_restaurants.id}"
  http_method   = "GET"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "get_restaurants_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.get_restaurants_get.resource_id}"
  http_method = "${aws_api_gateway_method.get_restaurants_get.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.get_restaurants.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_get_restaurants" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_restaurants.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_stage.stage.execution_arn}/*/*"
}

# SEARCH-RESTAURANTS
resource "aws_api_gateway_resource" "search_restaurants" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.get_restaurants.id}"
  path_part   = "search"
}

resource "aws_api_gateway_method" "search_restaurants_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.search_restaurants.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "search_restaurants_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.search_restaurants_post.resource_id}"
  http_method = "${aws_api_gateway_method.search_restaurants_post.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.search_restaurants.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_search_restaurants" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.search_restaurants.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_stage.stage.execution_arn}/*/*"
}

# PLACE-ORDER
resource "aws_api_gateway_resource" "place_order" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "orders"
}

resource "aws_api_gateway_method" "place_order_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.place_order.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "place_order_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.place_order_post.resource_id}"
  http_method = "${aws_api_gateway_method.place_order_post.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.place_order.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_place_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.place_order.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_stage.stage.execution_arn}/*/*"
}