from functools import lru_cache
from typing import Literal

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # ------------------------------------------------------------------
    # Application
    # ------------------------------------------------------------------

    APP_NAME: str = "Rangos API"
    APP_VERSION: str = "0.1.0"

    APP_ENV: Literal[
        "development",
        "testing",
        "production",
    ] = "development"

    DEBUG: bool = True

    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8080
    API_PREFIX: str = "/api/v1"

    # ------------------------------------------------------------------
    # Database
    # ------------------------------------------------------------------

    DATABASE_URL: str = ""

    # ------------------------------------------------------------------
    # Authentication
    # ------------------------------------------------------------------

    JWT_SECRET_KEY: SecretStr = SecretStr("")
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 dias


    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
