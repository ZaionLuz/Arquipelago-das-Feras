# Validação V7

✔ Executado = comando e saída registrados. ◐ Implementado, exige Studio/multiplayer. ✘ Pendente.

Comando integral desta execução:
```bash
LUAU_BIN=/workspace/work/luau-source/luau \
LUAU_COMPILER_BIN=/workspace/work/luau-source/luau-compile \
LUNE_BIN=/workspace/work/v7-tools/lune \
ROJO_BIN=/workspace/work/v7-tools/rojo scripts/test
```
Em instalação local com os binários no PATH: `bash scripts/test`.
Saída: `docs/RESULTADOS_V7.txt`. Compilação, suites antigas adaptadas, execução nativa, simulações, varredura e build terminam com código zero. O antigo stub de modelos foi substituído como verificação ativa pelo construtor nativo Lune; o arquivo histórico continua disponível.

| Requisito | Status | Evidência/limite |
|---|---|---|
| 0. Auditoria e regressão antes de editar | ✔ | docs/BASELINE_V6.txt e V7_AUDIT.md; seis suites de regras/serviços + modelos da V6 |
| 1. Migração e casos inválidos | ✔ / ◐ | v7_core + data.generated: 6 fixtures **sintéticas**, 1000 perfis, idempotência, preservação, lease, rejeição sem reset; contas reais/produção não disponíveis |
| 2. Access e remotes forjados | ✔ | v7_core: 6300 decisões; v7_engine_tests executa Main.Net/GameService reais com serviços simulados e nega tabela, NaN, ilha e nível falsos |
| 3. RegionGuard/respawn | ✔ / ◐ | política, volumes e destino executados; retorno físico, portões e CharacterAdded no Studio |
| 4. Níveis selvagens | ✔ | 280000 amostras: 7 ilhas × 4 raridades × 10000, limites e ≥5 valores distintos |
| 5. XP e ouro | ✔ | sim_balance: monotonicidade, 50%/10% XP por sobrenível, ouro de entrada maior que máximo anterior |
| 6. Balanceamento | ✔ / ◐ | núcleo real, 46000 lutas; médias nas metas, resultados por nível publicados; validação com pessoas ainda necessária |
| 7. Exclusividade/Fuligem | ✔ | 140000 sorteios de pools, todos 900 pares e 90000 cruzamentos, origens recusadas e varredura estática; ovo legado só com permissão por nonce |
| 8. Captura | ✔ | 300000 execuções Monte Carlo, limites/monotonicidade; JSON abaixo |
| 9. Concorrência | ✔ / ◐ | EncounterService real: yields de save, 100 reentradas bloqueadas, 101 capturas intercaladas = 1 concessão/selo, cooldown e desconexão; rede real pendente |
| 10. Sigilo | ✔ / ◐ | payload quest do estágio zero exatamente {stage=0}; bestiário usa substituto ???; catálogos compartilhados são mineráveis |
| 11. Redesign | ✔ / ◐ | 91 builds / 88 layouts; validação, joints locais no clone, orçamento e distâncias; estética humana pendente |
| 12. Desempenho | ✔ / ◐ | cena de 40: contagem abaixo; 100 atualizações mesmo estágio = 1 reconstrução; LOD/animações implementados, FPS e memória no celular pendentes |
| 13. Salvar/carregar | ✔ / ◐ | DataService real com UpdateAsync simulado, round-trip, lease e falha segura; DataStore real pendente |
| 14. Regressão/build | ✔ | scripts/test, Rojo sourcemap e build de place; bundle nativo de scripts validado |
| Interface e textos | ✔ / ◐ | 452 textos centralizados em Strings, Viewport reutilizado, painéis e alvos maiores; layout/toque/câmera exigem Studio |
| Apresentação e santuário | ✔ / ◐ | builder executado com 74 peças nativas dentro do orçamento e validações de altar; mergulho, onda, ambiente local e efeitos configuráveis implementados; render/áudio não executados |
| Ferramentas/análise tipada | ✔ / ✘ | Rojo 7.7.1, Lune 0.11.1, Luau/compile/analyze, StyLua 2.6.0 e Selene 0.32.0 disponíveis. luau-lsp baixado era ARM, não executou nesta máquina x86; nova tentativa de rede falhou. Análise completa com definições Roblox pendente |

## Resultados medidos

Médias da amostra de combate: comum **91.9%**, inimigo +5 **60.6%**, guardião **53.1%**, time dez níveis abaixo **0.0%**. Fênix: sem preparo **25.5%**; com contrajogo **61.3%**. Os presets e resultados por nível estão em BALANCE_SIMULATION.json; não se afirma que toda composição ou cada faixa individual atinge a mesma taxa.

- sem preparo: 4.000% por selo, 25.06 tentativas médias, 45.57% em até 15.
- médio: 9.278% por selo, 10.78 tentativas médias, 76.79% em até 15.
- ótimo: 20.630% por selo, 4.84 tentativas médias, 96.83% em até 15.

Modelos: menor distância 0.15218, limiar 0,12; par fenixfuligem/penugem:3. Cena de 40 = 1293 peças, orçamento 3200. Fênix = 122 peças, orçamento 170. Sem renderização, física ou benchmark de frame nesta medição.

✔ `selene src`: zero erros, zero avisos, zero erros de parsing com standard Luau e globais Roblox declaradas como any. Esse lint não verifica assinatura de toda API Roblox. ✔ StyLua e compilador Luau passaram. ✘ luau-analyze sem definições Roblox gera globais desconhecidas; não é apresentado como análise tipada limpa. Saída de diagnóstico resumida no audit.

Não há validação estética aprovada, multiplayer real ou prova de FPS em celular. O roteiro para essas verificações está em QA_STUDIO_V7.md. A V7 implementa o escopo de 30 espécies/7 ilhas, não a visão histórica de 100 espécies/10 regiões.

✔ Bundle releases/Feras-V7.rbxlx desserializado nativamente; as 57 fontes incorporadas foram comparadas ao src e coincidem (scripts/check_bundle_sources.py). Build não equivale a Play no Studio.
