# AWS Transit Gateway Attachment Accepter Terraform module

Terraform module which creates Transit Gateway Attachment Accepter resources on AWS.
These types of resources are supported:
* [Transit Gateway Attachment Accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter)
## Usage
### Create Transit Gateway Attachment Accepter
`main.tf`
```hcl
module "tgw-attachment-accepter" {
  source = "git@github.com:jangjaelee/terraform-aws-transit-gateway-attachment-accepter.git"

  account_id = var.account_id
  region     = var.region
  prefix     = var.prefix
  tags       = var.tags

  create_tgw_auto_accepter      = var.create_tgw_auto_accepter
  tgw_accepter_name             = var.tgw_accepter_name

  #transit_gateway_attachment_id = var.transit_gateway_attachment_id
  #transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_attachment_id = data.external.this.result.tgw_attachment_id
  
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
}
```

---
`provider.tf`
```hcl
provider  "aws" {
  region  =  var.region
  allowed_account_ids = var.account_id
  #shared_credentials_file = "~/.aws/credentials"
  profile = "default"

  #assume_role {
    #role_arn     = "arn:aws:iam::123456789012:role/test"
    #session_name = "test"
    #external_id  = "EXTERNAL_ID"
  #}
}
```
---

`terraform.tf`
```hcl
terraform {
  required_version = ">= 1.1.3"
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.72"
    }
  }

  backend "s3" {
    bucket = "kubesphere-terraform-state-backend" # S3 bucket 이름 변경(필요 시)
    key = "kubesphere/tgw-attachment-accepter/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "kubesphere-terraform-state-locks" # 다이나모 테이블 이름 변경(필요 시)
    encrypt = true
    profile = "default"
  }
}
```
---

`variables.tf`
```hcl
variable "region" {
  description = "AWS Region"
  type = string
  default = "ap-northeast-2"
}

variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type = list(string)
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type = string
}

variable "tags" {
  description = "tag map"
  type = map(string)
}

variable "create_tgw_auto_accepter" {
  description = "Controls if Transit Gateway Attachment Auto-Accepter should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "tgw_accepter_name" {
  description = "The name of the resource share"
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "The ID of the EC2 Transit Gateway Attachment to manage"
  type        = string
  default     = ""
}

variable "transit_gateway_default_route_table_association" {
  description = "Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table"
  type        = bool
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table"
  type        = bool
}
```
---

`terraform.tfvars`
```hcl
region      = "ap-northeast-2"
account_id  = ["123456789012","098765432109"]
prefix      = "dev"

create_tgw_auto_accepter      = true
tgw_accepter_name             = "jjlee.tgw-aa"
transit_gateway_attachment_id = ""
transit_gateway_default_route_table_association = false
transit_gateway_default_route_table_propagation = false

tags = {
    "CreatedByTerraform" = "true"
    "TerraformModuleName" = "terraform-aws-module-transit-gateway-attachment-accepter"
    "TeffaformModuleVersion" = "v1.0.0"
}
```
---

`outputs.tf`
```hcl
output "tgw_aa_id" {
  value = module.tgw-attachment-accepter.tgw_aa_id
}
output "tgw_aa_vpc_owner_id" {
  value = module.tgw-attachment-accepter.tgw_aa_vpc_owner_id
}
output "tgw_aa_tags_all" {
  value = module.tgw-attachment-accepter.tgw_aa_tags_all
}
```
---

`data.tf`
```hcl
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

/*data "aws_ec2_transit_gateway_vpc_attachment" "this" {
  filter {
    name   = "transit-gateway-attachment-id"
    values = ["tgw-attach-064de268b50a85bef"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-0d1e98f45e57655c5"]
  }

  filter {
    name   = "state"
    values = ["pendingAcceptance","available"]
  }
}*/

data "external" "this" {
  program = ["python3", "${path.module}/tgw-attach-id.py"]

  query = {
      #account = "123456789012"
      account = var.account_id[1]
      state = "pendingAcceptance"
      #state = "available"
      profile = "default"
  }
}
```
---

`tgw-attach-id.py`
```python
#!/usr/bin/env python3
import re
import sys
import argparse
import json
import boto3
from pprint import pprint as pp

def tgw_attachment_id(RESOURCE_OWNER_ID, STATE, AWS_PROFILE):
    session = boto3.session.Session(profile_name=AWS_PROFILE)
    ec2 = session.client('ec2')

    custom_filter = [
        {
            'Name': 'resource-owner-id',
            'Values': RESOURCE_OWNER_ID
        },
        {
            'Name': 'state',
            'Values': STATE
        }
    ]

    """
    custom_filter = [
        {
            'Name':'tag:Name',
            'Values': ['dev.jjlee.tgw-attachment']
        }
    ]
    """

    response = ec2.describe_transit_gateway_attachments(Filters=custom_filter)

    del response['ResponseMetadata']
    ##pp(response)

    for key, value in response.items():
        #print(key)
        #print(value)

        if key == 'TransitGatewayAttachments':
            if value != []:
                res = str(value)[2:][:-2]
                for i in res.split(','):
                    if 'TransitGatewayAttachmentId' in str(i.strip()):
                        res = i.strip().split(':')
                        #print(res[1].strip()[1:][:-1])
                        tgw_attach_id = res[1].strip()[1:][:-1]
            else:
                tgw_attach_id = ""

    return tgw_attach_id


def parsing_argument():
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--account', action='append', dest='account', help='The ID of the Amazon Web Services account that owns the resource', required=True)
    parser.add_argument('-p', '--profile',action='store', dest='profile', help='The name of a profile to use. If not given, then the default profile is used.', required=False)
    parser.add_argument('-s', '--state', action='append', dest='state', help=' The state of the attachment. Valid values are available | deleted | deleting | failed | failing | initiatingRequest | modifying | pendingAcceptance | pending | rollingBack | rejected | rejecting. (Default : pendingAcceptance)', required=False)
    parser.add_argument('--version', action='version', version='v0.1')

    return parser.parse_args()


def json_parsing():
    test_var = dict()

    input = sys.stdin.read()

    try:
        input_json = json.loads(input)

        

        if input_json.get("account"):
            test_var["account"] = input_json.get("account").split(":")

        if input_json.get("state"):
            test_var["state"] = input_json.get("state").split(":")

        if input_json.get("profile"):
            test_var["profile"] = input_json.get("profile").split(":")
    except ValueError as e:
        sys.exit(e)

    return test_var

def main():
    
    """
    # by using argument on CLI
    args = parsing_argument()
    print('{ "tgw_attachment_id" : "%s" }' % tgw_attachment_id(args.account, args.state, args.profile))
    """

    # by using json argument
    args = json_parsing()
    output = {
        "tgw_attachment_id" : tgw_attachment_id(args["account"], args["state"], str(args["profile"]).replace("'","")[1:][:-1])
    }

    output_json = json.dumps(output,indent=2)
    print(output_json)

if __name__ == "__main__":
    main()
```
