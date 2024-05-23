data "template_file" "foreign_account_root_template" {
  count = length(var.foreign_accounts)
  template = "\"arn:aws:iam::$${ForeignAccount}:root\""

  vars = {
    ForeignAccount                 = element(var.foreign_accounts, count.index)
  }
}
