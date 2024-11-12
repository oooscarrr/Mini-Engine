# resource "kubernetes_namespace" "se_cloud" {
#   metadata {
#     name = "se-cloud"
#   }

#   depends_on = [ google_container_node_pool.se_cloud_node_pool ]
# }

# resource "kubernetes_deployment" "se_cloud" {
#   metadata {
#     name      = "se-cloud"
#     namespace = kubernetes_namespace.se_cloud.metadata[0].name
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         app = "se-cloud"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "se-cloud"
#         }
#       }

#       spec {
#         container {
#           name  = "se-cloud"
#           image = "gcr.io/${var.project_id}/se-cloud:latest"

#           env {
#             name  = "KAFKA_BROKER"
#             value = "confluent-kafka-cp-kafka.kafka.svc.cluster.local:9092"
#           }

#           port {
#             container_port = 8080
#           }
#         }
#       }
#     }
#   }

#   depends_on = [ google_container_node_pool.se_cloud_node_pool ]
# }

# resource "kubernetes_service" "se_cloud_lb" {
#   metadata {
#     name      = "se-cloud-lb"
#     namespace = kubernetes_namespace.se_cloud.metadata[0].name
#   }

#   spec {
#     type = "LoadBalancer"

#     selector = {
#       app = "se-cloud"
#     }

#     port {
#       port        = 8080
#       target_port = 8080
#       protocol    = "TCP"
#     }
#   }

#   depends_on = [ kubernetes_deployment.se_cloud ]
# }


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
