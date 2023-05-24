resource "aws_ecr_repository" "main" {
  name         = "${var.namespace}-${var.project_name}-${var.environment}"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "install_aws_cli" {
  triggers = {
    setup_file = file("./script/install-aws.sh")
  }

  provisioner "local-exec" {
    command = "./script/install-aws.sh"
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

resource "null_resource" "image" {
  depends_on = [
    aws_ecr_repository.main,
    null_resource.install_aws_cli
  ]

  triggers = {
    ci_scripts      = archive_file.ci_scripts.output_sha
    Dockerfile      = filesha1("${path.module}/../Dockerfile")
    PackageLockJson = filesha1("${path.module}/../package-lock.json")
    PackageJson     = filesha1("${path.module}/../package.json")
    source_code     = archive_file.source_code.output_sha
  }

  provisioner "local-exec" {
    command = "publish"
    environment = {
      AWS_REGION     = var.aws_region
      IMAGE_NAME     = "${var.namespace}-${var.project_name}-${var.environment}"
      REPOSITORY_URL = aws_ecr_repository.main.repository_url
    }
    interpreter = [
      "npm",
      "run"
    ]
  }
}
