resource "aws_security_group" "demo-instance" {
  name        = "demo-instance-sg"
  description = "demo-instance-sg"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
