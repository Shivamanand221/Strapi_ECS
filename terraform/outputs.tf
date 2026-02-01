output "rds_endpoint" {
  value = aws_db_instance.strapi.address
}

output "alb_dns_name" {
  value = aws_lb.strapi_alb.dns_name
}
