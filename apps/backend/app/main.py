from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.core.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting Rangos API...")
    yield
    print("🛑 Shutting down Rangos API...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=(
        "REST API for the Rangos delivery platform, developed as a case study "
        "in Software Engineering and Quality Assurance."
    ),
    lifespan=lifespan,
)


@app.get("/", include_in_schema=False)
async def root():
    return {
        "message": f"Welcome to {settings.APP_NAME}",
    }


@app.get("/health", tags=["Health"])
async def health():
    return {
        "status": "healthy",
        "version": settings.APP_VERSION,
    }
