import logging
from importlib.resources import files

from clingo import Control
from clingo.symbol import String

try:
    from clingraph.clingo_utils import (
        ClingraphContext,
        add_elements_ids,
        add_svg_interaction,
    )
    from clingraph.graphviz import compute_graphs, render
    from clingraph.orm import Factbase

except ImportError:
    CLINGRAPH_AVAILABLE = False
else:
    CLINGRAPH_AVAILABLE = True

log = logging.getLogger(__name__)


def replace_internal_prefix(prg: str) -> str:
    """
    Replaces the __ prefix by & in the program.
    Used to show the output to the user.

    Args:
        prg (str): The program string to process.
    """
    return prg.replace("__", "&")


def replace_internal_prefix_html(prg: str) -> str:
    """
    Replaces the __ prefix by & in the program.
    Used to show the output to the user.

    Args:
        prg (str): The program string to process.
    """
    return prg.replace("__", "&amp;")


class MetaspContext(ClingraphContext):
    def formula_label(self, obj):
        return String(replace_internal_prefix_html(str(obj)))


def visualize_reified_program(reified_prg: str) -> None:
    """
    Visualize the reified program using clingraph.

    Args:
        reified_prg (str): The reified program as a string.
    """
    if not CLINGRAPH_AVAILABLE:
        log.error(
            "Clingraph is not available. Cannot visualize the reified program.\n Install clingraph manually https://clingraph.readthedocs.io/en/latest/"
        )

        return
    fbs = []
    ctl = Control(["-n2"])
    ctl.add("base", [], reified_prg)
    viz_encoding = files("metasp.encodings").joinpath("viz-reified.lp")
    log.debug("Loading encoding: %s", viz_encoding)

    ctl.load(str(viz_encoding))
    ctl.ground([("base", [])], MetaspContext())
    ctl.solve(on_model=lambda m: fbs.append(Factbase.from_model(m)))
    graphs = compute_graphs(fbs)
    render(graphs, name_format="reification-tree", format="png", view=True)
