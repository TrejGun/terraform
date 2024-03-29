resource "aws_iam_role" "autoscale_role" {
  name = "fargate-autoscale-role"
  assume_role_policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "application-autoscaling.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
EOF
}


resource "aws_iam_policy" "autoscale_policy" {
  name        = "fargate-autoscale-policy"
  path        = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "autoscale-attach" {
  depends_on = ["aws_iam_role.autoscale_role"]
  role       = "${aws_iam_role.autoscale_role.name}"
  policy_arn = "${aws_iam_policy.autoscale_policy.arn}"
}

resource "aws_iam_role" "task_execution_role" {
  name = "fargate-task-execution-role"
  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "task_execution_policy" {
  name        = "fargate-task-execution-policy"
  path        = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "kms:Decrypt",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:ssm:eu-west-1:852196116519:parameter/parameter_name",
                "arn:aws:secretsmanager:eu-west-1:852196116519:secret:secret_name",
                "arn:aws:kms:eu-west-1:852196116519:key:key_id"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task-execution-attach" {
  depends_on = ["aws_iam_role.task_execution_role"]
  role       = "${aws_iam_role.task_execution_role.name}"
  policy_arn = "${aws_iam_policy.task_execution_policy.arn}"
}
