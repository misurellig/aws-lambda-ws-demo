resource "aws_lambda_function" "get_index" {
  function_name = "${local.function_prefix}-get-index"

  s3_bucket = "${local.deployment_bucket}"
  s3_key    = "${local.deployment_key}"

  handler = "functions/get-index.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.get_index_lambda_role.arn}"
  timeout = 6

  environment {
    variables = {
      restaurants_api = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${var.stage}/restaurants"
      orders_api = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${var.stage}/orders"
      LOG_LEVEL = "${var.log_level}"
      SAMPLE_DEBUG_LOG_RATE = "0.50"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# IAM role which dictates what other AWS services the hello function can access
resource "aws_iam_role" "get_index_lambda_role" {
  name = "${local.function_prefix}-get-index-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_index_lambda_role_policy" {
  role       = "${aws_iam_role.get_index_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "get_index_lambda_apigateway_policy" {
  name = "apigateway_execute"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:*/*/GET/restaurants"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_index_lambda_apigateway_policy" {
  role       = "${aws_iam_role.get_index_lambda_role.name}"
  policy_arn = "${aws_iam_policy.get_index_lambda_apigateway_policy.arn}"
}