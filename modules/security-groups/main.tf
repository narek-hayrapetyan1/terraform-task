resource "aws_security_group" "alb_allow_http" {
  name        = "service-qa-alb-sg"
  description = "ALB security group allowing inbound HTTP"
  vpc_id      = var.qa_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "service-qa-alb-sg" })

}

resource "aws_security_group" "ecs_allow_alb" {
  name        = "service-qa-ecs-sg"
  description = "ECS service security group allowing inbound traffic from ALB"
  vpc_id      = var.qa_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "service-qa-ecs-sg" })
}

resource "aws_security_group_rule" "alb_allow_http_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_allow_http.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow HTTP from anywhere"
}

resource "aws_security_group_rule" "ecs_allow_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_allow_alb.id
  source_security_group_id = aws_security_group.alb_allow_http.id

  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"

  description = "Allow ALB to ECS on port 8080"
}
