from app.services.rds import check_rds
from app.services.dynamodb import check_dynamodb

def get_health_status():

    return {
        "status": "healthy",
        "rds": check_rds(),
        "dynamodb": check_dynamodb(),
    }
