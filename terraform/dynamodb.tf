resource "aws_dynamodb_table" "restaurants_table" {
  name           = "restaurants_${var.stage}_${var.my_name}"
  billing_mode   = "PAY_PER_REQUEST"  
  hash_key       = "name"

  attribute {
    name = "name"
    type = "S"
  }
}