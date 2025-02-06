resource "aws_sns_topic" "tracking_updates" {
  name = "tracking-updates-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.tracking_updates.arn
  protocol  = "email"
  endpoint  = "automationinforsk@gmail.com" 
}
