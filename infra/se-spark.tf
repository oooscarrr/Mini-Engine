# Injecting IP address of the webapp service into the frontend app
resource "local_file" "config_se_spark" {
  content  = <<EOF
  KAFKA_IP=${lookup(data.external.kafka_external_ip.result, "ip", "")}
  EOF
  filename = "../se-spark/.env"
  depends_on = [ data.external.kafka_external_ip ]
}

resource "null_resource" "build_push_se_spark" {
  depends_on = [ helm_release.kafka, local_file.config_se_spark ]

  # Authenticate Docker
  provisioner "local-exec" {
    command = "gcloud auth configure-docker"
  }

  # Create a buildx builder
  provisioner "local-exec" {
    command = <<EOT
      docker buildx create --name mybuilder --use || docker buildx use mybuilder
      docker buildx inspect mybuilder --bootstrap
    EOT
  }

  # Build and push to GCR
  provisioner "local-exec" {
    command = <<EOT
      docker buildx build --no-cache --platform linux/amd64,linux/arm64 -t gcr.io/${var.project_id}/${var.dockerhub_username}/se-spark:latest --push ../se-spark
    EOT
  }
}

resource "null_resource" "apply_se_spark_k8s" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${google_container_cluster.primary.location}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./kubernetes-manifests/se-spark-deployment.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl rollout restart deployment se-spark"
  }
  
  depends_on = [ null_resource.build_push_se_spark ]
}
