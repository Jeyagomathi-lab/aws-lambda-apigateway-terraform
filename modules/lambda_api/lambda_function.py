import json
import os
def lambda_handler(event,context):
    http_method = event.get('httpMethod', 'NA')
    env_var = os.getenv('ENV', 'NA')
    if http_method == "GET":
        try:
            response = {
                "statusCode": "200",
                "body": json.dumps({"message": f"Hello from aws gateway!!! you have triggered GET method from {env_var} environment"})        
                }
        except Exception as ex:
            response = {
                "statusCode": "405",
                "body": json.dumps({"Error": str(ex) })        
                }           
    elif http_method == "POST":
        try:
            bodyContent = json.loads(event.get('body', {}))
            name = bodyContent.get('Name', 'NoName')
            response = {
                "statusCode": "200",
                "body": json.dumps({"message": f"Hello {name}!! Welcome from {env_var} environment"})
            }
        except Exception as e:
            response = {
                "statusCode": "400",
                "body": json.dumps({"error": str(e), "message": "Error in POST request"})
                
            }
    else:
        response = {
            "statusCode": "405",
            "body": json.dumps({"message": f"${http_method} is not valid for this request"})
        }
    return response
