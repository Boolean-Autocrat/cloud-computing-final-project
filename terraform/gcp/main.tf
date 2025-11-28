
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

module "dataproc" {
  source = "./dataproc"

  project_id = var.gcp_project_id
  region     = var.gcp_region
}
