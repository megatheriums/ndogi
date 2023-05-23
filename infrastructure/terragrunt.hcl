remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "${get_env("TF_VAR_aws_account_id")}-${get_env("TF_VAR_namespace", "bitly")}-terraform-state"
    encrypt = true
    key = get_env("TF_VAR_project_path", "bitly/ndogi")
    region = get_env("TF_VAR_aws_region", "eu-central-1")
  }
}
