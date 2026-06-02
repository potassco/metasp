"""
Created on Jan 17, 2010

@author: Roland Kaminski
"""

import os
import re
import sys
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from benchmarktool.runscript import runscript  # nocoverage

clasp_re = {
    "models": ("float", re.compile(r"^(c )?Models[ ]*:[ ]*(?P<val>[0-9]+)\+?[ ]*$")),
    "choices": ("float", re.compile(r"^(c )?Choices[ ]*:[ ]*(?P<val>[0-9]+)\+?[ ]*$")),
    "time": ("float", re.compile(r"^\[runlim\] real:\s*(?P<val>[0-9]+(\.[0-9]+)?)")),
    "ctime": ("float", re.compile(r"^(c )?Time[ ]*:[ ]*(?P<val>[0-9]+(\.[0-9]+)?)")),
    "stime": (
        "float",
        re.compile(r"^(c )?Time[ ]*:[ ]*[0-9]+(\.[0-9]+)?s[ ]*\(Solving:[ ]*(?P<val>[0-9]+(\.[0-9]+)?)"),
    ),
    "fmtime": (
        "float",
        re.compile(r"^(c )?Time[ ]*:.*1st Model:[ ]*(?P<val>[0-9]+(\.[0-9]+)?)"),
    ),
    "rules": ("float", re.compile(r"^(c )?Rules[ ]*:[ ]*(?P<val>[0-9]+)")),
    "constraints": ("float", re.compile(r"^(c )?Constraints[ ]*:[ ]*(?P<val>[0-9]+)")),
    "roriginal": (
        "float",
        re.compile(r"^(c )?Rules[ ]*:[ ]*[0-9]+(\.[0-9]+)?[ ]*\(Original:[ ]*(?P<val>[0-9]+(\.[0-9]+)?)"),
    ),
    "rchoices": ("float", re.compile(r"^(c )?  Choice [ ]*:[ ]*(?P<val>[0-9]+)")),
    "atoms": ("float", re.compile(r"^(c )?Atoms[ ]*:[ ]*(?P<val>[0-9]+)")),
    "conflicts": (
        "float",
        re.compile(r"^(c )?Conflicts[ ]*:[ ]*(?P<val>[0-9]+)\+?.*$"),
    ),
    "restarts": ("float", re.compile(r"^(c )?Restarts[ ]*:[ ]*(?P<val>[0-9]+)\+?.*$")),
    "optimum": (
        "string",
        re.compile(r"^(c )?Optimization[ ]*:[ ]*(?P<val>(-?[0-9]+)( -?[0-9]+)*)[ ]*$"),
    ),
    "status": (
        "string",
        re.compile(r"^(s )?(?P<val>SATISFIABLE|UNSATISFIABLE|UNKNOWN|OPTIMUM FOUND)[ ]*$"),
    ),
    "interrupted": ("string", re.compile(r"(c )?(?P<val>INTERRUPTED)")),
    "error": ("string", re.compile(r"^\*\*\* clasp ERROR: (?P<val>.*)$")),
    "rstatus": ("string", re.compile(r"^\[runlim\] status:\s*(?P<val>.*)$")),
    "mem": ("float", re.compile(r"^\[runlim\] space:\s*(?P<val>[0-9]+(\.[0-9]+)?) MB")),
}

# penalized-average-runtime score constant
PAR = 2


# pylint: disable=unused-argument
def parse(
    path: str,
    runspec: "runscript.Runspec",
    instance: "runscript.Benchmark.Instance",
    run: int,
) -> dict[str, tuple[str, Any]]:
    """
    Extracts some clasp statistics.

    Attributes:
        path (str):                    The path to the run directory.
        runspec (Runspec):             The run specification of the benchmark.
        instance (Benchmark.Instance): The benchmark instance.
        run (int):                     The run number.
    """
    timeout = runspec.project.job.timeout
    res: dict[str, tuple[str, Any]] = {"time": ("float", timeout)}
    for f in ["runsolver.solver", "runsolver.watcher"]:
        try:
            with open(os.path.join(path, f), errors="ignore", encoding="utf-8") as file:
                for line in file:
                    for val, reg in clasp_re.items():
                        m = reg[1].match(line)
                        if m:
                            res[val] = (
                                reg[0],
                                (float(m.group("val")) if reg[0] == "float" else m.group("val")),
                            )
        except FileNotFoundError:
            sys.stderr.write(
                f"*** WARNING: Result file '{f}' not found for run {run} of instance '{instance.name}' "
                f"for system '{runspec.system.name}-{runspec.system.version}'! ({path})\n"
            )

    if "rstatus" in res and res["rstatus"][1] == "out of memory":
        res["error"] = ("string", "std::bad_alloc")
        res["status"] = ("string", "UNKNOWN")
    result: dict[str, tuple[str, Any]] = {}
    error = "status" not in res or ("error" in res and res["error"][1] != "std::bad_alloc")
    memout = "error" in res and res["error"][1] == "std::bad_alloc"
    status = res["status"][1] if "status" in res else None
    timedout = (
        memout
        or error
        or status == "UNKNOWN"
        or (status == "SATISFIABLE" and "optimum" in res)
        or res["time"][1] >= timeout
        or "interrupted" in res
    )
    if timedout:
        res["time"] = ("float", timeout)
    if error:
        sys.stderr.write(
            f"*** WARNING: Run {run} of instance '{instance.name}' "
            f"for system '{runspec.system.name}-{runspec.system.version}' "
            f"failed with unrecognized status or error! ({path})\n"
        )
    result["error"] = ("float", int(error))
    result["timeout"] = ("float", int(timedout))
    result["memout"] = ("float", int(memout))

    if "optimum" in res and not " " in res["optimum"][1]:
        result["optimum"] = ("float", float(res["optimum"][1]))
        del res["optimum"]
    if "interrupted" in res:
        del res["interrupted"]
    if "error" in res:
        del res["error"]
    for key, value in res.items():
        result[key] = (value[0], value[1])

    if "ctime" in res:
        result["ptime"] = ("float", round(res["time"][1] - res["ctime"][1], 2))

    if "ctime" in res:
        result["gtime"] = ("float", round(res["ctime"][1] - res["stime"][1], 2))

    return result
