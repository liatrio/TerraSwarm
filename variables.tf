variable "user" {
  type    = "string"
  default = "ec2-user"
}

variable "zone" {
  type    = "string"
  default = "us-east-1"
}

variable "ami" {
  type = "map"

  default = {
    us-east-1      = "ami-c58c1dd3"
    us-east-2      = "ami-4191b524"
    us-west-1      = "ami-7a85a01a"
    us-west-2      = "ami-4836a428"
    ca-central-1   = "ami-0bd66a6f"
    eu-west-1      = "ami-01ccc867"
    eu-central-1   = "ami-b968bad6"
    eu-west-2      = "ami-b6daced2"
    ap-northeast-1 = "ami-923d12f5"
    ap-northeast-2 = "ami-9d15c7f3"
    ap-southeast-1 = "ami-fc5ae39f"
    ap-southeast-2 = "ami-162c2575"
    ap-south-1     = "ami-52c7b43d"
    sa-east-1      = "ami-37cfad5b"
  }
}
