output "dns" {
  value = var.dns
}
output "cloudfront_id" {
  value = aws_cloudfront_distribution.cdn.id
}
