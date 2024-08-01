from django.contrib import admin

from toodaloo.todo.models import Task


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    """Manage the task models."""

    list_display = [
        "id",
        "owner",
        "title",
        "due",
        "completed",
    ]
    list_display_links = [
        "id",
        "title",
    ]
