resource "aws_sqs_queue" "dead" {
  name                              = "dead"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "example" {
  name                              = "example"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  policy                            = <<POLICY
{
  "Id": "SQSExamplePolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage",
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:eu-west-1:852196116519:example"
    }
  ]
}
POLICY
  redrive_policy                    = <<POLICY
{
  "deadLetterTargetArn": "${aws_sqs_queue.dead.arn}",
  "maxReceiveCount": 4
}
POLICY
}
