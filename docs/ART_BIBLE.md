# Bíblia visual — Arquipélago das Feras

Identidade original: cadernos de expedição, metal patinado, papel creme, céu lilás e ilhas recortadas. Inspiração retro em legibilidade, caráter e cor; nenhum personagem/asset de outro jogo.

## Grade e renderização

Roblox 3D preservado, sem resolução fixa forçada na câmera do jogador. UI trabalha em múltiplos de 4 px; ícones originais em 16×16 com células inteiras. Atlases de revisão usam células declaradas no manifest e nearest-neighbor. Não usar filtros de blur nem ampliar PNG com escala fracionária no pipeline. Não existe garantia de pixel perfeito em toda tela Roblox sem Studio; Viewports continuam renderização nativa 3D.

## Cor e luz

ArtTokens.luau é fonte única de 48 cores: oito rampas de cinco tons (Ember, Tidal, Leaf, Sand, Sky, Veil, Metal, Rose) + oito neutros. Sombras frias azul/ameixa, médios saturados e luz creme/pêssego. Luz aparente de cima/esquerda, contorno colorido seletivo, base/sombra de contato nos cenários; evitar preto e branco puros, vidro brilhante sem motivo e Neon excessivo.

## Criaturas

Manter 30 IDs e anatomias, distinguir espécies pela silhueta. Olhos, sobrancelhas e boca devem expressar personalidade; planos de corpo e cauda coloridos por luz. Ovo/filhote/juvenil/adulto são os estados já existentes, sem criar nova progressão. Fênix permanece o adulto solar em três fileiras de penas. Animação contínua equivale a seis poses-chave: repouso, antecipação, compressão, impacto, retorno e reação; não afirmar sprites 2D em uso no runtime.

## Interface

Fonte interna Arcade, tamanhos legíveis, texto creme. Bordas de 2 px, cantos chanfrados ou degraus, sombras duras, foco dourado e hover/pressed/disabled distintos. Alvos ≥44 px. Menu de exploração recolhido, batalha legível em retrato e paisagem. Ícones de 16 px desenhados por grade; evitar emoji como arte. Não adicionar fluxo de gameplay para justificar a arte.

## Movimento e custo

Transições curtas 120–250 ms; impacto com retorno garantido da câmera, shake local discreto, flashes sem repetição agressiva. Respeitar qualidade Baixo/Médio/Alto e movimentos reduzidos. Sem heartbeat por monstro/prop; loops centrais e LOD. Orçamento por criatura 28/48/80 e Fênix170 preservado. Cenários de batalha e decoração têm orçamento próprio testável.
