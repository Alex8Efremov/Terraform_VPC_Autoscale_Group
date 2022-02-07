#================Image Ubuntu_20================
data "aws_ami" "latest_ubuntu_20" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
#================Image Debian_10===============
data "aws_ami" "latest_Debian_10" {
  owners      = ["136693071363"]
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-10-amd64-*"]
  }
}
#================Image RedHat===============
data "aws_ami" "latest_RedHat" {
  owners      = ["309956199498"]
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL_HA-8.4.0_HVM-20210504-x86_64-*"]
  }
}
