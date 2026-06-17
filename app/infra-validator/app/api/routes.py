from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from app.core.config import settings
from app.core.metadata import get_ecs_metadata

from app.services.health import get_health_status
from app.services.rds import check_rds
from app.services.dynamodb import check_dynamodb

router = APIRouter()

templates = Jinja2Templates(
directory="app/templates"
)

@router.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):

    metadata = get_ecs_metadata()

    context = {
        "request": request,
        "app_name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "region": settings.AWS_REGION,
        "metadata": metadata,
        "health": get_health_status()
    }

    return templates.TemplateResponse(
        "index.html",
        context
    )


@router.get("/health")
async def health():
    return get_health_status()

@router.get("/info")
async def info():

    return {
        "application": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "region": settings.AWS_REGION,
        "ecs": get_ecs_metadata()
    }


@router.get("/debug")
async def debug():


    return {
        "metadata": get_ecs_metadata(),
        "rds": check_rds(),
        "dynamodb": check_dynamodb(),
    }


@router.get("/db")
async def db():
    return check_rds()

@router.get("/dynamodb")
async def dynamodb():
    return check_dynamodb()
