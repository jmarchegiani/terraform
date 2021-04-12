provider "aws" {
  region     = var.region_name
  access_key = ""
  secret_key = ""
}

variable "bucket_app_name" {
  default = ""
}

variable "region_name" {
  default = "eu-west-3"
}

resource "aws_iam_role_policy" "thumbnails-role-policy" {
  name = "thumbnails-role-policy"
  role = aws_iam_role.thumbnailerRole.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListAllMyBuckets",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }

    ]
})
}

resource "aws_iam_role" "thumbnailerRole" {
  name = "thumbnailerRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


}

resource "aws_lambda_function" "PDFAndImagesThumbnailer" {
  function_name = "PDFAndImagesThumbnailer"
  role          = aws_iam_role.thumbnailerRole.arn
  handler       = "lambda_function.lambda_handler"
  s3_bucket     = "thumbnail.lambda.code"
  s3_key        = "thumbnailer-app.zip"

  depends_on    = [
      aws_cloudwatch_log_group.thumbnailerLogsGroup
  ]

  runtime = "python3.8"
  timeout = 25

  layers = [
    "arn:aws:lambda:${var.region_name}:770693421928:layer:Klayers-python38-Pillow:9",
    "arn:aws:lambda:${var.region_name}:770693421928:layer:Klayers-python38-PyMUPDF:25"
  ]
}

variable "lambda_function_name" {
  default = "PDFAndImagesThumbnailer"
}

resource "aws_cloudwatch_log_group" "thumbnailerLogsGroup" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.PDFAndImagesThumbnailer.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.thumbnailerBucket.arn
}

resource "aws_s3_bucket" "thumbnailerBucket" {
  bucket = var.bucket_app_name
}

resource "aws_s3_bucket_notification" "thumbnailerNotification" {
  bucket = aws_s3_bucket.thumbnailerBucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.PDFAndImagesThumbnailer.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}