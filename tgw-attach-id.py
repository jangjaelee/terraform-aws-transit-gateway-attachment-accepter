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
