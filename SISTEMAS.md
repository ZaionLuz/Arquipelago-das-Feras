> V7 atual: consulte [docs/VALIDACAO_V7.md](docs/VALIDACAO_V7.md). O conteúdo abaixo registra as versões anteriores.

# Sistemas — versão de integração RPG/santuário (V6)

## Dados

DataStore ArquipelagoV1 e chaves P<UserId> preservados. Versão persistente 4, migrada de 3. Novos campos: playerLevel/playerXp, sanctuary, companion, storyClaimed, guardians, visited, materials, gatherAt e sealStock. Criaturas existentes e seus níveis/XP são mantidos; o teto aceito passa a 100. Perfil antigo sem santuário recebe posições válidas para ilhas já desbloqueadas. Habitantes legados incompatíveis de elemento são preservados, mas novas transferências precisam ser compatíveis.

A aquisição da sessão continua usando lease no mesmo registro, autorrenovado pelo autosave. Falhas de carregamento não criam um novo perfil descartável. Há salvamento periódico e na saída; uma queda abrupta pode perder ações desde o último save bem-sucedido. Não afirmamos durabilidade instantânea por captura. Alterações no formato devem ser testadas em experiência privada antes de usar dados reais.

## Progressão

Explorador e criaturas têm teto 100. XP do explorador para próximo nível: 50+25×nível. XP da criatura: 35+15×nível. Captura dá XP ao explorador; vitória dá XP a ambos (criatura ativa) e capítulos dão recompensas próprias. Alimentar continua como opção de treinamento por ouro.

Os marcos de evolução **legados 7/15 continuam**, preservando aparência e comportamento dos dados anteriores. O alvo sugerido 16/36, evolução manual por materiais e apresentação transformadora completa ainda não foram implementados. A Fênix segue adulta no estágio 3, com estágio 4 desativado.

## Selos

| Tipo | Receita / requisito | Efeito |
|---|---|---|
| Básico | 25 ouro, explorador 1 | Multiplicador base 1. |
| Reforçado | 60 ouro, explorador 8 | Multiplicador 1,12. |
| Elemental | 85 ouro +1 essência Natureza, explorador 16 | 1,35 com companheiro do mesmo elemento da fera; 1,1 nos demais casos. |
| Raro | 160 ouro +1 essência Terra, explorador 24 | 1,4 para espécies épicas/lendárias; 1,15 para comuns/raras legadas. |
| Ancestral | 300 ouro +2 essências Sombra, explorador 40 | 1,55 com vínculo 2 ou 3; 1,4 sem essa preparação. |

Na batalha, o botão Selo alterna o tipo antes de lançar. O servidor valida o estoque escolhido; selos básicos continuam usando o campo legado seals, outros usam sealStock. Mudar o tipo incrementa a versão, mas não consome turno. Só uma tentativa válida consome recurso. A probabilidade completa é calculada no servidor, incluindo vida e vínculo, com limite de 94%. Não há compras reais ou sorteios pagos.

## Batalha

Preserva equipe de três, criatura ativa, velocidade, defesa, tipos e seis habilidades por família. Feras selvagens podem ser capturadas diretamente ou enfraquecidas. Guardiões bloqueiam captura/vínculo. Token, versão, frequência, distância, sessão e propriedade são conferidos; respostas antigas não devem consumir outro recurso. A vitória só concede uma recompensa por encontro. Treino legado e duelos consensuais permanecem.

## Companheiro

A seleção é validada no servidor e persistida como UID próprio. Atributos públicos do Player replicam somente espécie/nível/UID para representação visual. Cada cliente mostra no máximo seis companheiros próximos e reduz exemplares grandes a uma escala confortável. Movimento é cosmético: interpolação, teste de obstrução simples e correção de distância; não é pathfinding completo. O mesmo pet fica oculto no habitat enquanto acompanha o dono, sem perder sua produção. Guardar o pet restaura a exibição no santuário.

Carinho gera uma reação visual, sem fome, penalidade ou recompensa explorável. Voo mantém altura leve. Resta testar paredes, escadas, água, respawn e câmera nos dispositivos reais. O pet não participa automaticamente da equipe de batalha: o jogador escolhe seu combatente no encontro.

## Construção

Habitat identificado pela região elemental, com no máximo um de cada região. Nove posições fixas previnem interpenetração de estruturas; não existe colocação livre. Construir exige desbloqueio e ouro; melhorar custa 180×nível atual; remover exige habitat vazio e não reembolsa. Novas transferências validam elemento/híbrido e capacidade. Nenhuma ação recebe um proprietário arbitrário do cliente. Toda mutação usa Data.get(jogador).

## Interface e gráficos

Nova aba Santuário com grade de construção, Home, viagem e carinho. HUD inclui nível, barra de XP e capítulo atual. Missões integra a aventura de Maia. Opções permite Baixo/Médio/Alto e movimentos reduzidos; as preferências são locais à sessão, não alteram de forma forçada a configuração gráfica global do Roblox. Baixo reduz alcance/animações e efeitos; não substitui revisão real de geometria e benchmarking. Interface mantém gavetas, áreas seguras e alvos de toque da V5.

Referência da API usada no transporte: [Player.RequestStreamAroundAsync — Roblox Creator Hub](https://create.roblox.com/docs/reference/engine/classes/Player#RequestStreamAroundAsync). A existência da API foi conferida na documentação; seu comportamento de streaming/teleporte nesta experiência ainda deve ser testado no Studio. A solicitação não substitui medição real de carregamento em rede lenta.
