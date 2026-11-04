# Pendências atuais — mundo aberto

Executar [o roteiro no Studio](docs/open_world/STUDIO_QA.md): caminhar nas sete estradas e 21 rampas, conferir streaming e fauna, viagens/morte, dois clientes, persistência real, UI mobile e desempenho. A suíte headless e o bundle passaram; a execução no Roblox não foi realizada aqui. Os itens abaixo registram as fases anteriores e não representam bloqueios de entrada nas áreas atuais.

---

# Histórico — reforma visual

Play e screenshots de todas as telas no Roblox Studio, revisão estética humana, toque/mobile e FPS real. A adaptação entregue é3D com linguagem pixel; conversão integral2D está fora do que foi verificado. Veja docs/ART_REPORT.md.

---

# Pendências e limites V7

◐ Revisão estética de cada espécie/estágio na galeria; movimento dos Motor6D, penas e caudas em render real.
◐ Device Emulator e aparelhos reais: responsividade, toque, câmera e consumo com vários jogadores.
◐ Barreiras, streaming e respawn físico; acesso lógico e remotes forjados já foram testados headless.
◐ Multiplayer e DataStore real: desconexão durante save, cooldown, leases e concessão única; plataforma simulada passou.
◐ Playtest do ritmo e composição de equipes; simulações batem as metas na média das faixas/presets documentados, com variação individual.
✘ Análise tipada completa com luau-lsp x86 e definições Roblox; binário ARM não executou, nova tentativa de download falhou na conexão.
✘ Fixtures de contas reais V1–V6 não fornecidas; as seis fixtures entregues são sintéticas e explicitamente rotuladas.

Áudio e monetização são configurações opcionais vazias/desativadas, sem IDs inventados. Estágio 4 da Fênix, 70 espécies adicionais e dez regiões pertencem à visão futura, fora da V7 de 30 espécies/sete ilhas.

Procedimento de revisão: docs/QA_STUDIO_V7.md. Evidências executadas: docs/VALIDACAO_V7.md e docs/RESULTADOS_V7.txt. Nenhum item acima foi marcado como executado no Studio.
