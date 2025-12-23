# Regional Database Module

This module creates regional Cloud SQL instances including:

- Cloud SQL (MySQL/PostgreSQL)
- High Availability configuration
- Backup and restore settings
- Database users and passwords
- Private IP connectivity

## Usage

```hcl
module "database" {
  source = "../../modules/regional/database"
  
  project_id = var.project_id
  region     = var.region  # e.g., asia-south1
  
  instance_name    = "my-db-instance"
  database_version = "POSTGRES_15"
  tier             = "db-custom-2-7680"
  
  network = module.networking.network_self_link
  
  ha_enabled     = true
  backup_enabled = true
  labels         = var.labels
}
```

## Inputs

| Name               | Description                                   | Type     | Default | Required |
| :----------------- | :-------------------------------------------- | :------- | :------ | :------- |
| `project_id`       | GCP Project ID                                | `string` | -       | yes      |
| `region`           | GCP Region (e.g., asia-south1)                | `string` | -       | yes      |
| `instance_name`    | Name of the database instance                 | `string` | -       | yes      |
| `database_version` | Database version (`POSTGRES_15`, `MYSQL_8_0`) | `string` | -       | yes      |
| `tier`             | Machine tier                                  | `string` | -       | yes      |
| `network`          | VPC network self link                         | `string` | -       | yes      |

## Outputs

| Name                       | Description        |
| :------------------------- | :----------------- |
| `instance_connection_name` | Connection name    |
| `private_ip_address`       | Private IP         |
| `instance_self_link`       | Instance self link |
