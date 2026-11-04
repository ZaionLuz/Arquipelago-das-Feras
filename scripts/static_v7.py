from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]
allowed={'Creatures.luau','CreatureDesigns.luau','CreatureGrant.luau','SpeciesRules.luau','Migration.luau','DesignChecks.luau','JournalUI.luau','CreatureGallery.luau'}
for p in (root/'src').rglob('*.luau'):
 s=p.read_text()
 if re.search(r'[\"\']fenix[\"\']|\.fenix\b',s):assert p.name in allowed, f'ID especial fora da lista: {p}'
 if re.search(r'\b(?:d|profile)\.creatures\s*\[[^\]]+\]\s*=',s):assert p.name=='CreatureGrant.luau',f'Concessão fora do ponto único: {p}'
 if p.name not in {'Sounds.luau','Strings.luau'}:assert not re.search(r'rbxassetid://[1-9]\d*',s),f'Asset não configurável: {p}'
assert 'ArquipelagoV1' in (root/'src/server/DataService.luau').read_text()
assert 'Run:IsStudio()' in (root/'src/server/CreatureGallery.luau').read_text()
print('PASS V7.07: varredura estática de ID especial, concessão central, chave preservada e galeria só Studio')
# A referência V6 é documentação, não fixture real de conta. Sem afirmar proveniência inexistente.
fixtures=json.loads((root/'tests/fixtures/v1-v6.json').read_text());assert len(fixtures)==6 and all(v['synthetic'] for v in fixtures.values())
print('PASS: proveniência das seis fixtures explicitamente sintética')
