# V7 — auditoria da base V6

✔ Executado: suíte anterior (55 arquivos compilados e sete suítes). Saída integral: `docs/BASELINE_V6.txt`. Fonte de partida: commit a35b1ea420381a378f18dad46d306d2ab910d3da.

## Divergências

- V6 de aplicação usa versão persistente 4, não um esquema chamado V6. Não há fixtures de contas reais: as fixtures de teste serão derivadas dos construtores/documentação históricos, identificadas como sintéticas.
- A Fênix não era exclusiva: participava de pools genéricos, ovos e reprodução.
- O acesso verificava unlocked em vários pontos, sem região autoritativa única; novos perfis tinham três regiões abertas.
- Os modelos eram compostos de peças ancoradas e o cliente alterava CFrames. Não havia rig Motor6D, validação completa ou cache.
- Apenas Luau CLI está disponível inicialmente por caminho absoluto; Lune 0.11.1 foi instalado nesta execução. Lune não implementa Model:GetBoundingBox/PivotTo; métricas deverão usar CFrames/Size reais e cálculo próprio de AABB.

## Módulos

| Caminho | Papel |
|---|---|
| `src/client/Client.client.luau` | cliente |
| `src/client/CollectionUI.luau` | cliente |
| `src/client/CompanionClient.luau` | cliente |
| `src/client/CreatureAnimator.luau` | cliente |
| `src/client/EncounterUI.luau` | cliente |
| `src/client/JournalUI.luau` | cliente |
| `src/client/NurseryUI.luau` | cliente |
| `src/client/SanctuaryUI.luau` | cliente |
| `src/client/UITheme.luau` | cliente |
| `src/server/Biomes.luau` | servidor |
| `src/server/CompanionService.luau` | servidor |
| `src/server/DataService.luau` | servidor |
| `src/server/EncounterService.luau` | servidor |
| `src/server/GameService.luau` | servidor |
| `src/server/Guardians.luau` | servidor |
| `src/server/IslandArchitecture.luau` | servidor |
| `src/server/Main.server.luau` | servidor |
| `src/server/MonetizationService.luau` | servidor |
| `src/server/Researcher.luau` | servidor |
| `src/server/SanctuaryService.luau` | servidor |
| `src/server/StartingCamp.luau` | servidor |
| `src/server/Transport.luau` | servidor |
| `src/server/Wildlife.luau` | servidor |
| `src/server/World.luau` | servidor |
| `src/shared/Access.luau` | compartilhado |
| `src/shared/Breeding.luau` | compartilhado |
| `src/shared/CaptureMath.luau` | compartilhado |
| `src/shared/CaptureRules.luau` | compartilhado |
| `src/shared/CombatRules.luau` | compartilhado |
| `src/shared/Config.luau` | compartilhado |
| `src/shared/CreatureDesigns.luau` | compartilhado |
| `src/shared/CreatureFeatures.luau` | compartilhado |
| `src/shared/CreatureGrant.luau` | compartilhado |
| `src/shared/Creatures.luau` | compartilhado |
| `src/shared/DesignChecks.luau` | compartilhado |
| `src/shared/Economy.luau` | compartilhado |
| `src/shared/Elements.luau` | compartilhado |
| `src/shared/EncounterPools.luau` | compartilhado |
| `src/shared/Islands.luau` | compartilhado |
| `src/shared/LevelBands.luau` | compartilhado |
| `src/shared/Migration.luau` | compartilhado |
| `src/shared/Missions.luau` | compartilhado |
| `src/shared/ModelFactory.luau` | compartilhado |
| `src/shared/PhoenixQuest.luau` | compartilhado |
| `src/shared/Progression.luau` | compartilhado |
| `src/shared/SanctuaryRules.luau` | compartilhado |
| `src/shared/Skills.luau` | compartilhado |
| `src/shared/Sounds.luau` | compartilhado |
| `src/shared/SpeciesLore.luau` | compartilhado |
| `src/shared/SpeciesRules.luau` | compartilhado |
| `src/shared/Story.luau` | compartilhado |
| `src/shared/Strings.luau` | compartilhado |

## Remotes da base

| Nome | Sentido | Parâmetros |
|---|---|---|
| Net | RF cliente → servidor | action:string, a:string/integer/nil, b:string/integer/nil; p é injetado pelo Roblox |
| EncounterNet | RF cliente → servidor | token,version,action,uid; Resume usa apenas a sessão do próprio Player |
| EncounterNotice | servidor → cliente | snapshot do encontro |
| WildNotice | servidor → cliente | message,position?,success? |
| StoryNotice | servidor → cliente | message |

## Nível/ilha e concessões — referências da base

| Arquivo:linha | Trecho | Mudança prevista |
|---|---|---|
| `src/client/Client.client.luau:189` | `if S.unlocked[def.id] then row("Ovo de "..def.name.." — "..(80*def.idx).." ouro",{{"Comprar",function() call("BuyEgg",de` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/client/Client.client.luau:193` | `if S.unlocked[def.id] then row(def.name.." ("..def.el..") • Nível "..def.minLevel..(def.id==isl and " ✓" or ""),{{"Selec` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/client/Client.client.luau:273` | `for _,d in I.List do local dist=(I.pos(d.idx)-hrp.Position).Magnitude;if dist<bd then best,bd=d,dist end end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/client/SanctuaryUI.luau:23` | `local buttons=entry and {{"Mover → "..slot,function() call("MoveHabitat",def.id,slot) end},{"Melhorar • "..Rules.upgrade` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Biomes.luau:9` | `local rng=Random.new(100+def.idx)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Biomes.luau:73` | `if not data or not root or (root.Position-stone.Position).Magnitude>=16 or not data.unlocked[def.id] then return end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/DataService.luau:39` | `if typeof(raw.unlocked)=="table" then for id in I.ById do if raw.unlocked[id]==true then d.unlocked[id]=true end end end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/DataService.luau:54` | `for _,def in I.List do if d.unlocked[def.id] then slot+=1;d.sanctuary[def.id]={slot=slot,level=1} end end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/DataService.luau:60` | `if def and d.unlocked[isl] and typeof(list)=="table" then` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/EncounterService.luau:17` | `local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=s.foe.id,lv=s.foe.lv,xp=0}` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:37` | `if not def or not d.unlocked[id] or not root then return fail("Destino indisponível") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:38` | `if not Transport.go(p,I.pos(def.idx)+Vector3.new(0,9,24)) then return fail("Destino ainda não carregou. Tente novamente.` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:53` | `if not def or not d.unlocked[id] or d.sanctuary[id] or not SR.available(d.sanctuary,slot) then return fail("Habitat, pos` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:101` | `if not d.creatures[uid] or not def or not d.unlocked[isl] then return fail("Ilha ou criatura inválida") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:115` | `if not def or d.unlocked[isl] then return fail("Ilha inválida") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:116` | `if (d.playerLevel or 1)<(def.minLevel or 1) then return fail("Explorador nível "..def.minLevel.." necessário") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:118` | `d.gold-=def.cost;d.unlocked[isl]=true;return ok(p,def.name.." desbloqueada!")` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:135` | `local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=e.id,lv=1,xp=0};d.discovered[e.id]=true;table.remove(d.eggs,i);` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:140` | `if not cr or not def or not d.unlocked[isl] then return fail("Batalha inválida") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:145` | `local g=pool[rng:NextInteger(1,#pool)];local glv=math.min(MAXLV,(def.minLevel or 1)+g.rar*2);local me=C.ById[cr.id]` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:155` | `local gold=math.floor(12*def.idx*g.rar*(me.el==M.event(os.time()) and 1.25 or 1));local gem=rng:NextNumber()<0.2 and 1 o` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:167` | `if not def or not d.unlocked[isl] then return fail("Ilha inválida") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/GameService.luau:169` | `local cost=80*def.idx;if d.gold<cost then return fail("Precisa de "..cost.." ouro") end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Guardians.luau:11` | `local level=math.min(100,(island.minLevel or 1)+7)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Guardians.luau:13` | `model:PivotTo(CFrame.new(I.pos(island.idx)+Vector3.new(-20,4+lift,8)));model.Parent=folder` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Guardians.luau:17` | `if not d or not root or (root.Position-model.PrimaryPart.Position).Magnitude>13 or not d.unlocked[island.id] or Encounte` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/IslandArchitecture.luau:6` | `local rng=Random.new(718+def.idx)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Wildlife.luau:23` | `local level=def.id=="fenix" and 15 or math.min(100,(s.island.minLevel or 1)+def.rar*2-2)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Wildlife.luau:25` | `local ground=I.pos(s.island.idx)+Vector3.new(s.slot==1 and -11 or 11,4,6)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/server/Wildlife.luau:35` | `if not d.unlocked[s.island.id] then notice:FireClient(player,"Desbloqueie esta ilha antes de capturar.");return end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/Access.luau:9` | `local unlocked=profile.unlocked and profile.unlocked[id]==true` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/Access.luau:14` | `if band.previous and not (profile.unlocked and profile.unlocked[band.previous]) then return {ok=false,reason="LOCKED_PRE` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/CreatureGrant.luau:21` | `profile.creatures[uid]={id=id,lv=math.clamp(math.floor(options.level or 1),1,100),xp=0}` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/EncounterPools.luau:21` | `function P.rollLevel(region,rarity,rng)` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/Islands.luau:14` | `for i,d in L do d.idx=i;d.minLevel=Bands.ById[d.id].min;d.cost=Bands.ById[d.id].cost;d.ambient=AMB[d.id][1];d.clock=AMB[` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/SanctuaryRules.luau:13` | `function R.buildCost(def) return R.BuildBase*def.idx end` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |
| `src/shared/SanctuaryRules.luau:19` | `if unlocked[def.id] and typeof(entry)=="table" and R.slot(entry.slot) and not occupied[entry.slot] then` | Centralizar Access/LevelBands/CreatureGrant/pool conforme responsabilidade. |

## Caminhos que adicionavam criaturas

| Caminho | Fênix possível na V6? | Tratamento V7 |
|---|---|---|
| Inicialização | Não (Cinzelo/Bolhinho) | Novo perfil só Alvorecer; sementes iniciais naturais. |
| Migração | Mantinha espécies/ovos existentes | Não criar espécimes; preservar IDs, números e permissões. |
| Captura selvagem | Sim | Pool filtrado; CreatureGrant central. |
| Hatch de ovo de reprodução/loja | Sim | Nonce por ovo; pool geral sem especial; concessão central e permissão controlada para ovo legado. |
| Breed | Sorteava ovo da Fênix | SpeciesRules.isGeneral em ambos ramos e tabela de chances. |
| BuyEgg | Loja excluía raridade 4, mas sem regra especial central | Filtrar também por isGeneral. |
| Missões/capítulos/diária/evento | Só moedas/gemas/XP/selos | Sem concessão de criatura. |
| Guardiões | Não capturáveis | Manter servidor bloqueando captura. |
| Santuário/companion | Moviam referências existentes | Não concedem espécies. |
| Troca/dev/admin | Não existem | Não adicionar atalhos. |

## Persistência e riscos

Campos base: v,gold,gems,seals,sealStock,playerLevel,playerXp,companion,storyClaimed,guardians,visited,materials,gatherAt,sanctuary,nextId,last,wins,creatures,eggs,stats,claimed,pass,receipts,dailyDay,streak,trophies,tut,habitat,unlocked,discovered e lease _session no registro.

Riscos prioritários: concorrência durante save especial, retomada após desconexão, spoofing de região, cache de instâncias com referências de joints e ausência de física/render em testes headless. Curvas anteriores: explorador 50+25×nível e criatura 35+15×nível; sob ritmo explicitado em simulação, o explorador chega ao 50 muito antes da meta de 16h. Ouro das regiões era muito inferior a uma hora de renda típica.

◐ A inspeção estética, barreiras físicas, física dos rigs, interfaces em dispositivos e concorrência real seguem dependentes de Studio.

## Medições consolidadas (comandos executados)

✔ Baseline de modelos: snapshot congelado `tests/models.generated.luau`, executado em stub para contagem. Não mede render/física/rotacionamento exato. ✔ V7: `lune run scripts/check_models.luau`, instâncias nativas e AABB por oito cantos dos CFrames.

| Espécie | Peças V6 em 1/7/15 | Peças V7 em 1/7/15 |
|---|---|---|
| abissauro | 33 / 37 / 41 | 14 / 20 / 24 |
| aeronimbo | 21 / 23 / 25 | 13 / 19 / 26 |
| ancestravore | 23 / 27 / 28 | 13 / 23 / 27 |
| aracnoflora | 25 / 29 / 31 | 23 / 36 / 42 |
| bolhinho | 18 / 20 / 21 | 16 / 22 / 26 |
| brotinho | 19 / 22 / 23 | 16 / 25 / 31 |
| carangueperola | 27 / 28 / 29 | 21 / 31 / 35 |
| caudalume | 21 / 22 / 23 | 11 / 16 / 21 |
| cinzavento | 33 / 39 / 44 | 20 / 32 / 40 |
| cinzelo | 16 / 19 / 22 | 11 / 18 / 22 |
| colossodune | 22 / 23 / 24 | 15 / 23 / 27 |
| escorpiodra | 23 / 25 / 27 | 22 / 34 / 38 |
| esfingeolito | 21 / 25 / 26 | 16 / 24 / 28 |
| fenix | 49 / 49 / 49 | 122 / 122 / 122 |
| fenixfuligem | 26 / 31 / 36 | 13 / 24 / 34 |
| folhuco | 24 / 27 / 28 | 16 / 25 / 31 |
| graozinho | 18 / 20 / 22 | 11 / 16 / 22 |
| lodinho | 16 / 19 / 21 | 11 / 17 / 24 |
| magmarau | 21 / 23 / 24 | 17 / 25 / 29 |
| magmaterra | 21 / 24 / 27 | 14 / 23 / 29 |
| marilisco | 23 / 24 / 25 | 13 / 18 / 23 |
| nevoamusgo | 23 / 27 / 28 | 14 / 24 / 28 |
| penugem | 24 / 30 / 36 | 15 / 26 / 36 |
| reinevoento | 18 / 22 / 24 | 11 / 17 / 24 |
| tempestalia | 26 / 31 / 36 | 16 / 28 / 36 |
| trovoraptor | 34 / 39 / 44 | 18 / 31 / 41 |
| vagalumorte | 25 / 26 / 27 | 20 / 30 / 34 |
| vaporino | 21 / 23 / 25 | 11 / 17 / 24 |
| ventanil | 25 / 31 / 36 | 16 / 26 / 34 |
| vulcanodrago | 33 / 37 / 41 | 18 / 31 / 41 |

Custo anterior: CFrame por peça a cada frame em animação local, sem limite de rigs ou LOD por distância; até 12 representantes por base e dois selvagens por ilha. V7: um Heartbeat central para juntas e previews, máximo 8/16/24 rigs em 30 Hz próximo ou 15 Hz médio, instâncias/componentes em cache. Seguidor e ambiente têm atualizadores próprios e não reconstroem os joints. O tempo por frame em ms não foi medido, porque não há renderer/Studio.

✔ Curvas anteriores medidas com Progression real extraído de a35b1ea, em scripts/audit_baseline.luau: BASELINE_PACING.json. Rodar a auditoria histórica exige exportar esse arquivo para /tmp/feras-v6-progression.luau com git show. Novos resultados: BALANCE_SIMULATION.json. A hipótese fixa de 50 vitórias/h isola a comparação, não representa telemetria real.

### Proveniência de fixtures

Não há dumps de contas reais no repositório ou anexos. V1–V6 são rótulos de aplicação; as fixtures reconstruídas usam esquemas 1,2,2,3,3,4 conforme a documentação histórica, e não seis versões persistentes diferentes. São sintéticas, explicitamente marcadas no JSON. O requisito de fixtures reais permanece pendente; não foi inventada proveniência.

### Ferramentas e verificações finais

Rojo 7.7.1 constrói place e sourcemap. Lune 0.11.1 executa os builders com tipos Roblox, sem joints físicos ou render. Luau compiler e CLI passam. Selene 0.32.0 passa com std Luau e globais de plataforma do v7_roblox.yml; StyLua 2.6.0 formata e verifica. luau-analyze foi executado sem definições Roblox e acusa globals script/Color3/etc desconhecidos; não é análise limpa. luau-lsp 1.70.1 foi baixado em arquitetura ARM por engano, não executou no x86. Nova tentativa de obtenção x86 falhou na conexão de rede; análise tipada completa está pendente.

Os callbacks de Main.Net e GameService foram executados em teste com tipos forjados/ilhas bloqueadas; nenhum chegou ao transporte. EncounterService foi interrompido em yields de Data.save para testar concorrência cooperativa. SanctuaryBuilder construiu 74 peças nativas (sinais simulados), com prompts de glifo validados por distância e região. Aspecto, colisão física, streaming, UI e multiplayer real continuam ◐.
