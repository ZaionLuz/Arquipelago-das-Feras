# Referências da revisão 3D

A direção do projeto continua sendo a imagem enviada pelo autor: criaturas expressivas, cores naturais vivas, sombras azul-violeta e volumes acolhedores. Nesta entrega isso foi traduzido em anatomia tridimensional, silhuetas e articulações próprias. A imagem de referência não é apresentada como um modelo do jogo.

## Materiais consultados

| Fonte | Consulta e aplicação |
| --- | --- |
| [Blender Studio: Stylized Character Workflow](https://studio.blender.org/training/stylized-character-workflow/) e [biblioteca de personagens](https://studio.blender.org/characters/) | Referências públicas de fluxo de trabalho: massas primárias antes de ornamentos, rosto legível e revisão da silhueta em vários ângulos. O curso completo e os arquivos privados não foram baixados. |
| [Fox, glTF Sample Assets / Khronos](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/Fox) | Um GLB público foi aberto e inspecionado no Blender: duas malhas, 1.770 vértices e um armature. Serviu para estudar proporções de quadrúpedes, distribuição de volume e leitura das patas. O modelo não integra os arquivos do jogo. |
| [Loomian Legacy, Roblox](https://www.roblox.com/games/306964494/Loomian-Legacy) | Página e mostruários publicados de criaturas em Roblox, incluindo [Sedimars](https://x.com/IuckyHD/status/1530959002280009729) e [Pyrolen](https://x.com/LLNewsCenter/status/1544452718873436166). Referência de rostos, silhuetas e contraste que funcionam à distância. Não foi executado o cliente Roblox durante a revisão. |
| [Pokémon: Octillery](https://www.pokemon.com/us/pokedex/octillery) e [imagem HOME pública do PokeAPI](https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/224.png) | Leitura de cabeça, olhos e braços de um cefalópode estilizado. O Kraken do projeto recebeu manto, braços curvos articulados, coroa de coral e paleta índigo/turquesa próprios. |
| [Palworld, página oficial do jogo no Steam](https://store.steampowered.com/app/1623730/Palworld/) | Referência de espécies com massas reconhecíveis e contraste entre corpo, acessórios orgânicos e rosto. |
| [Cassette Beasts, página oficial do jogo no Steam](https://store.steampowered.com/app/1321440/Cassette_Beasts/) | Referência de conceitos originais, combinações temáticas e transformações que mantêm a identidade da espécie. Sua arte 2D foi tratada como referência de design, não como geometria 3D pronta. |

O Fox público tem créditos próprios no repositório de origem: modelo de PixelMannen sob CC0; rig/animações de tomkranis sob CC-BY 4.0; conversão glTF de Asobo Studio/scurest sob CC-BY 4.0. A consulta foi feita fora da distribuição do projeto. Nenhuma malha, textura ou personagem dessas referências foi incorporado aos modelos entregues.

## Decisões aplicadas

- Cabeça, focinho, mandíbula, tórax, membros e cauda formam volumes separados com conexões verificadas; detalhes pequenos não substituem a anatomia.
- As 30 espécies existentes receberam mudanças de geometria. As dez novas têm temas e estruturas próprias: capivara de bambu, bode de brasa, axolote de coral, tatu das dunas, urso de nuvens, sapo luminoso, abelha de orquídea, lince de cristal, elefante-marinho e Kraken.
- Filhote, jovem e adulto mudam proporção e detalhes. Fênix e Kraken começam visualmente no estágio adulto; não foram inventadas formas infantis para essas duas espécies.
- O Kraken usa oito braços, segmentos curvos e ventosas; folhas, penas, garras e membranas seguem hierarquias articuladas no assembly nativo.
- A versão leve preserva corpo, cabeça e demais volumes essenciais. Ornamentos dispensáveis são reduzidos e a política existente de animação limita modelos ativos e atualizações por distância.

As pranchas de revisão são renders Blender da geometria exportada da `ModelFactory`, com frente, costas e estágios. São evidência da modelagem entregue; aparência e desempenho no renderer Roblox ainda exigem execução no Studio.
