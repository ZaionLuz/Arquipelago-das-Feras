"""Validate the exported review assets against the native source geometry."""
from pathlib import Path
import hashlib
import json
import math
import re
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
geometry = json.loads((ROOT / "assets/sculpt/geometry.json").read_text())
manifest = json.loads((ROOT / "assets/sculpt/manifest.json").read_text())
ids = set(re.findall(r'^add\(\s*"([^"]+)"', (ROOT / "src/shared/Creatures.luau").read_text(), re.M))
forms = {(id, stage) for id in ids for stage in ([3] if id == "fenix" else [1, 2, 3])}
assert len(ids) == 30 and len(forms) == 88
assert {(row["id"], row["stage"]) for row in geometry["models"]} == forms
assert len(geometry["models"]) == 88
canonical = json.dumps(geometry, sort_keys=True, separators=(",", ":")).encode()
assert manifest["sourceGeometryCanonicalSha256"] == hashlib.sha256(canonical).hexdigest()
assert not manifest["studioScreenshots"]
adults = {r["id"]: r for r in geometry["models"] if r["stage"] == 3}
summary = {r["id"]: r for r in manifest["models"]}
assert set(adults) == set(summary) == ids
archive = ROOT / "assets/sculpt/meshes.zip"
assert hashlib.sha256(archive.read_bytes()).hexdigest() == manifest["meshArchiveSha256"]
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert {n[:-4] for n in z.namelist() if n.endswith(".glb")} == ids
    rig_map = json.loads(z.read("rig-map.json"))
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
            for value in accessor.get("min", []) + accessor.get("max", []):
                assert isinstance(value, (int, float)) and math.isfinite(value)
        assert summary[id]["parts"] == len(adults[id]["parts"])
        assert rig_map[id]["nativeJoints"] == adults[id]["joints"]
images = [ROOT / p for p in manifest["reviewImages"]["files"]]
assert len(images) == 36 and len(set(images)) == 36
assert all(p.is_file() and p.stat().st_size > 1000 for p in images)
from PIL import Image
for path in images:
    with Image.open(path) as im:
        im.verify()
print("PASS assets: 30 self-contained GLBs, 88 native forms, 36 review images, source/mesh hashes and rig maps verified")
