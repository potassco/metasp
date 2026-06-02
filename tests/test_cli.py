from unittest import TestCase

from metasp.__main__ import run


class TestCli(TestCase):
    """
    Test command line
    """

    def test_solve(self):
        result = run(
            [
                "solve",
                "clingo",
                "--meta-config",
                "examples/tel/config.yml",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "0",
                "-c",
                "n=2",
            ]
        )

        self.assertEqual(result, 30)

    def test_transform(self):
        result = run(
            [
                "transform",
                "--meta-config",
                "examples/tel/config.yml",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "-c",
                "n=2",
            ]
        )

        self.assertEqual(result, 0)

    def test_reify(self):
        result = run(
            [
                "reify",
                "--meta-config",
                "examples/tel/config.yml",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "-c",
                "n=2",
            ]
        )

        self.assertEqual(result, 0)

    def test_invalid_config(self):

        self.assertRaises(
            Exception,
            run,
            [
                "reify",
                "--meta-config",
                "examples/tel/semantics.lp",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "-c",
                "n=2",
            ],
        )

    def test_reify_explicit_encodings(self):
        result = run(
            [
                "solve",
                "clingo",
                "--semantics-encoding",
                "examples/tel/semantics.lp",
                "--syntax-encoding",
                "examples/tel/syntax.lp",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "-c",
                "n=2",
            ]
        )

        self.assertEqual(result, 10)

    def test_reify_explicit_encodings_missing_semantics(self):
        result = run(
            [
                "solve",
                "clingo",
                "--syntax-encoding",
                "examples/tel/syntax.lp",
                "examples/tel/tests/paper-lights-n2-next.test.lp",
                "-c",
                "n=2",
            ]
        )

        self.assertEqual(result, 65)

    def test_help(self):
        result = run(
            [
                "-h",
            ]
        )
        self.assertEqual(result, 1)
