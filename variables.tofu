variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
}

variable "private_key" {
  description = "Private API key content"
  type        = string
  sensitive   = true
}


variable "region" {
  description = "OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "cluster_name" {
  description = "OKE cluster name"
  type        = string
  default     = "oke-always-free"
}

variable "vcn_cidr" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nodes_subnet_cidr" {
  description = "Worker node subnet CIDR"
  type        = string
  default     = "10.0.10.0/24"
}

variable "endpoint_subnet_cidr" {
  description = "Kubernetes API endpoint subnet CIDR"
  type        = string
  default     = "10.0.20.0/24"
}

variable "pods_cidr" {
  description = "Kubernetes pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
  default     = "10.96.0.0/16"
}

variable "kubernetes_version" {
  description = "Optional fixed Kubernetes version; leave empty to use latest available"
  type        = string
  default     = "v1.34.1"
}

variable "node_pool_size" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_shape" {
  description = "Compute shape for worker nodes"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_ocpus" {
  description = "OCPUs per node (A1 Flex)"
  type        = number
  default     = 1
}

variable "node_memory_in_gbs" {
  description = "Memory in GB per node (A1 Flex)"
  type        = number
  default     = 6
}

variable "node_image_id" {
  description = "OKE node image OCID"
  type        = string
  default     = "ocid1.image.oc1.uk-london-1.aaaaaaaascvgl22f563ata6tumzoqrdpos2xezvvjal5towzipl6g3utun7q"
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH to nodes and reach the public API endpoint"
  type        = string
  default     = "213.109.151.46/32"
}

variable "nodeport_min" {
  description = "Minimum NodePort range to allow from admin_cidr"
  type        = number
  default     = 30000
}

variable "nodeport_max" {
  description = "Maximum NodePort range to allow from admin_cidr"
  type        = number
  default     = 32767
}
