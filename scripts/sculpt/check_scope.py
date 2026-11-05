"""This pass changes creature presentation only, compared with the frozen source baseline."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BASE = "7c9c4bfe5635a48d4d69d61faea2f36fe1fa385c"
ALLOWED = {"src/shared/ModelFactory.luau", "src/shared/CreatureDesigns.luau", "src/shared/DesignChecks.luau", "src/client/CreatureAnimator.luau", "src/client/CollectionUI.luau", "src/client/EncounterUI.luau", "src/client/JournalUI.luau"}
REFERENCE = ROOT / "docs/sculpt/GAMEPLAY_UNCHANGED.json"

def digest(blob):
    return hashlib.sha256(blob).hexdigest()

try:
    listing = subprocess.check_output(["git", "ls-tree", "-r", "--name-only", BASE, "src"], cwd=ROOT, stderr=subprocess.DEVNULL).decode().splitlines()
except (FileNotFoundError, subprocess.CalledProcessError):
    listing = list(json.loads(REFERENCE.read_text())["files"])
    frozen = json.loads(REFERENCE.read_text())["files"]
else:
    frozen = {p: digest(subprocess.check_output(["git", "show", f"{BASE}:{p}"], cwd=ROOT)) for p in listing if p not in ALLOWED}

for path, before in frozen.items():
    assert digest((ROOT / path).read_bytes()) == before, f"Gameplay/UI/save changed during sculpt pass: {path}"

REFERENCE.parent.mkdir(parents=True, exist_ok=True)
REFERENCE.write_text(json.dumps({"baselineLocal": BASE, "baselinePublished": "710f660d5d688a76f8289358a24ffd3f46e76b9a", "scope": "All prior source files except creature presentation, viewport caching, animator and design checks byte-identical", "files": frozen}, indent=2))
print(f"PASS sculpt scope: {len(frozen)} source files unchanged (gameplay, saves, economy, map, remaining UI)")
