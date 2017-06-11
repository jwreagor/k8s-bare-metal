# Retrieve AWS credentials from env variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
provider "triton" {
  account = "${var.triton_account}"
  key_id  = "${var.triton_key_id}"
  key_material = "${file(var.triton_key_path)}"
  url = "${var.triton_url}"
}
