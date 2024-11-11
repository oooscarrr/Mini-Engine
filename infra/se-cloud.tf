# resource "null_resource" "build_push_se_cloud" {
#   depends_on = [ google_container_node_pool.se_cloud_node_pool ]

#   # Authenticate Docker
#   provisioner "local-exec" {
#     command = "gcloud auth configure-docker"
#   }

#   # Create a buildx builder
#   provisioner "local-exec" {
#     command = <<EOT
#       docker buildx create --name mybuilder --use || docker buildx use mybuilder
#       docker buildx inspect mybuilder --bootstrap
#     EOT
#   }

#   # Build and push to Docker Hub and GCR
#   provisioner "local-exec" {
#     command = <<EOT
#       docker buildx build --no-cache --platform linux/amd64,linux/arm64 -t gcr.io/${var.project_id}/${var.dockerhub_username}/se-cloud:latest --push ../se-cloud
#     EOT
#   }
# }

# resource "null_resource" "apply_se_cloud_k8s" {
#   provisioner "local-exec" {
#     command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${google_container_cluster.primary.location}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/se-server-deployment.yaml"
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/service-se-cloud-lb.yaml"
#   }

#   provisioner "local-exec" {
#     command = "kubectl rollout restart deployment se-cloud"
#   }
  
#   depends_on = [null_resource.build_push_se_cloud]
# }
