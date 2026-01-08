# Regional Compute Module

This module creates regional compute resources including:

- Compute Engine instances
- Instance templates
- Managed Instance Groups (MIG)
- Auto-scaling policies
- Health checks

## Usage

```hcl
module "compute" {
  source = "../../modules/regional/compute"
  
  project_id    = var.project_id
  region        = var.region
  zone          = var.zone
  
  instance_name = "my-instance"
  machine_type  = "e2-medium"
  
  network       = module.networking.network_name
  subnetwork    = module.networking.subnet_name
  
  tags          = ["web", "production"]
  labels        = var.labels
}
```

## Inputs

| Name            | Description                        | Type     | Default     | Required |
| :-------------- | :--------------------------------- | :------- | :---------- | :------- |
| `project_id`    | GCP Project ID                     | `string` | -           | yes      |
| `region`        | GCP Region (e.g., asia-south1)     | `string` | -           | yes      |
| `zone`          | GCP Zone (e.g., asia-south1-a)     | `string` | -           | yes      |
| `instance_name` | Name of the instance               | `string` | -           | yes      |
| `machine_type`  | Machine type                       | `string` | `e2-medium` | no       |
| `network`       | VPC network name                   | `string` | -           | yes      |
| `subnetwork`            | Subnet name                        | `string` | -           | yes      |
| `boot_disk_auto_delete` | Auto-delete boot disk on destroy   | `bool`   | `true`      | no       |

## Outputs

| Name                 | Description         |
| :------------------- | :------------------ |
| `instance_id`        | Instance ID         |
| `instance_ip`        | Internal IP address |
| `instance_group_url` | MIG URL             |
