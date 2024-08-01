import zoneinfo

from django.contrib.auth.decorators import login_required
from django.core.cache import cache
from django.shortcuts import redirect
from django.utils import timezone


class TimezoneMiddleware:
    """Allow setting timezone."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        tzname = request.session.get("django_timezone")
        if not tzname and request.user:
            # Try to pull a timezone value from the cache.
            tzname = cache.get(f"{request.user.username}:timezone")
            if tzname:
                request.session["django_timezone"] = tzname
        if tzname:
            timezone.activate(zoneinfo.ZoneInfo(tzname))
        else:
            timezone.deactivate()
        return self.get_response(request)


@login_required()
def set_timezone(request):
    """Handle timezone change."""
    if request.method == "POST":
        tzname = request.POST["timezone"]
        request.session["django_timezone"] = tzname
        cache.set(f"{request.user.username}:timezone", tzname)
    if "path" in request.POST:
        return redirect(request.POST["path"])
    return redirect("/")
