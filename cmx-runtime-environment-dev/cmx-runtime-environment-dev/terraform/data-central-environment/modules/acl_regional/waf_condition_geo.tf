resource "aws_wafregional_geo_match_set" "regional_geo_match_set" {
  name = "${var.environment}-${var.waf_prefix}-geo-match-set"

  geo_match_constraint {
    type  = "Country"
    value = "US"
  }

  geo_match_constraint {
    type  = "Country"
    value = "CA"
  }
}
