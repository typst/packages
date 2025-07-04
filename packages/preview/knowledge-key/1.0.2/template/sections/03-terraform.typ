#import "../utils.typ": *

= Terraform
The idea of Terraform is to help provision infrastructure (Infrastructure as code).
It has support for all common cloud provider.\
Terraform and Ansible are complementary.
Terraform deals with the infrastructure stack, Ansible deals with the application stack.\
In Terraform you interact with Provider Plugins.
A provider converts the terraform syntax to something that the SDK can consume.
The SDK then sends API calls to the cloud provider (for example AWS).
The different plugins are managed by the community (AWS, GCP, Azure, ...).

#sourcecode[```yaml
provider "aws" {
  access_key = "<AWS_ACCESS_KEY>"
  secret_key = "<AWS_SECRET_KEY>"
  region     = "us-east-1"
}
```]

#sourcecode[```yaml
resource "aws_instance" "excercise_0010" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
    Terraform = true
  }
}
```]

*Terraform workflow*
- Write your Terraform stuff
- Let Terraform plan the changes that must be applied
- Let Terraform apply the changes

*Common Terraform commands*
- `terraform init` (Initialize Terraform, perform where the .tf files are located)
- `terraform plan` (tells the operator what's going to be changed)
- `terraform apply` (applies the changes)
- `terraform destroy` (This command figures out what has been done and undo all the changes / Folder Specific)

*`terraform.tfstate` file*\
This file knows what has already been deployed.
So, if you run terraform apply twice in a row, it will know that there is nothing to do.
When you manually change something (e.g using the AWS web UI), terraform will revert your changes as the .tf files are the single source of truth.
Terraform creates the terraform.tfstate file the first time you run the command terraform apply.
Any other times it makes a 3-way diffs from the state's NEW, EXISTING and PREVIOUS to get a full picture of the current situation.
State files can get corrupted (not that often, but it can happen).
*References*\
References in Terraform are like variables.
You can reference references to get actual values defined in other places of your Terraform script.
*Output*\
Output are return values of a function.
You ultimately define references, which you want to display at the end of terraform apply.
#sourcecode[```tf
output "example-ip" {
  value = aws_instance.excercise_0010.public_ip
  description = "The public IP of the instance"
}
```]

*Data*\
The data is an input for the Terraform provider.
It uses the cloud to look up data and feed this data into the terraform script.
-> `data "aws_ami "latest_ubuntu" {...}`
*Variables*\
If a variable is defined without a default value, it will prompt the operators to enter the value.
#sourcecode[```tf
variable "port" {
  description = "The port to expose on the server"
  type = number
  default = 8080
}
```]
Variables can also be overwritten as an argument or environment variable.\
*Organization (Best practice):*
- Create one folder for each environment
- Every folder gets its own state file

*Module (Code re-use)*
- A module is just re-usable code
- A module can be invoked and supplied with all variables
