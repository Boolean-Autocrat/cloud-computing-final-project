
# HealthMonitor Design Document

## 1. System Overview

HealthMonitor is a multi-cloud microservices application designed to monitor patient vitals in real-time. It provides a dashboard for doctors to view patient alerts, ingests high-throughput vitals data, manages user metadata, processes alerts, parses lab reports, and performs real-time analytics on the vitals data.

## 2. Architecture Diagram Description

The architecture is designed to be a multi-cloud, microservices-based system.

*   **Provider A (AWS):** Hosts the majority of the services, including the web frontend, data ingestion, user management, alert processing, and report parsing. It also hosts the primary data stores (RDS and DynamoDB) and the object store (S3).
*   **Provider B (GCP):** Hosts the analytics engine, which is an Apache Flink cluster running on Google Dataproc.
*   **Confluent Cloud:** Acts as the message broker, bridging the services running on AWS and GCP.

## 3. Rationale for using Flink on GCP and DynamoDB

*   **Flink on GCP:** Apache Flink is a powerful stream processing framework that is well-suited for real-time analytics. Running Flink on a managed service like Google Dataproc simplifies the deployment and management of the Flink cluster. GCP's expertise in data analytics makes it a good choice for this component.
*   **DynamoDB:** DynamoDB is a fully managed NoSQL database that provides fast and predictable performance with seamless scalability. It is a good choice for the alert service, which needs to store a high volume of alert data with low latency.

## 4. Table of Microservices Responsibilities

| Service                 | Type              | Responsibilities                                                                                             |
| ----------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------ |
| `frontend-web`          | Web Service       | Provides a dashboard for doctors to view patient alerts.                                                     |
| `ingestion-service`     | Backend           | Receives high-throughput JSON vitals and pushes them to the `raw-vitals` Kafka topic.                           |
| `user-service`          | Backend           | Manages patient metadata, storing it in an RDS (PostgreSQL) database.                                        |
| `alert-service`         | Backend           | Consumes from the `raw-vitals` Kafka topic, checks for threshold breaches, and stores alerts in DynamoDB.       |
| `report-parser`         | Serverless (Lambda) | Parses uploaded PDF lab reports from S3 and logs the text.                                                    |
| `analytics-engine`      | Apache Flink      | Consumes from the `raw-vitals` Kafka topic, performs a 1-minute tumbling window aggregation, and publishes to the `aggregated-stats` Kafka topic. |
