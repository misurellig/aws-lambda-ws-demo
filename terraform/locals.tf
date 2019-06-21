locals {
  function_prefix = "${var.service_name}-${var.stage}-${var.my_name}"
  deployment_bucket = "ynap-production-ready-serverless-${var.my_name}"
  deployment_key = "workshop/${var.file_name}.zip"
}
