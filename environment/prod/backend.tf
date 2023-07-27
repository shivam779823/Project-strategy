#https://www.terraform.io/language/settings/backends/gcs


terraform {
   backend "gcs" {
   bucket = "statefile-001-prod"
   prefix = "terraform/state"
  }
}
