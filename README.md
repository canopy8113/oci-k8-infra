# OCI OKE Always Free (OpenTofu)

This repo provisions a small Oracle Kubernetes Engine (OKE) cluster using OpenTofu. The stack is designed for dev/test learning with Always Free resources and uses a NodePort-based exposure model to avoid provisioning OCI load balancers by default.

## What gets created
- VCN with an Internet Gateway and public route table
- Public subnets for worker nodes and the Kubernetes API endpoint
- OKE cluster (managed control plane)
- OKE node pool (default 1 node, A1.Flex)
- Security rules for SSH (22), Kubernetes API (6443), and NodePort range (30000-32767)

## Requirements
- Oracle Cloud account with Always Free resources
- Compartment OCID and API key credentials
- OpenTofu locally or Spacelift for remote runs

## Spacelift setup (recommended)
1) Create a new stack and connect it to this GitHub repo.
2) Select OpenTofu as the IaC engine.
3) Enable VCS-driven runs (plan on PRs, apply on merge to main).
4) Set the following variables (prefix with `TF_VAR_`):
   - `tenancy_ocid`
   - `user_ocid`
   - `fingerprint`
   - `private_key` (mark as secret)
   - `region`
   - `compartment_ocid`
   - `node_image_id`
   - `admin_cidr` (optional; set to your public `/32` for security)

## Key variables
- `node_pool_size`: Number of worker nodes (default 1)
- `node_shape`: Compute shape (default `VM.Standard.A1.Flex`)
- `node_ocpus`: OCPUs per node (default 1)
- `node_memory_in_gbs`: Memory per node (default 6)
- `admin_cidr`: CIDR allowed for SSH and NodePort access
- `nodeport_min` / `nodeport_max`: Allowed NodePort range

## NodePort access
This stack does not create a service load balancer subnet. To expose an app:
1) Create a `Service` of type `NodePort`.
2) Access the app via `http://<node-public-ip>:<nodePort>`.

Example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

## Outputs
- `cluster_id`
- `node_pool_id`
- `vcn_id`
- `nodes_subnet_id`
- `endpoint_subnet_id`
