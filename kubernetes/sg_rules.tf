# Security group for Load Balancer.
# Allow HTTP inbound traffic from anywhere.
#
# Check the ingress.annotations on the file templates/atlantis_values.yaml.tpl for referecnce.

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    description      = "Allow HTTP inbound"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

# This rule allows the ALB to communicate with the worker nodes
resource "aws_security_group_rule" "allow_atlantis_alb_to_cluster" {
  description              = "Allow access from atlantis ALB to worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_http.id
  security_group_id        = data.terraform_remote_state.infra.outputs.node_security_group_id
}
