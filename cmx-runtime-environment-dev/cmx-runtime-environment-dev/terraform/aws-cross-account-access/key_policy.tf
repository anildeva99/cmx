#Grants access to encryption keys

#Find keys used to encrypt
data "aws_kms_alias" "kms_key_aliases" {
  count = length(var.kms_keys)
  name  = lookup(element(var.kms_keys, count.index), "key_alias")
}

#Create Sharing Keys Policy with Reference to Role
resource "aws_kms_grant" "share_keys_foreign" {
  count = length(var.foreign_accounts) * length(data.aws_kms_alias.kms_key_aliases)

  grantee_principal = "arn:aws:iam::${var.foreign_accounts[floor(count.index / length(data.aws_kms_alias.kms_key_aliases))]}:root"
  key_id = data.aws_kms_alias.kms_key_aliases[count.index % length(data.aws_kms_alias.kms_key_aliases)].target_key_id

  name = "grant_access_s3_encryption_key_foreign_accounts"
  operations = var.kms_keys[count.index % length(data.aws_kms_alias.kms_key_aliases)].key_operations
}
