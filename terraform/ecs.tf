resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}

resource "aws_launch_template" "ecs" {
    image_id = data.aws_ami.ecs.id
    instance_type = var.instance_type

    key_name = "ecs-key"

    vpc_security_group_ids = [
      aws_security_group.strapi_sg.id
    ]

    iam_instance_profile {
      name = aws_iam_instance_profile.ecs_profile.name
    }
    user_data = base64encode(<<EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
      EOF
        )
      }

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}

resource "aws_autoscaling_group" "ecs" {
    desired_capacity = 1
    max_size = 1
    min_size = 1
    vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    launch_template {
      id = aws_launch_template.ecs.id
      version = "1"
    }
}

resource "aws_ecs_task_definition" "strapi" {
  family = "strapi"
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
        name = "strapi"
        image = "946301361309.dkr.ecr.us-east-1.amazonaws.com/strapi:latest"
        memory = 768
        portMappings = [
          {
            containerPort = 1337
          }
        ]
        environment = [
          { name = "APP_KEYS", value = "rlkHtEO3OmbvRD3ttbfcWw==,VeEdQy7xarlWwkBXQm6ivg==,FLiOSPzqC64SaOhVLULx/Q==,wclX3ufFrkjj/uCXv9AsuA==" },
          { name = "API_TOKEN_SALT", value = "lmKXY7Vr0z4jJR2msi+fwA==" },
          { name = "ADMIN_JWT_SECRET", value = "JNrFoapKZUbtX1RUWD3twg==" },
          { name = "JWT_SECRET", value = "ZLoCAamyFMM3cH7hFn3e1w==t" },
          { name = "TRANSFER_TOKEN_SALT", value = "WRCFuoWJ27cqvGG8FHD6rQ==" },
          { name = "ENCRYPTION_KEY", value = "M4M+D4fk6vADAYNqoEhisw==" },
          {
            name  = "HOST"
            value = "0.0.0.0"
          },
          {
            name  = "PORT"
            value = "1337"
          },
          {
            name = "NODE_ENV"
            value = "production"
          },
          {
            name = "DATABASE_CLIENT"
            value = "postgres"
          },
          {
            name = "DATABASE_HOST"
            value = aws_db_instance.strapi.address
          },
          {
            name = "DATABASE_PORT"
            value = "5432"
          },
          {
            name = "DATABASE_NAME"
            value = var.db_name
          },
          {
            name = "DATABASE_USERNAME"
            value = var.db_user
          },
          {
            name = "DATABASE_PASSWORD"
            value = var.db_password
          },
          { name = "DATABASE_SSL", value = "true" },
          { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" }
        ]
    }
  ])
}

resource "aws_ecs_service" "strapi" {
  name = "strapi"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.strapi_sg.id]
  }

  load_balancer {
  target_group_arn = aws_lb_target_group.strapi_tg.arn
  container_name   = "strapi"
  container_port   = 1337
}

}
