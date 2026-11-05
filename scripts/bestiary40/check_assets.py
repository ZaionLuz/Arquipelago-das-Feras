"""Validate published DCC artifacts against all 40 runtime species and 116 forms."""
from pathlib import Path
import hashlib
import json
import math
import os
import re
import struct
import subprocess
import tempfile
import zipfile

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "assets/bestiary40"
geometry = json.loads((ASSETS / "geometry.json").read_text())
baseline = json.loads((ASSETS / "baseline_geometry.json").read_text())
manifest = json.loads((ASSETS / "manifest.json").read_text())
ids = set(re.findall(r'^add\(\s*"([^"]+)"', (ROOT / "src/shared/Creatures.luau").read_text(), re.M))
catalog = {row["id"]: row for row in geometry["catalog"]}
assert set(catalog) == ids and len(catalog) == 40
forms = {(id, stage) for id, row in catalog.items() for stage in range(row["minStage"], 4)}
assert {id for id, row in catalog.items() if row["minStage"] == 3} == {"fenix", "kraken"}
assert len(forms) == 116
assert {(row["id"], row["stage"]) for row in geometry["models"]} == forms
assert len(geometry["models"]) == 116 and geometry["detail"] == "full"
canonical = json.dumps(geometry, sort_keys=True, separators=(",", ":")).encode()
assert manifest["sourceGeometryCanonicalSha256"] == hashlib.sha256(canonical).hexdigest()
assert not manifest["studioScreenshots"] and manifest["forms"] == 116 and manifest["adults"] == 40
with tempfile.TemporaryDirectory(prefix="feras-assets-native-") as temporary:
    current_path = Path(temporary) / "geometry.json"
    subprocess.run([os.environ.get("LUNE_BIN", "lune"), "run",
                    "scripts/sculpt/export_models.luau", str(ROOT), str(current_path), "full"],
                   cwd=ROOT, check=True)
    runtime = json.loads(current_path.read_text())
    assert json.dumps(runtime, sort_keys=True, separators=(",", ":")).encode() == canonical, "DCC geometry is stale relative to runtime source"
adults = {row["id"]: row for row in geometry["models"] if row["stage"] == 3}
summary = {row["id"]: row for row in manifest["models"]}
assert set(adults) == set(summary) == ids

for row in geometry["models"]:
    names = {part["name"] for part in row["parts"]}
    assert len(names) == len(row["parts"]), f"Duplicate part names: {row['id']}:{row['stage']}"
    assert {"Body", "Head"} <= names and len(row["joints"]) >= 3
    for part in row["parts"]:
        assert len(part["cf"]) == 12 and len(part["size"]) == 3
        assert all(math.isfinite(v) for v in part["cf"] + part["size"] + part["color"])
        assert all(v > 0 for v in part["size"])
    for joint in row["joints"]:
        assert joint["part0"] in names | {"Root"} and joint["part1"] in names
        assert all(math.isfinite(v) for v in joint["c0"])

# Compare actual volumes/transforms, excluding metadata and color, so a label or
# palette change cannot masquerade as remodeling one of the original creatures.
def shape_signature(row):
    return sorted(json.dumps({key: part.get(key) for key in
                              ("class", "size", "cf", "shape", "mesh", "meshScale")}, sort_keys=True)
                  for part in row["parts"])


before = {(row["id"], row["stage"]): row for row in baseline["models"]}
after = {(row["id"], row["stage"]): row for row in geometry["models"]}
assert len(before) == 88 and len({id for id, _ in before}) == 30
assert set(before) < set(after)
refined_forms = 0
for key, row in before.items():
    changed = shape_signature(row) != shape_signature(after[key])
    refined_forms += int(changed)
    assert changed, f"No geometric refinement: {key}"

archive = ASSETS / "meshes.zip"
assert hashlib.sha256(archive.read_bytes()).hexdigest() == manifest["meshArchiveSha256"]
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert {name[:-4] for name in z.namelist() if name.endswith(".glb")} == ids
    rig_map = json.loads(z.read("rig-map.json"))
    assert set(rig_map) == ids
    for id in sorted(ids):
        blob = z.read(id + ".glb")
        assert hashlib.sha256(blob).hexdigest() == summary[id]["glbSha256"]
        magic, version, length = struct.unpack_from("<III", blob)
        assert magic == 0x46546C67 and version == 2 and length == len(blob)
        chunk_length, chunk_type = struct.unpack_from("<II", blob, 12)
        assert chunk_type == 0x4E4F534A
        gltf = json.loads(blob[20:20 + chunk_length])
        assert len(gltf.get("meshes", [])) >= 20
        assert all(not b.get("uri") for b in gltf["buffers"]), "GLB must be self-contained"
        for accessor in gltf.get("accessors", []):
            assert all(isinstance(value, (int, float)) and math.isfinite(value)
                       for value in accessor.get("min", []) + accessor.get("max", []))
        assert summary[id]["parts"] == len(adults[id]["parts"])
        assert rig_map[id]["nativeJoints"] == adults[id]["joints"]

images = [ROOT / path for path in manifest["reviewImages"]["files"]]
expected_images = {ROOT / "docs/bestiary40/images" / name for name in
                   ["creatures-40-adults.webp", "before-after.webp"]}
expected_images |= {ROOT / f"docs/bestiary40/images/stages/{id}.webp" for id in ids}
expected_images |= {ROOT / f"docs/bestiary40/images/heroes/{id}.webp" for id in
                    ("cinzelo", "folhuco", "carangueperola", "fenix", "kraken")}
assert len(images) == 47 and len(set(images)) == 47 and set(images) == expected_images
assert all(path.is_file() and path.stat().st_size > 1000 for path in images)
for path in images:
    with Image.open(path) as im:
        im.verify()
review = (ASSETS / "review.html").read_text()
assert all(f'value="{id}"' in review for id in ids)
assert "40 adultos" in review and "meshes.zip" in review
print(f"PASS assets: 40 self-contained GLBs, 116 native forms, {refined_forms}/88 prior forms and all30 adults remodeled, 47 review images, hashes and rig maps verified")
