output "vm_id" {
  value       = google_compute_instance.app_server.id
  sensitive   = false
  description = "Output VM app_server id"
}
