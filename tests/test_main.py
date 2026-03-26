"""
Test cases for main application functionality.
"""

from io import StringIO
from unittest import TestCase

from metasp.utils import logging_utils
from metasp.utils.logging_utils import configure_logging, get_logger
from metasp.utils.parser import get_parser


class TestMain(TestCase):
    """
    Test cases for main application functionality.
    """

    def test_logger(self) -> None:
        """
        Test the logger.
        """
        sio = StringIO()
        configure_logging(sio, logging_utils.INFO, True)
        log = get_logger("main")
        log.info("test123")
        self.assertRegex(sio.getvalue(), "test123")
