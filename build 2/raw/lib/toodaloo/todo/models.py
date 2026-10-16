from django.conf import settings
from django.db import models
from django.urls import reverse


class Task(models.Model):
    """A to-do task."""

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        help_text="User that owns the task.",
    )
    title = models.CharField(
        max_length=1024,
        help_text="A title for the task.",
    )
    notes = models.TextField(
        null=True,
        blank=True,
        help_text="Additional notes for the task.",
    )
    due = models.DateTimeField(
        null=True,
        blank=True,
        db_index=True,
        help_text="Date and time the task must be completed by. E.g.: 2024-10-20 17:00:00",
    )
    completed = models.DateTimeField(
        null=True,
        blank=True,
        db_index=True,
        help_text="Date and time the task was marked as completed.",
    )
    created = models.DateTimeField(
        auto_now_add=True,
        help_text="Date and time the task was created.",
    )

    class Meta:
        verbose_name = "Task"
        verbose_name_plural = "Tasks"

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse("task-list")
