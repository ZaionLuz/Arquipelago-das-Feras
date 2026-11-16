"""Integridade real do catálogo expandido; execução e build são verificações separadas."""
import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def read(p): return (root/p).read_text()
def walk(x):
 if isinstance(x,dict):
  if '$path' in x: assert (root/x['$path']).exists(),x['$path']
  for v in x.values(): walk(v)
walk(json.loads(read('default.project.json')))
ids=re.findall(r'^add\(\s*"([^"]+)"',read('src/shared/Creatures.luau'),re.M)
assert len(ids)==len(set(ids)), 'IDs duplicados'
designs=set(re.findall(r'\{\s*"([a-z][a-z0-9]+)"\s*,',read('src/shared/CreatureDesigns.luau')))
assert set(ids)<=designs, set(ids)-designs
legacy=json.loads(read('tests/fixtures/legacy-ids.json'))
assert set(legacy['creatures'])<=set(ids),'ID legado removido'
assert 'fenix' in ids
islands=read('src/shared/Islands.luau')
assert all(re.search(r'id\s*=\s*"'+i+r'"',islands) for i in legacy['islands'])
assert len(re.findall(r'\bid\s*=\s*"',islands))==7
for p in (root/'src').rglob('*.luau'):
 assert p.read_text().strip(),f'Módulo vazio: {p}'
print(f'PASS: Rojo, {len(ids)} espécies únicas com receitas, IDs legados e sete ilhas preservados')
