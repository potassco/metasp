#!/usr/bin/env python3
"""
Side-by-side scatter plot of time (left) and solving time (right),
with a shared legend on the right.
"""

import matplotlib.lines as mlines
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np
import pandas as pd
from pathlib import Path

from plot_comparison import COLORS, DISPLAY_NAMES, DOMAINS, RESULTS_DIR, load_data


def draw_axes(ax: plt.Axes, metric: str, df: pd.DataFrame, lim=None) -> None:
    to_m = df["status_m"] == "UNKNOWN"
    to_t = df["status_t"] == "UNKNOWN"
    size = 120
    groups = {
        "normal": (df[~to_m & ~to_t], "o", 0.75, "none", size),
        "metasp_only": (df[to_m & ~to_t], ">", 0.75, "face", size),
        "telingo_only": (df[~to_m & to_t], "^", 0.75, "face", size),
        "both": (df[to_m & to_t], "X", 0.75, "face", size),
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
                marker=marker,
                alpha=alpha,
                edgecolors=ec,
                s=sz,
                zorder=3,
            )

    ax.set_xscale("log")
    ax.set_yscale("log")

    if lim is None:
        all_vals = pd.concat([df["metasp"], df["telingo"]])
        positive = all_vals[all_vals > 0]
        lo = 10 ** np.floor(np.log10(positive.min()))
        hi = 10 ** np.ceil(np.log10(positive.max()))
        lim = (lo, hi)
    ax.plot(lim, lim, color="grey", linewidth=0.8, linestyle="--", zorder=2)
    ax.set_xlim(lim)
    ax.set_ylim(lim)

    display = DISPLAY_NAMES[metric]
    ax.set_xlabel(f"{display} metasp", fontsize=22, weight="light")
    ax.set_ylabel(f"{display} telingo-λ", fontsize=22, weight="light")
    # ax.set_title(f"{display}: metasp vs telingo-λ", fontsize=15)
    ax.set_aspect("equal", adjustable="box")
    ax.tick_params(labelsize=18)
    ax.grid(True, linewidth=0.4, alpha=0.5)


def build_legend_handles(df: pd.DataFrame):
    handles, labels = [], []
    for domain in DOMAINS:
        if not df[df["domain"] == domain].empty:
            handles.append(mpatches.Patch(color=COLORS[domain], label=domain, alpha=0.75))
            labels.append(domain)
    timeout_entries = [
        (">", "metasp timeout", df["status_m"] == "UNKNOWN"),
        ("^", "telingo-λ timeout", df["status_t"] == "UNKNOWN"),
        ("X", "both timeout", df["timed_out"]),
    ]
    for marker, label, mask in timeout_entries:
        if mask.any():
            handles.append(
                mlines.Line2D([], [], color="grey", marker=marker, linestyle="None", markersize=7, label=label)
            )
            labels.append(label)
    return handles, labels


def main() -> None:
    df_time = load_data("time")
    df_stime = load_data("stime")

    all_vals = pd.concat([df_time["metasp"], df_time["telingo"], df_stime["metasp"], df_stime["telingo"]])
    hi = 10 ** np.ceil(np.log10(all_vals[all_vals > 0].max()))
    lim = (1e-1, hi)

    fig, (ax_time, ax_stime) = plt.subplots(1, 2, figsize=(14, 7))
    draw_axes(ax_time, "time", df_time, lim=lim)
    draw_axes(ax_stime, "stime", df_stime, lim=lim)

    # Suppress the 10^-1 tick label on both axes to avoid crowding at the origin
    def fmt_skip_first(x, pos):
        if abs(x - 0.1) < 1e-10:
            return ""
        exp = int(round(np.log10(x)))
        return f"$10^{{{exp}}}$"

    for ax in (ax_time, ax_stime):
        ax.xaxis.set_major_formatter(mticker.FuncFormatter(fmt_skip_first))
        ax.yaxis.set_major_formatter(mticker.FuncFormatter(fmt_skip_first))

    handles, labels = build_legend_handles(df_time)
    # fig.legend(handles, labels, title="legend", loc="center left", bbox_to_anchor=(1.0, 0.5), borderaxespad=0, fontsize=13, title_fontsize=13)

    plt.tight_layout(w_pad=6)
    out = Path(__file__).parent / "comparison_time+stime.pdf"
    plt.savefig(out, bbox_inches="tight")
    print(f"Saved: {out}")
    plt.show()


if __name__ == "__main__":
    main()
