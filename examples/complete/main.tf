provider "aws" {
  region = "eu-west-1"
}

module "newrelic_integration" {
  source = "../.."

  newrelic_iam_role_license_key = "123"
  newrelic_iam_enable_budget_monitoring = true 
}