# V5 — encontros por turnos, arte procedural e interface

## Jogar

1. Aproxime-se de uma fera selvagem e segure **Encontrar fera**.
2. Você pode **Lançar Selo** diretamente, sem batalhar, ou **Criar vínculo** para aumentar a chance (a fera pode fugir se você estiver sem companheiro).
3. Para lutar, selecione uma criatura da faixa da equipe. Até três criaturas diferentes podem participar do mesmo encontro. Trocar após a primeira seleção consome um turno e dá uma ação ao adversário. A vida de cada participante é mantida durante o encontro; trocar não cura.
4. Golpe usa vantagem elemental, ataque e defesa. A criatura mais rápida ataca primeiro. Habilidade recarrega em três turnos e depende da família: pulso vital (cura), investida (poder), rajada (redução do próximo dano), sopro (poder), maré debilitante (reduz ataque), trama aderente (reduz velocidade).
5. Proteger recupera 8% da vida máxima e reduz dano; vínculo tem até três cargas. Enfraquecer o adversário e criar vínculo aumentam a chance exibida de captura. Cada tentativa válida gasta um selo.
6. Se a vida selvagem chegar a zero, o encontro termina em vitória: ouro e XP para a fera ativa. **Uma fera exausta não pode ser capturada**. Use proteção/vínculo se quiser evitar derrotá-la antes de lançar o selo.
7. Captura bem-sucedida adiciona um UID único à coleção e ao Bestiário, mas não equipa habitat automaticamente. Use Pôr na aba Feras. Sem selo ou inventário cheio não há consumo. Crie selos por ouro no Mercado antes do encontro.
8. Fugir libera a criatura para outros jogadores. Capturar ou vencer remove o encontro e programa outro aparecimento. Encontros têm limite de 30 turnos, 150 segundos e distância de 40 studs do ponto inicial. Morrer, desconectar ou sair da região encerra o encontro. Recuperação de erro de conexão: botão Atualizar. Não tente continuar movendo o personagem durante a batalha.
9. O treino antigo e os duelos consensuais continuam disponíveis, com suas regras anteriores. Os botões antigos Lutar foram renomeados Treino; o combate selvagem é o novo modo interativo. Demais operações da coleção ficam bloqueadas durante encontro ativo para manter as regras consistentes.

## Segurança e persistência

`CombatRules` é puro e só o servidor o aplica. O cliente envia ação/UID/token/versão, nunca vida, dano ou resultado. O servidor verifica perfil, criatura própria, distância, vida do jogador, sessão ativa, prazo e frequência. Versões antigas não consomem recurso. Recompensa/concessão/liberação são feitas uma vez por sessão. Selos e coleção são mutados sem yield no trecho decisório. Capturas concorrentes reservam a fera para um jogador; o prompt é liberado na fuga/timeout. Não há monetização real.

O DataStore e os IDs existentes foram preservados. XP por vitória utiliza o campo já persistido; custo de nível = 35 + nível × 15, até nível 20. Evolução continua seguindo níveis 7/15. A Fênix mantém estágio adulto 3; estágio 4 continua desativado. HP dos encontros é temporário; a coleção não fica permanentemente ferida. Recursos seguem o ciclo de salvamento existente, não um save por clique: uma falha abrupta pode perder ações desde o último save bem-sucedido. Não garantimos durabilidade transacional por captura.

## Arte e desempenho

- Todas as 30 espécies receberam proporções explícitas e motivos anatômicos, além de elementos/estágios: focinhos, carapaças, guelras, pétalas, placas, mantos, penas, antenas, núcleos e detalhes solares. Não há modelos/assets copiados de Pokémon.
- Estágio jovem/adulto aumenta número de penas, placas e detalhes; filhote usa cabeça proporcionalmente maior. Fênix adulta e Fênix Fuligem seguem separadas.
- Geologia das seis ilhas tem volumes rochosos grandes e litoral, vegetação menos regular, iluminação mais natural. Colisão da superfície original é preservada; geometria costeira nova é decorativa.
- Streaming configurado no projeto Rojo (64/256 studs) e criaturas com streaming atômico. Confirmar essas propriedades no Studio ao importar/sincronizar.
- Máximo de 12 criaturas animadas nas proximidades, revisão da lista a cada 0,5s e poses a 20Hz. Instâncias fora do alcance não recebem animação contínua. Animador inclui feras selvagens, limitando alterações locais a membros; posição decisória permanece do servidor.
- 12 encontros selvagens no máximo; deslocamento do servidor reduzido a 2Hz. Não é IA com pathfinding. Ela patrulha pequenas regiões seguras; obstáculos novos devem ser testados.
- Prévia principal e miniaturas visíveis no Bestiário, com descarregamento ao sair do painel. Modelos da batalha são reutilizados entre turnos. Nenhum emissor de partículas contínuo ou PointLight por criatura foi acrescentado.
- O teste estrutural construiu 90 variações; máximo observado de 49 partes por modelo. Isso é contagem de geometria, não benchmark de FPS.

## Interface

Tema comum verde-petróleo/champagne, contornos finos, cartões mais legíveis e gaveta responsiva. Ações da coleção em linha própria com alvos de 46px; abas de 50px. Tutorial some enquanto a gaveta/encontro está aberto. Bestiário tem miniaturas, pesquisa por nome descoberto, filtros de raridade/bioma/elemento, uma prévia principal giratória e exemplares. Batalha tem cenário 3D em ViewportFrame, nomes, barras de vida, logs, chance real de captura, equipe e ações. Menu ajusta largura à tela, barras de ações/equipe têm rolagem interna; controles mínimos de 44px. Mouse, toque e seleção de gamepad foram preparados em código; homologação em dispositivos não foi executada.

## Testes executados

- Compilação sintática de todos os arquivos Luau via CLI oficial compilado neste ambiente.
- Regras de combate/captura em Luau: 900 pares de dano, 150 simulações completas, chances/vida limitadas, seleção inválida sem mutação, equipe de até três, recarga, fuga, captura direta, selos, inventário e encerramento.
- Serviço de encontros em ambiente simulado: token incorreto, versão antiga, UID alheio, consumo e concessão únicos, vitória sem recompensa repetida, timeout e saída. Esses testes simulam os serviços Roblox, não a rede real.
- ModelFactory executado com stub de estruturas/tipos: 90 variantes, tamanhos positivos, ancoragem e máximo de 49 partes. O stub não implementa render, rotações ou física Roblox; não valida qualidade visual, rig, colisões ou bounding boxes reais.
- Regressão de reprodução, estágios e Fênix: 900 pares, 27 mil sorteios e amostra adicional de 20 mil híbridos. IDs e mapeamentos Rojo preservados.

## Limitações de verificação

Não há Roblox Studio neste ambiente. Não foram executados playtest visual, teste real de remotes/concorrência, DataStore, gamepad, celular nem medição de FPS/memória. A compilação e simulação não provam aparência ou desempenho em um aparelho. Não chamamos a versão de jogo comercial homologado. A arte é procedural estilizada com geometria básica, sem uma equipe de modelagem/rigging produzindo meshes esculpidas. Áudio permanece silencioso até configuração de assets autorizados. Nenhuma dessas limitações foi escondida como teste aprovado.

### Relatório final de checagens
`python tests/run_checks.py --luau <caminho-do-luau> --compiler <caminho-do-luau-compile>` aprovado: 37 arquivos compilados; quatro suítes isoladas executadas. Recuperação Resume permite à própria sessão recuperar um evento inicial perdido, sem concessão de recompensa. O personagem tem seus controles locais bloqueados durante o encontro via ContextActionService; fuga/fechamento libera os controles. A distância/morte também é validada pelo servidor. Essas integrações de controles continuam pendentes de validação real no Studio.
