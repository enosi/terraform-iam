data "aws_caller_identity" "current" {
}
# ------------------------------------------------------------------------
# DevOps Groups
# ------------------------------------------------------------------------

resource "aws_iam_group" "devops_prod" {
  name = "DevopsProduction"
}

resource "aws_iam_group_policy" "devops_prod" {
  name   = "DevopsProduction"
  group  = aws_iam_group.devops_prod.name
  policy = data.aws_iam_policy_document.devops_prod.json
}

data "aws_iam_policy_document" "devops_prod" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.devops_role_name}",
      var.production_account_ids,
    )
  }
}

resource "aws_iam_group" "devops" {
  name = "Devops"
}

resource "aws_iam_group_policy" "devops" {
  name   = "Devops"
  group  = aws_iam_group.devops.name
  policy = data.aws_iam_policy_document.devops.json
}

data "aws_iam_policy_document" "devops" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.devops_role_name}",
      var.non_production_account_ids,
    )
  }
}

# ------------------------------------------------------------------------
# Superuser Group
# ------------------------------------------------------------------------

resource "aws_iam_group" "superuser_prod" {
  name = "SuperuserProduction"
}

resource "aws_iam_group_policy" "superuser_prod" {
  name   = "SuperuserProduction"
  group  = aws_iam_group.superuser_prod.name
  policy = data.aws_iam_policy_document.superuser_prod.json
}

data "aws_iam_policy_document" "superuser_prod" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.superuser_role_name}",
      var.production_account_ids,
    )
  }
}

resource "aws_iam_group" "superuser" {
  name = "Superuser"
}

resource "aws_iam_group_policy" "superuser" {
  name   = "Superuser"
  group  = aws_iam_group.superuser.name
  policy = data.aws_iam_policy_document.superuser.json
}

data "aws_iam_policy_document" "superuser" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.superuser_role_name}",
      var.non_production_account_ids,
    )
  }
}

# ------------------------------------------------------------------------
# Support group
# ------------------------------------------------------------------------

resource "aws_iam_group" "support_prod" {
  name = "SupportProduction"
}

resource "aws_iam_group_policy" "support_prod" {
  name   = "SupportProduction"
  group  = aws_iam_group.support_prod.name
  policy = data.aws_iam_policy_document.support_prod.json
}

data "aws_iam_policy_document" "support_prod" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.support_role_name}",
      var.production_account_ids,
    )
  }
}

resource "aws_iam_group" "support" {
  name = "Support"
}

resource "aws_iam_group_policy" "support" {
  name   = "Support"
  group  = aws_iam_group.support.name
  policy = data.aws_iam_policy_document.support.json
}

data "aws_iam_policy_document" "support" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.support_role_name}",
      var.non_production_account_ids,
    )
  }
}

# ------------------------------------------------------------------------
# ReadOnly group
# ------------------------------------------------------------------------

resource "aws_iam_group" "readonly_prod" {
  name = "ReadOnlyProduction"
}

resource "aws_iam_group_policy" "readonly_prod" {
  name   = "ReadOnlyProduction"
  group  = aws_iam_group.readonly_prod.name
  policy = data.aws_iam_policy_document.readonly_prod.json
}

data "aws_iam_policy_document" "readonly_prod" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.readonly_role_name}",
      var.production_account_ids,
    )
  }
}

resource "aws_iam_group" "readonly" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy" "readonly" {
  name   = "ReadOnly"
  group  = aws_iam_group.readonly.name
  policy = data.aws_iam_policy_document.readonly.json
}

data "aws_iam_policy_document" "readonly" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = formatlist(
      "arn:aws:iam::%s:role/${var.readonly_role_name}",
      var.non_production_account_ids,
    )
  }
}

# ------------------------------------------------------------------------
# UserSelfManagement group
# ------------------------------------------------------------------------

resource "aws_iam_group" "self_management" {
  name = "UserSelfManagement"
}

resource "aws_iam_group_policy" "self_management" {
  name   = "UserSelfManagement"
  group  = aws_iam_group.self_management.name
  policy = data.aws_iam_policy_document.self_management.json
}

data "aws_iam_policy_document" "self_management" {
  statement {
    sid = "AllowUsersToDeactivateTheirOwnVirtualMFADevice"

    actions = [
      "iam:DeactivateMFADevice",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid = "AllowUsersToDeleteTheirOwnVirtualMFADevice"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid = "AllowUsersToListMFADevicesandUsersForConsole"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = ["iam:ChangePassword"]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"]
  }

  statement {
    actions   = ["iam:GetAccountPasswordPolicy"]
    resources = ["*"]
  }

  statement {
    actions = ["iam:GetLoginProfile"]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:UpdateAccessKey",
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:ListAccessKeys",
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}
