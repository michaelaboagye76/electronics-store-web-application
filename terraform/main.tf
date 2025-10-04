provider "aws" {
  region = "us-east-1"
}

# ------------------------
# VPC and Networking
# ------------------------
resource "aws_vpc" "flask_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "flask_igw" {
  vpc_id = aws_vpc.flask_vpc.id
}

resource "aws_subnet" "flask_subnet" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-sg"
  description = "Allow Flask app traffic and outbound to ECR"
  vpc_id      = aws_vpc.flask_vpc.id

  ingress {
    description = "Flask app HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------
# IAM Role for ECS Task
# ------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "flask-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------
# ECR Repository
# ------------------------
resource "aws_ecr_repository" "flask_repo" {
  name = "flask-app-repo"
}

# ------------------------
# ECS Cluster
# ------------------------
resource "aws_ecs_cluster" "flask_cluster" {
  name = "my-ecs-cluster"
}

# ------------------------
# ECS Task Definition
# ------------------------
resource "aws_ecs_task_definition" "flask_task" {
  family                   = "my-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "flask-app",
    "image": "${aws_ecr_repository.flask_repo.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ]
  }
]
DEFINITION
}

# ------------------------
# ECS Service
# ------------------------
resource "aws_ecs_service" "flask_service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask_cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.flask_subnet.id]
    security_groups = [aws_security_group.flask_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_internet_gateway.flask_igw]
}
