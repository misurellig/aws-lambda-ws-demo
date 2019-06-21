resource "aws_kinesis_stream" "orders_stream" {
  name        = "orders_${var.stage}_${var.my_name}"
  shard_count = 1
}