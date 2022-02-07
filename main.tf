#=========================================================
#
# Provision Highly Available Web in any Region Default VPC
# Create:
#       - VPC network public and DB subnets
#       - Security Group for Web Server
#       - Deploy Web server with DB
#       - Launch Configuration with Auto AMI Lookup
#       - Auto Scaling Group using 2 Availability Zones
#       - Classic Load Balancer in 2 Availability Zones
#
# Made by Aleksandr Vyskrebtcev 20-January-2022
#
#=========================================================

# data "aws_availability_zones" "available" {}

#-------------------------Security Group-------------------------------
resource "aws_security_group" "public_SecGr" {
  name        = "Dynamic Security Group"
  description = "My First Security Group"
  vpc_id      = aws_vpc.terra_vpc.id

  dynamic "ingress" {
    for_each = ["80", "443", "22", "3306"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "Dynamic Security Group"
    Owner   = "Aleksandr V"
    Project = "Terraform_VPC_Web_DB"
  }

  depends_on = [aws_vpc.terra_vpc]
}

#--------------------------Launch Configuration------------------------

resource "aws_launch_configuration" "web" {
  name_prefix          = "WebServer-Highly-Available-LC-" # to change name
  image_id             = data.aws_ami.latest_ubuntu_20.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.public_SecGr.id]
  user_data            = file("user_data_php.sh")
  key_name             = "efremov_london"
  iam_instance_profile = "ParameterStore"

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------Auto Scaling Group--------------------------

resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  max_size             = 3
  min_size             = 1
  desired_capacity     = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier = [aws_subnet.public[0].id,
  aws_subnet.public[1].id]
  load_balancers = [aws_elb.web.name]

  dynamic "tag" {
    for_each = {
      Name    = "WebServer in ASG"
      Owner   = "Efremov"
      TagName = "Web_VPS_ASG"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
#--------------------------E Load Balancer-----------------------------

resource "aws_elb" "web" {
  name = "WebServer-HA-ELB"
  subnets = [aws_subnet.public[0].id,
  aws_subnet.public[1].id]
  security_groups = [aws_security_group.public_SecGr.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }
  tags = {
    Name = "WebServer-Highly-Available-ELB"
  }
}

# ------------------------Create DB-------------------------------
resource "aws_instance" "my_DB" {
  count                  = 1
  ami                    = data.aws_ami.latest_RedHat.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public_SecGr.id]
  subnet_id              = aws_subnet.db[0].id
  private_ip             = "10.20.23.23"
  key_name               = "efremov_london"

  tags = {
    Name    = "Linux_DB"
    Owner   = "Aleksandr V"
    Project = "Terraform_VPC_Web_DB"
  }
}
