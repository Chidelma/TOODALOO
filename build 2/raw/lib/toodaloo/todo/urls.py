"""URL configuration for to-do app."""

from django.contrib.auth.decorators import login_required
from django.urls import path

from toodaloo.todo.views import (
    TaskCompleteView,
    TaskCreateView,
    TaskDeleteView,
    TaskListView,
    TaskRestoreView,
    TaskUpdateView,
)


urlpatterns = [
    path(
        "",
        login_required(TaskListView.as_view()),
        name="task-list",
    ),
    path(
        "create",
        login_required(TaskCreateView.as_view()),
        name="task-create",
    ),
    path(
        "<int:pk>/",
        login_required(TaskUpdateView.as_view()),
        name="task-update",
    ),
    path(
        "<int:pk>/delete",
        login_required(TaskDeleteView.as_view()),
        name="task-delete",
    ),
    path(
        "<int:pk>/complete",
        login_required(TaskCompleteView.as_view()),
        name="task-complete",
    ),
    path(
        "<int:pk>/restore",
        login_required(TaskRestoreView.as_view()),
        name="task-restore",
    ),
]
