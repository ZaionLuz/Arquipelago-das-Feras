# V7 — designs, acesso e encontro secreto

✔ Testes e build executados; ◐ homologação no Studio pendente. Evidências: docs/VALIDACAO_V7.md.

- Redesenhadas 30 espécies com dez famílias anatômicas, olhos/cabeças/caudas diferentes, transformação 7/15, materiais sem assets, rigs Motor6D e cache por estágio. Fênix adulta com 48 penas de asa, 11 penas de cauda, ponteiras e halo.
- Introduzidos Access/LevelBands, região de sessão, RegionGuard e arcos de entrada; novos perfis só Alvorecer, legado preservado. Ouro, XP e combate recalibrados por simulações.
- Fonte especial da Fênix: três vestígios nas Dunas/Picos, câmara nas ruínas, altar nível 45+, cooldown persistido e concessão por nonce. Pools comuns excluem especiais; ovos legados autenticados continuam válidos.
- DataStore ArquipelagoV1 mantido, esquema 5 idempotente; corrupção/futuro recusados antes de escrever. Estoques antigos acima de limites preservados.
- UI com nível/faixa/motivo e acesso legado por ilha, dificuldade, diário gradual, Viewports reutilizados e 452 textos em Strings. Apresentação especial local, efeitos configuráveis e câmera do Viewport restaurada.
- Runner headless, construtores nativos Lune, simulação de combate/captura, lint, galeria opt-in e documentação por espécie.

# Changelog — V6: primeira expedição e santuário

## Implementado nesta versão
- Ilha do Alvorecer adicionada sem remover seis IDs de ilha anteriores. Acampamento, fonte, Maia e flora inicial integrados ao mundo.
- Progressão do explorador e criaturas com teto 100, HUD de nível/XP e bloqueios graduais de novos destinos. Preços de desbloqueio mais baixos; permissões antigas preservadas.
- Viagem rápida para regiões desbloqueadas, ida ao terreno pessoal e portal de retorno. Solicita streaming antes de mover e mantém o personagem brevemente ancorado na chegada. Falhas de carregamento/personagem cancelam transporte.
- Santuários individuais; nove posições fixas, construção, movimentação, remoção de habitat vazio, melhoria até nível 3 e validação de elemento/capacidade. Terrenos são organizados por proprietário e liberados na saída.
- Seleção/armazenamento de companheiro persistido; representação próxima no multiplayer, escala para não ocupar a câmera, seguimento cosmético com desvio simples e reação a carinho.
- Sete capítulos iniciais de Maia, pontos de coleta, essências e recompensa única de descoberta. Guardiões regionais usam o modo de turnos sem captura e têm bônus individual único.
- Cinco tipos de selo com receitas, requisitos e condições de bônus, alternáveis dentro do encontro. Estado de selos e progresso novo persistidos na versão 4 de dados.
- Nova aba Santuário, opções gráficas/redução de movimentos e fichas de descrição/personalidade das 30 espécies no Bestiário.
- Testes novos de migração, santuário, progressão, receitas, ações do GameService e desafios. Nenhum resultado visual ou benchmark real foi inventado.

## Conteúdo que NÃO foi concluído
A meta total do briefing permanece aberta: não há 100 espécies jogáveis, dez mapas finais ou arte equivalente às referências. CRIATURAS.md distingue 30 espécies integradas de 70 conceitos planejados. PENDENCIAS.md lista o restante. Não anunciamos esta etapa como jogo comercial homologado.

## Arquivos principais
Novos módulos: Progression, SanctuaryRules, Story, SpeciesLore, SanctuaryService, CompanionService, CompanionClient, SanctuaryUI, Researcher, StartingCamp, Guardians e Transport.
Alterações: DataService, GameService, EncounterService, CombatRules, CaptureRules, World, Biomes, Wildlife, Islands, Economy, Client.client, EncounterUI, JournalUI e CreatureAnimator.
Documentos: CRIATURAS.md, MUNDO.md, SISTEMAS.md, PENDENCIAS.md, testes e instruções atualizados.
