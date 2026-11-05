"""Verify the additive catalog/model scope against the delivered 30-species tree."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BASE = "e773b32237466f1b80dc6c533acd069dfaeec27f"
PUBLISHED_BASE = "063a05d2ee156137912160cfc042bebca9a49e54"
REPORT = ROOT / "docs/bestiary40/SOURCE_SCOPE.json"
ALLOWED = {
    "src/shared/Creatures.luau", "src/shared/CreatureDesigns.luau",
    "src/shared/SpeciesLore.luau", "src/shared/SpeciesRules.luau",
    "src/shared/EncounterPools.luau", "src/shared/Breeding.luau",
    "src/shared/ModelFactory.luau", "src/shared/SculptOrganic.luau",
    "src/shared/SculptMystic.luau", "src/shared/SculptDrakes.luau",
    "src/shared/SculptTidal.luau", "src/shared/SculptSky.luau",
}
ADDED = {"src/shared/SculptExpansionA.luau", "src/shared/SculptExpansionB.luau"}
GAME = "src/server/GameService.luau"


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def outside_breed(blob):
    # Only A.Breed may differ in the server action service. All other actions,
    # remote validation, economy and request handling remain byte-identical.
    text = blob.decode("utf8")
    pattern = r"(?ms)^function A\.Breed\(.*?(?=^function A\.|\Z)"
    result, count = re.subn(pattern, "-- A.Breed catalog eligibility guard\n", text)
    assert count == 1, "A.Breed function boundary missing/ambiguous"
    return result.encode("utf8")


try:
    names = subprocess.check_output(
        ["git", "ls-tree", "-r", "--name-only", BASE, "src"], cwd=ROOT,
        stderr=subprocess.DEVNULL,
    ).decode().splitlines()
    source = {name: subprocess.check_output(["git", "show", f"{BASE}:{name}"], cwd=ROOT)
              for name in names}
    baseline = {name: digest(blob) for name, blob in source.items()}
    breed_remainder = digest(outside_breed(source[GAME]))
except (FileNotFoundError, subprocess.CalledProcessError):
    frozen = json.loads(REPORT.read_text())
    baseline = frozen["baselineFiles"]
    breed_remainder = frozen["gameServiceOutsideBreedSha256"]

current = {p.relative_to(ROOT).as_posix(): p.read_bytes()
           for p in (ROOT / "src").rglob("*.luau")}
assert set(current) == set(baseline) | ADDED, "Unexpected source addition/removal"
unchanged = {name: old for name, old in baseline.items() if name not in ALLOWED | {GAME}}
for name, old in unchanged.items():
    assert digest(current[name]) == old, f"Outside bestiary scope: {name}"
assert digest(outside_breed(current[GAME])) == breed_remainder, "Server action changed outside A.Breed"
assert 'ProfileVersion = 6' in current["src/shared/Config.luau"].decode(), "Profile schema changed"
REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(json.dumps({
    "baselineLocal": BASE,
    "baselinePublished": PUBLISHED_BASE,
    "scope": "40-species additive catalog, designs, encounter weights and guarded breeding; all other source unchanged",
    "baselineFiles": baseline,
    "unchangedFiles": unchanged,
    "changedWithinScope": {name: {"before": baseline.get(name), "after": digest(current[name])}
                           for name in sorted(ALLOWED | ADDED | {GAME})},
    "gameServiceOutsideBreedSha256": breed_remainder,
    "saveSchema": 6,
    "dataStoreChanged": False,
    "studioExecution": False,
}, indent=2) + "\n")
print(f"PASS bestiary scope: {len(unchanged)} source files unchanged; only Breed differs in GameService; schema6 preserved")
