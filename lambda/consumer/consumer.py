import boto3
import json
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
sqs = boto3.client("sqs")
sns = boto3.client("sns")

# Retrieve SNS Topic ARN from environment variables
SNS_TOPIC_ARN = os.getenv("SNS_TOPIC_ARN")

# AWS Lambda handler function triggered by SQS
def handler(event, context):
    """
    AWS Lambda function triggered by SQS event. 
    Processes incoming messages, sends email via SNS, and deletes messages from SQS.
    """
    print("Received event:", json.dumps(event, indent=4))
    logger.info("Received event: " + json.dumps(event))
    
    if "Records" not in event:
        print("No records found in event")
        return

    for record in event["Records"]:
        try:
            # Parse message body
            message_body = json.loads(record["body"])
            print(f"Processing message: {message_body}")

            order_number = message_body.get("order_number")
            tracking_id = message_body.get("tracking_id")
            email = message_body.get("email")
            username = message_body.get("username")

            if not order_number or not tracking_id or not email or not username:
                print("Invalid message format, skipping...")
                continue

            # Send email notification via SNS
            send_sns_email(email, order_number, tracking_id, username)

            # Delete message from SQS (optional: AWS automatically removes messages after Lambda executes)
            delete_sqs_message(record["receiptHandle"])

        except Exception as e:
            print(f"Error processing message: {e}")

# Function to send email notification via SNS
def send_sns_email(email, order_number, tracking_id, username):
    """
    Sends an email notification via AWS SNS.
    """
    subject = f"Tracking Update for Order {order_number}"
    message = f"Dear {username},\n\nYour order {order_number} has been updated.\nTracking ID: {tracking_id}\n\nBest regards,\nShipping Team"

    response = sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=message,
        Subject=subject
    )
    print(f"Email sent to {email}: Message ID {response['MessageId']}")

# Function to delete processed messages from SQS
def delete_sqs_message(receipt_handle):
    """
    Deletes a message from the SQS queue after processing.
    """
    print("Message successfully processed, removing from queue...")
    sqs.delete_message(QueueUrl=os.getenv("SQS_QUEUE_URL"), ReceiptHandle=receipt_handle)