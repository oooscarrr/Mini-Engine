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

resource "helm_release" "zookeeper" {
  name       = "zookeeper"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "zookeeper"
  version    = "12.0.0"

  set {
    name  = "replicaCount"
    value = 3
  }

  set {
    name  = "persistence.size"
    value = "5Gi"
  }

  depends_on = [ google_container_node_pool.kafka_node_pool, null_resource.configure_kubectl ] # kubernetes_namespace.kafka
}

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "27.0.0"
  timeout    = 600

  set {
    name  = "kraft.enabled"
    value = "false"
  }

  set {
    name  = "zookeeper.enabled"
    value = "true"
  }

  # Enable RBAC resources
  set {
    name  = "rbac.create"
    value = "true"
  }

  # Disable KRaft mode (use Zookeeper mode)
  set {
    name  = "controller.replicaCount"
    value = "0"
  }

  # Enable Zookeeper mode
  set {
    name  = "zookeeper.enabled"
    value = "true"
  }

  # Kafka replica count
  set {
    name  = "broker.replicaCount"
    value = "3"
  }

  # Persistence configuration
  set {
    name  = "persistence.size"
    value = "3Gi"
  }

  # External access configuration
  set {
    name  = "externalAccess.enabled"
    value = "true"
  }

  set {
    name  = "externalAccess.autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "externalAccess.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "externalAccess.service.port"
    value = "9092"
  }

  set {
    name  = "controller.automountServiceAccountToken"
    value = "true"
  }

  set {
    name  = "broker.automountServiceAccountToken"
    value = "true"
  }

  set {
    name  = "listeners.client.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.external.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.interbroker.protocol"
    value = "PLAINTEXT"
  }

  # # Node affinity to schedule Kafka only on nodes labeled with `kafka-only=true`
  # set {
  #   name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
  #   value = "kafka-only"
  # }

  # set {
  #   name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
  #   value = "In"
  # }

  # set {
  #   name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]"
  #   value = "true"
  # }

  # # Tolerations to allow Kafka pods to be scheduled on tainted nodes
  # set {
  #   name  = "tolerations[0].key"
  #   value = "kafka-only"
  # }

  # set {
  #   name  = "tolerations[0].operator"
  #   value = "Equal"
  # }

  # set {
  #   name  = "tolerations[0].value"
  #   value = "true"
  # }

  # set {
  #   name  = "tolerations[0].effect"
  #   value = "NoSchedule"
  # }

  depends_on = [ helm_release.zookeeper ]
}


# data "kubernetes_service" "kafka" {
#   metadata {
#     name      = "kafka-external-access"
#     namespace = "default"
#   }
# }

# resource "helm_release" "confluent_platform" {
#   name       = "confluent-platform"
#   repository = "https://packages.confluent.io/helm/"
#   chart      = "confluent-for-kubernetes"
#   # namespace  = "kafka"

#   depends_on = [ google_container_node_pool.kafka_node_pool, google_container_node_pool.se_cloud_node_pool, null_resource.configure_kubectl ] # kubernetes_namespace.kafka
# }

# resource "null_resource" "k8s_apply_zookeeper" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/zookeeper.yaml"
#   }
#   depends_on = [ helm_release.confluent_platform ]
# }

# resource "null_resource" "k8s_apply_kafka" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/kafka.yaml"
#   }
#   depends_on = [ null_resource.k8s_apply_zookeeper ]
# }

# resource "null_resource" "k8s_apply_kafka_topic" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./kubernetes-manifests/my-topic.yaml"
#   }
#   depends_on = [ null_resource.k8s_apply_kafka ]
# }

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