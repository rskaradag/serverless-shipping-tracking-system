import json
import re
import sys
sys.path.append("lambda/")  
from handler import handler

def test_lambda_handler_success():
    """
    Test a successful request.
    """
    order_number = "ORDER123"
    event = {
        "body": json.dumps({"order_number": order_number})
    }
    context = {}

    response = handler(event, context)

    assert response["statusCode"] == 200  # Should return 200
    body = json.loads(response["body"])
    assert "tracking_id" in body  # tracking_id should be in response
    
    tracking_id = body["tracking_id"]
    assert tracking_id.startswith(order_number)  # tracking_id should start with order_number
    assert len(tracking_id.split("-")) == 2  # Ensure correct format
    generated_tracking_part = tracking_id.split("-")[1]

    assert len(generated_tracking_part) == 10  # Ensure tracking ID is exactly 10 characters
    assert re.match(r'^[A-Z0-9]+$', generated_tracking_part)  # Ensure it contains only alphanumeric characters

def test_lambda_handler_missing_order_number():
    """
    Test a request with missing `order_number`, which should return a 400 error.
    """
    event = {
        "body": json.dumps({})  # `order_number` is missing
    }
    context = {}

    response = handler(event, context)

    assert response["statusCode"] == 400  # Should return 400
    body = json.loads(response["body"])
    assert "error" in body
    assert body["error"] == "order_number is required"

def test_lambda_handler_invalid_json():
    """
    Test a request with an invalid JSON body, expecting a 500 error.
    """
    event = {
        "body": "{invalid_json}"  # Invalid JSON format
    }
    context = {}

    response = handler(event, context)

    assert response["statusCode"] == 500  # Should return 500
    body = json.loads(response["body"])
    assert "error" in body
