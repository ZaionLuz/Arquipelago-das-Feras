# Auditoria de sistemas para mundo aberto

Inspeção do baseline artístico publicado em `fe5606ffcc8a958ae59a090bb856b41e71894e00` (mesma árvore do checkout local antes desta reforma). Os números de linha abaixo se referem a esse baseline. Esta é uma auditoria de entrada: correções posteriores devem ser confirmadas pela suíte da implementação, não se presume que o código final continue com os defeitos descritos.

Legenda: ✔ reproduzido/executado; ◐ conclusão por inspeção ou exige Roblox Studio. Nenhum teste aqui executa física, rede multiplayer ou DataStore Roblox real.

## Prioridades

| Prioridade | Achado e evidência | Tratamento/teste requerido |
|---|---|---|
| P1 — ✔ reproduzido | `Transport.luau:32–54`: `busy` e `session.transporting` são liberados antes de terminar a janela ancorada de 1 s. A segunda viagem aceita nesse intervalo captura `wasAnchored=true`; os callbacks restauram false e depois true. O personagem termina permanentemente ancorado. | Manter exclusão até restaurar a raiz ou usar token e valor original únicos. Duas viagens sobrepostas, falha de streaming, troca de personagem e raiz previamente ancorada devem ter resultado explícito e não prender o jogador. |
| P1 — ✔ reproduzido | `RegionService.luau:30,43–49`: `session.region=="sanctuary"` basta para autorizar contexto de casa em qualquer posição fora de ilhas. O teste em `(9999,12,9999)` passou shop/home sem provar presença no terreno. | `Sanctuary.contains(player,position)` ou equivalente por dono e volume; fora do terreno e no terreno de outro jogador não autorizam operações que dependem de casa. |
| P1 — ✔ reproduzido | `DataService.load:259–305`, `Main.server:join/PlayerRemoving`: a saída durante UpdateAsync ocorre antes da criação de `sessions[player]`; release retorna sem fazer nada. Ao retomar, load cria perfil/lease de um Player removido. Autosave pode renovar esse lease fantasma e impedir reconexão. | Cancelamento/generation token ou checagem da conexão após load seguida de release antes de criar mundo/plot. Testar load pausado → saída → retomada: nenhum perfil/plot/lease ativo remanescente. |
| P1 — ◐ integração | `RegionGuard.luau:12–19,38–40` escolhe a maior ilha autorizada para o primeiro spawn. Liberar Access para todas faria um novo jogador nascer diretamente no Pântano. | Alvorecer para jogador novo e checkpoint real validado para respawn; não inferir progresso por permissão de viagem. |
| P1 — ◐ persistência | `DataService.validate:184–203` descarta ocupantes de habitat se `unlocked[island]` não estiver true. Se a nova Access permitir construir/colocar em área livre e o flag legado continuar false, o próximo login limpa a atribuição, apesar de manter a criatura. | Flags aditivos ou remoção do filtro legado, preservando as listas. Testar construir/Place em região nunca comprada → save/load: estrutura, ocupantes e inventário idênticos. |
| P1 — ◐ integração | Ainda existem checagens de `unlocked` fora de Access: GameService.Travel/Battle, Guardians, Biomes, PhoenixQuest e saneamento do DataService. Remover apenas a barreira principal deixa serviços incoerentes. | Auditar todas as ocorrências. Requisitos especiais do chefe Fênix podem permanecer separados, mas compra de Dunas não deve continuar representando acesso territorial. |
| P1 — ✔ fórmula executável | Captura comum ignora nível do explorador/time: `CaptureRules.chance(1,50)` = 55,5% com selo básico e HP cheio. Abertura total/viagem grátis permite ao iniciante tentar pet de nível 50 quase sem preparação, enquanto combate usa forte pressão de nível. | Decidir e medir uma penalidade suave de captura por desnível, calculada no servidor e sem bloqueio de mapa/captura absoluta. Preservar monotonicidade de preparo/selos; testar explorador1 vs comum50 e casos de nível equivalente. Não alterar acidentalmente a fórmula especial da Fênix. |
| P2 — ◐ inspeção | EncounterService.open/startSpecial só verificam Humanoid/vida no primeiro turno. Um altar acionado com personagem morto pode persistir tentativa/cooldown de vinte minutos antes de a ação seguinte encerrar o encontro. | Conferir personagem/vida antes de reservar e antes de abrir após save/streaming. Testar morte e respawn no yield da abertura especial. |
| P2 — ◐ direção de produto | Story.current obriga feed3 e eclosão/casa antes dos próximos capítulos; HUD de coletar renda e treino por menu mantêm a criação como ciclo obrigatório. | Fazer exploração/captura/descobertas conduzirem a trilha principal e conservar cuidado/criação como atividades opcionais compatíveis, sem retirar coleções/ovos/capítulos já resgatados. |

## Reproduções executadas

### Viagem e contexto de casa

Comando executado: `/workspace/work/v7-tools/lune run /tmp/ow-audit-repro.luau`.

Carregou cópias reais dos módulos Transport e RegionService do baseline; tipos Vector3/CFrame são nativos de `@lune/roblox`. Apenas Data, Access, streaming e a fila `task.delay` foram injetados.

1. Primeira viagem aceita com raiz `Anchored=false`; callback A enfileirado.
2. Segunda viagem aceita antes de A, com raiz já `Anchored=true`; callback B enfileirado.
3. A restaurou false, B restaurou true. Assert final confirmou o defeito.
4. Sessão sanctuary, raiz em posição arbitrária distante e sem terreno: current retornou sanctuary e requireContext(shop,allowHome=true) autorizou. Assert confirmou a ausência de prova espacial.

Saída registrada:

```text
REPRODUCED: two accepted transports restore Anchored=true after both delays
REPRODUCED: home shop context accepted at arbitrary out-of-region position without plot ownership/presence proof
```

### Saída durante carregamento

Comando executado: `/workspace/work/luau-source/luau /tmp/ow-load-repro.luau`.

A reprodução usou o DataService real incorporado ao harness `tests/data.generated.luau` do baseline. UpdateAsync foi interrompido com coroutine.yield; release foi chamado e o Player marcado como removido antes de retomar o load. Após retomada, Data.get ainda retornava perfil e o armazenamento simulado tinha `_session` ativo.

```text
REPRODUCED: load resumes after release/disconnect and leaves a live profile + active lease for removed Player
```

Os arquivos temporários são reproduções de auditoria, não parte da suíte entregue. A implementação deve incorporar os casos positivos corrigidos na suíte permanente, com asserts de negação/limpeza.

### Captura sem preparo na área avançada

Comando executado: `/workspace/work/luau-source/luau /tmp/ow-capture-repro.luau`, com núcleo real congelado do harness de combate do baseline.

```text
REPRODUCED: baseline common level50/fullHP/basic seal/no active pet capture chance = 0.555
```

Este valor não depende do nível do explorador na fórmula anterior; a abertura territorial torna essa falta de pressão de nível especialmente relevante.

## Salvaguardas já presentes que convém preservar

- CreatureGrant centraliza aquisição e nonce; EncounterService marca terminal/released antes do save especial.
- O servidor deriva região/partida, propriedade e estoque, sem aceitar chance ou nível vindos do cliente.
- O DataStore continua ArquipelagoV1, com lease e rejeição de entrada corrompida/futura antes de sobrescrever.
- Selos e recompensas são debitados/concedidos no servidor; guardiões são incapturáveis.
- LOD/cache das criaturas e decoração centralizada já existem e devem acompanhar a ampliação territorial.

## Validação que ainda exige Studio

Percorrer as rotas com streaming ligado, morrer em trânsito, fazer duas viagens rápidas em dispositivo real, reconectar durante save/load com dois servidores e conferir multiplayer em áreas grandes. Testes headless comprovam política/transações/geometria, não asseguram FPS, ausência de desníveis físicos ou perfeito funcionamento de todas as APIs Roblox.
