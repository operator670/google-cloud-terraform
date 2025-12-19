output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_self_link" {
  description = "The self link of the Cloud SQL instance"
  value       = google_sql_database_instance.main.self_link
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.public_ip_address
}

output "instance_first_ip_address" {
  description = "The first IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.first_ip_address
}

output "database_names" {
  description = "Names of the created databases"
  value       = [for db in google_sql_database.databases : db.name]
}

output "user_names" {
  description = "Names of the created users"
  value       = [for user in google_sql_user.users : user.name]
}
