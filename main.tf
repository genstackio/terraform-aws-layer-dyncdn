resource "aws_cloudfront_function" "function" {
  for_each = {for k, v in local.functions: k => v if null != v.code}
  name    = "${var.name}-${each.key}"
  runtime = lookup(each.value, "runtime", "cloudfront-js-1.0")
  comment = "${each.key} function"
  key_value_store_associations = lookup(each.value, "kv_stores", null)
  publish = true
  code    = lookup(each.value, "code", null)
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name         = var.fake_origin
    origin_id           = "origin"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    dynamic custom_header {
      for_each = var.edge_lambdas_variables
      content {
        name  = "x-lambda-var-${replace(lower(custom_header.key), "_", "-")}"
        value = custom_header.value
      }
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name} Distribution"

  aliases = [var.dns]

  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = "origin"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = var.compress

    cache_policy_id            = var.cache_policy
    origin_request_policy_id   = var.origin_request_policy
    response_headers_policy_id = var.response_headers_policy

    forwarded_values {
      query_string = true
      headers      = concat(["Origin"], var.forwarded_headers)
      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 86400

    dynamic "function_association" {
      for_each = local.functions
      content {
        event_type   = lookup(function_association.value, "event_type", "viewer-request")
        function_arn = null != function_association.value.arn ? function_association.value.arn : aws_cloudfront_function.function[function_association.key].arn
      }
    }

    dynamic "lambda_function_association" {
      for_each = local.edge_lambdas
      content {
        event_type   = lookup(lambda_function_association.value, "event_type", null)
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn", null)
        include_body = lookup(lambda_function_association.value, "include_body", null)
      }
    }

  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = length(var.geolocations) == 0 ? "none" : "whitelist"
      locations        = length(var.geolocations) == 0 ? null : var.geolocations
    }
  }

  tags = {
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  web_acl_id = var.web_acl
}

resource "aws_route53_record" "cdn" {
  zone_id = var.dns_zone
  name    = var.dns
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.dns
  validation_method = "DNS"
  provider          = aws.acm

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_type
  zone_id = var.dns_zone
  records = [element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_value]
  ttl     = 60
}
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
