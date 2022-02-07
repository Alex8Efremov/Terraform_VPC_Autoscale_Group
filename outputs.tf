# output "Latest_Debian_10_ami_id" {
#   value = data.aws_ami.latest_Debian_10.id
# }
output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}
