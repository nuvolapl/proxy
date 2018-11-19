variable "region" {
    description = ""
}

variable "cloudwatch-log-group-name" {
    description = ""
}

variable "domain" {
    description = ""
}

variable "vpc-id" {
    description = ""
}

variable "vpc-public-subnets" {
    type        = "list"
    description = ""
}

variable "vpc-private-subnets" {
    type        = "list"
    description = ""
}

variable "caller-identity-account-id" {
    description = ""
}

variable "s3-bucket-arn" {
    description = ""
}

variable "s3-bucket-id" {
    description = ""
}

variable "s3-bucket-name" {
    description = ""
}

variable "iam-role-ecs-td-arn" {
    description = ""
}

variable "ecs-cluster-id" {
    description = ""
}
