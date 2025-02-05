import json
import random
import string
import boto3
import os

# Initialize AWS SQS client
sqs = boto3.client("sqs")

# Get the SQS Queue URL from environment variables
SQS_QUEUE_URL = os.environ.get("SQS_QUEUE_URL")

def generate_tracking_id():
    """Generate a 10-character tracking ID with only alphanumeric characters."""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))

def handler(event, context):
    """
    Lambda handler function for generating a tracking ID based on order number.
    """
    try:
        # Parse the JSON body from the event
        body = json.loads(event.get("body", "{}"))
        order_number = body.get("order_number")
        email = body.get("email")
        username = body.get("username")

        if not order_number:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "order_number is required"})
            }

        # Generate a tracking ID
        tracking_id = f"{order_number}-{generate_tracking_id()}"

        # Construct the message payload
        message_payload = {
            "order_number": order_number,
            "tracking_id": tracking_id,
            "username": username,
            "email": email
        }

        # Send message to SQS queue
        response = sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(message_payload)
        )

        # Return a success response with SQS Message ID
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Order received and sent to SQS",
                "order_number": order_number,
                "tracking_id": tracking_id,
                "username": username,
                "email": email
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
