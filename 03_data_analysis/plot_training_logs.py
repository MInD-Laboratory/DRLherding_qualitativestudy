#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import time
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from tensorboard.backend.event_processing import event_accumulator


def discover_event_files(root: Path) -> list[Path]:
    return sorted(root.rglob("events.out.tfevents.*"))


def extract_scalars(
    event_file: Path, selected_tags: set[str] | None = None, max_scalars_per_tag: int = 0
) -> dict[str, pd.DataFrame]:
    size_guidance = {"scalars": max_scalars_per_tag if max_scalars_per_tag > 0 else 0}
    accumulator = event_accumulator.EventAccumulator(str(event_file), size_guidance=size_guidance)
    accumulator.Reload()

    tag_to_df: dict[str, pd.DataFrame] = {}
    tags = accumulator.Tags().get("scalars", [])
    if selected_tags is not None:
        tags = [tag for tag in tags if tag in selected_tags]

    for tag in tags:
        events = accumulator.Scalars(tag)
        if not events:
            continue
        rows = [{"step": e.step, "value": e.value} for e in events]
        tag_df = pd.DataFrame(rows).groupby("step", as_index=False)["value"].mean()
        tag_to_df[tag] = tag_df
    return tag_to_df


def sanitize_filename(value: str) -> str:
    sanitized = re.sub(r"[^A-Za-z0-9._-]+", "_", value)
    return sanitized.strip("_") or "metric"


def aggregate_method_runs(tag_dfs: list[pd.DataFrame]) -> pd.DataFrame:
    all_rows = []
    for run_index, df in enumerate(tag_dfs, start=1):
        run_df = df.copy()
        run_df["run"] = run_index
        all_rows.append(run_df)

    combined = pd.concat(all_rows, ignore_index=True)
    grouped = combined.groupby("step")["value"]

    summary = grouped.agg(["mean", "std", "count"]).reset_index()
    summary["std"] = summary["std"].fillna(0.0)
    summary["ci95"] = 1.96 * (summary["std"] / np.sqrt(summary["count"].clip(lower=1)))
    return summary


def plot_metric(tag: str, method_to_summary: dict[str, pd.DataFrame], out_dir: Path) -> Path:
    plt.figure(figsize=(8.5, 5.2))

    for method_name, summary in method_to_summary.items():
        x = summary["step"].to_numpy()
        y = summary["mean"].to_numpy()
        ci = summary["ci95"].to_numpy()

        plt.plot(x, y, linewidth=2, label=f"{method_name} (mean)")
        plt.fill_between(x, y - ci, y + ci, alpha=0.2)

    plt.xlabel("Training step")
    plt.ylabel(tag)
    plt.title(f"{tag} (mean ± 95% CI across runs)")
    plt.legend(frameon=False)
    plt.grid(alpha=0.3)
    plt.tight_layout()

    out_path = out_dir / f"{sanitize_filename(tag)}.png"
    plt.savefig(out_path, dpi=180)
    plt.close()
    return out_path


def build_default_roots(repo_root: Path) -> dict[str, Path]:
    return {
        "DRL-AA": repo_root / "01_DRL_training" / "training_results" / "DRL-AA",
        "DRL-HP-AA": repo_root / "01_DRL_training" / "training_results" / "DRL-HP-AA",
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Aggregate ML-Agents TensorBoard logs and create method-level training curves."
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Repository root directory.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="Output folder for PNG plots (default: 03_data_analysis/outputs/training_plots).",
    )
    parser.add_argument(
        "--tags",
        nargs="+",
        default=None,
        help="Optional list of scalar tags to plot. If omitted, plots all tags present in both methods.",
    )
    parser.add_argument(
        "--max-scalars-per-tag",
        type=int,
        default=20000,
        help="Maximum scalar points to load per tag per event file (0 = load all).",
    )
    parser.add_argument(
        "--progress-every",
        type=int,
        default=5,
        help="Print parse progress every N event files per method.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    out_dir = (
        args.out_dir.resolve()
        if args.out_dir is not None
        else (repo_root / "03_data_analysis" / "outputs" / "training_plots")
    )
    out_dir.mkdir(parents=True, exist_ok=True)

    method_roots = build_default_roots(repo_root)
    method_tag_series: dict[str, dict[str, list[pd.DataFrame]]] = defaultdict(lambda: defaultdict(list))
    selected_tags_set = set(args.tags) if args.tags else None

    for method_name, method_root in method_roots.items():
        if not method_root.exists():
            print(f"[WARN] Missing method folder: {method_root}")
            continue

        event_files = discover_event_files(method_root)
        if not event_files:
            print(f"[WARN] No TensorBoard event files found for {method_name} at {method_root}")
            continue

        print(f"[INFO] {method_name}: found {len(event_files)} event files")
        method_start = time.perf_counter()

        for file_index, event_file in enumerate(event_files, start=1):
            if file_index == 1 or file_index % max(1, args.progress_every) == 0 or file_index == len(event_files):
                print(f"[INFO] {method_name}: parsing event file {file_index}/{len(event_files)}")
            try:
                tag_to_df = extract_scalars(
                    event_file,
                    selected_tags=selected_tags_set,
                    max_scalars_per_tag=args.max_scalars_per_tag,
                )
            except Exception as error:
                print(f"[WARN] Could not parse {event_file}: {error}")
                continue

            for tag, tag_df in tag_to_df.items():
                method_tag_series[method_name][tag].append(tag_df)

        elapsed_seconds = time.perf_counter() - method_start
        print(f"[INFO] {method_name}: parsing complete in {elapsed_seconds:.1f}s")

    if not method_tag_series:
        print("[ERROR] No usable scalar data found.")
        return

    available_tags_by_method = {
        method: set(tag_map.keys()) for method, tag_map in method_tag_series.items()
    }

    if args.tags:
        selected_tags = args.tags
    else:
        if len(available_tags_by_method) < 2:
            selected_tags = sorted(next(iter(available_tags_by_method.values())))
        else:
            selected_tags = sorted(set.intersection(*available_tags_by_method.values()))

    if not selected_tags:
        print("[ERROR] No common tags found to plot.")
        print("[INFO] Try passing explicit tags with --tags")
        for method_name, tags in available_tags_by_method.items():
            preview = ", ".join(sorted(tags)[:10])
            print(f"[INFO] {method_name} tags (sample): {preview}")
        return

    generated = []
    for tag in selected_tags:
        method_to_summary: dict[str, pd.DataFrame] = {}
        for method_name, tag_map in method_tag_series.items():
            if tag not in tag_map or not tag_map[tag]:
                continue
            method_to_summary[method_name] = aggregate_method_runs(tag_map[tag])

        if len(method_to_summary) < 1:
            continue

        out_path = plot_metric(tag, method_to_summary, out_dir)
        generated.append(out_path)

    if generated:
        print(f"[OK] Generated {len(generated)} plots in: {out_dir}")
        for path in generated[:10]:
            print(f" - {path}")
        if len(generated) > 10:
            print(f" - ... and {len(generated) - 10} more")
    else:
        print("[ERROR] No plots were generated.")


if __name__ == "__main__":
    main()
