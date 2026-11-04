# MISSÃO DA NOITE: REFORMA GRÁFICA TOTAL DO JOGO

Você é um engenheiro sênior + technical artist continuando o desenvolvimento do meu jogo de captura/criação de monstros (inspirado em Pokémon e Dragon City). Vou dormir e você vai trabalhar sozinho a noite inteira, focado em UMA ÚNICA COISA:

>>> A MELHORIA COMPLETA, PROFUNDA E CONSISTENTE DO DESIGN GRÁFICO DE ABSOLUTAMENTE TUDO QUE APARECE NO JOGO. <<<

Meta de qualidade visual: nível CASSETTE BEASTS. Isso significa pixel art de alta qualidade, paleta rica e harmoniosa, contornos coloridos, monstros carismáticos e cheios de personalidade, animações fluidas, ambientes vivos e cheios de detalhe, UI com identidade própria e muito "juice" (partículas, flashes, shake, transições). Use o estilo como INSPIRAÇÃO. NÃO copie assets, personagens ou designs de Cassette Beasts, Pokémon ou qualquer outro jogo. Tudo deve ser original.

## REGRAS DE OURO
1. FOCO ÚNICO: só arte/visual. Não adicione features de gameplay, não mude balanceamento, não refatore lógica, não mexa em save data. Única exceção: mudanças mínimas de código necessárias para carregar, animar ou renderizar os novos visuais (atlas, animações, shaders, CSS, etc.).
2. AUTONOMIA TOTAL: não me faça perguntas. Decida sozinho e registre as decisões em docs/ART_PROGRESS.md.
3. O JOGO NUNCA PODE QUEBRAR. Depois de cada bloco de trabalho: rode build/lint/testes (se existirem) e abra o jogo para confirmar que funciona. Só então faça commit.
4. Crie a branch `art-overhaul` e faça commits pequenos e frequentes (`art(battle): novo fundo de floresta`). Nunca delete assets originais: mova para `assets/_legacy`.
5. Consistência vale mais que quantidade. Tudo precisa parecer do mesmo jogo.

## FASE 0: RECONHECIMENTO (primeiros 20-30 min)
- Leia README, AGENTS.md, package.json etc. Descubra a stack, como o jogo renderiza, como os assets são carregados, a resolução base e a estrutura de pastas.
- Rode o jogo e capture screenshots (headless com Playwright/Puppeteer, se possível) de TODAS as telas e estados.
- Crie docs/GRAPHICS_AUDIT.md com o inventário COMPLETO de tudo que é visual: monstros, tipos/elementos, jogador, NPCs, tiles, prédios, props, cenários, fundos de batalha, UI, ícones, efeitos, fontes, transições, tela de título, loading, etc. Dê uma nota de 0 a 10 para o estado atual de cada item.
- Transforme esse inventário em checklist em docs/ART_PROGRESS.md.

## FASE 1: DIREÇÃO DE ARTE (docs/ART_BIBLE.md)
Defina e siga rigorosamente:
- GRID: resolução base e tamanho de sprites/tiles (respeite o que já existe no jogo). Escala sempre inteira, renderização sem blur (nearest-neighbor / image-rendering: pixelated).
- PALETA: paleta global (~32-48 cores) com rampas de 4-5 tons por cor. Sombras com hue-shift (puxando para azul/roxo), luzes quentes. Cores saturadas, mas harmoniosas.
- CONTORNO: 1px colorido (selective outlining), nunca preto puro em tudo.
- LUZ: fonte única (cima-esquerda), com rim light e sombras no chão.
- MONSTROS: silhuetas fortes e únicas (reconhecível só pela sombra), proporções expressivas, designs esquisitos e carismáticos, linguagem visual coerente com o tipo/elemento, rostos com personalidade.
- ANIMAÇÃO: idle de 4-6 frames, squash & stretch, ataques com antecipação, impacto e follow-through.
- UI: identidade própria e consistente (painéis com bordas pixeladas, cantos chanfrados, sombras duras, estados normal/hover/pressed/disabled), fonte pixel legível.
- Centralize cores, bordas e espaçamentos em design tokens (um único arquivo).

## FASE 2: PIPELINE DE ASSETS
- Se você tiver ferramenta de geração de imagem, use. Caso contrário, crie scripts reproduzíveis (Python+Pillow ou Node) que gerem pixel art a partir de grids de caracteres + paleta, ou use SVG/Canvas, conforme a stack do jogo.
- Gere spritesheets/atlas organizados e um comando único (ex: `npm run assets`) que regenera tudo.
- VALIDE VISUALMENTE cada lote: renderize contact sheets e screenshots, olhe o resultado e refaça o que estiver feio.

## FASE 3: EXECUÇÃO (ordem de impacto)
1. TELA DE BATALHA (a mais vista): fundos por bioma, plataformas, sprites de frente/costas, barras de HP, menus, animações de ataque, números de dano, status effects, transições de entrada/saída.
2. MONSTROS (TODOS): sprite base + idle + ataque + dano + derrota, evoluções/estágios (ovo, filhote, adulto, se existirem), variações por tipo, ícones pequenos para party/box/coleção.
3. OVERWORLD: tilesets completos (grama, água animada, árvores, pedra, caminhos, areia, neve, caverna, cidade, interiores), props, prédios, sombras, profundidade, variações para não repetir, animações ambientais (grama balançando, água, flores, nuvens), iluminação/dia-noite/clima se existir.
4. PERSONAGENS: jogador (4 direções, andar, correr, idle), NPCs, treinadores, retratos/expressões de diálogo.
5. UI/UX VISUAL: tela de título, menu principal, party, inventário, coleção/dex, loja, habitats/criação (se existir), caixas de diálogo, botões, modais, notificações, tooltips, loading.
6. ÍCONES: itens, tipos, golpes, status, moedas, conquistas.
7. VFX E JUICE: partículas, hit flash, screen shake, captura, evolução, level up, transições de cena, easing em tudo que se mexe.
8. POLIMENTO FINAL: passe de consistência (paleta, alinhamento, contraste), performance (60 FPS), zero pixel borrado, zero placeholder.

## LOOP DE TRABALHO
Escolher o próximo item do checklist -> criar/melhorar -> integrar no jogo -> rodar e capturar screenshot -> comparar antes/depois -> corrigir -> commit -> marcar o checklist -> repetir.

## CRITÉRIO DE QUALIDADE
Para cada tela e asset, pergunte: "isso poderia aparecer num screenshot de Cassette Beasts sem destoar?" Se a nota for menor que 8/10, refaça. Não avance deixando retângulo colorido, emoji, sprite genérico ou placeholder para trás.

## SE TRAVAR
- Se um asset não ficar bom em 3 tentativas, faça uma versão mais simples porém consistente, anote como TODO no progress e siga em frente. Não gaste a noite inteira em um item só.
- Se algo quebrar e você não resolver em ~15 min, reverta o bloco (git) e siga para o próximo.

## NÃO PARE CEDO
Quando terminar o checklist, comece um segundo passe de polimento completo, de novo pela tela mais vista. Continue melhorando até acabar o tempo. Mantenha docs/ART_PROGRESS.md sempre atualizado.

## ENTREGA FINAL
Crie docs/ART_REPORT.md com: screenshots antes/depois, tudo que foi feito, o que ficou pendente, como rodar o jogo e como regenerar os assets. No fim, mande um resumo curto do que mudou.