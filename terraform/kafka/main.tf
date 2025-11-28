
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.41.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_kafka_cluster" "main" {
  display_name = "health-monitor-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-1"
  basic {}
  environment {
    id = var.confluent_environment_id
  }
}

resource "confluent_kafka_topic" "raw_vitals" {
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  topic_name    = "raw-vitals"
  partitions    = 6
  http_endpoint = confluent_kafka_cluster.main.http_endpoint
  credentials {
    key    = var.confluent_cloud_api_key
    secret = var.confluent_cloud_api_secret
  }
}

resource "confluent_kafka_topic" "aggregated_stats" {
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  topic_name    = "aggregated-stats"
  partitions    = 6
  http_endpoint = confluent_kafka_cluster.main.http_endpoint
  credentials {
    key    = var.confluent_cloud_api_key
    secret = var.confluent_cloud_api_secret
  }
}
