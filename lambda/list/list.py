import logging
import json
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    print("Received event:", json.dumps(event, indent=4))
    logger.info("Received event: " + json.dumps(event))

    html_content = """
    <html>
    <head>
        <title>Hello World</title>
        <style>
            body { background-color: blue; color: white; text-align: center; padding: 50px; font-size: 24px; }
        </style>
    </head>
    <body>
        <h1>Hello World</h1>
    </body>
    </html>
    """

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": html_content
    }