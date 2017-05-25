variable "credentials" {
  type = "map"

  default = {
    name     = "supersecure"
    location = "~/.ssh"
  }
}
