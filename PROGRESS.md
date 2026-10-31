# Entrega incremental

## Fase 1 — implementada em código; validação Studio pendente
- Mesma chave/DataStore ArquipelagoV1/P<UserId>, versão 2 normalizada sem remover IDs.
- Aquisição e renovação por UpdateAsync com token único e lease de 180s; autosave existente de 60s renova. Sessão concorrente recusada. Escrita exige mesmo token; erro de carregamento não cria perfil padrão.
- Futuras versões e envelopes estruturalmente inválidos são recusados para evitar sobrescrita silenciosa. Campos legados válidos continuam migrados pelo validador.
- nextId reconciliado, ovos finitos, booleanos de recompensas verificados; snapshot profundo sem recibos e sem campos transitórios no salvamento.
- Escritas serializadas por perfil, liberações com tentativas, shutdown paralelo limitado a 25s.
- Filtro de argumentos escalares, remotes serializados por jogador; cliente tolera erro de transporte.
- Duelo exige convite recíproco de 30s. Convite é indicado na mensagem e instrução da Arena; não há popup no rival nesta versão.

## Fase 2 — primeira parcela concreta
Biomes.luau acrescenta rochas de brasa, corais/cristais, árvores/flora, ruínas, nuvens e árvores umbrais. Geração determinística com caminhos e centro livres. Marcador explorável altera atributo BiomaVisitado no servidor com verificação de distância. Decoração sem colisão para não bloquear pontes. World mantém posições originais e coloca atributos de dono/família nos modelos. Idle varia por família e ignora modelos além de 130 studs. Não implementa caminhada articulada. HUD e modelos por espécie continuam pendentes.

## Verificações realizadas
Inspeção do código original; comparação automática dos catálogos preservados; parse JSON Rojo; teste estrutural de caminhos mapeados e módulos; integridade do ZIP. Não há Luau, Rojo ou Roblox Studio instalados. Nenhum teste de execução Luau, teste visual, multiplayer ou DataStore real foi realizado. Esta entrega é fonte para teste, não uma versão validada para publicação comercial.

## Próximo passo
Executar TESTES-STUDIO.md antes de avançar para habitats/bestiário/combate. Fase 1 não deve ser considerada homologada até os testes de concorrência, recibos e falha de rede passarem.

## Continuação — design e coleção
- CreatureDesigns.luau define 29 identidades e preserva IDs/catálogo. ModelFactory mantém API build(def,lv) com novas silhuetas: golem para Colossodune, espíritos, aves com bico/asas, insetos com oito pernas, serpentes segmentadas e quadrúpedes. Híbridos combinam duas cores. Evoluções mudam escala e quantidade de detalhes.
- Emissores contínuos e PointLights dos modelos foram removidos; neon é geometria limitada. Labels limitados a 65 studs; partes sem colisão/touch/query.
- Bestiário com silhuetas, filtros de elemento/descoberta e ViewportFrame. Modelos são criados apenas em cartões na região visível da lista e destruídos ao sair. Tela de descoberta para eclosão/evolução traz modelo, raridade, nível e atributos-base (não representa dano final da batalha).
- Proteção inFlight para requisições/batalhas sobrepostas; erro de transporte restaura entrada. Animações a 20Hz com cutoff 130 studs e articulação leve de asas, pernas e caudas.
- Ainda não implementados: caminhar real/pathfinding, inspeção detalhada com todas as informações, filtros de raridade/família, redesign completo do HUD, botões de habitat 3D. Interface existente de sete abas ainda exige teste no menor celular. Não alegamos homologação visual.
- Verificação de integridade dos catálogos passou novamente. A validação Luau/Studio e medidas de FPS continuam pendentes.

## Versão 3 — reprodução e estabilidade
Base: ZIP designs-v2 extraído, não projeto reiniciado.

Implementado:
- Breeding.outcomes calcula a distribuição completa do pick existente, sem mudar receitas/IDs. Mesma escolha entre elementos tem resultados; elementos distintos têm 25% de híbrido apenas se existir receita; o restante usa raridade ponderada 1/rar². Incremento de teto tem ramo de 10%; lendário segue exigindo ambos pais épicos ou superiores. Incubação = 30 × raridade² segundos. Sorteio continua no servidor.
- Economy centraliza nível máximo, inventário, incubadora, custo e incubação. GameService usa essas constantes e evita sobrescrever UID mesmo se contador ficar inconsistente em memória.
- NurseryUI: ovos 3D por elemento e cor secundária de híbrido; contagem e custo atualizados sem reconstruir viewports a cada segundo. Chocar só fica ativo quando pronto; acelerar só durante espera.
- Prévia de progenitores, resultados/probabilidades, custo e disponibilidade. Não há incompatibilidade artificial: preservadas todas as regras originais, inclusive cruzamentos sem híbrido.
- Eclosão épica/lendária com título distinto; apresentação 3D existente mantida. Não há animação de casca quebrando/rig de evolução: ainda são telas de apresentação.
- Compras reais bloqueadas no servidor; botões Robux removidos do mercado. Mercado de ovos com ouro preservado.
- Abas em duas fileiras para mais espaço de toque; painel de conteúdo reduzido para não cobrir a barra. Estados Processando/erro existentes preservados.

Arquivos novos: Economy.luau, NurseryUI.luau, testes isolados de reprodução, ABRIR-NO-STUDIO.md.
Modificados: Breeding, GameService, MonetizationService, Client.client, CollectionUI, documentação e testes estruturais.

Pendências: combate interativo por turnos/equipes, XP, santuário pessoal e construção, clima, criaturas selvagens e tutorial atualizado. PvE original permanece autoritativo, mas ainda simula todo combate de uma vez. Não avançamos sobre essas áreas sem homologar a prioridade 1 no Studio. Todos os limites e falhas conhecidos da auditoria continuam aplicáveis.

### Verificação efetivamente executada nesta entrega
Foi possível construir o CLI oficial Luau a partir do código-fonte luau-lang/luau (a versão anterior não tinha interpretador). Compilação sintática de todos os 20 arquivos .luau aprovada. Teste isolado das regras de Creatures/Breeding executado em Luau: 841 pares, 25.230 sorteios consistentes com a tabela de resultados, limites de estágio e IDs inválidos aprovados; 20 mil sorteios adicionais cinzelo/bolhinho deram 25,145% de híbridos, próximo dos 25% configurados. JSON/caminhos Rojo e 29 IDs/designs aprovados. Estes testes não executam APIs Roblox. Build de lugar via Rojo, visual, multiplayer, DataStore e performance continuam não executados.
A entrada do cliente também ganhou novas tentativas de Get enquanto o perfil carrega, evitando ficar sem interface por uma consulta inicial antes de Data.load terminar.
