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

METRICS = {"time", "stime", "rules", "choices", "conflicts"}
DOMAINS = ["hanoi", "labyrinth", "nomystery", "ricochetrobot", "sokoban", "visitall"]
COLORS = {
    "hanoi":         "#e41a1c",
    "labyrinth":     "#377eb8",
    "nomystery":     "#4daf4a",
    "ricochetrobot": "#984ea3",
    "sokoban":       "#ff7f00",
    "visitall":      "#a65628",
}

RESULTS_DIR = Path(__file__).parent / "results"


def load_data(metric: str) -> pd.DataFrame:
    df_m = pd.read_excel(RESULTS_DIR / "metasp-tel.xlsx", header=[0, 1])
    df_t = pd.read_excel(RESULTS_DIR / "telingo-tel.xlsx", header=[0, 1])

    inst_col = ("Unnamed: 0_level_0", "Unnamed: 0_level_1")
    m_sys = "metasp-1/default"
    t_sys = "telingo-1/default"

    df_m = df_m[[inst_col, (m_sys, metric)]].copy()
    df_m.columns = ["instance", "metasp"]

    df_t = df_t[[inst_col, (t_sys, metric)]].copy()
    df_t.columns = ["instance", "telingo"]

    merged = pd.merge(df_m, df_t, on="instance")
    merged = merged.dropna(subset=["metasp", "telingo"])

    def extract_domain(path: str) -> str:
        m = re.search(r"instances/(\w+)/", str(path))
        return m.group(1) if m else "unknown"

    merged["domain"] = merged["instance"].apply(extract_domain)
    return merged


def plot(metric: str, df: pd.DataFrame) -> None:
    fig, ax = plt.subplots(figsize=(7, 7))

    for domain in DOMAINS:
        subset = df[df["domain"] == domain]
        if subset.empty:
            continue
        ax.scatter(
            subset["metasp"],
            subset["telingo"],
            color=COLORS[domain],
            label=domain,
            alpha=0.75,
            edgecolors="none",
            s=50,
            zorder=3,
        )

    # Diagonal reference line
    all_vals = pd.concat([df["metasp"], df["telingo"]])
    lo, hi = all_vals.min(), all_vals.max()
    pad = (hi - lo) * 0.05
    lim = (lo - pad, hi + pad)
    ax.plot(lim, lim, color="grey", linewidth=0.8, linestyle="--", zorder=2, label="_nolegend_")
    ax.set_xlim(lim)
    ax.set_ylim(lim)

    ax.set_xlabel(f"{metric} metasp", fontsize=12)
    ax.set_ylabel(f"{metric} telingo", fontsize=12)
    ax.set_title(f"{metric}: metasp vs telingo", fontsize=13)
    ax.set_aspect("equal", adjustable="box")
    ax.legend(title="domain", bbox_to_anchor=(1.02, 1), loc="upper left", borderaxespad=0)
    ax.grid(True, linewidth=0.4, alpha=0.5)

    plt.tight_layout()
    out = RESULTS_DIR / f"comparison_{metric}.pdf"
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
