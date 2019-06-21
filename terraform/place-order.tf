resource "aws_lambda_function" "place_order" {
  function_name = "${local.function_prefix}-place-order"

  s3_bucket = "${local.deployment_bucket}"
  s3_key    = "${local.deployment_key}"

  handler = "functions/place-order.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.place_order_lambda_role.arn}"

  environment {
    variables = {
      order_events_stream = "${aws_kinesis_stream.orders_stream.name}"
      LOG_LEVEL = "${var.log_level}"
      SAMPLE_DEBUG_LOG_RATE = "0.50"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# IAM role which dictates what other AWS services the hello function can access
resource "aws_iam_role" "place_order_lambda_role" {
  name = "${local.function_prefix}-place-order-role"

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

resource "aws_iam_role_policy_attachment" "place_order_lambda_role_policy" {
  role       = "${aws_iam_role.place_order_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "place_order_lambda_kinesis_policy" {
  name = "place_order_kinesis"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "kinesis:PutRecord",
      "Resource": "${aws_kinesis_stream.orders_stream.arn}"
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

resource "aws_iam_role_policy_attachment" "place_order_lambda_kinesis_policy" {
  role       = "${aws_iam_role.place_order_lambda_role.name}"
  policy_arn = "${aws_iam_policy.place_order_lambda_kinesis_policy.arn}"
}