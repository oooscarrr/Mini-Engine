output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster"
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "zookeeper_release_name" {
  value = helm_release.zookeeper.name
}

output "kafka_release_name" {
  value = helm_release.kafka.name
}

# output "kafka_external_ip" {
#   description = "External IP address of the Kafka LoadBalancer service"
#   value       = data.kubernetes_service.kafka.status[0].load_balancer[0].ingress[0].ip
# }
