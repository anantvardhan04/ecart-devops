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
# os.environ['AWS_REGION_NAME'] = "ap-southeast-1"
# os.environ['USER_POOL_ID'] = ""
# os.environ['APP_CLIENT_ID'] = ""
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
    # logger.error(f"key url is {keys_url}")
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


def verify_jwt_token(token):
    try:
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
            logger.error("Token is expired")
            return False
        # and the Audience  (use claims['client_id'] if verifying an access token)
        logger.info(f"data is {claims}")
        if claims['client_id'] != app_client_id:
            logger.error("Token was not issued for this audience")
            return False
        # now we can use the claims
        return claims
    except Exception as error:
        logger.error(f"some  error in jwt function and error is {error}")
        return False


def get_policy_acl():
    with open("policy.json") as f:
        data = json.load(f)
    return data

def main(event, context):
    response = {}
    try:
        logger.info(f"event information is {json.dumps(event)}")
        headers = event['headers']
        jwt_data = verify_jwt_token(headers["authorization"])
        principal_id = ""
        if jwt_data:
            logger.info(jwt_data)
            principal_id = jwt_data['cognito:groups'][0]
            logger.info(f"policy is allowed and principal id is {principal_id}")
            route_arn = event['routeArn']
            method_arn_segments = route_arn.split('/')
            api_stage = method_arn_segments[1]
            api_verb = method_arn_segments[2].upper()
            api_resource = method_arn_segments[3]
            logger.info(f"methodArnSegments:{method_arn_segments}")
            logger.info(f"apiStage: {api_stage}")
            logger.info(f"apiVerb: {api_verb}")
            logger.info(f"apiResource: {api_resource}")
            user_acl = get_policy_acl()
            logger.info(f"user policy is {user_acl}")
            response = user_acl.get(principal_id)
        else:
            logger.info("policy is not allowed")
            response = generateAuthPolicy(principal_id, event['routeArn'], "Deny")

    except Exception as e:
        logger.error(e)

    finally:
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
