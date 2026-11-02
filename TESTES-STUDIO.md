# Validação obrigatória no Studio

1. Instale Rojo CLI e plugin. Na raiz: `rojo build -o Feras.rbxlx`. Abra o arquivo no Studio. Alternativa: `rojo serve` e conectar plugin. Não colar módulos em locais diferentes do default.project.json.
2. Publique uma experiência PRIVADA DE TESTE. Habilite Game Settings → Security → Enable Studio Access to API Services somente nela. Não teste sobre dados comerciais. Áudio e produtos permanecem zero/vazios.
3. F5: conferir Output sem erros; novo jogador inicia com 100 ouro, 5 gemas, cinzelo/bolhinho e Brasa. Coletar, alimentar, comprar ovo, cruzar, aguardar 30–480s, chocar. Reconectar e verificar recursos/IDs.
4. Legado: usar perfil v1 com u99 e nextId=3; carregar e chocar deve criar u100 sem substituir u99. Dados com v maior que 2 ou creatures não-tabela devem recusar entrada, não sobrescrever.
5. Dois servidores com a mesma chave de teste: segundo deve recusar lease ativo. Após saída normal permite entrar. Após encerramento abrupto aguardar até 180s. Servidor velho nunca deve sobrescrever token novo. Simular falhas de UpdateAsync: avisos no Output, reconexão preserva último save. Lease expirado bloqueia ações.
6. Start Server com dois clientes: cada um só alimenta/move UID próprio; chamadas Get retornam cópias sem receipts/_session. Spammar remotes, usar tables/Instances/NaN/strings gigantes/IDs ausentes: sem alteração de recursos nem crash.
7. Desafiar outro jogador: primeira ação não deve dar ouro/troféu. Rival deve clicar Desafiar no nome do remetente em 30s. Convite expirado não luta. Rival que saiu não luta; cooldown limita recompensas.
8. Inspecionar seis biomas, pontes, spawn e trajetos em celular via Device Emulator. Confirmar decoração não impede navegação e criaturas apoiadas no chão. Medir FPS/Parts no MicroProfiler com dois clientes e inventários cheios. Verificar idle de Bird/Serpent/Insect e pausa à distância.
9. Testar alimentar até 7/15/20, habitat cheio, incubadora com três ovos, inventário com 60, ilhas sem ouro, resgatar missão/diária duas vezes, acelerar ovo pronto. Nada deve consumir indevidamente ou duplicar recompensa.
10. Produtos continuam DESATIVADOS. Antes de ativar: testes de recibo repetido, falha no save, desconexão durante compra e duas callbacks simultâneas. Revisar regras atuais do Roblox e permissões de áudio. Não usar compra paga aleatória sem revisão específica.

Limitações: nenhum teste acima foi executado neste ambiente. Não há garantia de FPS, resultado visual ou comportamento de DataStore sem validação no Studio.

## Design e coleção (nova entrega)
- Abrir cada uma das 29 espécies nos níveis 1/7/15; conferir silhuetas, olhos, apoio no chão, bounding box e frente da criatura na batalha. Conferir especialmente Colossodune (golem), Fênix Fuligem (ave), Aracnoflora (oito pernas) e Rei Nevoento (espírito).
- Bestiário: rolar até o final e voltar, redimensionar janela, trocar abas 30 vezes. Verificar filtros, silhuetas desconhecidas e ausência de crescimento contínuo de instâncias/conexões. Modelos fora da lista visível devem ser destruídos.
- Chocar ovo: modelo e nome correto; Continuar fecha. Alimentar de 6→7 e 14→15 mostra evolução uma única vez. Fechar automaticamente após 20s. Alimentação comum não abre evolução.
- Cliques rápidos durante combate não iniciam segunda requisição; falha de conexão libera interação. Conferir asas/pernas/caudas sem deslocamento acumulado após 5 minutos.
- Device Emulator 360px e controle: conferir área dos sete botões, textos de stats e fechamento da apresentação. Medir FPS antes/depois com 60 criaturas de dois jogadores. Nenhum desses testes visuais foi executado aqui.

## Versão 3 — teste integrado da chocadeira
1. Escolher cinzelo/bolhinho. Ver duas prévias, resultados possíveis e chances; custo 50 ouro. Confirmar híbrido vaporino entre os resultados. Não cobrar antes de clicar Cruzar.
2. Acumular três ovos: tentativa adicional recusa e não desconta. Sem 50 ouro: prévia desabilita cruzamento; chamada direta também recusa.
3. Enquanto incuba: Chocar desabilitado; custo de Acelerar muda conforme o tempo. Ao chegar a zero: Chocar ativo/Acelerar inativo. Conferir regra no servidor alterando relógio do cliente.
4. Chocar dois ovos rapidamente: inFlight impede sobreposição; ovo só removido depois do sucesso, UID único e descoberta registrada. Inventário 60: ovo permanece intacto.
5. Desconectar/reconectar durante incubação: tempo usa ready do servidor e segue correndo offline. Eclosão mostra modelo correto; raro/épico tem título apropriado.
6. Confirmar que contagem não destrói e recria ViewportFrames a cada segundo. Abrir/fechar aba Ovos 50 vezes, inspecionar memória. Testar duas fileiras em Device Emulator e gamepad.
7. Mercado não mostra Robux. Remote Buy deve recusar mesmo após configuração de IDs. Não realizar compras reais nesta versão.
8. Gerar os 87 modelos com DesignChecks.run(). Rodar DataStore e testes de dois servidores da seção anterior antes de publicar.

## Homologação V4 (pendente, não executada aqui)
1. Rojo build e Play. Ver apenas HUD/atalhos, sem gaveta. Abrir/fechar Menu, Escape, trocar todas as abas. Confirmar acesso a Coletar, ovos, missões, mercado, ilhas, duelos e som. Medir >=75% livre durante exploração com tutorial fechado. Testar 360×640, paisagem e tablet com controles Roblox e entalhe.
2. Bestiário: girar prévia, rolar seleção, raridade/bioma, silhuetas não descobertas, quantidade e estágio. Trocar abas 100 vezes e verificar desconexão de Heartbeat/memória. Só uma prévia principal deve permanecer viva.
3. Rodar `require(game.ReplicatedStorage.Shared.DesignChecks).run()`: agora 90 combinações (29 originais × 3 + Fênix testada nos níveis 1/7/15, sempre adulta). Conferir partes, olhos, silhueta, asas e halo solar da Fênix.
4. Criatura selvagem: se aproximar, segurar prompt; tentar disparar remotamente de longe, sem selo, inventário 60, ilha bloqueada, morto e com dois jogadores segurando ao mesmo tempo. Só um UID por encontro. Confirmar que falha consome 1 selo e remove encontro; tentativas inválidas não consomem.
5. Ir ao Mercado, criar selo: ouro -25, selo +1. Reconectar: saldo preservado. Migração de v2 recebe cinco selos uma única vez e mantém criaturas, moedas e XP. Nova sessão v3 não renova selos automaticamente.
6. Capturar e desconectar: confirmar último progresso salvo conforme autosave; forçar save e reconectar. Captura entra no Bestiário e na coleção, não em habitat automaticamente; usar Pôr na aba Feras.
7. Testar spawn por ilha, limite global 12, 25s de reposição, nenhum modelo dentro de decoração. Verificar patrulha plana/voo e custo de replicação com vários clientes. Teleporte exploratório deve ser validado separadamente antes de jogo competitivo.
8. Inspeção visual especial da Fênix: adulta em lv1/7/15/20, Fênix Fuligem preservada; `futureStage.enabled=false`; nenhum acesso ao estágio 4 por Feed, Hatch, captura ou remote. Para visualizar sem capturar, usar DesignChecks ou criar modelo localmente no Studio com ModelFactory.build(Creatures.ById.fenix,1).
9. Cenários novos: caminhar pelo centro e pontes, conferir marcos/cachoeira decorativa, superfícies sem bloqueios invisíveis. Não presumir água/lava perigosas: são decorativas nesta versão.

## V5 — homologação de encontro, arte e interface

- Gerar lugar com Rojo, abrir Output e F5; conferir streaming 64/256 e modelos atômicos. Desbloquear/visitar as seis ilhas, atravessar pontes, testar proximidade e criaturas sem sobreposição com árvores/rochas. Inspecionar novas bordas costeiras por baixo e por cima.
- Executar DesignChecks.run(): comparar todas as 90 variantes com luz natural. Conferir rostos, focinhos, olhos e piscar, asas, carapaças e proporções nos níveis 1/7/15. Verificar Fênix, Colossodune, Aracnoflora, Ancestrávore e Rei Nevoento. O teste com stub não substitui esta inspeção.
- Encontro sem selecionar companheiro: vínculo até três cargas, tentar capturar, falhar, fugir; verificar débito e UID. Sem selos ou coleção cheia: não consumir. Criar selo antes do encontro custa 25 ouro.
- Encontro com equipe: escolher até três criaturas, trocar (vida não restaura), golpe, velocidade, vantagem elemental, seis habilidades, recarga, proteção, companheiro exausto. Reduzir HP melhora a chance de captura; derrotar zera HP e dá ouro/XP, não captura.
- Dois clientes usam mesmo prompt simultaneamente: um único proprietário de encontro. Enviar mesmo token/versão 20 vezes: um único consumo/recompensa. Token alheio, versão passada, UID alheio, strings grandes, ação inválida e requisições sem sessão não alteram recursos.
- Encerrar por fuga, 150 segundos, 30 turnos, morte, saída da região e desconexão. A criatura deve ser liberada ou reposta; nenhuma reserva permanente. Personagem que respawna deve poder iniciar outro encontro. Encontro interrompido não premia.
- Conferir ganho de XP, subida de nível, evolução legada e persistência depois de save/reconexão. Repetir State/Attack/Capture depois da vitória/captura não repete concessão. Simular falha de save e perda de conexão; botão Atualizar deve recuperar estado.
- Batalha: animação de avanço/retorno, barras, log, selo visual; repetir 100 encontros e monitorar conexões/instâncias. Nenhum modelo de prévia deve ser reconstruído a cada frame. O bloqueio de animação impede cliques sobrepostos; testar também perda de resposta.
- Interface: 320×568, 360×640, tablet, paisagem 640×360 e desktop; tocar ações de 44px, rolar equipe/ações, fechar gaveta, pesquisar e filtrar Bestiário. Não cobrir joystick/salto durante exploração. Testar gamepad com seleção e retorno à exploração. Confirmar tutorial oculto com gaveta aberta.
- Performance: dois e oito clientes, 60 criaturas por jogador, Bestiário aberto/fechado, fauna completa. Medir FPS, memória, replicação e frame time no MicroProfiler; avaliar cutoff de 12 animações e streaming. Nenhum valor de FPS foi medido neste ambiente.
- Verificar bloqueio e liberação do movimento em teclado, toque e gamepad durante o encontro, inclusive morte/timeout. Botões de golpe/habilidade/proteção sem companheiro e habilidade em recarga devem estar desabilitados. Simular evento de início perdido e confirmar recuperação Resume ao inicializar a interface.
