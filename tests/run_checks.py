"""Regras puras e estrutura; não substitui teste no Roblox Studio."""
from pathlib import Path
import argparse,subprocess,sys
root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--luau',default='luau')
parser.add_argument('--compiler',default='luau-compile')
args=parser.parse_args()
for name in ['generate_breeding_test.py','generate_combat_test.py','generate_service_test.py','generate_models_test.py','generate_rpg_test.py','generate_data_test.py','generate_game_actions_test.py','check_source.py']:
 subprocess.run([sys.executable,str(root/'tests'/name)],cwd=root,check=True)
files=list(root.rglob('*.luau'))
for path in files:
 result=subprocess.run([args.compiler,str(path)],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 if result.returncode:
  sys.stderr.write(result.stderr.decode(errors='replace'));raise SystemExit(result.returncode)
print(f'PASS: sintaxe de {len(files)} arquivos Luau',flush=True)
for name in ['breeding.generated.luau','combat.generated.luau','encounter-service.generated.luau','models.generated.luau','rpg.generated.luau','data.generated.luau','game-actions.generated.luau']:
 subprocess.run([args.luau,str(root/'tests'/name)],cwd=root,check=True)
