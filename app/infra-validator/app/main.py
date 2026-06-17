from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from app.api.routes import router

app = FastAPI(
title="Infrastructure Validator",
version="1.0.0"
)

app.include_router(router)

templates = Jinja2Templates(directory="app/templates")

app.mount("/static", StaticFiles(directory="app/templates"), name="static")
