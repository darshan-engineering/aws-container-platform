from app.core.config import settings


def check_rds():

    if not settings.DB_HOST:
        return {
            "configured": False,
            "status": "not_configured"
        }

    try:
        import pymysql

        conn = pymysql.connect(
            host=settings.DB_HOST,
            port=int(settings.DB_PORT),
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            database=settings.DB_NAME,
            connect_timeout=5
        )

        with conn.cursor() as cur:
            cur.execute("SELECT NOW();")
            result = cur.fetchone()

        conn.close()

        return {
            "configured": True,
            "status": "healthy",
            "database": settings.DB_NAME,
            "host": settings.DB_HOST,
            "timestamp": str(result[0])
        }

    except Exception as e:
        return {
            "configured": True,
            "status": "unhealthy",
            "database": settings.DB_NAME,
            "host": settings.DB_HOST,
            "error": str(e)
        }
