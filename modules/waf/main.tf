resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name}-waf"
  description = "WAF Web ACL protecting the ALB for ${var.name}"
  scope       = "REGIONAL" # Must be REGIONAL for ALBs ('CLOUDFRONT' is only for CloudFront)

  default_action {
    allow {} # Default action allows traffic unless blocked by a specific rule
  }

  # Rate limiting: block IPs sending more than 1000 requests in any 5-minute window
  rule {
    name     = "RateLimitRule"
    priority = 0 # Evaluated first — cheapest check, drops flood traffic before managed rules run
    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-RateLimit"
      sampled_requests_enabled   = true
    }
  }

  # Common Rule Set: blocks XSS, HTTP anomalies, scanner probes
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Known Bad Inputs: blocks log4j, Spring4Shell, and other known exploit patterns
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {} # Use the rule group's default actions (Block/Count)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection: critical since the app connects to MySQL RDS
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-LinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-IPReputation"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}


resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# WAF logging — sends all request logs to S3
# Bucket name MUST start with "aws-waf-logs-" (AWS requirement)
# resource "aws_wafv2_web_acl_logging_configuration" "this" {
#   log_destination_configs = [var.waf_log_bucket_arn]
#   resource_arn            = aws_wafv2_web_acl.this.arn

#   # Redact sensitive headers from logs
#   redacted_fields {
#     single_header {
#       name = "authorization"
#     }
#   }

#   redacted_fields {
#     single_header {
#       name = "cookie"
#     }
#   }
# }
