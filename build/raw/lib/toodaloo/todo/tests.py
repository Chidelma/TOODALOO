from django.test import TestCase


class SimpleTestCase(TestCase):
    """Perform some simple tests."""

    def test_add(self):
        """Add two numbers."""
        self.assertEqual(1 + 1, 2)

    def test_subtract(self):
        """Subtract two numbers."""
        self.assertEqual(1 - 1, 0)
