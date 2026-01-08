resource "google_folder" "main" {
  display_name = var.display_name
  parent       = var.parent
}
