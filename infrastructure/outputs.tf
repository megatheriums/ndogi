output "database_address" {
  value = aws_db_instance.main.address
}

output "docker_repository" {
  value = aws_ecr_repository.main.repository_url
}

output "url" {
  value = aws_lb.main.dns_name
}
