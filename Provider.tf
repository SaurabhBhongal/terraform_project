terraform {
  required_providers {
    aws = {
        source= "hashicorp/aws"
        version = "5.11.0"
    }
  }
}
provider "aws" {
    access_key=
    secret_key=
    region = "us-east-1"
    }


resource "aws_vpc" "my_vpc1"{
  cidr_block=var.cidr
  tags = {
    Name= "saurabh11"

  }
}
resource "aws_subnet" "my_subnet1" {
  vpc_id=aws_vpc.my_vpc1.id
  cidr_block="10.0.0.0/24"
  availability_zone="us-east-1a"
 map_public_ip_on_launch = true
  
}
resource "aws_subnet" "my_subnet2" {
  vpc_id=aws_vpc.my_vpc1.id
  cidr_block="10.0.1.0/24"
  availability_zone="us-east-1b"
 map_public_ip_on_launch = true
  
}
resource "aws_internet_gateway" "my_gateway1"{
  vpc_id=aws_vpc.my_vpc1.id
}
resource "aws_route_table" "myrt1"{
    vpc_id=aws_vpc.my_vpc1.id
    route {
      cidr_block="0.0.0.0/0"
      gateway_id=aws_internet_gateway.my_gateway1.id
    }
}
resource "aws_route_table_association" "my1"{
  subnet_id = aws_subnet.my_subnet1.id
  route_table_id=aws_route_table.myrt1.id
}
resource "aws_route_table_association" "my2"{
  subnet_id = aws_subnet.my_subnet2.id
  route_table_id=aws_route_table.myrt1.id
}
resource "aws_security_group" "sec11" {
  name        = "allowss"
  vpc_id      = aws_vpc.my_vpc1.id

  ingress {
    
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
  ingress {
    
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

}
resource "aws_s3_bucket""my_bucket11"{
  bucket= "saurabhbhongal2001"
}
resource "aws_instance""myinstance1"{
  ami="ami-0bb4c991fa89d4b9b"
  instance_type="t2.micro"
  vpc_security_group_ids=[aws_security_group.sec11.id]
  subnet_id=aws_subnet.my_subnet1.id
  user_data=base64encode(file("userdata1.sh"))
}
resource "aws_instance""myinstance2"{
  ami="ami-0bb4c991fa89d4b9b"
  instance_type="t2.micro"
  vpc_security_group_ids=[aws_security_group.sec11.id]
  subnet_id=aws_subnet.my_subnet2.id
  user_data=base64encode(file("userdata2.sh"))
}
resource "aws_lb""mylb1"{
 name="saurabhbh"
 internal= false
load_balancer_type="application"
security_groups=[aws_security_group.sec11.id]
subnets=[aws_subnet.my_subnet1.id,aws_subnet.my_subnet2.id]
tags={
  Name="brrr"
}

}
resource "aws_lb_target_group""mytarget"{
  name="myarg"
  port=80
  protocol="HTTP"
  vpc_id=aws_vpc.my_vpc1.id
  health_check{
    path="/"
    port="traffic-port"
  }
}
resource "aws_lb_target_group_attachment""attach1"{
  target_id=aws_instance.myinstance1.id
  target_group_arn=aws_lb_target_group.mytarget.arn
  port=80

}
resource "aws_lb_target_group_attachment""attach2"{
  target_id=aws_instance.myinstance2.id
  target_group_arn=aws_lb_target_group.mytarget.arn
  port=80

}
resource "aws_lb_listener""mylisteneer"{
  load_balancer_arn= aws_lb.mylb1.arn
  port=80
  protocol="HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.mytarget.arn
    type             = "forward"
  }



}
output instance_id1 {
  value       = aws_instance.myinstance1.id
  
}
output instance_id2 {
  value       = aws_instance.myinstance2.id
  
}
