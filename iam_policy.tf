locals {
  # Supposons que le nom du bucket est construit dynamiquement
  mon_bucket_specifique_nom = "data-${var.project_name}-${terraform.workspace}"
  s3_bucket_arn_prefix      = "arn:aws:s3:::${local.mon_bucket_specifique_nom}"
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "PolitiqueAccesS3-${var.project_name}-${terraform.workspace}"
  description = "Politique autorisant l'accès au bucket ${local.mon_bucket_specifique_nom}"

  # Utilisation de jsonencode pour construire le document de politique
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${local.s3_bucket_arn_prefix}/*",         # Pour les objets dans le bucket
          trimsuffix(local.s3_bucket_arn_prefix, "") # Pour lister le bucket lui-même (l'ARN du bucket sans /*)
        ]
      },
      {
        Effect = "Allow",
        Action = "s3:PutObject",
        Resource = [
          "${local.s3_bucket_arn_prefix}/*"
        ],
        Condition = { # Exemple de condition
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
