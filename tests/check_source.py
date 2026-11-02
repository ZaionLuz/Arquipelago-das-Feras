"""Checks de integridade, não substituem execução Luau/Studio."""
import json,re,zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
original=Path('/workspace/attachments/77f9b470-e2d4-401c-b70a-a265207462e4/arquipelago-das-feras (1).zip')
config=json.loads((root/'default.project.json').read_text())
def walk(x):
 if isinstance(x,dict):
  if '$path' in x:assert (root/x['$path']).exists()
  for v in x.values():walk(v)
walk(config)
assert len(re.findall(r'^add\(', (root/'src/shared/Creatures.luau').read_text(),re.M))==30
if original.exists():
 with zipfile.ZipFile(original) as z:
  for name in ['Islands','Elements','Sounds']:
   p=f'src/shared/{name}.luau';assert z.read(p)==(root/p).read_bytes(),p
print('PASS: Rojo paths, JSON, 30 espécies e catálogos originais preservados')
designs=(root/'src/shared/CreatureDesigns.luau').read_text()
ids=set(re.findall(r'^add\("([^"]+)"', (root/'src/shared/Creatures.luau').read_text(),re.M))
design_ids=set(re.findall(r'\b([a-z]+)=\{crest=',designs))
assert ids==design_ids,(ids-design_ids,design_ids-ids)
print('PASS: 30 designs próprios, sem IDs ausentes ou órfãos')

if original.exists():
 with zipfile.ZipFile(original) as z:
  legacy=set(re.findall(r'^add\("([^"]+)"',z.read('src/shared/Creatures.luau').decode(),re.M))
  assert legacy <= ids and ids-legacy=={'fenix'}
print('PASS: todos os IDs legados preservados; somente fenix adicionada')
