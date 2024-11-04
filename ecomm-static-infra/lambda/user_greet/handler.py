import json
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def user(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.info('## EVENT')
    logger.info(event)
    print(event)
    body = {
        "message": "Welcome Normal user message",
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response

