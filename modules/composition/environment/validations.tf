# Validation Rules for Environment Composition Module

# Validate that subnet_name is provided for compute instances when using Shared VPC
check "shared_vpc_subnet_names" {
  assert {
    condition = !var.is_shared_vpc_service || alltrue([
      for k, v in var.compute_instances : v.subnet_name != null
    ])
    error_message = "For Shared VPC service projects (is_shared_vpc_service = true), all compute instances must have subnet_name explicitly specified. Compute instances missing subnet_name: ${join(", ", [for k, v in var.compute_instances : k if v.subnet_name == null])}"
  }
}
