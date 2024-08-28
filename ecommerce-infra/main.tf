provider "aws" {
    region = "ca-central-1"
}
#create an s3-bucket for the terraform_state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ecommerce-terraform-state-anudeep"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "ecommerce-terraform-state-anudeep"
    key            = "terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
#create ECR-repo
resource "aws_ecr_repository" "ecommerce_repo" {
    name = "ecommerce-monolith"
}
#create ecs-cluster
resource "aws_ecs_cluster" "ecommerce_cluster" {
  name = "ecommerce-cluster"
}
#ecs-taskexecution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
#iam-role-policy attachement
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#ecs-task-definition
resource "aws_ecs_task_definition" "ecommerce_task" {
  family                   = "ecommerce-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "ecommerce-monolith-container",
      image     = "${aws_ecr_repository.ecommerce_repo.repository_url}:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}
#ecs-service
resource "aws_ecs_service" "ecommerce_service" {
  name            = "ecommerce-service"
  cluster         = aws_ecs_cluster.ecommerce_cluster.id
  task_definition = aws_ecs_task_definition.ecommerce_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-id"]  # Replace with your subnet IDs
    security_groups  = ["sg-id"]  # Replace with your security group IDs
    assign_public_ip = true
  }
}