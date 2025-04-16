#Create iam role for lambda function
resource "aws_iam_role" "lambda_role" {
    name = "${var.environment}_api_lambda_exec_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = { Service = "lambda.amazonaws.com"}
            }
        ]
    })  
}

#Attach basic execution policy (cloud watch log permission) to lambda role
resource "aws_iam_role_policy_attachment" "lambda_log_policy" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Zip lambda code
resource "archive_file" "zip_lambda" {
  type = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

#Creation of lambda
resource "aws_lambda_function" "api_lambda_function" {
    function_name = "${var.environment}_serverless_api"
    role = aws_iam_role.lambda_role.arn
    handler = "lambda_function.lambda_handler"
    filename = archive_file.zip_lambda.output_path
    runtime = "python3.8"
    environment {
      variables = {
        ENV = var.environment
      }
    }
}

#Create rest api
resource "aws_api_gateway_rest_api" "api" {
    name = "${var.environment}_serverless_api"  
}

resource "aws_api_gateway_resource" "api_resource" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    parent_id = aws_api_gateway_rest_api.api.root_resource_id
    path_part = "gwapiaws"
}

#Create Method for GET
resource "aws_api_gateway_method" "get_method" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = "GET"
    authorization = "NONE"
}

#Create Method for POST
resource "aws_api_gateway_method" "post_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = "POST"
  authorization = "NONE"
}

#Set integration to invoke lambda from api gateway for get method
resource "aws_api_gateway_integration" "post_method_integration" {
    resource_id = aws_api_gateway_resource.api_resource.id
    rest_api_id = aws_api_gateway_rest_api.api.id
    http_method = aws_api_gateway_method.post_method.http_method
    type = "AWS_PROXY"
    integration_http_method = "POST"
    uri = aws_lambda_function.api_lambda_function.invoke_arn 
}

#Set integration to invoke lambda from api gateway for post method
resource "aws_api_gateway_integration" "get_method_integration" {
    resource_id = aws_api_gateway_resource.api_resource.id
    rest_api_id = aws_api_gateway_rest_api.api.id
    http_method = aws_api_gateway_method.get_method.http_method
    type = "AWS_PROXY"
    integration_http_method = "POST"
    uri = aws_lambda_function.api_lambda_function.invoke_arn  
}

#Add deployment
resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on = [ aws_api_gateway_integration.get_method_integration,  aws_api_gateway_integration.post_method_integration ]

}
#Add stage for deployment
resource "aws_api_gateway_stage" "deploy_stage" {
  stage_name = "${var.environment}"
  rest_api_id = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}


#Set lambda permission to allow api requests from gateway
resource "aws_lambda_permission" "lambda_gw_permission" {
    statement_id = "AllowRestAPIRequests"
    function_name = aws_lambda_function.api_lambda_function.function_name
    action = "lambda:InvokeFunction"
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
