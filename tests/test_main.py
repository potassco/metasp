"""
Test cases for main application functionality.
"""

from io import StringIO
from platform import processor
from unittest import TestCase, result

from metasp.grammar import Grammar
from metasp.system import MetaSystem
from metasp.utils import logging_utils
from metasp.utils.logging_utils import configure_logging
from metasp.utils.parser import get_parser
import subprocess
import os
from metasp.app import make_app
from metasp.utils.parser import parse_constants
from clingo.application import clingo_main
from metasp.utils.test import run_tests
from metasp import MetaspProcessor, replace_internal_prefix

from metasp import replace_internal_prefix

BOOL_DIC = {"syntax_encoding": ["./examples/bool/syntax.lp"], "semantics_encoding": ["./examples/bool/semantics.lp"]}
TEL_DIC = {
    "syntax_encoding": ["./examples/tel/syntax.lp"],
    "semantics_encoding": ["./examples/tel/semantics.lp"],
    "required_constants": ["n"],
}


class TestUtils(TestCase):
    """
    Test cases for utility functions.
    """

    def test_replace_internal_prefix(self) -> None:
        """
        Test the replace_internal_prefix function.
        """
        self.assertEqual(replace_internal_prefix("__test"), "&test")
        self.assertEqual(replace_internal_prefix("test"), "test")

    def test_reify_extend_bool(self) -> None:
        """
        Test the reify_and_extend function of the MetaspProcessor.
        """

        dic = BOOL_DIC
        const = {}
        # prg = ":- &and(a,b).\n"  # Gets an error I can't understand
        prg = ":- a."  # Gets an error I can't understand

        meta_system = MetaSystem.from_dict(dic)
        meta_system.set_constants(const)
        # transformed_input = meta_system.fo_transform(["examples/bool/instances/simple.lp"], prg)
        transformed_input = meta_system.fo_transform([], prg)
        grammar = Grammar.from_asp_files(meta_system.syntax_encoding)
        processor = MetaspProcessor(grammar)

        # replace_internal_prefix(transformed_input)
        reified = processor.reify_and_extend(transformed_input, const)
        final_files = meta_system.get_files(reified)

    def test_required_constant(self) -> None:
        """
        Test the reify_and_extend function of the MetaspProcessor.
        """

        dic = TEL_DIC
        const = {}

        meta_system = MetaSystem.from_dict(dic)
        with self.assertRaises(Exception):
            meta_system.set_constants(const)
