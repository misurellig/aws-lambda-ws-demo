resource "aws_sns_topic" "restaurant_notification" {
  name = "restaurant-notificaton-${var.stage}-${var.my_name}"
}