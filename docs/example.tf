provider "aws" {
  region     = "eu-west-1"
}

data "aws_acm_certificate" "example-cert" {
  domain   = "holymotors.info"
  statuses = ["ISSUED"]
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "example" {
  bucket        = "holymotors-example-bucket"
  acl           = "private"
  force_destroy = true

  policy        = <<POLICY
{
  "Id": "S3ExamplePolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::holymotors-example-bucket/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

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

resource "aws_instance" "example" {
  ami           = "ami-08d658f84a6d84a80"
  instance_type = "t2.micro"
  key_name      = "example"
  count         = 2
  depends_on    = [aws_s3_bucket.example, aws_sqs_queue.example]
}

# Create a new load balancer
resource "aws_elb" "example" {
  name               = "example-elb"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  access_logs {
    bucket        = "${aws_s3_bucket.example.bucket}"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port       = 8000
    instance_protocol   = "http"
    lb_port             = 443
    lb_protocol         = "https"
    ssl_certificate_id  = "${data.aws_acm_certificate.example-cert.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = "${aws_instance.example.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}
