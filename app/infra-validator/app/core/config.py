import os

class Settings:
    APP_NAME = os.getenv("APP_NAME", "Infrastructure Validator")
    APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
    AWS_REGION = os.getenv("AWS_REGION", "ap-south-1")

    # RDS
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME", "mydb")
    DB_USER = os.getenv("DB_USER", "myuser")
    DB_PASSWORD = os.getenv("DB_PASSWORD")

    # DynamoDB
    DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")

    # # S3
    # S3_BUCKET = os.getenv("S3_BUCKET")

    # # EFS
    # EFS_MOUNT_PATH = os.getenv("EFS_MOUNT_PATH", "/data")

settings = Settings()
