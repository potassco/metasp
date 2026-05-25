#!/usr/bin/env python3
"""
Scatter plot comparing a benchmark metric between metasp and telingo.

Usage:
    python plot_comparison.py <metric>

Where <metric> is one of: time, stime, rules, choices, conflicts
"""

import sys
import re
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
from pathlib import Path

METRICS = {"time", "stime", "rules", "choices", "conflicts", "gtime"}
DOMAINS = ["hanoi", "labyrinth", "nomystery", "ricochetrobot", "sokoban", "visitall"]
COLORS = {
    "hanoi": "#e41a1c",
    "labyrinth": "#377eb8",
    "nomystery": "#4daf4a",
    "ricochetrobot": "#984ea3",
    "sokoban": "#ff7f00",
    "visitall": "#a65628",
}

DISPLAY_NAMES = {
    "time": "Time (s)",
    "stime": "Solving time (s)",
    "gtime": "Grounding time (s)",
    "rules": "Rules",
    "choices": "Choices",
    "conflicts": "Conflicts",
}

RESULTS_DIR = Path(__file__).parent.parent / "results"


def load_data(metric: str) -> pd.DataFrame:
    df_m = pd.read_excel(RESULTS_DIR / "metasp-tel.xlsx", header=[0, 1])
    df_t = pd.read_excel(RESULTS_DIR / "telingo-tel.xlsx", header=[0, 1])

    inst_col = ("Unnamed: 0_level_0", "Unnamed: 0_level_1")
    m_sys = "metasp-1/default"
    t_sys = "telingo-1/default"

    status_m = df_m[[inst_col, (m_sys, "status")]].copy()
    status_m.columns = ["instance", "status_m"]
    status_t = df_t[[inst_col, (t_sys, "status")]].copy()
    status_t.columns = ["instance", "status_t"]

    if metric == "gtime":
        df_m = df_m[[inst_col, (m_sys, "time"), (m_sys, "stime")]].copy()
        df_m.columns = ["instance", "_time", "_stime"]
        df_m["metasp"] = df_m["_time"] - df_m["_stime"]
        df_m = df_m[["instance", "metasp"]]

        df_t = df_t[[inst_col, (t_sys, "time"), (t_sys, "stime")]].copy()
        df_t.columns = ["instance", "_time", "_stime"]
        df_t["telingo"] = df_t["_time"] - df_t["_stime"]
        df_t = df_t[["instance", "telingo"]]
    else:
        df_m = df_m[[inst_col, (m_sys, metric)]].copy()
        df_m.columns = ["instance", "metasp"]

        df_t = df_t[[inst_col, (t_sys, metric)]].copy()
        df_t.columns = ["instance", "telingo"]

    merged = pd.merge(df_m, df_t, on="instance")
    merged = pd.merge(merged, status_m, on="instance")
    merged = pd.merge(merged, status_t, on="instance")
    merged = merged.dropna(subset=["metasp", "telingo"])
    merged["timed_out"] = (merged["status_m"] == "UNKNOWN") | (merged["status_t"] == "UNKNOWN")

    def extract_domain(path: str) -> str:
        m = re.search(r"instances/(\w+)/", str(path))
        return m.group(1) if m else "unknown"

    merged["domain"] = merged["instance"].apply(extract_domain)
    return merged


def plot(metric: str, df: pd.DataFrame) -> None:
    fig, ax = plt.subplots(figsize=(7, 7))

    # Partition by which system(s) timed out
    to_m = df["status_m"] == "UNKNOWN"
    to_t = df["status_t"] == "UNKNOWN"
    groups = {
        "normal": (df[~to_m & ~to_t], "o", 0.75, "none", 50),
        "metasp_only": (df[to_m & ~to_t], ">", 0.75, "face", 50),
        "telingo_only": (df[~to_m & to_t], "^", 0.75, "face", 50),
        "both": (df[to_m & to_t], "X", 0.75, "face", 50),
    }

    for key, (subset_all, marker, alpha, ec, sz) in groups.items():
        for domain in DOMAINS:
            subset = subset_all[subset_all["domain"] == domain]
            if subset.empty:
                continue
            ax.scatter(
                subset["metasp"],
                subset["telingo"],
                color=COLORS[domain],
                label=domain if key == "normal" else "_nolegend_",
                marker=marker,
                alpha=alpha,
                edgecolors=ec,
                s=sz,
                zorder=3,
            )

    ax.set_xscale("log")
    ax.set_yscale("log")

    # Diagonal reference line
    all_vals = pd.concat([df["metasp"], df["telingo"]])
    positive = all_vals[all_vals > 0]
    lo = 10 ** np.floor(np.log10(positive.min()))
    hi = 10 ** np.ceil(np.log10(positive.max()))
    lim = (lo, hi)
    ax.plot(lim, lim, color="grey", linewidth=0.8, linestyle="--", zorder=2, label="_nolegend_")
    ax.set_xlim(lim)
    ax.set_ylim(lim)

    display = DISPLAY_NAMES[metric]
    ax.set_xlabel(f"{display} metasp", fontsize=14)
    ax.set_ylabel(f"{display} telingo-λ", fontsize=14)
    ax.set_title(f"{display}: metasp vs telingo-λ", fontsize=15)
    ax.set_aspect("equal", adjustable="box")

    # Build legend: domain colour patches + per-timeout-case marker entries
    import matplotlib.lines as mlines

    handles, labels = ax.get_legend_handles_labels()
    timeout_entries = [
        (">", "metasp timeout"),
        ("^", "telingo-λ timeout"),
        ("X", "both timeout"),
    ]
    for marker, label in timeout_entries:
        if not df[
            (
                df["timed_out"]
                if label == "both timeout"
                else (df["status_m"] == "UNKNOWN") if label == "metasp timeout" else (df["status_t"] == "UNKNOWN")
            )
        ].empty:
            handles.append(
                mlines.Line2D(
                    [],
                    [],
                    color="grey",
                    marker=marker,
                    linestyle="None",
                    markersize=7,
                    label=label,
                )
            )
            labels.append(label)
    ax.legend(handles, labels, title="legend", bbox_to_anchor=(1.02, 1), loc="upper left", borderaxespad=0, fontsize=13, title_fontsize=13)
    ax.grid(True, linewidth=0.4, alpha=0.5)

    plt.tight_layout()
    out = Path(__file__).parent / f"comparison_{metric}.pdf"
    plt.savefig(out, bbox_inches="tight")
    print(f"Saved: {out}")
    plt.show()


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in METRICS:
        print(f"Usage: python {sys.argv[0]} <metric>")
        print(f"  metric must be one of: {', '.join(sorted(METRICS))}")
        sys.exit(1)

    metric = sys.argv[1]
    df = load_data(metric)
    print(f"Loaded {len(df)} instances with data for both systems.")
    plot(metric, df)


if __name__ == "__main__":
    main()
