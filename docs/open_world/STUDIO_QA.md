# Validação prática — mundo aberto

Status desta entrega: **pendente no Roblox Studio**. Os testes automatizados desta fase executaram regras e geometria com plataforma simulada. Nenhum resultado abaixo está marcado como aprovado sem uma sessão real.

Use [Feras-Open-World.rbxlx](../../releases/Feras-Open-World.rbxlx), reconstruído das fontes atuais. Execute `bash scripts/open_world/test` antes da revisão. Para persistência, publique uma experiência privada de teste e habilite API Services; use contas e dados de teste, sem editar perfis de produção para montar cenários.

Registre versão/commit do place, dispositivo, resolução, qualidade gráfica, número de clientes e mensagens do Output. Para cada falha, anote posição, região, passos para reproduzir e resultado observado.

## 1. Entrada, mapa e exploração

- [ ] Perfil novo nasce no Alvorecer, com as sete regiões disponíveis no Mapa e sem cobrança de ouro para viajar.
- [ ] Com explorador nível 1 e sem ouro, percorra **a pé** Alvorecer → Brasa → Recife → Floresta → Dunas → Picos → Pântano → Alvorecer. A travessia não deve exigir compra, nível, guardião ou teleporte.
- [ ] Confira piso e colisão na entrada, no meio e na saída das sete estradas. Cruze também pelas bordas para procurar frestas, degraus ou queda entre peças.
- [ ] Suba e desça os três mirantes de cada região pelas rampas, sem salto especial. Confira sentido da rampa, junção com o topo e colisões de colunas/decoração.
- [ ] Explore centro, periferia, marcos, ruínas e pontos de encontro. Verifique se os modelos não aparecem sob o piso ou dentro dos mirantes.
- [ ] Confira placas e texto da região no HUD. Ao caminhar para o próximo território, o contexto deve mudar para a região física atual.
- [ ] Observe o Mapa durante a travessia de uma estrada: o destino só deve ficar Visitado após entrar no território. A visita não deve surgir apenas por selecionar a região no menu.
- [ ] Entre em Dunas, morra e confira respawn no último acampamento seguro. Queda no vazio deve retornar ao acampamento sem reiniciar a coleção.

## 2. Streaming e viagens

O projeto configura `StreamingEnabled=true`, raio mínimo 64 e alvo 256. O comportamento depende da execução real e da conexão.

- [ ] Caminhe pelos caminhos com streaming ativo; confira carregamento do piso à frente e ausência de queda por geometria que ainda não chegou ao cliente.
- [ ] Viaje repetidamente para destinos distantes, incluindo o acampamento pessoal. Aguarde a breve janela de estabilização e confirme que o personagem volta a se mover.
- [ ] Clique rapidamente em dois destinos. A segunda viagem deve ser recusada enquanto a primeira ainda está em andamento, sem deixar o personagem preso ou registrar visita no destino recusado.
- [ ] Morra ou provoque respawn enquanto uma viagem estiver carregando. O novo personagem deve continuar utilizável e conseguir viajar novamente.
- [ ] Após sair do acampamento, retorne caminhando a uma região e confira que o contexto de casa não permanece ativo.
- [ ] Observe Output durante desconexão/reentrada e viagens. Registre erros de streaming, `PivotTo`, personagem ou callbacks.

## 3. Encontros, captura e níveis

- [ ] Com o mesmo explorador iniciante, encontre feras em Alvorecer e Pântano. Compare com as faixas do Mapa: o nível selvagem deve depender da região e da raridade, sem reduzir para acompanhar o jogador.
- [ ] Repita com conta de nível alto. Alvorecer deve continuar oferecendo níveis baixos. Raridade 3 pode exceder o teto base em dois níveis; raridade 4, em três.
- [ ] Aproxime-se de uma fera, abra o encontro, ataque, use vínculo, troque companheiro, tente captura direta e fuja. Confira HP, selos, estoque, recompensas, encerramento e retorno à exploração.
- [ ] Tente capturar uma fera muito acima do preparo, depois compare com equipe/selos mais preparados. A interface deve continuar utilizável; a captura continua possível, com pressão de dificuldade.
- [ ] Afaste-se e retorne aos pontos de fauna. Confira surgimento próximo, descarte distante após a tolerância e respawn após captura, sem duplicar exemplares do mesmo ponto.
- [ ] Deixe um encontro aberto enquanto outro cliente se afasta da área. A fera ocupada deve permanecer até o encontro terminar.
- [ ] Morra durante encontro e confira encerramento, liberação da fera e possibilidade de iniciar outro encontro após respawn.
- [ ] Guardiões devem manter suas regras e não conceder captura. A missão da Fênix continua exigindo seus glifos, nível e cooldown, mesmo com Dunas aberta desde o início.
- [ ] Acione o altar com personagem morto e morra durante uma abertura. Não deve restar encontro preso nem cobrança de tentativa/cooldown por abertura interrompida.

## 4. Multiplayer e propriedade

Execute **Start Server com pelo menos dois clientes**. Esses cenários não foram executados pelo teste headless.

- [ ] Dois jogadores tentam abrir a mesma fera ao mesmo tempo. Apenas um obtém o encontro; o outro continua livre para jogar.
- [ ] Repita captura, fuga, derrota, morte e desconexão do dono do encontro. O ponto deve ser liberado uma vez, sem duplicar aquisição, débito de selo ou recompensa.
- [ ] Mantenha os clientes em regiões diferentes. Confira população regional, companheiros, respawn e atualização de contexto independentes.
- [ ] Visite o próprio acampamento, o terreno do outro cliente e um ponto fora dos terrenos. Ações que dependem de casa só devem funcionar no terreno pertencente ao jogador.
- [ ] Um jogador sai enquanto o outro permanece na base. O terreno removido não deve continuar autorizando ações do antigo dono.

## 5. Persistência e migração

Faça estes cenários com perfis antigos copiados para um ambiente isolado de teste.

- [ ] Migre perfil anterior para esquema 6 no mesmo DataStore `ArquipelagoV1`, chave `P<UserId>`. Compare moedas, gemas, criaturas/UIDs, níveis/XP, ovos, inventário, companheiro, habitats, missões e Fênix antes/depois.
- [ ] Confira regiões abertas e navegação inicial. As regiões liberadas não devem criar habitats automaticamente; capítulos já resgatados não devem oferecer a recompensa novamente.
- [ ] Coloque uma fera em habitat de uma região antes não comprada. Salve, saia, entre novamente e confira ocupantes, estruturas e inventário.
- [ ] Desconecte durante carregamento e reconecte. Não deve persistir perfil ou terreno fantasma nem sessão renovada para quem já saiu.
- [ ] Entre com a mesma conta em dois servidores de teste. Confira proteção de lease sem sobrescrever o progresso da sessão ativa.
- [ ] Teste indisponibilidade de dados, perfil inválido e versão futura no ambiente isolado. A entrada deve ser recusada, preservando o registro; não deve surgir reset automático.
- [ ] Feche o servidor de teste e entre novamente. Confira salvamento de checkpoint, coleção e alterações recentes.

## 6. Interface, renderização e desempenho

- [ ] Teste mouse/teclado, toque e gamepad. Confira foco, ativação dos prompts, botões do combate e fechamento/reabertura das abas.
- [ ] No Device Emulator, confira telas pequenas em retrato e paisagem. Mapa, Equipe, Regiões, Diário, Acampamento, Criação e Bestiário devem rolar sem botões cortados ou sobrepostos.
- [ ] Alterne de companheiro e use Ver no bestiário. A espécie selecionada deve aparecer mesmo se havia filtro de busca anterior.
- [ ] Confira cuidado, habitat, produção e reprodução como opções da base. A trilha principal deve poder avançar por visitas e capturas sem exigir criação.
- [ ] Revise modelos e decoração em todas as regiões: pés no chão, sombras, contraste, nomes, câmera, escala e transições de distância.
- [ ] Meça em aparelho real de entrada e desktop: FPS, tempo de frame, memória, instâncias, custo do servidor e tráfego. Compare uma região vazia, fauna ativa, combate e múltiplos clientes espalhados.
- [ ] Faça sessão contínua de pelo menos 20 minutos com viagens e capturas; procure crescimento de instâncias/memória, callbacks duplicados e degradação de resposta.

## Registro de execução

| Campo | Preencher após testar |
|---|---|
| Place / commit | Pendente |
| Data e responsável | Pendente |
| Dispositivos e resoluções | Pendente |
| Clientes simultâneos | Pendente |
| Física e streaming | Não executados nesta entrega |
| Multiplayer e DataStore real | Não executados nesta entrega |
| Renderização e desempenho | Não executados nesta entrega |
| Falhas encontradas / evidências | Pendente |
| Decisão para publicar | Pendente de revisão prática |

Concluir o roteiro exige registrar os resultados reais e corrigir/retestar as falhas encontradas. Suíte automatizada aprovada não substitui essa homologação.
