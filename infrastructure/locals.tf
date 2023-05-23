locals {
  database_password = "12345678"
  database_username = "foo"
  regions = {
    1 = "${var.aws_region}a",
    2 = "${var.aws_region}b"
  }
}
