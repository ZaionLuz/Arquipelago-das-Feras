PROMPT MESTRE
0. Missão e regras inegociáveis
Você trabalha no projeto Arquipélago das Feras (V6, Roblox/Luau): criaturas colecionáveis, 7 ilhas, batalhas por turnos, captura com selos, evolução, cruzamento, incubadora, santuários, habitats, companheiro, bestiário, missões e capítulos. Entregue a V7 sobre o código existente. Não reinicie o projeto.
A V7 tem três frentes:
• A. Redesign das 30 espécies × 3 estágios, com a Fênix como obra-prima.
• B. Progressão real das 7 ilhas por nível, com bloqueio efetivo no servidor.
• C. Fênix lendária secreta no Santuário Solar, usando a batalha e a captura que já existem.
A ordem de execução não é a ordem de importância. Arte nova sobre uma migração quebrada ou um servidor furado não vale nada, então primeiro vêm a auditoria, os testes e a base segura. Depois entram progressão, Fênix e arte, nessa sequência.
Regras inegociáveis
• R1. Antes de criar qualquer módulo, procure um equivalente que possa ser ampliado. Não duplique sistemas.
• R2. A chave do DataStore ArquipelagoV1 não muda. A migração é versionada, idempotente e nunca reduz nada: ilhas, criaturas, níveis, XP, ouro, ovos, construções, habitats, missões. Falha de leitura nunca vira perfil padrão salvo por cima de um perfil real.
• R3. O servidor é a autoridade. O cliente envia só intenções (ids). Região atual, nível, flags, probabilidades e cooldowns ficam no servidor. Nenhum remote trata ilha, nível ou chance vindos do cliente como verdade.
• R4. Uma decisão, um ponto de entrada: Access (ilhas), CreatureGrant (toda criatura nova), CaptureMath (probabilidade de captura) e EncounterPools (sorteio selvagem).
• R5. Concorrência: confira e marque o estado antes de qualquer yield (DataStore, task.wait, remote). Toda concessão é idempotente.
• R6. Preserve IDs persistentes de espécies (inclusive a Fênix Fuligem), os marcos de evolução 7 e 15, as opções gráficas e todos os sistemas listados acima.
• R7. Não invente IDs de assets. Áudio, imagens e texturas ficam configuráveis e vazios por padrão. Sem dependência de modelos externos.
• R8. Honestidade: nunca marque algo como concluído sem executar a verificação. Use esta legenda em todo relatório:
    ◦ ✔ Executado: comando e resultado registrados.
    ◦ ◐ Implementado, não executável aqui: precisa do Roblox Studio ou de multiplayer real.
    ◦ ✘ Pendente.
1. Como trabalhar
• Leia primeiro README, AGENTS.md, PROGRESS.md, default.project.json e a árvore de src/. Releia docs/V7_SPEC.md no início de cada fase.
• Este prompt descreve o estado esperado. Nomes de arquivos, ids e campos podem divergir. Registre as divergências em docs/V7_AUDIT.md e adapte sem perguntar.
• Não faça perguntas, salvo bloqueio total. Em caso de ambiguidade, use o padrão indicado aqui e registre em docs/DECISOES_V7.md (decisão, alternativas, motivo, como reverter).
• Commits pequenos por tarefa. Rode a suíte antes e depois de cada fase.
• Crie flags em Config (por exemplo V7.EnforceIslandLevels, V7.PhoenixSanctuary) para rollback rápido. O padrão é ligado.
• Se o contexto ou o tempo acabar, pare em um ponto estável e escreva em PROGRESS.md o próximo passo exato.
• Verifique as ferramentas disponíveis: rojo, luau, luau-analyze, luau-lsp, selene, stylua, lune. Tente instalar o que faltar se houver rede, e registre o que não conseguiu.
2. Fase 0 — Auditoria e infraestrutura de testes
Entregável: docs/V7_AUDIT.md, com estas tabelas.
• Mapa: módulos de servidor, cliente e shared, e todos os RemoteEvents/RemoteFunctions, com seus parâmetros.
• Uso de nível e ilha: todo trecho que usa nível mínimo, unlock, ilha/região, idx, faixas de nível e guardiões (arquivo:linha → o que faz → mudança prevista).
• Caminhos que concedem criaturas: captura, eclosão, cruzamento, lojas e ovos, missões, capítulos, recompensas diárias e de evento, migração, inicialização, comandos de dev/admin, santuários, qualquer troca. Para cada um, responda: hoje pode conceder a Fênix? Qual ação resolve?
• Construção e animação de criaturas: arquivos responsáveis, contagem de peças por espécie e estágio (escreva um script que meça), custo por frame e o LOD atual.
• Perfil salvo: campos, versões e fixtures reais V1 a V6 (extraia do histórico do git ou da documentação).
• Curvas atuais: XP do explorador e da criatura, e o tempo estimado para os níveis 10, 18, 26, 34, 42 e 50 (simulação).
• Riscos encontrados.
Infraestrutura de testes
• Isole a lógica pura, sem game:GetService, com dependências injetadas: Progression, Access, LevelBands, Migration, CaptureMath, EncounterPools, SpeciesRules, CreatureGrant.
• Crie um runner headless (Lune ou luau CLI) com scripts/test, que sai com código diferente de zero se algo falhar.
• Se possível, use rojo sourcemap e luau-lsp analyze com as definições do Roblox, para eliminar o ruído de globais desconhecidas.
• Rode a suíte existente antes de mudar qualquer coisa e registre o resultado base.
3. Fase 1 — Progressão real das ilhas
3.1 Curva (valores de partida; ajuste só com justificativa de simulação)
Ilha
Nível mín. do explorador
Faixa selvagem
Guardião sugerido
Ilha do Alvorecer
1
1–9
11
Ilha das Brasas
10
10–17
19
Recife Cristalino
18
18–25
27
Floresta Murmurante
26
26–33
35
Dunas Quebradas
34
34–41
43
Picos Celestes
42
42–49
51
Pântano Umbral
50
50–57
59
O guardião usa nível da faixa máxima +2 e atributos ×1,15 a ×1,35. Os custos de ouro atuais são mantidos, mas o ouro precisa crescer de forma monotônica e ser alcançável em cerca de 0,7 a 1,2 hora de renda típica da faixa anterior. Só ajuste se a auditoria mostrar uma violação.
3.2 Regras de desbloqueio (padrão)
Para desbloquear a ilha N: o explorador precisa ter o nível mínimo, a ilha N−1 precisa estar desbloqueada e o ouro precisa ser pago. Exigir a vitória sobre o guardião anterior fica atrás da flag RequireGuardian, desligada por padrão.
Jogador novo começa só com o Alvorecer. Jogador antigo mantém tudo que já tinha desbloqueado (grandfathering), marcado como legacyGrandfathered para a interface explicar o motivo.
3.3 Serviço Access
• Função pura: Access.check(perfil, ilhaId, propósito) devolve {ok, motivo}.
• Propósitos: travel, encounter, capture, battle, hatch, shop, habitat, sanctuary.
• Motivos como códigos: UNKNOWN_ISLAND, NOT_UNLOCKED, LOCKED_LEVEL, LOCKED_PREV, LOCKED_GOLD.
• Todo remote com parâmetro de região passa por Access.
• A região atual do jogador fica na sessão do servidor (session.region) e só muda por Travel validado. Encontros, capturas e batalhas usam session.region, nunca o valor enviado pelo cliente.
3.4 Barreiras físicas
Barreira física não é segurança, porque o cliente consegue atravessá-la. A segurança está no servidor, e a barreira serve de feedback e conforto.
• Um RegionGuard no servidor define volumes por ilha e checa a posição do personagem (a cada cerca de 1 s, com throttle). Em região bloqueada, devolve o jogador ao último ponto seguro, com aviso.
• A checagem também roda em respawn e ao entrar: RespawnLocation aponta para o ponto seguro da maior ilha permitida.
• Portões nas pontes (arco com selo do nível exigido) dão a leitura visual. O servidor nega qualquer ação ligada a uma região bloqueada, independentemente de onde o jogador esteja.
3.5 Níveis das criaturas selvagens
• Implemente EncounterPools.rollLevel(ilha, raridade, rng) com distribuição triangular enviesada: Comum na parte baixa da faixa, Raro no centro, Épico na parte alta.
• Raridades altas podem passar do máximo da faixa em até +3 (Épico até +2). Nenhum nível fica abaixo do mínimo da faixa.
• Evite níveis todos iguais. Teste que 10.000 sorteios por ilha ficam dentro dos limites e produzem pelo menos 5 níveis distintos.
• O RNG é injetável nos testes.
3.6 Combate, XP e ouro
Revise encontros selvagens, batalhas tradicionais, guardiões, XP, ouro e dificuldade.
• XP: reduza com sobrenível (por exemplo, 50% quando o time está 8+ níveis acima do inimigo, 10% com 15+), para não permitir farm de ilhas fáceis.
• Ouro: cresce com a ilha e com o nível do inimigo, e é sempre maior em ilhas mais avançadas.
• Metas medidas por simulação headless com o módulo real de batalha (extraia o núcleo puro se necessário), em scripts/sim_balance:
    ◦ time no nível recomendado contra selvagem comum: 85–95% de vitória;
    ◦ contra selvagem 5 níveis acima: 55–70%;
    ◦ contra o guardião: 45–60%;
    ◦ time 10 níveis abaixo da faixa: menos de 15%.
• Tempo até o nível mínimo de cada ilha, para o ritmo de partida, em horas de jogo: 10 ≈ 0,75, 18 ≈ 2, 26 ≈ 4, 34 ≈ 7, 42 ≈ 11, 50 ≈ 16. Se a curva atual divergir muito, ajuste e documente.
• Verifique que o nível 50 do explorador e o nível 60 de criatura são alcançáveis (limites atuais).
3.7 Migração
• Aumente a versão do perfil e implemente Migration.run(raw) em passos.
• Invariantes testadas com fixtures reais, e também com perfis gerados aleatoriamente: nenhuma criatura perdida, nenhum campo numérico diminui, ilhas desbloqueadas são superconjunto, e migrate(migrate(x)) == migrate(x).
• Perfil vazio, corrompido ou de versão futura não derruba o servidor nem apaga dados.
4. Fase 2 — Fênix e Santuário Solar
4.1 Decisões padrão (registre-as em docs/DECISOES_V7.md)
• Local: o Santuário Solar fica numa câmara selada, integrada às ruínas das Dunas Quebradas, sem criar uma oitava ilha. Se a auditoria mostrar uma ilha de tema mais adequado, escolha-a e justifique.
• Requisitos, validados no servidor:
    1. Explorador nível 45+ e Dunas desbloqueada.
    2. Três Glifos Solares: dois nas Dunas (um em área escondida, um em ruína de acesso difícil) e um nos Picos Celestes. Cada um usa um ProximityPrompt, e o servidor confere a distância e grava o flag no perfil.
    3. No altar, a interação "Oferecer chama" inicia o encontro.
• Descoberta gradual: o 1º glifo cria a entrada "Eco de Fogo Antigo" no diário; o 2º dá uma pista de direção; o 3º abre o portão. Se o sistema de Missões/Capítulos permitir, a trilha aparece como capítulo oculto, sem criar mecânica paralela.
• Política após capturar: PhoenixMaxPerAccount = 1, configurável. O altar entra em repouso depois da captura.
• Retentativa: após falha, o encontro volta depois de PhoenixRetrySeconds = 1200, persistido em nextAttemptAt e calculado com os.time() do servidor.
4.2 Estado persistido
Adicione perfil.phoenix = { glyphs = {}, sanctuaryOpen = false, attempts = 0, nextAttemptAt = 0, captured = false, encounterId = nil }. A migração cria esse bloco vazio, e nenhuma etapa concede criatura.
4.3 Exclusividade por construção
• Marque a espécie com acquisition = "special".
• CreatureGrant.grant(perfil, especieId, origem) passa a ser a única função que adiciona criaturas. Refatore todos os caminhos da auditoria para usá-la. Espécies special só aceitam a origem "phoenix_sanctuary".
• Todos os pools (selvagens, cruzamento, ovos comerciais e de loja, recompensas de missão, evento e diária) filtram por Species.isGeneral(id).
• Legado: quem já possui a Fênix, ou um ovo dela, mantém. Não revogue nada. Apenas bloqueie novas fontes, e documente.
• Testes obrigatórios:
    ◦ 10.000 sorteios em cada pool, com zero Fênix;
    ◦ cruzamento: nenhum filho é a Fênix, mesmo com qualquer par de pais;
    ◦ grant com qualquer outra origem falha;
    ◦ varredura estática que acusa o id da Fênix fora de arquivos permitidos;
    ◦ migração e inicialização não concedem nada;
    ◦ a Fênix Fuligem continua em todos os pools, sem alteração.
4.4 Encontro
Crie EncounterService.startSpecial(jogador, "phoenix_solar"), que monta uma sessão com o mesmo construtor de batalha e captura existente, com estas sobreposições: espécie, nível 60, captureBase = 0.04, isLegendary = true, intro = "phoenix". Não crie um segundo laço de batalha.
O servidor valida requisitos, cooldown e ausência de sessão ativa. Ele grava o encounterId (nonce) antes de qualquer yield, e a captura consome esse encontro de forma idempotente. Teste N chamadas simultâneas de Capture, duplo clique e desconexão no meio do encontro: o resultado é exatamente uma concessão ou nenhuma.
Se o encontro terminar sem captura (derrota, fuga, selos esgotados), grave nextAttemptAt e mostre a contagem regressiva no altar. Se terminar com captura, conceda via CreatureGrant e marque captured.
4.5 Captura (3% a 5% de base)
• Reaproveite a fórmula atual: p = clamp(base × selo × vida × vínculo × condição, pMin, pMax).
• Para a Fênix: base 4%, pMin = 1%, pMax = 35%. Em preparação ótima (vida ≤ 10% e melhor selo), a chance por tentativa deve ficar perto de 18–25%.
• Monte Carlo com pelo menos 100.000 execuções, com RNG injetável, em três cenários. Metas de tentativas esperadas: ótimo ≈ 5, médio ≈ 10, sem preparação ≈ 25. Probabilidade de capturar em até 15 selos: ótimo ≥ 90%, sem preparação ≈ 45%.
• Teste também a monotonicidade (mais selo ou menos vida nunca baixa a chance) e que o servidor impõe os limites.
• Dificuldade de batalha: nível 60 com atributos ×1,3. Um time de nível 45–55 com preparação deve vencer em algo como 25–40% das tentativas sem preparação e 60–75% com preparação. Meça com a simulação.
4.6 Apresentação
• Modelo exclusivo (seção 5.7), com entrada de voo: desce do céu com onda de choque.
• A câmera faz um movimento rápido e termina sempre restaurada, mesmo com erro (use pcall/finalização garantida).
• Cartão de abertura com "FÊNIX · LENDÁRIA · Nv. 60", e destaque de nome, nível e raridade na interface de batalha.
• Efeitos: no máximo 1 emissor e 1 luz, desativados em qualidade baixa.
• Sons por configuração, com IDs vazios.
• Para os demais jogadores, o encontro é apresentado só no cliente de quem está lutando.
4.7 O Santuário Solar
Construa em módulo próprio (SanctuaryBuilder), com orçamento de até cerca de 400 peças ancoradas e agrupadas:
• ruínas com colunas partidas e arcos;
• altar solar com disco dourado e runas em Neon;
• cristais dourados e rochas vulcânicas;
• glifos e uma arena circular com símbolos no chão.
A atmosfera própria (pôr do sol, névoa dourada, correção de cor) só é aplicada no cliente enquanto o jogador está dentro da área, e custa zero fora dela.
4.8 Sem spoilers
O servidor envia ao cliente apenas o estágio de descoberta. Antes do 1º glifo, nenhum texto, coordenada ou nome do santuário trafega para o cliente. Teste que o payload do estágio 0 não contém "Fênix", "Santuário" ou "Glifo". No bestiário, a Fênix aparece como "???" até ser descoberta, a menos que o jogador a já possua pelo legado.
5. Fase 3 — Redesign das 30 criaturas
5.1 Realidade do trabalho
Você não consegue ver imagens renderizadas. Por isso: (1) a diferenciação é medida por métricas estruturais automáticas; (2) o repositório ganha uma Galeria de Criaturas para revisão humana; (3) cada espécie tem uma ficha em docs/CRIATURAS.md. Marque toda avaliação estética como ◐ até um humano aprovar.
5.2 Arquitetura orientada a dados
• CreatureDesigns: por espécie, familia, planoDeCorpo, cabeca, olhos, membros, apendices, superficie (manchas, listras, escamas, placas, rachaduras em Neon, veios), motivoElemental, paleta (3–5 cores, nunca só a cor do elemento), estagios[1..3] (regras keep/replace/add, e escala sozinha não conta), orcamento, anim e lod.
• CreatureFeatures: biblioteca de componentes parametrizados (chifre, nadadeira, asa, pena, garra, cauda, crista, folha, raiz, cristal, placa rochosa, chama, antena, mandíbula, tipos de olho). Reutilizar componentes é permitido; reutilizar a combinação não.
• ModelFactory: monta e valida. CreatureAnimator: anima por família.
• Famílias sugeridas (adapte às 30 espécies reais, sem criar ids novos): quadrúpede, bípede, alado, serpentino, artrópode, aquático, vegetal, mineral/golem, espectral, dracônico. Cada uma com construtor de esqueleto próprio, não variações de um boneco único.
5.3 Técnicas permitidas
• Partes primitivas (Block, Wedge, CornerWedge, Cylinder, Ball). SpecialMesh com Scale não uniforme (Sphere, Cylinder, Wedge, Head) cria elipsoides, formas achatadas e afuniladas. Use isso para fugir do "boneco de esferas".
• Padrões e texturas por peças finas, Neon, materiais (Slate, Granite, Ice, Glass, Fabric etc.) e variação de cor. Nada de Decal ou Texture com ID.
• EditableMesh só como opção, com detecção de recurso, pcall e fallback. Nunca obrigatório.
• MeshPart só se o arquivo do mesh estiver versionado no repositório. Sem IDs de assets inventados.
• Estrutura do modelo: PrimaryPart é uma raiz invisível e ancorada. As partes ficam ligadas por Motor6D (articulações animadas) ou WeldConstraint (estáticas), e a animação altera o Transform dos joints, sem recriar peças.
• Colisão: todas as peças com CanCollide = false, CanQuery = false, CanTouch = false, Massless = true, e CastShadow = false nas pequenas. Use um grupo de colisão Creatures que não colide com jogadores.
• ModelFactory.validate(modelo) falha se: não houver PrimaryPart; algum Size for ≤ 0 ou NaN; a caixa envolvente sair do intervalo do estágio; passar do orçamento; existir peça com colisão ativa; houver nomes de joints repetidos ou scripts dentro do modelo.
5.4 Orçamento e desempenho
• Peças por criatura: filhote ≤ 28, juvenil ≤ 48, adulto ≤ 80. Fênix ≤ 170.
• Emissores: ≤ 1 por criatura (≤ 2 na Fênix). Luzes: ≤ 1.
• LOD com um único Heartbeat central: perto (< 70 studs) animação completa; médio (< 150) idle a 15–20 Hz, sem emissores; longe, congelado; muito longe, oculto. Limite o número de modelos animados em simultâneo, por exemplo 24 perto.
• Cache por (espécie, estágio) com Clone() em vez de reconstruir.
• Viewports (bestiário): reaproveite um ViewportFrame com WorldModel por painel, reconstrua só quando espécie ou estágio mudar, gire a 30 Hz apenas quando visível e limpe ao fechar.
• Respeite as opções gráficas atuais. Em qualidade baixa: sem emissores, sem luzes extras, LOD agressivo.
5.5 Processo por espécie
Para cada uma das 30, escreva primeiro a ficha em docs/CRIATURAS.md: nome, família, animal-base ou inspiração (diferente das outras), silhueta em uma frase, 3 traços exclusivos, rosto e olhos, motivo elemental e uma frase de história, diferenças entre estágios e orçamento. Só depois implemente. Trabalhe por família, com um commit por lote.
Evite: corpo = esfera com apêndices; olhos esféricos brancos com pupila em todas; mesma boca e mesma posição de rosto; mais de 4 espécies com o mesmo tipo de olho.
• Olhos: defina pelo menos 8 variantes (pupila vertical, fenda, olhos compostos, olhos laterais de peixe, olho único, olhos de cristal, olhos fendidos incandescentes, olhos cegos com marcas, olho solar).
• Fogo, água, natureza, sombra, terra e as demais direções do seu briefing original continuam valendo como inspiração, mas não aplique todas a todas as espécies. Cada espécie escolhe os elementos que fazem sentido para a própria história.
5.6 Estágios como transformação
• Filhote: menor, cabeça proporcionalmente grande (cerca de 40–50% da altura), membros curtos, olhos grandes, sem chifres e espinhos, detalhes reduzidos.
• Juvenil: anatomia mais desenvolvida, primeiros apêndices distintivos, padrões de superfície aparecendo.
• Adulto: estrutura completa, detalhes elementais, postura e presença marcantes.
• Preserve os marcos 7 e 15 (stage(level) inalterado, com testes).
5.7 Fênix — obra-prima
• Asas: amplas, com pelo menos 3 fileiras × 7–9 penas por asa. Cada pena é uma peça individual com pequena variação de comprimento, curvatura e cor (carmim → laranja → dourado → branco-quente nas pontas).
• Cauda: longa e ornamental, com 9–13 penas compridas que ondulam em fase.
• Corpo: esguio e nobre, pescoço longo, cabeça com crista, bico e garras douradas, olhos solares, plumagem de peito em camadas.
• Halo solar: anel de segmentos com raios, girando lentamente. Evite luzes e emissores além do orçamento.
• Animação: bater de asas com onda de fase entre as penas, oscilação do corpo e balanço da cauda; mergulho de entrada; hover; investida com onda solar; ascensão na derrota ou fuga.
• Teste: validate, contagem de penas, orçamento e nomes individuais por pena. A aparência precisa ser claramente superior à de qualquer ave comum do jogo.
5.8 Animação
CreatureAnimator por família: respiração e olhar no idle; locomoção própria (passos, ondulação, voo, deslize, flutuação); ataque (preparação → golpe → retorno) integrado aos efeitos elementais existentes; reação ao dano e desmaio. Sem laço wait por criatura: um Heartbeat central, Transform via Motor6D e pooling.
5.9 Verificação do redesign
• Assinatura estrutural por (espécie, estágio): razões de aspecto da caixa envolvente, histograma por tipo de peça e de mesh, conjunto de ids de features, tipo de olho, de cabeça e de cauda, número de membros e paleta quantizada.
• Testes: a distância entre qualquer par de espécies no mesmo estágio passa de um limiar definido e justificado por você; nenhuma dupla compartilha a mesma tupla (família, cabeça, olhos, cauda, membros); estágios consecutivos diferem de forma significativa e nunca são o mesmo layout só escalado; validate passa nas 90 combinações mais a Fênix.
• Se os builders dependem de APIs do Roblox, execute-os headless com Lune (@lune/roblox) ou com mocks mínimos em tests/mocks/, e registre as limitações.
• CreatureGallery (apenas Studio, RunService:IsStudio()): grade de todas as 90 combinações mais a Fênix, com rótulos, rotação e alternância de estágio. Documente em docs/QA_STUDIO_V7.md como revisar e o que olhar. Nunca entra no jogo publicado.
6. Fase 4 — Interface
• Painel de ilhas: por ilha, estado de bloqueio, "Nível mín. X (você: Y)" com barra de progresso, faixa selvagem, nível recomendado, custo em ouro e o motivo do bloqueio vindo do servidor (código → texto pt-BR). Mostre "Acesso legado" para ilhas preservadas.
• Progresso do explorador: próxima ilha e quanto falta, de forma compacta.
• Encontros: nível do selvagem em destaque e cor por dificuldade relativa ao seu time (verde, amarelo, laranja, vermelho), com aviso para +8 níveis ou mais.
• Fênix e Santuário: o diário "Vestígios" só aparece após o 1º glifo. Os textos são por estágio de descoberta. Informações especiais sobre a Fênix só depois da descoberta.
• Mobile: alvos de toque ≥ 44 px, painéis recolhíveis, sem poluir a tela. Mantenha a identidade visual atual.
• Todos os textos em um módulo de strings pt-BR.
7. Fase 5 — Validação, documentos e relatório final
Testes obrigatórios (nomeie cada um e deixe o runner executar todos):
1. Migração com fixtures V1–V6, perfil vazio, corrompido e de versão futura: nada perdido, idempotente, só o Alvorecer para jogador novo, Fênix nunca concedida.
2. Access em matriz (nível × ilha × propósito), com remotes forjados: ilha inexistente, tipos errados, tabela no lugar de id, NaN, nível adulterado.
3. RegionGuard e respawn.
4. Faixas de nível por ilha e por raridade.
5. XP e ouro: crescimento monotônico por ilha e penalidade de sobrenível.
6. Simulação de balanceamento contra as metas da seção 3.6.
7. Exclusividade da Fênix (todos os caminhos da seção 4.3) e Fênix Fuligem intacta.
8. Captura: limites, monotonicidade, Monte Carlo.
9. Concorrência: N capturas simultâneas = 1 concessão; reentrada de encontro; cooldown persistido; desconexão no meio.
10. Spoilers: payload do estágio 0.
11. Modelos: 90 combinações + Fênix (validate, orçamento, PrimaryPart, assinaturas, estágios, marcos 7 e 15).
12. Desempenho: contagem total de peças numa cena simulada (por exemplo, 40 criaturas) abaixo do orçamento global; contagem de reconstruções de Viewport.
13. Salvar e carregar (round-trip).
14. Regressão: a suíte existente continua verde.
Documentos a atualizar ou criar: CHANGELOG.md, PROGRESS.md, PENDENCIAS.md, docs/V7_AUDIT.md, docs/DECISOES_V7.md, docs/CRIATURAS.md, docs/MUNDO.md, docs/QA_STUDIO_V7.md.
Relatório final: tabela com cada requisito do briefing, status (✔ ◐ ✘), comando executado e resultado. Liste de forma explícita o que depende do Roblox Studio ou de multiplayer real (aparência final, animação, performance em celular, barreiras físicas, apresentação da Fênix, interface em telas pequenas).
Critérios de pronto:
• Uma criatura só é considerada pronta se suas métricas passarem e o modelo passar em validate.
• Uma ilha só é considerada protegida se um remote forjado for negado pelo servidor, em teste.
• A Fênix só é considerada exclusiva se a varredura estática e os testes de pools, CreatureGrant e migração passarem.
• Código que apenas compila não é entrega.