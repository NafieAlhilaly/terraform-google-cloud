variables {
  file_name_prefix = "website"
}


run "test_storage_name_is_valid" {

  command = plan

  assert {
    condition     = google_storage_bucket.files-storage.name == "website-files"
    error_message = "Google storage name did not match expected"
  }

}
