resource "aws_acm_certificate" "this" {
    domain_name               = "${var.domain}"
    subject_alternative_names = ["*.${var.domain}"]
    validation_method         = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "this" {
    certificate_arn = "${aws_acm_certificate.this.arn}"
}

resource "aws_security_group" "world" {
    name_prefix = "nuvola-world-"
    vpc_id      = "${var.vpc-id}"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_alb" "proxy" {
    name            = "nuvola-world"
    security_groups = ["${aws_security_group.world.id}"]
    subnets         = ["${var.vpc-public-subnets}"]

    access_logs {
        enabled = true
        bucket  = "${var.s3-bucket-name}"
        prefix  = "alb-world-logs"
    }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb-proxy" {
    bucket = "${var.s3-bucket-id}"
    policy = <<JSON
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowToPutLoadBalancerLogsToS3Bucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "${var.s3-bucket-arn}/alb-world-logs/*"
        }
    ]
}
JSON
}

resource "aws_alb_target_group" "proxy" {
    name        = "nuvola-proxy"
    vpc_id      = "${var.vpc-id}"
    port        = 8888
    protocol    = "HTTP"
    target_type = "ip"

    lifecycle {
        create_before_destroy = true
    }

    health_check {
        path = "/health-check"
    }
}

resource "aws_alb_listener" "world" {
    load_balancer_arn = "${aws_alb.proxy.arn}"
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2015-05"
    certificate_arn   = "${aws_acm_certificate.this.arn}"
    depends_on        = ["aws_alb_target_group.proxy"]

    default_action {
        type             = "forward"
        target_group_arn = "${aws_alb_target_group.proxy.arn}"
    }
}

resource "aws_security_group" "proxy" {
    name_prefix = "nuvola-proxy-"
    vpc_id      = "${var.vpc-id}"

    ingress {
        from_port       = 8888
        to_port         = 8888
        protocol        = "TCP"
        security_groups = ["${aws_alb.proxy.security_groups}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}
