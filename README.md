# Arquipélago das Feras — art-overhaul

Reforma visual original sobre a V7, em branch separada. Abra **releases/Feras-Art-Overhaul.rbxlx** no Roblox Studio. Gameplay, save e balanceamento permanecem iguais; a apresentação usa modelos3D refinados e UI em pixel grid.

- Comparações e resultados: **docs/ART_REPORT.md**.
- Revisão de atlas/poses: **assets/review.html** (offline, não é o jogo).
- Regenerar imagens: `pip install -r scripts/art/requirements.txt` e `python scripts/art/build_assets.py`, com Lune no PATH ou LUNE_BIN.
- Verificar código/arte: `bash scripts/art/test`; scripts e ferramentas estão descritos no relatório.
- Tokens: src/shared/ArtTokens.luau; arte original anterior preservada em assets/_legacy.

Testes nativos e build passaram. Play no Studio, screenshots reais, aprovação estética e60FPS continuam pendentes. O atlas exportado não usa IDs inventados nem é apresentado como sprite já integrado ao Roblox.

---

# Arquipélago das Feras — V7

RPG de exploração, batalha, captura e criação de criaturas para Roblox: 30 espécies, sete ilhas, santuários pessoais, habitats, cruzamento, companheiro e capítulos.

## Abrir e jogar

Baixe o ZIP do repositório, extraia e abra **releases/Feras-V7.rbxlx** no Roblox Studio. Pressione Play. O place já inclui os scripts; não precisa colá-los manualmente nem instalar o plugin Rojo para essa opção.

Para editar pelo VS Code, mantenha `src/` e `default.project.json`. Com Rojo instalado: `rojo serve` para sincronizar pelo plugin, ou `rojo build -o Feras.rbxlx`. Alterações em src não atualizam automaticamente o bundle de releases: reconstrua o place.

Em experiência privada de teste, habilite API Services para verificar persistência real. O jogo mantém a chave ArquipelagoV1 e migra para esquema 5 sem rebaixar progresso. Dados corrompidos/futuros causam recusa de entrada e nunca reset automático.

## Verificar e personalizar

- `bash scripts/test`: requer Python 3, Luau CLI/compiler, Lune e Rojo no PATH. Variáveis opcionais: LUAU_BIN, LUAU_COMPILER_BIN, LUNE_BIN, ROJO_BIN.
- `selene src` e `stylua --syntax Luau --check src scripts` para lint/formatação. O standard v7_roblox declara globais da plataforma; não é tipagem completa de APIs.
- Config.V7 permite rollback de enforcement, altar e exigência do guardião. Config.Assets e Sounds estão vazios; nenhum ID externo inventado. IDs de produtos/passes continuam 0, desativados.
- Textos visíveis em `src/shared/Strings.luau`; anatomia em CreatureDesigns/CreatureFeatures/ModelFactory; curva em LevelBands/Progression e parâmetros de luta em CombatRules.
- Para revisão da galeria: docs/QA_STUDIO_V7.md. Fichas: docs/CRIATURAS.md. Resultados: docs/VALIDACAO_V7.md. Decisões e exceções de legado: docs/DECISOES_V7.md.

✔ Suites e build executados headless. ◐ Aparência, física, multiplayer e desempenho em celular exigem Roblox Studio; não se afirma homologação visual. A meta histórica de 100 espécies e estágio 4 da Fênix permanece fora desta V7.
