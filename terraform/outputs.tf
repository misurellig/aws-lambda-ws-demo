data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}"
}