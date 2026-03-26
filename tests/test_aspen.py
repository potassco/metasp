from io import StringIO
from pathlib import Path
from tempfile import NamedTemporaryFile
import shutil

from aspen.utils.testing import AspenTestCase
from aspen.tree import AspenTree
from tree_sitter import Language
import tree_sitter_metasp as ts_metasp
from clingo import Function
from clingo.ast import parse_string, parse_files, AST

from metasp.system import MetaSystem

metasp_lang = Language(ts_metasp.language())

test_files_dir = Path(__file__).parent / "asp"
tel_test_dir = test_files_dir / "tel"
mel_test_dir = test_files_dir / "mel"
del_test_dir = test_files_dir / "del"

examples_dir = Path(__file__).parent.parent / "examples"
tel_examples_dir = examples_dir / "tel"
mel_examples_dir = examples_dir / "mel"
del_examples_dir = examples_dir / "del"

encodings_dir = Path(__file__).parent.parent / "src" / "metasp" / "encodings"


class TestAspenPreprocess(AspenTestCase):
    """Test suit for aspen-based preprocessing done in input AST."""

    def setUp(self) -> None:
        self.out_dir = Path(__file__).parent / "out"
        self.out_dir.mkdir(parents=True, exist_ok=True)
        super().setUp()

    # def tearDown(self) -> None:
    #     shutil.rmtree(self.out_dir)
    #     super().tearDown()

    def assert_encoding_equal(self, encoding1: str | Path, encoding2: str | Path) -> None:
        """Assert that two ASP encodings are the same, modulo whitespace and formatting."""
        stms1: list[AST] = []
        stms2: list[AST] = []
        for encoding, stms in [(encoding1, stms1), (encoding2, stms2)]:
            if isinstance(encoding, str):
                parse_string(encoding, lambda stm: stms.append(stm))
            elif isinstance(encoding, Path):
                parse_files([str(encoding)], lambda stm: stms.append(stm))
            else:
                raise RuntimeError("Code should be unreachable.")
        stm_strs1 = set([str(stm) for stm in stms1])
        stm_strs2 = set([str(stm) for stm in stms2])
        self.assertSetEqual(stm_strs1, stm_strs2)

    def assert_preprocess_equal(
        self,
        *,
        syntax_encodings: list[Path],
        semantics_encodings: list[Path],
        input_files: list[Path],
        expected_syntax_fact_file: Path,
        expected_rewritten_semantics: list[Path],
        expected_rewritten_input_files: list[Path],
    ) -> None:
        """Assert that aspen preprocessing generates the expected
        syntax fact files, and rewrites input files and semantics
        encoding in the expected manner."""
        system = MetaSystem(
            name="metasp",
            control_name="clingo",
            syntax_encoding=[str(f) for f in syntax_encodings],
            semantics_encoding=[str(f) for f in semantics_encodings],
            out_dir=self.out_dir,
        )
        system.fo_transform(input_files, "")
        self.assert_encoding_equal(self.out_dir / "syntax_facts.lp", expected_syntax_fact_file)
        for sem, expected in zip(input_files, expected_rewritten_semantics):
            self.assert_encoding_equal(self.out_dir / (sem.stem + "_rewritten.lp"), expected)
        for inp, expected in zip(input_files, expected_rewritten_input_files):
            self.assert_encoding_equal(self.out_dir / (inp.stem + "_rewritten.lp"), expected)

    def test_syntax_file_generation(self) -> None:
        """Test that syntax file generation behaves as expected."""
        self.assert_preprocess_equal(
            syntax_encodings=[tel_examples_dir / "syntax.lp"],
            expected_syntax_fact_file=tel_test_dir / "syntax_facts.lp",
            semantics_encodings=[tel_examples_dir / "semantics.lp"],
            expected_rewritten_semantics=[tel_test_dir / "semantics_rewritten.lp"],
            input_files=[tel_examples_dir / "instances" / "paper-lights.lp"],
            expected_rewritten_input_files=[tel_test_dir / "paper-lights_rewritten.lp"],
        )
