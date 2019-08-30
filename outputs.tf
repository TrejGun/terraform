output "alb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "qsq_queue" {
  value = "${aws_sqs_queue.example.id}"
}
