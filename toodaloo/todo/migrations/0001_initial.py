import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Task",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "title",
                    models.CharField(
                        help_text="A title for the task.", max_length=1024
                    ),
                ),
                (
                    "notes",
                    models.TextField(
                        blank=True,
                        help_text="Additional notes for the task.",
                        null=True,
                    ),
                ),
                (
                    "due",
                    models.DateTimeField(
                        blank=True,
                        db_index=True,
                        help_text="Date and time the task must be completed by. E.g.: 2024-10-20 17:00:00",
                        null=True,
                    ),
                ),
                (
                    "completed",
                    models.DateTimeField(
                        blank=True,
                        db_index=True,
                        help_text="Date and time the task was marked as completed.",
                        null=True,
                    ),
                ),
                (
                    "created",
                    models.DateTimeField(
                        auto_now_add=True,
                        help_text="Date and time the task was created.",
                    ),
                ),
                (
                    "owner",
                    models.ForeignKey(
                        help_text="User that owns the task.",
                        on_delete=django.db.models.deletion.CASCADE,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "verbose_name": "Task",
                "verbose_name_plural": "Tasks",
            },
        ),
    ]
