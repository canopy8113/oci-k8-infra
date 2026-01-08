output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "cluster_id" {
  value = oci_containerengine_cluster.oke.id
}

output "node_pool_id" {
  value = oci_containerengine_node_pool.oke.id
}

output "nodes_subnet_id" {
  value = oci_core_subnet.nodes.id
}

output "endpoint_subnet_id" {
  value = oci_core_subnet.endpoint.id
}
