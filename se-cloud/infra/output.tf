# Output the external IP of the frontend load balancer.
output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster"
}