import json
import re
import sys
import os
import boto3
from unittest.mock import patch 
import pytest

sys.path.append("lambda/")  
from handler import handler

AWS_REGION = os.environ.get("AWS_REGION", "us-central-1")
SQS_QUEUE_NAME = os.environ.get("SQS_QUEUE_NAME", "queue-test")

@pytest.fixture(scope="function")
def mock_sqs_client():
    """Mock AWS SQS Client"""
    with patch("boto3.client") as mock_boto:
        mock_sqs = mock_boto.return_value
        mock_sqs.send_message.return_value = {"MessageId": "12345"}
        os.environ["SQS_QUEUE_URL"] = "https://sqs.eu-central-1.amazonaws.com/600210043783/serverless-tracking-queue.fifo"
        yield mock_sqs

def test_lambda_handler_success(mock_sqs_client):
    """
    Test a successful request.
    """
    order_number = "ORDER123"
    email = "test@gmail.com"
    username = "testo"

    event = {
        "body": json.dumps({"order_number": order_number, "email": email, "username": username})  
    }
    context = {}

    response = handler(event, context)

    assert response["statusCode"] == 200  
    body = json.loads(response["body"])
    assert "tracking_id" in body  
    assert "email" in body  
    assert "username" in body  
    
    tracking_id = body["tracking_id"]
    assert tracking_id.startswith(order_number)  
    assert len(tracking_id.split("-")) == 2  
    generated_tracking_part = tracking_id.split("-")[1]

    assert len(generated_tracking_part) == 10  
    assert re.match(r'^[A-Z0-9]+$', generated_tracking_part)  