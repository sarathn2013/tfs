 


# Creating  AWS OpsWorks Stack
resource "aws_opsworks_stack" "prototype" {
   name = "prototype"
   region = "us-east-2"
   configuration_manager_version = "11.10"
   default_os = "Ubuntu 14.04 LTS"
   use_custom_cookbooks = true
   custom_cookbooks_source {
   url = "https://s3.us-east-2.amazonaws.com/testsarnidra/opsworks-example-cookbooks-master+(1).zip"
   type = "s3"
   }
   service_role_arn             = "${aws_iam_role.opsworks-service-role.arn}"
   default_instance_profile_arn = "${aws_iam_instance_profile.opsworks2.arn}"
   vpc_id                       = "${aws_vpc.secondary-vpc.id}"
   default_subnet_id            = "${aws_subnet.secondary-private-1.id}"
   use_opsworks_security_groups = false 

}


# Create layer inside opsworks stack
resource "aws_opsworks_rails_app_layer" "prototype" {
  name     =   "prototype"
  stack_id = "${aws_opsworks_stack.prototype.id}"
  custom_security_group_ids = ["${aws_security_group.staging-security-group.id}"]
}


# Create App in the opsworks stack
 resource "aws_opsworks_application" "prototype" {
  name        = "prototype"
  short_name  = "prototype"
  type        = "rails"
  stack_id    = "${aws_opsworks_stack.prototype.id}"
  description = "This is a rails application"
  domains = [
    "example.com",
    "sub.example.com",
 ]

 environment = {
    key    = "key"
    value  = "value"
    secure = true
  }

  app_source = {
    type     = "git"
    revision = "master"
    url      = "https://github.com/sarathn2013/alpha_blog.git"
  }

#  enable_ssl = true

#  ssl_configuration = {
#    private_key = "${file("./foobar.key")}"
#    certificate = "${file("./foobar.crt")}"
#  }

  document_root         = "public"
  auto_bundle_on_deploy = true
  rails_env             = "staging"
 }


# Creating ec2 instance for this stack.

resource "aws_opsworks_instance" "test-instance" {
   stack_id = "${aws_opsworks_stack.prototype.id}"

  layer_ids = [
    "${aws_opsworks_rails_app_layer.prototype.id}",
  ]
  
  ssh_key_name = "${aws_key_pair.mykeypair.key_name}"
  instance_type = "t2.micro"
  subnet_id  = "${aws_subnet.secondary-private-1.id}"
  security_group_ids = ["${aws_security_group.staging-security-group.id}"]  
  ami_id             = "ami-019abc64"
  state         = "stopped"
}
