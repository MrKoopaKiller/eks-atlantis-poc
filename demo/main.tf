module "demo-instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = "demo-instance"
  instance_type          = "t3.micro"
  monitoring             = false
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.demo-instance.id]
  user_data              = file("${path.module}/userdata.sh")
}
