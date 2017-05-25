variable "credentials" {
  type = "map"

  default = {
    name     = "cogmind"
    location = "~/.ssh"
  }
}
