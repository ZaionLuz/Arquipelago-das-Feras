from pathlib import Path
r=Path(__file__).resolve().parents[1]
# Reutiliza apenas os módulos puros, antes dos testes, sem executar combat.spec.
base=(r/'tests/combat.generated.luau').read_text().split('-- Executado pelo harness',1)[0]
s=(r/'src/server/EncounterService.luau').read_text()
s=s.replace('local RS=game:GetService("ReplicatedStorage");local Players=game:GetService("Players");local Http=game:GetService("HttpService")','')
s=s.replace('local Data=require(script.Parent.DataService);local C=require(RS.Shared.Creatures);local Rules=require(RS.Shared.CombatRules)','local Rules=R')
s=s.replace('local E={};local sessions={};local rng=Random.new();','local E={};local sessions={};local rng={NextNumber=function() return 0 end};')
s=s.replace('require(script.Parent.World)','World')
progression=(r/'src/shared/Progression.luau').read_text()
s=s.replace('require(RS.Shared.Progression)','Progression').replace('require(RS.Shared.CaptureRules)','Capture')
base+='\nlocal Progression=(function()\n'+progression+'\nend)()\n'
spec=(r/'tests/encounter-service.spec.luau').read_text().replace('-- SERVICE_MODULE','local E=(function()\n'+s+'\nend)()')
(r/'tests/encounter-service.generated.luau').write_text(base+'\n'+spec)
