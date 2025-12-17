resource "aws_ssm_parameter" "acm_certificate_arn" {
  name  = "/${var.project_name}/${var.environment}/acm_certificate_arn"
  type  = "String"
  # This forces SSM to wait until the DNS validation is actually finished
  value = aws_acm_certificate_validation.expense.certificate_arn
}