# Serverless Shipping Tracking System

This project implements a **serverless shipping tracking system** using AWS services and Terraform. It provides an API to create and track shipments, leveraging AWS Lambda, API Gateway, DynamoDB, and S3.

## Architecture

The system comprises the following components:

- **API Gateway**: Manages HTTP requests for creating and retrieving shipment tracking information.
- **AWS Lambda Functions**: Handle business logic for creating shipments and retrieving tracking details.
- **DynamoDB**: Serves as the primary database to store shipment information.
- **S3**: Stores static assets or logs as needed.

## Prerequisites

Before deploying the system, ensure you have:

- An AWS account with appropriate permissions.
- [Terraform](https://www.terraform.io/downloads.html) installed.
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured.


