# output ec2 endpoint
output "ec2_endpoint" {
  value = module.demo-instance.public_dns
}
