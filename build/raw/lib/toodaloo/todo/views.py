from django.db.models import F
from django.urls import reverse_lazy
from django.utils import timezone
from django.views.generic import CreateView, DeleteView, ListView, UpdateView

from toodaloo.todo.models import Task


class TaskListView(ListView):
    """View a list of tasks for a user."""

    def get_queryset(self):
        """Filter by tasks that are not completed."""
        return Task.objects.filter(owner=self.request.user, completed=None).order_by(
            F("due").asc(nulls_last=True)
        )

    def get_context_data(self, *, object_list=None, **kwargs):
        """Add list of completed tasks to context data."""
        context = super().get_context_data(**kwargs)
        context["completed"] = (
            Task.objects.filter(owner=self.request.user)
            .exclude(completed=None)
            .order_by("-completed")
        )
        return context


class TaskCreateView(CreateView):
    """Create a task."""

    model = Task
    fields = [
        "title",
        "notes",
        "due",
    ]
    template_name_suffix = "_create_form"

    def form_valid(self, form):
        """Set the task owner to current user."""
        form.instance.owner = self.request.user
        return super().form_valid(form)


class TaskUpdateView(UpdateView):
    """Update details for a task."""

    model = Task
    fields = [
        "title",
        "notes",
        "due",
    ]
    template_name_suffix = "_update_form"

    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)


class TaskDeleteView(DeleteView):
    """Delete a task."""

    model = Task
    success_url = reverse_lazy("task-list")

    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)


class TaskCompleteView(UpdateView):
    """Complete a task."""

    model = Task
    fields = ["completed"]
    template_name_suffix = "_complete_form"

    def form_valid(self, form):
        """Set the complete time to now."""
        form.instance.completed = timezone.now()
        return super().form_valid(form)

    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)


class TaskRestoreView(UpdateView):
    """Restore a completed task."""

    model = Task
    fields = ["completed"]
    template_name_suffix = "_restore_form"

    def form_valid(self, form):
        """Set the complete time to None."""
        form.instance.completed = None
        return super().form_valid(form)

    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)
