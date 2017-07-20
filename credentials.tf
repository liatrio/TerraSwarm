variable "credentials" {
  type = "map"

  default = {
    name     = "ldop-test"
    location = "~/.ssh"
  }
}
