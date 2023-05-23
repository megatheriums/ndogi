resource "aws_db_instance" "main" {
  allocated_storage = 10
  db_name           = var.project_name
  engine            = "mysql"
  engine_version    = "5.7"
  identifier        = "${var.namespace}-${var.project_name}-${var.environment}"
  instance_class    = "db.t3.micro"
  username          = local.database_username # TODO Use KMS
  password          = local.database_password # TODO Use KMS
  storage_encrypted = !var.enable_debugging

  # Stability
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  final_snapshot_identifier   = "${var.namespace}-${var.project_name}-${var.environment}-final-snapshot"
  multi_az                    = true
  max_allocated_storage       = 1000 # 10 TB
  blue_green_update {
    enabled = true
  }

  # Debugging
  publicly_accessible = var.enable_debugging
  # monitoring_interval          = var.enable_debugging ? 1 : 0
  # performance_insights_enabled = var.enable_debugging
  skip_final_snapshot = var.enable_debugging
}
