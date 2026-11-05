# Arquipélago das Feras — 30 criaturas remodeladas em 3D

Nova passagem dedicada exclusivamente à modelagem das30 espécies:88 formas, anatomias próprias, rostos em camadas e membros/caudas/asas articulados. Gameplay, save, mapa e economia preservados; caches e animações receberam otimizações para PCs mais fracos.

- **Inspecionar os modelos sem DataStore:** abra [releases/Galeria-Criaturas-3D.rbxl](releases/Galeria-Criaturas-3D.rbxl) no Roblox Studio. As88 formas já estão montadas.
- **Jogar com os modelos novos:** [releases/Feras-Creature-Sculpt.rbxlx](releases/Feras-Creature-Sculpt.rbxlx).
- [Relatório e direção das30 espécies](docs/sculpt/README.md), [pranchas de revisão offline](assets/sculpt/review.html) e [meshes GLB](assets/sculpt/meshes.zip).
- **Modo leve:** cerca de 19% menos peças nos adultos, previews fora da tela pausados e ajuste automático no Médio. Há também [galeria leve](releases/Galeria-Criaturas-3D-Leve.rbxl).
- Testar: `bash scripts/sculpt/test`. Renderizar: `python scripts/sculpt/render_models.py`.

Rigs nativos, clones, regressão e serialização foram verificados. Play/animação no renderer Roblox e desempenho real aguardam conferência no Studio. As imagens são renders Blender da geometria real exportada.

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
