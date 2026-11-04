# Mundo V7

✔ `scripts/test`: Access, faixas, inspeção de região, destino de respawn e remotes reais com plataforma simulada.
◐ Montagem das barreiras, streaming, saltos e respawn físico exigem Studio.

| ID preservado | Explorador | Selvagens | Guardião | Ouro |
|---|---:|---|---:|---:|
| Alvorecer | 1 | 1–9 | 11 | 0 |
| Brasa | 10 | 10–17 | 19 | 1440 |
| Recife | 18 | 18–25 | 27 | 3384 |
| Floresta | 26 | 26–33 | 35 | 5112 |
| Dunas | 34 | 34–41 | 43 | 6840 |
| Picos | 42 | 42–49 | 51 | 8568 |
| Pantano | 50 | 50–57 | 59 | 10296 |

O cliente pede um destino. Access valida nível, desbloqueio, ilha anterior e ouro; Transport marca a operação antes de solicitar streaming e só confirma a região após sucesso. Caminhar diretamente para outro volume sem entrar pelo portão/viagem não altera a sessão: RegionGuard devolve ao último ponto seguro. Os arcos nas pontes oferecem a entrada validada. Dados antigos mantêm as permissões com `legacyGrandfathered`.

Ruínas das Dunas: câmara com paredes, arena, colunas, altar, cristais e três vestígios (dois nas Dunas, um nos Picos). Prompt validado por distância e contexto. O terceiro sinal libera a apresentação local do portão; atravessar visualmente a laje não autoriza o altar. Atmosfera e correção de cor são locais e removidas/restauradas ao sair, sem emissores globais. A trilha oculta usa a aba Missões e o snapshot do diário já existente.

Os nomes genéricos nas ruínas evitam anunciar o encontro. O teste de sigilo cobre o payload especial `quest` no estágio zero, exatamente `{stage=0}`. Catálogos e textos compartilhados continuam inspecionáveis pelo cliente; não se promete sigilo contra mineração de arquivos.
