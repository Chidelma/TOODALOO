"""
Production Django settings for toodaloo project.

For more information on this file, see
https://docs.djangoproject.com/en/5.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.0/ref/settings/
"""

import os


# Database
# https://docs.djangoproject.com/en/5.0/ref/settings/#databases

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.getenv("TOODALOO_DB_NAME", "toodaloo"),
        "USER": os.getenv("TOODALOO_DB_USER", "toodaloo"),
        "PASSWORD": os.getenv("TOODALOO_DB_PASSWORD", "toodaloo"),
        "HOST": os.getenv("TOODALOO_DB_HOST", "127.0.0.1"),
        "PORT": os.getenv("TOODALOO_DB_PORT", "10016"),
        "OPTIONS": {
            "client_encoding": "UTF8",
        },
    }
}

# Caching
# https://docs.djangoproject.com/en/5.0/ref/settings/#caches

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": os.getenv("TOODALOO_REDIS_URL", "redis://127.0.0.1:6379"),
        "KEY_PREFIX": "toodaloo",
    }
}
