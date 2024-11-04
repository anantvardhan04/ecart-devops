try:
    import unzip_requirements
except ImportError:
    pass
import json
import logging
import os
import time
import urllib.request

from jose import jwk, jwt
from jose.utils import base64url_decode

logger = logging.getLogger()
logger.setLevel(logging.INFO)
os.environ['AWS_REGION_NAME'] = "ap-southeast-1"
os.environ['USER_POOL_ID'] = "ap-southeast-1_4IxEh7pCt"
os.environ['APP_CLIENT_ID'] = "7nraq3g2jjc1upeav51j96gbcg"
try:
    region = os.environ['AWS_REGION_NAME']
    userpool_id = os.environ['USER_POOL_ID']
    app_client_id = os.environ['APP_CLIENT_ID']
    keys_url = 'https://cognito-idp.{}.amazonaws.com/{}/.well-known/jwks.json'.format(region, userpool_id)
    # instead of re-downloading the public keys every time
    # we download them only on cold start
    # https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/
    with urllib.request.urlopen(keys_url) as f:
        response = f.read()
    keys = json.loads(response.decode('utf-8'))['keys']

except Exception as e:
    logging.error(e)
    raise ("Unable to download JWKS")


def check_ip(IP_ADDRESS, IP_RANGE):
    VALID_IP = False
    cidr_blocks = list(filter(lambda element: "/" in element, IP_RANGE))
    if cidr_blocks:
        for cidr in cidr_blocks:
            net = ip_network(cidr)
            VALID_IP = ip_address(IP_ADDRESS) in net
            if VALID_IP:
                break
    if not VALID_IP and IP_ADDRESS in IP_RANGE:
        VALID_IP = True

    return VALID_IP


def generateAuthPolicy(principalId, resource, effect):
    authResponse = {}
    authResponse["principalId"] = principalId
    if effect and resource:
        policyDocument = {}
        policyDocument["Version"] = '2012-10-17'
        policyDocument["Statement"] = []
        statementOne = {}
        statementOne["Action"] = 'execute-api:Invoke'
        statementOne["Effect"] = effect
        statementOne["Resource"] = resource
        policyDocument["Statement"].append(statementOne)
        authResponse["policyDocument"] = policyDocument
    return authResponse


def verify_token(token):
    # get the kid from the headers prior to verification
    headers = jwt.get_unverified_header(token)
    kid = headers['kid']
    # search for the kid in the downloaded public keys
    key_index = -1
    for i in range(len(keys)):
        if kid == keys[i]['kid']:
            key_index = i
            break
    if key_index == -1:
        logger.info("Public key not found in jwks.json")
        return False
    # construct the public key
    public_key = jwk.construct(keys[key_index])
    # get the last two sections of the token,
    # message and signature (encoded in base64)
    message, encoded_signature = str(token).rsplit('.', 1)
    # decode the signature
    decoded_signature = base64url_decode(encoded_signature.encode('utf-8'))
    # verify the signature
    if not public_key.verify(message.encode("utf8"), decoded_signature):
        logger.info("Signature verification failed")
        return False
    logger.info("Signature successfully verified")
    # since we passed the verification, we can now safely
    # use the unverified claims
    claims = jwt.get_unverified_claims(token)
    # additionally we can verify the token expiration
    if time.time() > claims['exp']:
        logger.info("Token is expired")
        return False
    # and the Audience  (use claims['client_id'] if verifying an access token)
    logger.info(f"data is {claims}")
    if False and claims['client_id'] != app_client_id:
        logger.info("Token was not issued for this audience")
        return False
    # now we can use the claims
    return claims


userAcl = {
    "user": {
        'principalId': 'user',
        'policyDocument': {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": 'execute-api:Invoke',
                    "Effect": 'Allow',
                    "Resource": "arn:aws:execute-api:*:*:*/*"
                },
                {
                    "Action": 'execute-api:Invoke',
                    "Effect": 'Deny',
                    "Resource": [
                        "arn:aws:execute-api:*:*:*/*/*/admin/*",

                    ]
                }

            ]
        }
    },
    "admin": {
        'principalId': 'admin',
        'policyDocument': {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": 'execute-api:Invoke',
                    "Effect": 'Allow',
                    "Resource": "arn:aws:execute-api:*:*:*/*"
                },
                {
                    "Action": 'execute-api:Invoke',
                    "Effect": 'Deny',
                    "Resource": [
                        "arn:aws:execute-api:*:*:*/*/*/user/*",

                    ]
                }

            ]
        }
    }
}


def policy_statements(principalId, methodArnSegments, userAcl):
    meta_data = {}
    statements = []
    auth_response = {}
    policy_document = {
        "Version": "2012-10-17"
    }
    auth_response["principalId"] = principalId
    for acl in userAcl:
        resource = ""
        id = ""
        resourceArn = "/".join([
            methodArnSegments[0],
            resource,
            '*',
            id
        ])
        policy = {
            "Action": 'execute-api:Invoke',
            "Effect": 'Allow',
            "Resource": resourceArn
        }

        statements.append(policy)

    if True:
        policy = {
            "Action": 'execute-api:Invoke',
            "Effect": 'Deny',
            "Resource": "/".join(methodArnSegments)
        }
        statements.append(policy)

    policy_document["Statement"] = statements
    auth_response["policyDocument"] = policy_document
    auth_response["context"] = meta_data
    return auth_response


def main(event, context):
    response = {}

    try:
        logger.info(f"event information is {json.dumps(event)}")
        headers = event['headers']
        principalId = "user"
        if True or verify_token(headers["authorization"]):
            logger.info("policy is allowed")
            route_arn = event['routeArn']
            methodArnSegments = route_arn.split('/')
            apiStage = methodArnSegments[1]
            apiVerb = methodArnSegments[2].upper()
            apiResource = methodArnSegments[3]
            logger.info(f"methodArnSegments:{methodArnSegments}")
            logger.info(f"apiStage: {apiStage}")
            logger.info(f"apiVerb: {apiVerb}")
            logger.info(f"apiResource: {apiResource}")
            response = userAcl[principalId]
            # print(policy_statements(principalId, methodArnSegments, userAcl))
            #
            # response = generateAuthPolicy(principalId, event['routeArn'], "Allow")
        else:
            logger.info("policy is not allowed")
            response = generateAuthPolicy(principalId, event['routeArn'], "Deny")

    except Exception as e:
        logger.error(e)

    finally:
        print(response)
        return response

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
