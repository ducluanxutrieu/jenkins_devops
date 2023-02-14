moved {
  from = aws_vpc.main_vpc
  to   = module.aws_vpc.aws_vpc.main_vpc
}

moved {
  from = aws_subnet.public_subnet
  to   = module.aws_vpc.aws_subnet.public_subnet
}