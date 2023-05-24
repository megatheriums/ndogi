locals {
  database_password = "12345678"
  database_username = "foo"
  docker_image_trigger = jsonencode({
    ci_scripts      = data.archive_file.ci_scripts.output_sha
    Dockerfile      = filesha1("${path.module}/../Dockerfile")
    PackageLockJson = filesha1("${path.module}/../package-lock.json")
    PackageJson     = filesha1("${path.module}/../package.json")
    source_code     = data.archive_file.source_code.output_sha
  })
  regions = {
    1 = "${var.aws_region}a",
    2 = "${var.aws_region}b"
  }
}

data "archive_file" "source_code" {
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../src.zip"
  type        = "zip"
}

data "archive_file" "ci_scripts" {
  source_dir  = "${path.module}/../ci"
  output_path = "${path.module}/../ci.zip"
  type        = "zip"
}
