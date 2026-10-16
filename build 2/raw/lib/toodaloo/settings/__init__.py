"""Load the appropriate settings."""

import os

from toodaloo.settings.base import *  # noqa: F403


if os.getenv("PRODUCTION", "").lower() == "true":
    from toodaloo.settings.production import *  # noqa: F403
