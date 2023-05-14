data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = [
      var.vpc_name
    ]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["public"]
  }
}
