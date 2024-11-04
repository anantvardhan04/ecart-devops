import json


def admin(event, context):
    body = {
        "message": "Welcome admin",
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response
