import json
import random
import string

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

        if not order_number:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "order_number is required"})
            }

        # Generate a tracking ID
        tracking_id = f"{order_number}-{generate_tracking_id()}"

        response = {
            "statusCode": 200,
            "body": json.dumps({"tracking_id": tracking_id})
        }

        return response

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
