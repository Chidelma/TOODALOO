# Install aws provider
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
        }
    }
}

# Configure aws provider with region ca-central-1
provider "aws" {
  region = "ca-central-1"
}

# Define a variable for the project name
variable "projectName" {
  default = "toodaloo"
}

# Define a local variable for tags
locals {
  tags = {
    Name = var.projectName
  }
}

# Create a VPC with CIDR block 10.0.0.0/16
resource "aws_vpc" "toodaloo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = local.tags
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "toodaloo_igw" {
  vpc_id = aws_vpc.toodaloo_vpc.id
  tags = local.tags
}

# Create a Route Table for the VPC with a route to the Internet Gateway
resource "aws_route_table" "toodaloo_public_route_table" {
  vpc_id = aws_vpc.toodaloo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.toodaloo_igw.id
  }

  tags = local.tags
}

# Create three subnets in three availability zones
resource "aws_subnet" "toodaloo_public_subnet_1" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ca-central-1a"
  tags                    = local.tags
}

resource "aws_subnet" "toodaloo_public_subnet_2" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ca-central-1b"
  tags                    = local.tags
}

resource "aws_subnet" "toodaloo_public_subnet_3" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ca-central-1d"
  tags                    = local.tags
}

# Associate the subnets with the route table
resource "aws_route_table_association" "toodaloo_public_route_table_association_1" {
  subnet_id      = aws_subnet.toodaloo_public_subnet_1.id
  route_table_id = aws_route_table.toodaloo_public_route_table.id
}

resource "aws_route_table_association" "toodaloo_public_route_table_association_2" {
  subnet_id      = aws_subnet.toodaloo_public_subnet_2.id
  route_table_id = aws_route_table.toodaloo_public_route_table.id
}

resource "aws_route_table_association" "toodaloo_public_route_table_association_3" {
  subnet_id      = aws_subnet.toodaloo_public_subnet_3.id
  route_table_id = aws_route_table.toodaloo_public_route_table.id
}

# Create three private subnets in three availability zones (private subnets are not accessible from the Internet)
resource "aws_subnet" "toodaloo_private_subnet_4" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ca-central-1a"
  tags                    = local.tags
}

resource "aws_subnet" "toodaloo_private_subnet_5" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ca-central-1b"
  tags                    = local.tags
}

resource "aws_subnet" "toodaloo_private_subnet_6" {
  vpc_id                  = aws_vpc.toodaloo_vpc.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = "ca-central-1d"
  tags                    = local.tags
}

# Create a security group for the ALB to allow HTTP traffic from anywhere
resource "aws_security_group" "toodaloo_sg_ec2" {
  vpc_id = aws_vpc.toodaloo_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Get the latest AMI (ami-toodaloo)
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-toodaloo"]
  }
}

# Create a Launch Template for the AMI
resource "aws_launch_template" "toodaloo_lt" {
  name_prefix   = "${var.projectName}-launch-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # Uncomment the following line to use user_data to run a script on startup
  # user_data = filebase64("${path.module}/userdata.sh")

  vpc_security_group_ids = aws_elb.toodaloo_alb.security_groups

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
}

# Create an Elastic Load Balancer (Classic)
# We could have used an Application Load Balancer (ALB) instead, but lets keep it simple for now as ALB would require a Target Group
resource "aws_elb" "toodaloo_alb" {
    name               = "${var.projectName}-alb"
    internal           = false
    security_groups    = [aws_security_group.toodaloo_sg_ec2.id]
    subnets            = [aws_subnet.toodaloo_public_subnet_1.id, aws_subnet.toodaloo_public_subnet_2.id, aws_subnet.toodaloo_public_subnet_3.id]
    
    # Listener for HTTP traffic on port 80 and bind it to port 80 on the instance(s)
    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    tags = local.tags
}

# Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "toodaloo_asg" {
  desired_capacity     = 1 # Number of instances to launch initially, even if there is a termination
  max_size             = 10 # Maximum number of instances
  min_size             = 1 # Minimum number of instances
  launch_template {
    id      = aws_launch_template.toodaloo_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [aws_subnet.toodaloo_public_subnet_1.id, aws_subnet.toodaloo_public_subnet_2.id, aws_subnet.toodaloo_public_subnet_3.id]

  load_balancers = [ aws_elb.toodaloo_alb.name ]

  tag {
    key                 = "Name"
    value               = var.projectName
    propagate_at_launch = true
  }
}

# Create a Scheduled Action for the ASG
# This will scale up the ASG during peak hours (8am-5pm) and scale down during off-peak hours (5pm-8am)
resource "aws_autoscaling_schedule" "toodaloo_schedule" {
  scheduled_action_name  = "peak-daylight-hours"
  min_size               = 5
  max_size               = 20
  desired_capacity       = 5
  recurrence             = "* 8-17 * * *"
  autoscaling_group_name = aws_autoscaling_group.toodaloo_asg.name
}

# Attach the ASG to the ALB
resource "aws_autoscaling_attachment" "toodaloo_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.toodaloo_asg.name
  elb = aws_elb.toodaloo_alb.id
}

# Create a security group for the RDS instance to allow access only from the ALB
resource "aws_security_group" "toodaloo_sg_rds" {
  vpc_id = aws_vpc.toodaloo_vpc.id

  ingress {
    from_port   = 80
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.toodaloo_public_subnet_1.cidr_block, aws_subnet.toodaloo_public_subnet_2.cidr_block, aws_subnet.toodaloo_public_subnet_3.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Create a DB Subnet Group for the RDS instance with the private subnets
resource "aws_db_subnet_group" "toodaloo_private_subnet_group" {
  name       = "${var.projectName}-private-subnet-group"
  subnet_ids = [aws_subnet.toodaloo_private_subnet_4.id, aws_subnet.toodaloo_private_subnet_5.id, aws_subnet.toodaloo_private_subnet_6.id]
}

# Create a RDS instance
resource "aws_db_instance" "toodaloo_rds" {
  db_name                = "toodaloo"
  allocated_storage      = 10
  max_allocated_storage  = 100 # Enable auto-scaling for the storage
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  username               = "toodaloo"
  password               = "toodaloo" # Best practice is to use a secret manager to store the password
  multi_az               = true
  port                   = 5432
  vpc_security_group_ids = [aws_security_group.toodaloo_sg_rds.id]
  db_subnet_group_name = aws_db_subnet_group.toodaloo_private_subnet_group.name
  tags = local.tags
}
