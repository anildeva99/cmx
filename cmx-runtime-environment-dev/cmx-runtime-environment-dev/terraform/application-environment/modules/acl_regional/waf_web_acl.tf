resource "aws_wafregional_web_acl" "wafregional_acl" {
  name        = "${var.environment}-${var.waf_prefix}-generic-acl"
  metric_name = "${var.environment}${var.waf_prefix}genericacl"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application Regional WAF ACL - wafregional_acl"
      Type = "wafregional_acl"
    }
  )

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.cmx_rgnl_geo_location_limit_rule.id
    type     = "REGULAR"
  }


  rule {
    action {
      # !!! This rule keeps biting us, because Mirth needs to send in very large messages sometimes
      # !!! Need to see if we can exclude certain API endpoints or something to make this better.
      #type = "BLOCK"
      type = "COUNT"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.restrict_sizes.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 3
    rule_id  = aws_wafregional_rule.detect_blacklisted_ips.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 4
    rule_id  = aws_wafregional_rule.mitigate_sqli.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 5
    rule_id  = aws_wafregional_rule.mitigate_xss.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 6
    rule_id  = aws_wafregional_rule.detect_rfi_lfi_traversal.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 7
    rule_id  = aws_wafregional_rule.detect_php_insecure.id
    type     = "REGULAR"
  }

  # !!! This rule keeps biting us, it seems to want to block our API traffic. Need to figure out why.
  # !!! Disabling CSRF rule for now since it keeps blocking legit traffic, need to understand it better
  # rule {
  #   action {
  #     type = "COUNT"
  #   }
  #
  #   priority = 8
  #   rule_id  = aws_wafregional_rule.enforce_csrf.id
  #   type     = "REGULAR"
  # }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 9
    rule_id  = aws_wafregional_rule.detect_ssi.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = aws_wafregional_rule.detect_admin_access.id
    type     = "REGULAR"
  }
}
