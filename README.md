# Arquipélago das Feras (Roblox, Luau)
Colecione, cruze e evolua feras em seis ilhas elementais; batalhe com vantagem de elemento.

## Rodar
1. Instale Rojo (rojo.space) e rode `rojo serve`; no Studio, conecte pelo plugin Rojo. Ou `rojo build -o Feras.rbxlx` e abra o arquivo.
2. Para salvar no Studio: Game Settings > Security > Enable Studio Access to API Services.
3. Play (F5). Aba Feras: alimentar, pôr na ilha, lutar. Aba Ilhas: desbloquear/selecionar. Aba Ovos: cruze 2 feras, chocar, acelerar com gemas. Missões (15) e Loja de ovos por ilha.

## Arquitetura
- `shared/` Elements, Creatures (29 feras), Islands (6 biomas), Breeding, ModelFactory (modelos procedurais).
- `server/` DataService (DataStore validado, retry, não sobrescreve se falhar), GameService (regras autoritativas), World (mapa e feras nas ilhas), Main (RemoteFunction única, validação e limite de chamadas).
- `client/` interface criada por código. Cliente só pede ações; o servidor decide tudo.
Renda usa `os.time()` do servidor (limite de 8 h): mexer no relógio local não ajuda.

## Configuração obrigatória antes de publicar
- **Áudio:** `src/shared/Sounds.luau` está vazio (silencioso). Cole IDs de áudio que você tem permissão de usar.
- **Robux:** `src/server/MonetizationService.luau`: crie 2 Developer Products (gemas) e 2 Game Passes (ouro em dobro, aura cosmética) e cole os IDs. Com 0 o item fica desativado. Compras são opcionais; nada bloqueia o jogo gratuito.
- **Eventos:** elemento da vez (+50% ouro) muda a cada 3 dias; recompensa diária com sequência.
- **Balanceamento (precisa de playtest):** preços/recompensas em GameService (`80*idx` ovo, `12*idx*raridade` vitória, cooldown de batalha 20 s, `lv*20` alimentar) e `gpm` em Creatures.

## Novidades
- Efeitos de golpe por elemento (projétil, trajetória, partículas e onda de choque próprios).
- Evolução com silhueta nova por estágio (filhote, jovem com membros, ancestral com cabeça separada).
- Arena: duelo contra outros jogadores do MESMO servidor (melhor fera de cada um; rival não perde nada; cooldown 30 s; troféus).
- Tutorial guiado de 5 passos (destaca o botão certo; pode pular).
- Mundo: pontes entre ilhas, água, atmosfera e bloom. Feras agora ficam em pé sobre o chão.

## Entrega incremental atual
Leia `AUDITORIA.md`, `PROGRESS.md` e `TESTES-STUDIO.md`. A versão de dados foi elevada para 2, preservando o DataStore e IDs antigos. Backup e teste privado são obrigatórios antes de usar dados de produção. Biomas próprios e idle por família foram adicionados; esta não é ainda a implementação completa da visão do jogo.

## Versão 3
Abra primeiro `ABRIR-NO-STUDIO.md`. Melhorias da chocadeira, regras e limitações estão em PROGRESS.md. A interface do projeto é criada por código; não exige assets externos ou plugins além do fluxo Rojo. Assets de áudio continuam vazios. Não há monetização real habilitada.
