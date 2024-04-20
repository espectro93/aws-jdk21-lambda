provider "aws" {
  region = "eu-central-1"
}

locals {
  lambda_payload_file = "${path.module}/../build/libs/awsjdk21lambda-0.0.1-SNAPSHOT-aws.jar"
}

# IAM Roles and Policies
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "basic_lambda_exec" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "logging" {
  name   = "logging"
  policy = data.aws_iam_policy.basic_lambda_exec.policy
}

resource "aws_iam_role_policy_attachment" "logging" {
  policy_arn = aws_iam_policy.logging.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# Lambda Function and Packaging
resource "aws_s3_bucket" "bucket" {
  bucket = "test-jar-2"
}

resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.bucket.id
  key    = "test-lambda"
  source = local.lambda_payload_file
  etag   = filesha256(local.lambda_payload_file)
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "aws_jdk21_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"

  s3_bucket         = aws_s3_bucket.bucket.id
  s3_key            = aws_s3_object.lambda_jar.key
  s3_object_version = aws_s3_object.lambda_jar.version_id

  runtime = "java21"
  environment {
    variables = {
      FUNCTION_NAME = "obfuscate"
    }
  }

  lifecycle {
    replace_triggered_by = [
      aws_s3_object.lambda_jar.version_id
    ]
  }
}

resource "aws_lambda_permission" "sqs" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "sqs.amazonaws.com"
}
