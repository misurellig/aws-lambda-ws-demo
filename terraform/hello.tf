resource "aws_lambda_function" "hello" {
  function_name = "hello-ynap-${var.my_name}"

  s3_bucket = "ynap-production-ready-serverless-${var.my_name}"
  s3_key    = "workshop.zip"

  # "main" is the file within the zip file above (functions/hello.js) 
  # "handler" is the name of the exported property in functions/hello.js
  handler = "functions/hello.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.hello_lambda_role.arn}"
}

# IAM role which dictates what other AWS services the hello function can access
resource "aws_iam_role" "hello_lambda_role" {
  name = "hello-lambda-role-${var.my_name}"

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

resource "aws_iam_role_policy_attachment" "hello_lambda_role_policy" {
  role       = "${aws_iam_role.hello_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}