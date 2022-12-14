data "aws_iam_policy_document" "kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  # TODO: this statement should only exist if the user
  # provided an AWS Config role ARN
  #
  # statement {
  #     effect = "Allow"
  #     actions = [
  #         "kms:Decrypt",
  #         "kms:DescribeKey"
  #     ]
  #     principals {
  #         type = "AWS"
  #         identifiers = var.config_role
  #     }
  #     resources = ["*"]
  # }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.role.arn]
    }
  }
}

resource "aws_kms_key" "kms" {
  description             = "Key used for ${local.app_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json

  depends_on = [aws_iam_role.role]
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${local.app_name}"
  target_key_id = aws_kms_key.kms.key_id
}