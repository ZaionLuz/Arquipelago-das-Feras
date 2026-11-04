# Auditoria gráfica — art-overhaul

Stack confirmada: Roblox/Luau + Rojo, rigs Motor6D, WorldModels e ViewportFrames. Não existe package.json, canvas web, tileset em uso ou runtime de sprites 2D. Referência de origem: árvore V7 publicada em c5a3860.

✔ Suíte base executada em checkout isolado, sem alterações; docs/ART_BASELINE.txt.
Não há Roblox Studio/renderizador Roblox neste Linux. Playwright não executa uma experiência Roblox. Screenshots reais de todas as telas e notas estéticas observadas não estão disponíveis. As notas abaixo são **prioridade heurística por inspeção do código**, não avaliação de screenshots ou aprovação artística.

| Superfície/inventário | Fonte | Nota técnica estimada /10 | Lacuna |
|---|---|---:|---|
| 30 monstros × estágios, Fênix, rigs | CreatureDesigns/Features/Factory, Animator | 5 | primitivas lisas, rostos e materiais inconsistentes |
| Seis elementos/raridades | Elements, UI, catálogo | 5 | cores soltas e indicação sobretudo textual |
| Batalha/guardião/captura | EncounterUI, SolarPresentation | 3 | chão plano genérico, pouco cenário, HP e feedback simples |
| Sete ilhas e céu/água/pontes | World, Biomes, IslandArchitecture | 4 | repetição de geometrias, bordas e paletas heterogêneas |
| Casas/acampamento/interiores | StartingCamp, SanctuaryService | 4 | volumes básicos sem acabamento |
| Altar e ruínas solares | SanctuaryBuilder, SolarPresentation | 5 | materiais sem direção conjunta, efeitos simples |
| Jogador | avatar Roblox nativo | 5 | aparência escolhida pelo usuário; preservar e aplicar apenas ambientação/cosmética local |
| Maia/NPC/placas/prompts | Researcher, World | 3 | corpo simples e texto padrão |
| HUD, navegação, ilhas, opções | Client, UITheme | 4 | cantos redondos e fontes genéricas, símbolos de moeda em texto |
| Bestiário/party/coleção | JournalUI, CollectionUI | 5 | previews funcionais, ausência de moldura e ícones próprios |
| Ovos/loja/habitats/missões | NurseryUI, SanctuaryUI, Client | 4 | linguagem de componentes genérica |
| Título/loading/diálogo/notificações | Client, Researcher | 2 | sem apresentação coordenada |
| Ícones (tipos/itens/status/ações) | rótulos e caracteres | 2 | atlas e componentes originais ausentes |
| VFX, dano, evolução, transições | Client, EncounterUI, Solar, Collection | 4 | orbes genéricos e pouca variação visual |
| Fontes/bordas/escala/espaçamento | arquivos de UI | 3 | valores dispersos, sem fonte pixel |
| Performance visual | cache/LOD V7 | 6 | limites existentes; FPS real e memória de aparelho não medidos |

Todos os elementos listados têm destino no checklist ART_PROGRESS. Renderizações offline mostram geometria exportada dos builders, com limitações explícitas para física, transparência, meshes e efeitos Roblox. Não são screenshots do jogo. Nenhum asset de terceiros será copiado.
