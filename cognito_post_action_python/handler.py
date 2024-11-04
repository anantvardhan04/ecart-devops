import json
import boto3
import logging
import os
logger = logging.getLogger()
logger.setLevel(logging.INFO)
region = os.environ['AWS_REGION_NAME']
poolId = os.environ['USER_POOL_ID']

client = boto3.client('cognito-idp', region_name=region)


def main(event, context):
    logger.info(f"event information is {json.dumps(event)}")
    email = event['request']['userAttributes']['email']
    group = 'user'

    response = client.admin_add_user_to_group(UserPoolId=poolId, Username=email, GroupName=group)

    return event

# if __name__ == "__main__":
#     event = {
#         "RequestType": "Create",
#         "ResponseURL": "",
#         "headers": {
#             "authorization": "eyJraWQiOiIyQSsyalRybmp6TFVDNEJ2a2NqcmxNR0pZdlpsTm5DXC9KS2VTdElRTUNlTT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3YzFiMDY1MS04MWQ0LTRjYjgtODY1Ny1iMjczOGJlNDI4MGIiLCJjb2duaXRvOmdyb3VwcyI6WyJ1c2VyIl0sImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5hcC1zb3V0aGVhc3QtMS5hbWF6b25hd3MuY29tXC9hcC1zb3V0aGVhc3QtMV80SXhFaDdwQ3QiLCJjbGllbnRfaWQiOiI3bnJhcTNnMmpqYzF1cGVhdjUxajk2Z2JjZyIsIm9yaWdpbl9qdGkiOiI4YWNmNWNmMC1jMjQxLTRiYzUtODExNC0yMzkwNzYzOTllY2MiLCJldmVudF9pZCI6IjY5NzRjZGY4LTlhNzAtNDNhNi1hZjc0LWYxNzQ4Y2JlYzEzNiIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE2Nzc1MDI5MjMsImV4cCI6MTY3NzUwNjUyMywiaWF0IjoxNjc3NTAyOTIzLCJqdGkiOiI0MTJmZWM1OC1lY2VlLTQ5ZGUtODJkZC1jOTQwYzUyZDNiMzMiLCJ1c2VybmFtZSI6IjdjMWIwNjUxLTgxZDQtNGNiOC04NjU3LWIyNzM4YmU0MjgwYiJ9.LIuH5wfW37D2M0fvJCN6TB4agxmCvLO3SX_Iaa_IO-AzInlczsFS8KOtA9cc-bhybnWnCbggNw6QFaFmzk6CtklxIxf-PVADK8sOR-pVDdYGNLhivg0sFqIVjCWA4ZMsoIi84sWulHagpREi800RltK0PYzrhIzIXL9BMaTQowGTgxQbptk98COYOj1x9v5QXCKO8BSEsY1hEBA5Oeet6Ba8jeW22G3x8FEW9rQOV4FWjq52le2_Ns8o7jhm5UpD_lBiu13zXtam4OXwgU_nsyZ3WPFTpZBvDppcwOzzKhXnod-gAVLPyAgJ2zO7fuwSh25ssN9giUWbNEWmqQmmFQ",
#
#         },
#         "routeArn": "arn:aws:execute-api:ap-southeast-1:730736917320:z6vng5vdl2/dev/GET/user"
#     }
#     context = {}
#
#     # Note: This will error because of cfnresponse.send() not having a context "log_stream_name".
#
#     print(main(event, context))