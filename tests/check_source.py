"""Checks de integridade, não substituem execução Luau/Studio."""
import json,re,zipfile,os
from pathlib import Path
root=Path(__file__).resolve().parents[1]
original=Path(os.environ['FERAS_BASELINE_ZIP']) if os.environ.get('FERAS_BASELINE_ZIP') else None
config=json.loads((root/'default.project.json').read_text())
def walk(x):
 if isinstance(x,dict):
  if '$path' in x:assert (root/x['$path']).exists()
  for v in x.values():walk(v)
walk(config)
assert len(re.findall(r'^add\(', (root/'src/shared/Creatures.luau').read_text(),re.M))==30
if original and original.exists():
 with zipfile.ZipFile(original) as z:
  for name in ['Elements','Sounds']:
   p=f'src/shared/{name}.luau';assert z.read(p)==(root/p).read_bytes(),p
print('PASS: Rojo paths, JSON, 30 espécies e catálogos originais preservados')
designs=(root/'src/shared/CreatureDesigns.luau').read_text()
ids=set(re.findall(r'^add\("([^"]+)"', (root/'src/shared/Creatures.luau').read_text(),re.M))
design_ids=set(re.findall(r'\b([a-z]+)=\{crest=',designs))
assert ids==design_ids,(ids-design_ids,design_ids-ids)
print('PASS: 30 designs próprios, sem IDs ausentes ou órfãos')

if original and original.exists():
 with zipfile.ZipFile(original) as z:
  legacy=set(re.findall(r'^add\("([^"]+)"',z.read('src/shared/Creatures.luau').decode(),re.M))
  assert legacy <= ids and ids-legacy=={'fenix'}
print('PASS: todos os IDs legados preservados; somente fenix adicionada')

original_ids={'Brasa','Recife','Floresta','Dunas','Picos','Pantano'}
island_source=(root/'src/shared/Islands.luau').read_text()
assert all('id="'+key+'"' in island_source for key in original_ids)
assert len(re.findall(r'\{id="',island_source))==7
assert 'Alvorecer' in island_source
print('PASS: seis IDs de ilha preservados e Alvorecer adicionado')

lore=(root/'src/shared/SpeciesLore.luau').read_text()
lore_ids=set(re.findall(r' (\w+)=\{description=',lore))
assert lore_ids==ids
print('PASS: fichas e personalidades das 30 espécies integradas')

legacy_fixture=json.loads((root/'tests/fixtures/legacy-ids.json').read_text())
assert set(legacy_fixture['creatures']) <= ids
assert all('id="'+i+'"' in island_source for i in legacy_fixture['islands'])
print('PASS: fixture portátil de IDs anteriores preservada')
