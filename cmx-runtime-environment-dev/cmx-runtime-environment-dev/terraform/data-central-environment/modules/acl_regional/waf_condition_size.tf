resource "aws_wafregional_size_constraint_set" "size_restrictions" {
  name = "${var.environment}-${var.waf_prefix}-generic-size-restrictions"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.acl_constraint_body_size

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.acl_constraint_cookie_size

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.acl_constraint_query_string_size

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.acl_constraint_uri_size

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_size_constraint_set" "csrf_token_set" {
  name = "${var.environment}-${var.waf_prefix}-generic-match-csrf-token"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = "36"

    field_to_match {
      type = "HEADER"
      data = "x-csrf-token"
    }
  }
}
