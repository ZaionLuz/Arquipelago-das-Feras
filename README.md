# Arquipélago das Feras — bestiário de 40 criaturas em 3D

Os 30 modelos anteriores receberam uma nova passagem de anatomia, rostos e acabamento. Entram dez espécies originais, incluindo o **Kraken lendário**, com oito braços articulados, ventosas e coroa de coral. São **116 formas distintas**: 38 espécies com três estágios, mais Fênix e Kraken adultos.

- **Inspecionar os modelos:** abra [releases/Galeria-40-Feras.rbxl](releases/Galeria-40-Feras.rbxl) no Roblox Studio; as 116 formas já estão montadas. Há também uma [galeria leve](releases/Galeria-40-Feras-Leve.rbxl).
- **Jogar com o bestiário ampliado:** [releases/Feras-Bestiario-40.rbxlx](releases/Feras-Bestiario-40.rbxlx).
- [Pranchas de revisão offline](assets/bestiary40/review.html), [40 meshes GLB para revisão 3D](assets/bestiary40/meshes.zip), [relatório](docs/bestiary40/README.md) e [referências consultadas](docs/bestiary40/REFERENCIAS.md).
- Testar: `bash scripts/bestiary40/test`. Renderizar: `python scripts/sculpt/render_models.py --expected-species 40 --expected-forms 116`.

As novas espécies participam dos sistemas existentes de encontros, captura, equipe, companheiro e bestiário. O Kraken não participa de reprodução nem dos ovos comerciais. Os IDs e atributos das 30 espécies anteriores, os perfis e o esquema 6 do DataStore foram preservados.

Os modelos usam rigs nativos e versões leves; animações e previews mantêm as otimizações da entrega anterior. Renders Blender mostram a geometria exportada do jogo. Validação no renderer Roblox e medições reais de FPS dependem do [roteiro no Studio](docs/bestiary40/STUDIO_QA.md).

---

## Histórico — 30 criaturas remodeladas

A entrega anterior permanece em [Feras-Creature-Sculpt.rbxlx](releases/Feras-Creature-Sculpt.rbxlx), [galeria de 88 formas](releases/Galeria-Criaturas-3D.rbxl), [relatório](docs/sculpt/README.md) e [revisão offline](assets/sculpt/review.html). Seus renders e métricas são preservados como histórico; a entrega atual é o bestiário de 40 espécies acima.

---

## Histórico — fase de mundo aberto


Fase atual: aventura, batalha e captura em **sete regiões de 840 studs de diâmetro**, conectadas por caminhos de 64 studs. Todas podem ser visitadas desde o início; o perigo cresce pelos níveis próprios de cada região. O acampamento e a criação continuam como atividades opcionais.

Abra **[releases/Feras-Open-World.rbxlx](releases/Feras-Open-World.rbxlx)** no Roblox Studio e pressione Play. Para editar o código no VS Code, use `src/` e `default.project.json` com Rojo. Reconstrua o place após mudar as fontes: `rojo build -o releases/Feras-Open-World.rbxlx`.

- [Relatório da implementação e resultados](docs/open_world/README.md).
- [Roteiro de validação no Roblox Studio](docs/open_world/STUDIO_QA.md).
- Verificar esta fase: `bash scripts/open_world/test`.
- Persistência: esquema **6**, no mesmo DataStore **ArquipelagoV1**, com migração dos perfis anteriores e preservação de progresso válido.

Os testes automatizados cobrem regras, persistência simulada e geometria nativa. Física, streaming real, multiplayer, renderização e desempenho precisam da validação no Studio descrita acima.

---

## Histórico — art-overhaul

Reforma visual anterior sobre a V7. **releases/Feras-Art-Overhaul.rbxlx** preserva essa entrega histórica; a versão atual de mundo aberto mantém sua direção artística e amplia os sistemas e o mapa.

- Comparações e resultados: **docs/ART_REPORT.md**.
- Revisão de atlas/poses: **assets/review.html** (offline, não é o jogo).
- Regenerar imagens: `pip install -r scripts/art/requirements.txt` e `python scripts/art/build_assets.py`, com Lune no PATH ou LUNE_BIN.
- Verificador histórico: `bash scripts/art/test` na branch `art-overhaul`. Ele exige gameplay igual à V7 e não é o verificador da fase atual; nesta branch use `bash scripts/open_world/test`.
- Tokens: src/shared/ArtTokens.luau; arte original anterior preservada em assets/_legacy.

Testes nativos e build passaram. Play no Studio, screenshots reais, aprovação estética e60FPS continuam pendentes. O atlas exportado não usa IDs inventados nem é apresentado como sprite já integrado ao Roblox.

---

## Histórico — V7

RPG de exploração, batalha, captura e criação de criaturas para Roblox: 30 espécies, sete ilhas, santuários pessoais, habitats, cruzamento, companheiro e capítulos.

## Abrir e jogar

O arquivo **releases/Feras-V7.rbxlx** preserva a V7 histórica. Para jogar a fase atual, abra o place de mundo aberto indicado no início deste documento. Os places já incluem os scripts; não precisa colá-los manualmente nem instalar o plugin Rojo para abri-los.

Para editar pelo VS Code, mantenha `src/` e `default.project.json`. Com Rojo instalado: `rojo serve` para sincronizar pelo plugin, ou `rojo build -o Feras.rbxlx`. Alterações em src não atualizam automaticamente o bundle de releases: reconstrua o place.

Em experiência privada de teste, habilite API Services para verificar persistência real. A fase atual mantém o DataStore ArquipelagoV1 e migra para esquema 6. Dados corrompidos/futuros causam recusa de entrada e nunca reset automático. Os bundles históricos não são rollback de perfis já migrados para uma versão que eles não reconhecem.

## Verificar e personalizar

- `bash scripts/test`: requer Python 3, Luau CLI/compiler, Lune e Rojo no PATH. Variáveis opcionais: LUAU_BIN, LUAU_COMPILER_BIN, LUNE_BIN, ROJO_BIN.
- `selene src` e `stylua --syntax Luau --check src scripts` para lint/formatação. O standard v7_roblox declara globais da plataforma; não é tipagem completa de APIs.
- Config.V7 permite rollback de enforcement, altar e exigência do guardião. Config.Assets e Sounds estão vazios; nenhum ID externo inventado. IDs de produtos/passes continuam 0, desativados.
- Textos visíveis em `src/shared/Strings.luau`; anatomia em CreatureDesigns/CreatureFeatures/ModelFactory; curva em LevelBands/Progression e parâmetros de luta em CombatRules.
- Para revisão da galeria: docs/QA_STUDIO_V7.md. Fichas: docs/CRIATURAS.md. Resultados: docs/VALIDACAO_V7.md. Decisões e exceções de legado: docs/DECISOES_V7.md.

✔ Suites e build executados headless. ◐ Aparência, física, multiplayer e desempenho em celular exigem Roblox Studio; não se afirma homologação visual. A meta histórica de 100 espécies e estágio 4 da Fênix permanece fora desta V7.
