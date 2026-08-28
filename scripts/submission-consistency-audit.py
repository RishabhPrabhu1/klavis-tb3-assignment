#!/usr/bin/env python3
"""Fail closed on stale submission metadata and accidental development residue."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TASK_REL = "tasks/build-snapshot-publish"
EXPECTED_ORACLE = "68/68"
EXPECTED_TB3 = "79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"


def fail(message: str) -> None:
    print(f"CONSISTENCY FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def git(*args: str) -> str:
    return subprocess.check_output(["git", "-C", str(ROOT), *args], text=True).strip()


tree = git("rev-parse", f"HEAD:{TASK_REL}")
if git("status", "--porcelain", "--", TASK_REL):
    fail("task subtree is dirty")

status_path = ROOT / "results/preflight-status.json"
try:
    status = json.loads(status_path.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"cannot parse {status_path.relative_to(ROOT)}: {exc}")

expected_status = {
    "task_tree": tree,
    "qualified": True,
    "oracle_reference": EXPECTED_ORACLE,
    "harbor_oracle": 1,
    "harbor_nop": 0,
    "frontier_model_calls": 0,
    "terminal_bench_head": EXPECTED_TB3,
}
for key, expected in expected_status.items():
    actual = status.get(key)
    if actual != expected:
        fail(f"preflight status {key}={actual!r}, expected {expected!r}")

if status.get("qualification_mode") == "successor-delta-exact-tree":
    if status.get("predecessor_mutants") != "40/40_rejected":
        fail("successor qualification does not record predecessor 40/40 rejection")
    if status.get("fully_qualified_predecessor_tree") != "301107828273e249fbd31ed34d86bf3fed7143a1":
        fail("unexpected fully-qualified predecessor tree")

current_docs = [
    "README.md",
    "results/environment.md",
    "results/validation.md",
    "results/standard-trials.md",
    "results/cheat-trials.md",
    "results/failure-analysis.md",
    "results/implementation-rubric-review.md",
]
for rel in current_docs:
    text = (ROOT / rel).read_text(encoding="utf-8")
    if tree not in text:
        fail(f"{rel} does not identify current task tree {tree}")

obsolete_current_hashes = {
    "85eb3be3ce69a625a06eab3e37c69badbab89779",
    "f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8",
}
for rel in current_docs:
    text = (ROOT / rel).read_text(encoding="utf-8")
    for old in obsolete_current_hashes:
        if old in text:
            fail(f"{rel} still contains obsolete current-candidate hash {old}")

readme = (ROOT / "README.md").read_text(encoding="utf-8")
if not re.search(r"(?:Oracle/reference|Reference verifier).{0,120}68/68", readme, flags=re.IGNORECASE | re.DOTALL):
    fail("README does not state current 68/68 qualification")
if "1/3 counted" not in readme:
    fail("README does not state current counted Codex status")
if "Claude access unavailable" not in readme:
    fail("README does not disclose the Claude access limitation")

environment = (ROOT / "results/environment.md").read_text(encoding="utf-8")
if EXPECTED_TB3 not in environment:
    fail("environment snapshot does not identify pinned Terminal-Bench revision")
if "8 runs total" not in environment:
    fail("environment snapshot does not state the current eight-run matrix")

authoritative_scripts = [
    "scripts/run-qualification.sh",
    "scripts/run-codex-standard-matrix.sh",
    "scripts/run-claude-standard-matrix.sh",
    "scripts/run-cheat-matrix.sh",
    "scripts/run-candidate-trial.sh",
    "scripts/final-submission-audit.sh",
]
calibration_tree = "fc064cac2fb1241b68a98475dbc8ea04fbe579cc"
for rel in authoritative_scripts:
    path = ROOT / rel
    if not path.is_file():
        fail(f"required execution path is missing: {rel}")
    text = path.read_text(encoding="utf-8")
    pin_patterns = [
        rf'FROZEN_TASK_TREE=["\']{re.escape(calibration_tree)}["\']',
        rf'EXPECTED_TREE=["\']{re.escape(calibration_tree)}["\']',
        rf'EXPECTED_TASK_TREE=["\']{re.escape(calibration_tree)}["\']',
    ]
    if any(re.search(pattern, text) for pattern in pin_patterns):
        fail(f"{rel} is still operationally pinned to historical calibration tree")

qualifier = (ROOT / "scripts/run-qualification.sh").read_text(encoding="utf-8")
if "oracle_tests=68" not in qualifier or "oracle_reference=68/68" not in qualifier:
    fail("qualification entry point does not record/report 68 tests")

forbidden_paths = [
    "results/execution-plan.md",
    "results/submission-checklist.md",
    "scripts/deadline-status.sh",
    "scripts/resume-deadline-cycle.sh",
    "scripts/resume-macos-deadline-cycle.sh",
    "scripts/run-codex-strong-test.sh",
    "scripts/run-corrected-tree-local-qualification.sh",
    "scripts/run-deadline-cheat-matrix.sh",
    "scripts/run-deadline-claude-matrix.sh",
    "scripts/run-deadline-claude-pipeline.sh",
    "scripts/run-deadline-sol-matrix.sh",
    "scripts/run-fast-cycle.sh",
    "scripts/run-fast-final-successor-qualification.sh",
    "scripts/run-fast-frontier-cycle.sh",
    "scripts/run-final-tree-deadline-qualification.sh",
    "scripts/run-four-hour-codex-finish.sh",
    "scripts/run-implementation-rubric-bedrock.sh",
    "scripts/run-next-frontier-step.sh",
    "scripts/run-next-qualification-step.sh",
    "scripts/run-one-qualified-sol-probe.sh",
    "scripts/run-parallel-final-matrix.sh",
    "scripts/run-required-cheat.sh",
    "scripts/smoke-test-claude-bedrock.sh",
]
for rel in forbidden_paths:
    if (ROOT / rel).exists():
        fail(f"development-only residue remains on submission branch: {rel}")

reviewer_text = "\n".join((ROOT / rel).read_text(encoding="utf-8") for rel in current_docs)
markers = (
    "Chat" + "GPT",
    "Luna" + " Max",
    "TODO",
    "FIXME",
    "/Users/" + "rishabhprabhu/",
)
for marker in markers:
    if marker in reviewer_text:
        fail(f"reviewer-facing residue marker found: {marker}")

print("=== SUBMISSION CONSISTENCY AUDIT ===")
print(f"task_tree={tree}")
print("preflight_status=PASS")
print("oracle_reference=68/68")
print("environment_snapshot=PASS")
print("reviewer_docs=PASS")
print("submission_hygiene=PASS")
print("authoritative_entry_points=PASS")
print("task_tree_clean=YES")
print("CONSISTENCY_STATUS=PASS")
