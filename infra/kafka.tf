# resource "kubernetes_namespace" "kafka" {
#   metadata {
#     name = "kafka"
#   }
#   depends_on = [ google_container_node_pool.kafka_node_pool ]
# }

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${google_container_cluster.primary.location}"
  }

  depends_on = [ google_container_cluster.primary ]
}

resource "helm_release" "confluent_platform" {
  name       = "confluent-platform"
  repository = "https://packages.confluent.io/helm/"
  chart      = "confluent-for-kubernetes"
  # namespace  = "kafka"

  depends_on = [ google_container_node_pool.kafka_node_pool, google_container_node_pool.se_cloud_node_pool, null_resource.configure_kubectl ] # kubernetes_namespace.kafka
}

resource "null_resource" "k8s_apply_zookeeper" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./kubernetes-manifests/zookeeper.yaml"
  }
  depends_on = [ helm_release.confluent_platform ]
}

resource "null_resource" "k8s_apply_kafka" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./kubernetes-manifests/kafka.yaml"
  }
  depends_on = [ null_resource.k8s_apply_zookeeper ]
}

# resource "null_resource" "k8s_apply_schema_registry" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/schema-registry.yaml"
#   }
#   depends_on = [ null_resource.k8s_apply_kafka ]
# }

# resource "null_resource" "k8s_apply_control_center" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/control-center.yaml"
#   }
#   depends_on = [ null_resource.k8s_apply_schema_registry ]
# }

# resource "kubernetes_manifest" "zookeeper" {
#   manifest = yamldecode(file("./kubernetes-manifests/zookeeper.yaml"))
#   depends_on = [helm_release.confluent_platform]
# }

# resource "kubernetes_manifest" "kafka" {
#   manifest = yamldecode(file("./kubernetes-manifests/kafka.yaml"))
#   depends_on = [kubernetes_manifest.zookeeper]
# }

# resource "kubernetes_manifest" "schema_registry" {
#   manifest = yamldecode(file("./kubernetes-manifests/schema-registry.yaml"))
#   depends_on = [kubernetes_manifest.kafka]
# }

# resource "kubernetes_manifest" "control_center" {
#   manifest = yamldecode(file("./kubernetes-manifests/control-center.yaml"))
#   depends_on = [kubernetes_manifest.schema_registry]
# }
