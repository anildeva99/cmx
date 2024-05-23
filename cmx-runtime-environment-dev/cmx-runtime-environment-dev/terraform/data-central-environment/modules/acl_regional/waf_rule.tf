resource "aws_wafregional_rule" "detect_admin_access" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-admin-access"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectadminaccess"

  predicate {
    data_id = aws_wafregional_ipset.admin_remote_ipset.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_byte_match_set.match_admin_url.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_admin_access"
      Type = "detect_admin_access"
    }
  )
}

resource "aws_wafregional_rule" "detect_bad_auth_tokens" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-bad-auth-tokens"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectbadauthtokens"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_auth_tokens.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_bad_auth_tokens"
      Type = "detect_bad_auth_tokens"
    }
  )
}

resource "aws_wafregional_rule" "detect_blacklisted_ips" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-blacklisted-ips"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectblacklistedips"

  predicate {
    data_id = aws_wafregional_ipset.blacklisted_ips.id
    negated = false
    type    = "IPMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_blacklisted_ips"
      Type = "detect_blacklisted_ips"
    }
  )
}

resource "aws_wafregional_rule" "detect_php_insecure" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-php-insecure"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectphpinsecure"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_php_insecure_uri.id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = aws_wafregional_byte_match_set.match_php_insecure_var_refs.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_php_insecure"
      Type = "detect_php_insecure"
    }
  )
}

resource "aws_wafregional_rule" "detect_rfi_lfi_traversal" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-rfi-lfi-traversal"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectrfilfitraversal"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_rfi_lfi_traversal.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_rfi_lfi_traversal"
      Type = "detect_rfi_lfi_traversal"
    }
  )
}

resource "aws_wafregional_rule" "detect_ssi" {
  name        = "${var.environment}-${var.waf_prefix}-generic-detect-ssi"
  metric_name = "${var.environment}${var.waf_prefix}genericdetectssi"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_ssi.id
    negated = false
    type    = "ByteMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - detect_ssi"
      Type = "detect_ssi"
    }
  )
}

resource "aws_wafregional_rule" "enforce_csrf" {
  name        = "${var.environment}-${var.waf_prefix}-generic-enforce-csrf"
  metric_name = "${var.waf_prefix}genericenforcecsrf"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_csrf_method.id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = aws_wafregional_size_constraint_set.csrf_token_set.id
    negated = true
    type    = "SizeConstraint"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - enforce_csrf"
      Type = "enforce_csrf"
    }
  )
}

resource "aws_wafregional_rule" "mitigate_sqli" {
  name        = "${var.environment}-${var.waf_prefix}-generic-mitigate-sqli"
  metric_name = "${var.environment}${var.waf_prefix}genericmitigatesqli"

  predicate {
    data_id = aws_wafregional_sql_injection_match_set.sql_injection_match_set.id
    negated = false
    type    = "SqlInjectionMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - mitigate_sqli"
      Type = "mitigate_sqli"
    }
  )
}

resource "aws_wafregional_rule" "mitigate_xss" {
  name        = "${var.environment}-${var.waf_prefix}-generic-mitigate-xss"
  metric_name = "${var.environment}${var.waf_prefix}genericmitigatexss"

  predicate {
    data_id = aws_wafregional_xss_match_set.xss_match_set.id
    negated = false
    type    = "XssMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - mitigate_xss"
      Type = "mitigate_xss"
    }
  )
}

resource "aws_wafregional_rule" "restrict_sizes" {
  name        = "${var.environment}-${var.waf_prefix}-generic-restrict-sizes"
  metric_name = "${var.environment}${var.waf_prefix}genericrestrictsizes"

  predicate {
    data_id = aws_wafregional_size_constraint_set.size_restrictions.id
    negated = false
    type    = "SizeConstraint"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - restrict_sizes"
      Type = "restrict_sizes"
    }
  )
}

resource "aws_wafregional_rule" "cmx_rgnl_geo_location_limit_rule" {
  name        = "${var.environment}-${var.waf_prefix}-match-geo-and-route"
  metric_name = "${var.environment}${var.waf_prefix}MatchGeoAndRoute"

  predicate {
    data_id = aws_wafregional_geo_match_set.regional_geo_match_set.id
    negated = true
    type    = "GeoMatch"
  }

  predicate {
    data_id = aws_wafregional_ipset.local_ipset.id
    negated = true
    type    = "IPMatch"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central Regional WAF Rule - cmx_rgnl_geo_location_limit_rule"
      Type = "cmx_rgnl_geo_location_limit_rule"
    }
  )
}
