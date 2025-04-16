# AWS Lambda + API Gateway Deployment with Terraform

This repository demonstrates how to deploy a serverless REST API using **AWS Lambda**, **API Gateway**, and **Terraform**.

✅ **Highlights:**
- Infrastructure as Code (IaC) with Terraform.
- Clean separation of environments (`dev`, `prod`).
- Python-based Lambda function.
- Automated IAM role and policy creation.
- Supports both **GET** and **POST** requests.
- Environment-aware API responses for easy debugging and monitoring.

---

## 🏗️ Architecture

![aws_api_gateway drawio](https://github.com/user-attachments/assets/c8376a62-bb49-4233-8216-a43e6cde14cd)


---

## 💡 Features

- **Modular Terraform Structure:**  
  - `modules/serverless_api` contains reusable Terraform code.
  - `environments/dev` & `environments/prod` control deployments for different stages.

- **Environment Variables:**  
  - Lambda dynamically knows which environment it is deployed in (`dev`, `prod`) and includes it in its responses.

- **Clean API Methods:**
  - `GET /gwapiaws` - For reading data.
  - `POST /gwapiaws` - For sending data.

