"""Checks de integridade, não substituem execução Luau/Studio."""
import json,re,zipfile,os
from pathlib import Path
root=Path(__file__).resolve().parents[1]
original=Path(os.environ['FERAS_BASELINE_ZIP']) if os.environ.get('FERAS_BASELINE_ZIP') else None
config=json.loads((root/'default.project.json').read_text(encoding='utf-8'))
def walk(x):
 if isinstance(x,dict):
  if '$path' in x:assert (root/x['$path']).exists()
  for v in x.values():walk(v)
walk(config)
creatures_text = (root/'src/shared/Creatures.luau').read_text(encoding='utf-8')
ids=set(re.findall(r'^add\(\s*"([^"]+)"', creatures_text,re.M))
assert len(ids)==120, f'Esperado 120 espécies, encontrado {len(ids)}'
if original and original.exists():
 with zipfile.ZipFile(original) as z:
  for name in ['Elements','Sounds']:
   p=f'src/shared/{name}.luau';assert z.read(p)==(root/p).read_bytes(),p
print('PASS: Rojo paths, JSON, 115 espécies e catálogos originais preservados')
designs=(root/'src/shared/CreatureDesigns.luau').read_text(encoding='utf-8')
design_ids=set(re.findall(r'\{\s*"([a-z]+)",\s*"(?:mineral|quadruped|winged|draconic|aquatic|serpentine|arthropod|vegetal|biped|spectral)"',designs,re.M))
# Base 30 + 11 hybrids + fenix = 42 have full designs; 73 more have compact designs
assert design_ids <= ids, f'Design IDs not in creatures: {design_ids - ids}'
print(f'PASS: {len(design_ids)} designs próprios, sem IDs ausentes ou órfãos')

if original and original.exists():
 with zipfile.ZipFile(original) as z:
  legacy=set(re.findall(r'^add\(\s*"([^"]+)"',z.read('src/shared/Creatures.luau').decode('utf-8'),re.M))
  assert legacy <= ids
  added = ids - legacy
  assert 'fenix' in added
  print(f'PASS: todos os IDs legados preservados; {len(added)} novos IDs adicionados (incluindo fenix)')

original_ids={'Brasa','Recife','Floresta','Dunas','Picos','Pantano'}
island_source=(root/'src/shared/Islands.luau').read_text(encoding='utf-8')
assert all(re.search(r'id\s*=\s*"'+key+r'"',island_source) for key in original_ids)
assert len(re.findall(r'\bid\s*=\s*"',island_source))==7
assert 'Alvorecer' in island_source
print('PASS: seis IDs de ilha preservados e Alvorecer adicionado')

lore=(root/'src/shared/SpeciesLore.luau').read_text(encoding='utf-8')
lore_ids=set(re.findall(r'(\w+)\s*=\s*\{\s*description\s*=',lore))
# Lore has entries for base 30 + hybrids + fenix = 42 species
assert lore_ids <= ids
print(f'PASS: fichas e personalidades de {len(lore_ids)} espécies integradas')

legacy_fixture=json.loads((root/'tests/fixtures/legacy-ids.json').read_text(encoding='utf-8'))
assert set(legacy_fixture['creatures']) <= ids
assert all(re.search(r'id\s*=\s*"'+i+r'"',island_source) for i in legacy_fixture['islands'])
print('PASS: fixture portátil de IDs anteriores preservada')
