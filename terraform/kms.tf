resource "aws_kms_key" "main" {
    description             = "EKS KMS key"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
}

resource "aws_kms_alias" "main" {
    name          = "alias/kms_demo"
    target_key_id = aws_kms_key.main.key_id
}