locals {
  vcn_cidr               = var.vcn_cidr
  nodes_subnet_cidr      = var.nodes_subnet_cidr
  endpoint_subnet_cidr   = var.endpoint_subnet_cidr
  service_lb_subnet_cidr = var.service_lb_subnet_cidr
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_block     = local.vcn_cidr
  display_name   = "${var.cluster_name}-vcn"
  dns_label      = "okevcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.cluster_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.cluster_name}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.cluster_name}-public-sl"

  ingress_security_rules {
    protocol = "6"
    source   = var.admin_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = local.vcn_cidr
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.vcn_cidr
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = local.nodes_subnet_cidr
  display_name   = "${var.cluster_name}-nodes-subnet"
  dns_label      = "nodes"

  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "endpoint" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = local.endpoint_subnet_cidr
  display_name   = "${var.cluster_name}-endpoint-subnet"
  dns_label      = "endpoint"

  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "service_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = local.service_lb_subnet_cidr
  display_name   = "${var.cluster_name}-service-lb-subnet"
  dns_label      = "lb"

  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : data.oci_containerengine_cluster_option.oke.kubernetes_versions[0]
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.main.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.endpoint.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.service_lb.id]
    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }
}

resource "oci_containerengine_node_pool" "oke" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.oke.id
  kubernetes_version = oci_containerengine_cluster.oke.kubernetes_version
  name               = "${var.cluster_name}-pool"
  node_shape         = var.node_shape

  node_config_details {
    size = var.node_pool_size

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.nodes.id
    }
  }

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_in_gbs
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.node_image_id
  }
}
