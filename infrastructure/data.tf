data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}
