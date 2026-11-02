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

## V4 — exploração compacta, captura e Fênix

### Implementado
- HUD reduzida, gaveta fechada por padrão, botão Menu/Fechar e fechamento com Escape. Uma única gaveta para abas; viewport do mapa livre durante exploração. Respeita DeviceSafeInsets. A área exata ocupada depende do dispositivo/tutorial e deve ser medida no Studio.
- Bestiário com uma prévia 3D giratória, seleção de espécies, filtros por raridade e bioma, exemplares possuídos e estágio. Espécies desconhecidas mantêm silhueta e texto oculto. Não copiamos interface/assets da referência; usamos somente a direção de composição.
- Marcos de composição por bioma: formação vulcânica, cachoeira estilizada, árvore principal, arco de ruínas, portal umbral e nuvens/cristais. Mantidas seis ilhas e seus IDs. Gelo/tempestade como novos biomas ainda não foram implementados.
- Wildlife: até 12 encontros simultâneos (2/ilha), limite por espécie, peso 1/raridade², locomoção em pequena área plana. Prompt Capturar usa 1 Selo. Servidor verifica perfil, proximidade, cooldown, ilha desbloqueada, inventário e saldo. Consumo/concessão não fazem yield; um encontro só concede uma criatura. Falha faz a fera fugir; reposição após 25s. Sem captura decidida pelo cliente.
- Cinco selos iniciais na migração para versão 3 de dados; criação no mercado custa 25 ouro e tem limite 10 mil. Selos, XP existente e capturas persistidos. Não foram trocadas chaves nem DataStore.
- Chance: comum 80%, rara 50%, épica 28%, lendária 12%, menos 0,5 ponto percentual por nível acima de 1; limitada entre 5% e 90%. Sem bônus ou tipos de selos nesta entrega. Prompt exibe porcentagem inteira arredondada para baixo. Falhas consomem um selo; inventário cheio/ilha bloqueada não consomem.
- Feedback de captura é aviso compacto e anel local de curta duração; sincroniza snapshot após captura. Não abre apresentação enorme.
- Nova espécie `fenix` (Fênix lendária, Fogo, ave): asas radiantes amplas, cauda tripla e halo. A Fênix Fuligem existente NÃO foi substituída. Total: 30 espécies. Fênix sempre usa estágio adulto 3, mesmo em nível individual baixo. Encontro selvagem dela usa nível individual 15. Pode sair em cruzamentos com teto lendário; regra original de sorteio mantida, catálogo ampliado. Não é concedida gratuitamente.
- `futureStage={target=4,enabled=false,...}` declara uma futura mecânica de renascimento. Não há ação, compra ou evolução automática para estágio 4. Estágio é diferente de nível individual.

### Testes executados
23 arquivos Luau compilados com luau-compile. Teste isolado em Luau: 900 pares e 27 mil sorteios consistentes com outcomes; 20 mil sorteios adicionais de híbridos = 25,17%. Regras de estágio adulto fixo da Fênix, bloqueio do estágio 4 e limites/ordenação das probabilidades de captura aprovados. JSON e caminhos Rojo, igualdade dos 29 IDs originais mais somente fenix e paridade design/catálogo aprovados.

### Não executado / limites
Nenhum teste no Roblox Studio, nem medida de FPS, área da HUD, aparência, colisões, DataStore ou múltiplos jogadores. Compilar sintaxe não valida APIs em runtime. Wildlife usa patrulha curta, não pathfinding, perseguição, fuga física ou comportamento territorial sofisticado. Há validação de ilha na captura, mas não barreira física impedindo visita. Interação via prompt requer teste de distâncias/linha de visão. Não há apelidos, companheiro ativo ou evolução interativa por escolha; a evolução legada por nível continua automática. HUD não inventa nível/XP de jogador ausentes no projeto. Filtragem por elemento dedicada ainda pendente no novo Bestiário; dados de elemento aparecem na espécie descoberta. Capturas não equipam automaticamente a criatura em habitat. Áudio permanece silencioso até configuração autorizada.

### Arquivos
Novos: CaptureRules.luau, Wildlife.luau, JournalUI.luau.
Alterados: Client.client, CollectionUI, DataService, GameService, Main.server, Biomes, Creatures, CreatureDesigns, ModelFactory, testes e documentação.
Próximo passo: homologar HUD/captura com dois clientes e celulares; depois adicionar evolução interativa e companheiro, sem desbloquear estágio 4 da Fênix antes de definir a mecânica.

A conquista de coleção completa agora usa a quantidade real do catálogo (30), preservando o ID e as recompensas já resgatadas de perfis antigos.
