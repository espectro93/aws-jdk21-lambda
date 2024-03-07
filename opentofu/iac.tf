provider "aws" {
  region = "eu-central-1"
}

locals {
  lambda_payload_filename = "./build/awsjdk21lambda-0.0.1-SNAPSHOT.jar"
}

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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "messaging" {
  policy_arn = aws_iam_policy.sqs.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_policy" "sqs" {
  name = "sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:*"]
    effect  = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "logging" {
  policy_arn = aws_iam_policy.logging.arn
  role       = aws_iam_role.iam_for_lambda.arn
}

resource "aws_iam_policy" "logging" {
  name = "logging"
  policy = data.aws_iam_policy_document.logging.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    actions = ["logs:*"]
    effect  = "Allow"

    resources = ["*"]
  }
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.jar"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "aws_jdk21_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "java21"
}

resource "aws_lambda_permission" "sqs" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "sqs.amazonaws.com"
}