"""Rejeita releases obsoletos sem alterar nem regravar fontes."""
from pathlib import Path
import hashlib,json,subprocess,sys
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'releases/BUILD-MANIFEST.json').read_text())
for name in manifest['files']:
 p=root/'releases'/name
 assert hashlib.sha256(p.read_bytes()).hexdigest()==manifest['sha256'],f'Hash inválido: {name}'
 subprocess.run([sys.executable,str(root/'scripts/check_bundle_sources.py'),str(p)],check=True,cwd=root)
print('PASS: três builds sincronizadas com os fontes; hash e inventário de módulos conferidos')
