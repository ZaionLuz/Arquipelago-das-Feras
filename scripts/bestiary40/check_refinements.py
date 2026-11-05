#!/usr/bin/env python3
"""Compare actual volumes, ignoring part names, colors, materials and annotations."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import os

ROOT = Path(__file__).resolve().parents[2]


def geometry_key(part):
    # Rounded native floats tolerate serialization noise, not anatomy changes.
    numbers = part["size"] + part["cf"] + part.get("meshScale", [1, 1, 1])
    return (part["class"], part["shape"], part.get("mesh", ""),
            *(round(value, 4) for value in numbers))


def check(current_path):
    baseline_path = ROOT / "assets/bestiary40/baseline_geometry.json"
    baseline = json.loads(baseline_path.read_text())
    current = json.loads(current_path.read_text())
    old = {(r["id"], r["stage"]): r for r in baseline["models"]}
    new = {(r["id"], r["stage"]): r for r in current["models"]}
    assert len({id for id, _ in old}) == 30 and len(old) == 88
    assert len({id for id, _ in new}) == 40 and len(new) == 116
    metrics = []
    refined = set()
    for key, before in old.items():
        after = new[key]
        a = Counter(geometry_key(p) for p in before["parts"])
        b = Counter(geometry_key(p) for p in after["parts"])
        kept = sum((a & b).values())
        added, removed = sum((b - a).values()), sum((a - b).values())
        assert added + removed >= 1, f"No geometry refinement: {key}"
        if key[1] == 3:
            assert added + removed >= 3, f"No meaningful adult geometry refinement: {key}"
            refined.add(key[0])
        metrics.append({"id": key[0], "stage": key[1],
                        "beforeVolumes": len(before["parts"]),
                        "afterVolumes": len(after["parts"]),
                        "unchangedGeometry": kept, "addedOrMovedVolumes": added,
                        "removedOrMovedVolumes": removed})
    assert len(refined) == 30
    output = {"baselineSha256": hashlib.sha256(baseline_path.read_bytes()).hexdigest(),
              "legacySpecies": 30, "legacyForms": 88, "refinedLegacyForms": len(metrics),
              "refinedAdultSpecies": len(refined), "minimumChangedVolumesPerForm": 1,
              "minimumChangedVolumesPerAdult": 3,
              "ignoresNamesColorsMaterials": True,
              "method": "Multiset of shape, size and world transform, rounded to 1e-4; no subjective art score",
              "forms": metrics}
    destination = ROOT / "docs/bestiary40/REFINEMENT_METRICS.json"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print("PASS geometry refinement: all88 legacy forms changed /30adult designs have >=3 changed volumes; colors/names ignored")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--geometry", type=Path)
    args = parser.parse_args()
    if args.geometry:
        check(args.geometry)
    else:
        with tempfile.TemporaryDirectory(prefix="feras-refinement-") as temporary:
            geometry = Path(temporary) / "geometry.json"
            subprocess.run([os.environ.get("LUNE_BIN", "lune"), "run",
                            "scripts/sculpt/export_models.luau", str(ROOT), str(geometry), "full"],
                           cwd=ROOT, check=True)
            check(geometry)
