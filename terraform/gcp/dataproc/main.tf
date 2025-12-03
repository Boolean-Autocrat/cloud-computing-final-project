resource "google_dataproc_cluster" "flink_cluster" {
  name    = "flink-cluster"
  region  = var.region
  project = var.project_id

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-4"
      
      disk_config {
        boot_disk_size_gb = 50
        boot_disk_type    = "pd-standard"
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"
      
      disk_config {
        boot_disk_size_gb = 50
        boot_disk_type    = "pd-standard"
      }
    }
    
    software_config {
      image_version = "2.1-debian11"
      optional_components = ["FLINK"]
    }
  }
}