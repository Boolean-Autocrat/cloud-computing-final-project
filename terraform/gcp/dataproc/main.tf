
resource "google_dataproc_cluster" "flink_cluster" {
  name   = "flink-cluster"
  region = var.region
  project = var.project_id

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-4"
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"
    }
    
    software_config {
      optional_components = ["FLINK"]
    }
  }
}
