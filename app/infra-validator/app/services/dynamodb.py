import boto3

from app.core.config import settings

def check_dynamodb():
    if not settings.DYNAMODB_TABLE:
        return {
            "configured": False,
            "status": "not_configured"
        }

    try:
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table(
            settings.DYNAMODB_TABLE
        )
        table.load()
        return {
            "configured": True,
            "status": "healthy",
            "table": settings.DYNAMODB_TABLE
        }

    except Exception as e:
        return {
            "configured": True,
            "status": "unhealthy",
            "error": str(e)
        }
