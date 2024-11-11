variable "project_id" {
  type        = string
  description = "ID of the Google Project"
}

variable "region" {
  type        = string
  description = "Default Region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Default Zone"
  default     = "us-central1-a"
}

variable "cluster_name" {
  type        = string
  description = "Name of server"
}

variable "machine_type" {
  type        = string
  description = "Machine Type"
  default     = "e2-standard-2"
}

variable "credentials_json" {
  type        = string
  description = "Credentials JSON file"
  default     = "./terraform.json"
}

variable "dockerhub_username" {
  type        = string
  description = "Dockerhub Username"
}