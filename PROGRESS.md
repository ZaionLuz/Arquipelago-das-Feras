# Reforma visual atual

Leia docs/ART_PROGRESS.md e docs/ART_REPORT.md. A branch art-overhaul contém duas passagens de arte, pipeline e bundle separados. Main e a lógica V7 foram preservados. As pendências visuais de Studio estão discriminadas no relatório.

---

# Progresso atual — V7

✔ Código, testes e build da V7 concluídos neste ambiente. Estado estável: `bash scripts/test` retorna zero; relatório em docs/VALIDACAO_V7.md.

Entregue: acesso central por região/nível; migração para esquema 5 no mesmo ArquipelagoV1; Fênix especial por três vestígios e altar; 30 designs com 88 layouts efetivos, rigs/cache/LOD; galeria Studio; UI de ilhas/dificuldade e bestiário com Viewport reutilizado; simulações e regressão.

◐ Próximo passo exato: abrir releases/Feras-V7.rbxlx em experiência privada, Play e executar CreatureGallery.build pelo Command Bar do servidor conforme docs/QA_STUDIO_V7.md. Registrar aprovação de aparência/animação, dois clientes, mobile, respawn, barreiras, streaming e DataStore real. Não chamar a homologação estética de concluída antes disso.

✘ Análise tipada integral com luau-lsp e definições Roblox permanece indisponível aqui (binário ARM incompatível e nova conexão de download indisponível); lint/sintaxe e testes executáveis passaram. Fixtures históricas são sintéticas, não dados reais de contas.

O escopo V7 são 30 espécies e sete ilhas. Planos anteriores de 100 criaturas/dez regiões não foram adicionados a esta etapa. Estágio 4 da Fênix permanece futuro e desativado.
