from pathlib import Path
import subprocess,hashlib,json
root=Path(__file__).resolve().parents[2]
base='c5a3860d77a68b6f8a18c771bfd07c5aaef5669d'
known=base
if subprocess.run(['git','cat-file','-e',known],cwd=root,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode:known='9ece1fd6a35b7bbd8cd871bb2a265652ce0c8033'
shared=['Creatures','Elements','Breeding','CaptureRules','CaptureMath','CombatRules','CreatureGrant','EncounterPools','SpeciesRules','LevelBands','Access','Migration','PhoenixQuest','Progression','Economy','Islands','Story','Missions','Config']
server=['DataService','GameService','EncounterService','RegionGuard','RegionService','Transport','Main.server','Guardians','Wildlife','MonetizationService','CompanionService','Biomes']
records={}
for folder,names in [('shared',shared),('server',server)]:
 for name in names:
  path=f'src/{folder}/{name}.luau';before=subprocess.check_output(['git','show',known+':'+path],cwd=root);after=(root/path).read_bytes();assert before==after,f'Mudança fora do escopo visual: {path}';records[path]=hashlib.sha256(after).hexdigest()
(root/'docs/art/GAMEPLAY_UNCHANGED.json').write_text(json.dumps({'baseline':base,'scope':'gameplay/save/balance/persistent IDs byte-identical','files':records},indent=2))
print('PASS art scope:',len(records),'arquivos de gameplay/save/balance/IDs idênticos ao baseline')
