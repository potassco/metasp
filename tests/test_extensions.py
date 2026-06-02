"""
Test cases for main application functionality.
"""

import os
from unittest import TestCase

from metasp.utils.test import run_tests


class TestAvailableSystems(TestCase):
    """
    Test cases for main application functionality.
    """

    def test_provided_systems(self) -> None:
        example_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), f"../"))
        status = run_tests([], current_path=example_dir)
        self.assertEqual(status, 0, msg="Test failed")
