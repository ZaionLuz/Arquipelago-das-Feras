# Arquipélago das Feras — fase de mundo aberto

Esta fase organiza o jogo em torno de explorar, encontrar feras, batalhar e capturar. As sete regiões estão abertas desde o início; seus níveis próprios indicam o risco. Acampamento, habitats, cuidado, produção e reprodução continuam disponíveis como atividades opcionais. A direção visual e os modelos da reforma artística anterior foram preservados.

O código e os testes desta entrega estão na branch `open-world`. O place correspondente é [Feras-Open-World.rbxlx](../../releases/Feras-Open-World.rbxlx). O arquivo de distribuição desta fase é `arquipelago-das-feras-open-world.zip`.

## Abrir e verificar

Abra o place no Roblox Studio e pressione Play. O mapa é montado pelos scripts durante a execução. Para editar pelo VS Code, sincronize `default.project.json` com Rojo ou gere novamente o place:

```bash
rojo build -o releases/Feras-Open-World.rbxlx
bash scripts/open_world/test
```

O verificador usa Python 3, Luau CLI/compiler, Lune, Rojo, Selene e StyLua. As variáveis `LUAU_BIN`, `LUAU_COMPILER_BIN`, `LUNE_BIN`, `ROJO_BIN`, `SELENE_BIN` e `STYLUA_BIN` permitem indicar executáveis fora do PATH. Alterações em `src/` só aparecem em um `.rbxlx` reconstruído ou sincronizado pelo Rojo.

## Territórios livres e dificuldade regional

[WorldLayout](../../src/shared/WorldLayout.luau) centraliza a geometria usada pelo mapa, pelos encontros e pelo servidor para detectar a região. Cada território tem raio de 420 studs, ou **840 studs de diâmetro**. Os centros estão em um anel de raio 1.400 studs. Sete estradas sólidas de **64 studs de largura** conectam os vizinhos, incluindo o retorno do Pântano ao Alvorecer.

Há três mirantes com rampas por região, marcos de trilha, decoração distribuída e oito pontos planejados de encontros por território. O acampamento pessoal foi separado do circuito de aventura, com terrenos próprios a partir da posição `(5000, 12, 5000)`.

`Config.World.FreeExploration = true` é o padrão. Nível, ouro e compra de ilha não impedem entrar, caminhar ou viajar para uma região válida. A ação legada `Unlock` responde sem cobrar ouro nesse modo. Proximidade física, propriedade, estado do personagem e regras especiais dos encontros continuam sendo verificadas pelo servidor.

| Região | Faixa base das feras | Guardião |
|---|---:|---:|
| Alvorecer | 1–9 | 11 |
| Brasa | 10–17 | 19 |
| Recife | 18–25 | 27 |
| Floresta | 26–33 | 35 |
| Dunas | 34–41 | 43 |
| Picos | 42–49 | 51 |
| Pântano | 50–57 | 59 |

As faixas vêm de [LevelBands](../../src/shared/LevelBands.luau). O nível sorteado depende da região e da raridade, sem acompanhar o nível do jogador: raridade 3 pode chegar a dois níveis acima do teto base e raridade 4, a três. A interface mostra a faixa base e avisa quando o nível do explorador está abaixo do mínimo regional.

A captura direta continua disponível. Em encontros comuns, um grande desnível reduz suavemente a chance; dano, vínculo, selos e um companheiro preparado ajudam. No cenário automatizado de `lodinho` nível 50, explorador nível 1, HP cheio, selo básico e sem companheiro, a chance calculada é aproximadamente **3,51%**. Esse é um cenário específico de teste. A Fênix mantém sua fórmula especial, requisitos de missão, limite por conta e cooldown; acesso territorial livre não concede automaticamente esse encontro.

## Navegação, encontros e base

O servidor deriva a região da posição real do personagem. Entrar no território registra a visita e atualiza o último acampamento seguro; atravessar a estrada muda o contexto sem conceder antecipadamente a visita ao destino. Jogador novo nasce no Alvorecer, e o respawn usa o checkpoint registrado. Queda abaixo do limite de segurança retorna ao último acampamento.

A população selvagem usa 56 pontos planejados. Os modelos surgem quando há jogador a até 300 studs; fora de 440 studs, um exemplar sem encontro ativo é removido após 15 segundos. Um único pulso de 0,5 segundo coordena os pontos. A reserva de uma fera impede dois jogadores de abrir o mesmo encontro simultaneamente, e uma criatura ocupada fica preservada durante o encontro. Falhas de construção de modelo têm nova tentativa após cinco segundos.

O HUD prioriza Mapa, Equipe, Regiões e Diário. Os capítulos antes ligados a alimentar, eclodir ou melhorar habitat foram convertidos em visitas e capturas. Capítulos já resgatados continuam resgatados. Recolher suprimentos, cuidar e colocar feras em habitats ficam no Acampamento; ovos e reprodução permanecem na aba Criação.

## Correções de sistemas

| Problema tratado | Comportamento atual e cobertura |
|---|---|
| Viagens rápidas podiam deixar o personagem ancorado | A reserva permanece até restaurar a âncora original. Testes recusam a segunda viagem durante streaming e durante a janela ancorada. |
| Erro de streaming, morte ou troca de personagem deixavam viagem inconsistente | A viagem limpa a reserva sem registrar visita. Há casos de recuperação para essas falhas, raiz removida, encontro iniciado durante streaming e erro de `PivotTo`. |
| Sessão marcada como casa autorizava ações em qualquer posição fora das ilhas | O contexto de casa exige estar dentro do terreno pertencente ao jogador. Terreno alheio, terreno liberado e vazio são recusados. |
| Abrir todas as permissões faria o iniciante nascer na última região | Spawn inicial usa Alvorecer; permissão de viagem não é tratada como progresso. |
| Saída durante o carregamento podia manter perfil e lease fantasma | O carregamento pode ser cancelado antes ou depois da escrita do lease, com limpeza da sessão. |
| Habitat em região livre podia perder ocupantes ao recarregar | A migração libera os flags territoriais legados e preserva os vínculos válidos entre habitat e criaturas. |
| Altar podia consumir tentativa ao abrir com personagem morto | Personagem morto é recusado; abertura interrompida por morte durante save reverte tentativa e cooldown. |
| Captura de nível alto ignorava o preparo do explorador | Encontros comuns calculam a pressão de desnível no servidor; não há bloqueio absoluto de captura ou entrada. |
| Exceção ao abrir encontro deixava o exemplar reservado | A reserva e o prompt são restaurados quando a abertura falha. |

As reproduções do estado anterior estão na [auditoria de entrada](../SYSTEMS_AUDIT_OPEN_WORLD.md). Ela documenta os defeitos encontrados no baseline; os resultados da implementação atual estão nos testes abaixo.

## Migração e preservação

O esquema atual é **6**, usando o mesmo DataStore **`ArquipelagoV1`** e a mesma chave de perfil **`P<UserId>`**. Não foi criado um armazenamento vazio para substituir o progresso anterior.

A migração adiciona `navigation.visited` e `navigation.checkpoint`, aproveita visitas legadas válidas e começa o checkpoint de perfis sem navegação no Alvorecer. Todas as regiões ficam liberadas no modo aberto; isso não constrói habitats automaticamente. Estruturas existentes e progresso válido de criaturas, níveis, XP, moedas, ovos, inventários, companheiro, missões e Fênix continuam sendo migrados.

Os testes verificam perfis antigos, estoques legados acima do limite atual, metadados adicionais, capítulos já resgatados e round-trip de habitat em região livre. Perfis corrompidos ou de versão futura são recusados antes da substituição por um perfil inicial. Bundles antigos que só reconhecem esquema 5 não devem ser usados como rollback de perfis migrados para 6.

## Evidência automatizada

Os resultados abaixo vêm dos verificadores desta fase e das suítes de regressão. Tipos e geometrias Roblox nativos são usados onde indicado, com serviços e sinais simulados.

| Verificação | Resultado registrado |
|---|---|
| Acesso e progressão | 6.300 decisões de acesso livre; 280.000 sorteios regionais; preservação de capítulos na migração. |
| Mapa | Sete regiões, 21 mirantes, 21 rampas, 56 pontos de encontro; 483 peças nas superfícies e rotas; 2.847 peças na montagem estática completa do teste. |
| Dimensões | Nove mosaicos de água; nenhuma peça da montagem acima de 2.048 studs por dimensão; nenhum portão legado. |
| Navegação | 707 posições entre regiões/corredores, zero teleporte durante caminhada simulada, sete visitas, checkpoint e respawn. |
| Transporte | Exclusão de viagens concorrentes, âncora original preservada, sete falhas com recuperação e cinco destinos inválidos recusados. |
| Contexto de casa | Somente terreno próprio autoriza contexto de casa. |
| Fauna | Duas regiões observadas, 50 ativações duplicadas, densidade por região, descarte por distância, cooldown de respawn e recuperação de erros. |
| Persistência e encontro especial | Cancelamento de load antes/depois do lease; habitat preservado; morte antes/durante abertura do altar. |

Detalhes gerados: [mapa](MAP_METRICS.json), [progressão](PROGRESSION_TESTS.json), [fauna](WILDLIFE_TESTS.json) e [navegação](../OPEN_WORLD_NAVIGATION_METRICS.json). A contagem estática do mapa não inclui todos os personagens, companheiros, terrenos e exemplares que podem existir em uma sessão multiplayer.

**Não foram executados Roblox Studio, física real, streaming real, multiplayer, DataStore Roblox real ou renderização do jogo.** Os testes não medem FPS nem comprovam aparência ou fluidez em dispositivos reais. A homologação prática está pendente no [roteiro de Studio](STUDIO_QA.md); a entrega não é uma afirmação de perfeição ou ausência total de bugs.
