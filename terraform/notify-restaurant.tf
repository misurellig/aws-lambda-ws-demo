resource "aws_lambda_function" "notify_restaurant" {
  function_name = "${local.function_prefix}-notify-restaurant"

  s3_bucket = "${local.deployment_bucket}"
  s3_key    = "${local.deployment_key}"

  handler = "functions/notify-restaurant.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.notify_restaurant_lambda_role.arn}"

  environment {
    variables = {
      order_events_stream = "${aws_kinesis_stream.orders_stream.name}"
      restaurant_notification_topic = "${aws_sns_topic.restaurant_notification.arn}"
      LOG_LEVEL = "${var.log_level}"
      SAMPLE_DEBUG_LOG_RATE = "0.50"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_iam_role" "notify_restaurant_lambda_role" {
  name = "${local.function_prefix}-notify-restaurant-role"

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

resource "aws_iam_role_policy_attachment" "notify_restaurant_lambda_role_policy" {
  role       = "${aws_iam_role.notify_restaurant_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "notify_restaurant_lambda_policy" {
  name = "notify_restaurant"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:PutRecord",
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListStreams"
      ],
      "Resource": "${aws_kinesis_stream.orders_stream.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.restaurant_notification.arn}"
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

resource "aws_iam_role_policy_attachment" "notify_restaurant_lambda_policy" {
  role       = "${aws_iam_role.notify_restaurant_lambda_role.name}"
  policy_arn = "${aws_iam_policy.notify_restaurant_lambda_policy.arn}"
}

resource "aws_lambda_event_source_mapping" "notify_restaurant_lambda_kinesis" {
  event_source_arn  = "${aws_kinesis_stream.orders_stream.arn}"
  function_name     = "${aws_lambda_function.notify_restaurant.arn}"
  starting_position = "LATEST"
  batch_size        = 10
}