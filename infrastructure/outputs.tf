output "database_address" {
  value = aws_db_instance.main.address
}

output "database_connection_string" {
  value = nonsensitive("${aws_db_instance.main.engine}://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}")
}

output "docker_repository" {
  value = aws_ecr_repository.main.repository_url
}
