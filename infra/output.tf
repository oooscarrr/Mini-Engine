output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster"
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "kafka_external_ip" {
  description = "External IP address of the Kafka LoadBalancer service"
  value       = data.external.kafka_external_ip.result["ip"]
}
