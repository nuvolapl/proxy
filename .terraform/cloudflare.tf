provider "cloudflare" {
    version = "~> 0.1"
}

resource "cloudflare_record" "certificate-validation" {
    domain = "${aws_acm_certificate.this.domain_validation_options.0.domain_name}"
    type   = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_type}"
    name   = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_name}"
    value  = "${substr(aws_acm_certificate.this.domain_validation_options.0.resource_record_value, 0, length(aws_acm_certificate.this.domain_validation_options.0.resource_record_value)-1)}"
}

resource "cloudflare_record" "domain" {
    domain  = "${aws_acm_certificate.this.domain_name}"
    type    = "CNAME"
    name    = "${aws_acm_certificate.this.domain_name}"
    value   = "${aws_alb.proxy.dns_name}"
    proxied = true
}

resource "cloudflare_record" "subdomain-www" {
    domain  = "${aws_acm_certificate.this.domain_name}"
    type    = "CNAME"
    name    = "www"
    value   = "${aws_acm_certificate.this.domain_name}"
    proxied = true
}
