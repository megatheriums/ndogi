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

resource "null_resource" "image" {
  depends_on = [
    aws_ecr_repository.main,
    null_resource.install_aws_cli
  ]

  triggers = {
    # always_run = timestamp()
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
