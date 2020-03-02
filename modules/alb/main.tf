#-------------------------------------------------------------------------------
# Prerequisites
#-------------------------------------------------------------------------------

data "aws_acm_certificate" "certificate" {
  domain = "*.example.com"
}

locals {
  alb_name = "terraform-${var.environment}-${random_string.id.result}"
}

resource "random_string" "id" {
  length  = 6
  special = false
}

#-------------------------------------------------------------------------------
# SECURITY
#-------------------------------------------------------------------------------

resource "aws_security_group" "tfe_alb" {
  name        = "allow_https"
  description = "Allow HTTP(S) inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-------------------------------------------------------------------------------
# ALB
#-------------------------------------------------------------------------------

resource "aws_alb" "tfe_alb" {
  name                       = local.alb_name
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = var.environment == "production" ? true : false

  security_groups = [aws_security_group.tfe_alb.id]
  subnets         = var.subnet_ids
}

resource "aws_alb_target_group" "tfe" {
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
  }

  health_check {
    interval            = 5
    timeout             = 3
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 3
    port                = "traffic-port"
  }
}

resource "aws_alb_listener" "tfe_https_app" {
  load_balancer_arn = aws_alb.tfe_alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.tfe.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "tfe_redirect_to_https" {
  load_balancer_arn = aws_alb.tfe_alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
