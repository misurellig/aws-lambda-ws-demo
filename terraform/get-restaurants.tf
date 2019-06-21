resource "aws_lambda_function" "get_restaurants" {
  function_name = "${local.function_prefix}-get-restaurants"

  s3_bucket = "${local.deployment_bucket}"
  s3_key    = "${local.deployment_key}"

  handler = "functions/get-restaurants.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.get_restaurants_lambda_role.arn}"

  environment {
    variables = {
      restaurants_table = "${aws_dynamodb_table.restaurants_table.name}"
      LOG_LEVEL = "${var.log_level}"
      SAMPLE_DEBUG_LOG_RATE = "0.50"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# IAM role which dictates what other AWS services the hello function can access
resource "aws_iam_role" "get_restaurants_lambda_role" {
  name = "${local.function_prefix}-get-restaurants-role"

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

resource "aws_iam_role_policy_attachment" "get_restaurants_lambda_role_policy" {
  role       = "${aws_iam_role.get_restaurants_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "get_restaurants_lambda_dynamodb_policy" {
  name = "get_restaurants_dynamodb_scan"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dynamodb:scan",
      "Resource": "${aws_dynamodb_table.restaurants_table.arn}"
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

resource "aws_iam_role_policy_attachment" "get_restaurants_lambda_dynamodb_policy" {
  role       = "${aws_iam_role.get_restaurants_lambda_role.name}"
  policy_arn = "${aws_iam_policy.get_restaurants_lambda_dynamodb_policy.arn}"
}