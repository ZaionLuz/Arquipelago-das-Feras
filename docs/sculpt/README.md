# Esculturas 3D — 30 feras

Esta entrega muda exclusivamente os modelos das criaturas. As 30 espécies receberam anatomias próprias, com volumes conectados, rostos em camadas, membros, caudas e apêndices construídos em 3D. A direção é fantasia acolhedora: cores quentes, creme, sombras azul-violeta, formas expressivas e silhuetas fáceis de reconhecer, tomando a imagem fornecida como referência de estilo.

Há **88 formas**: três estágios para 29 espécies e a Fênix solar somente adulta. Nomes, IDs, elementos, atributos de combate, marcos de evolução e aquisição foram preservados. O estágio 4 da Fênix continua futuro. O trabalho de recursos em andamento ficou separado desta branch.

## Abrir os modelos

- **[Galeria-Criaturas-3D.rbxl](../../releases/Galeria-Criaturas-3D.rbxl)**: abra no Roblox Studio para inspecionar as 88 formas já montadas, mesmo sem apertar Play ou configurar DataStore. Estão organizadas por espécie, com filhote, jovem e adulto lado a lado. A galeria é estática e não contém scripts.
- **[Feras-Creature-Sculpt.rbxlx](../../releases/Feras-Creature-Sculpt.rbxlx)**: jogo com os modelos novos integrados a encontros, companheiros, habitats, combate e bestiário pelo ModelFactory compartilhado.
- **[Revisão offline](../../assets/sculpt/review.html)**: extraia o ZIP e abra este HTML no navegador para ver as pranchas.
- **[Meshes GLB](../../assets/sculpt/meshes.zip)**: 30 adultos para Blender e outras ferramentas 3D, reconstruídos da mesma geometria usada no jogo. São meshes de revisão estáticos, sem skinning. Não representam MeshParts publicados no Roblox. O jogo usa os assemblies nativos articulados por Motor6D, sem IDs de assets inventados.

## Direção de cada espécie

| Espécie | Anatomia e identidade visual |
|---|---|
| Cinzelo | Salamandra baixa com focinho largo, dedos, fornalha arredondada, alvenaria e chaminé. |
| Magmarau | Javali de brasa robusto, focinho projetado, presas curvas e placas vulcânicas. |
| Fênix Fuligem | Ave de fuligem com peito de brasa, máscara, leque de penas e cauda carbonizada. |
| Vulcanodrago | Dragão basáltico quadrúpede, mandíbula, chifres, espinha e asas próprias. |
| Bolhinho | Peixe arredondado, bochechas, nadadeiras e leque de guelras. |
| Marilisco | Serpente marinha curva com crista, barbatanas e antenas aquáticas. |
| Caranguepérola | Carapaça perolada, coral, pernas de dois segmentos e pinças opostas. |
| Abissauro | Predador abissal de mandíbula larga, dentes e isca luminosa arqueada. |
| Brotinho | Semente viva com patas de raiz, sépalas, folhas e crescimento floral. |
| Folhuco | Raposa laranja e creme, orelhas folhosas triangulares, peito felpudo e cauda curva. |
| Aracnoflora | Aranha floral com pernas articuladas, cálice e coroa adulta de pétalas. |
| Ancestravore | Guardião de tronco bípede, galhadas ramificadas, mãos e raízes. |
| Grãozinho | Geodo de carapaça mineral, cristais e face expressiva. |
| Escorpiodra | Escorpião de couraça com pinças, patas e cauda arqueada segmentada. |
| Esfingeólito | Esfinge felina com peito, patas, cauda e toucado construído em camadas. |
| Colossodune | Semente de ruína que se torna golem, com arcos e vãos reais no torso adulto. |
| Penugem | Coruja arredondada com olhos grandes, penugem, asas dobradas e pés curtos. |
| Ventanil | Ave esguia de vento, pescoço, asas abertas em leque e fitas na cauda. |
| Trovoraptor | Raptor elétrico ereto, pernas com joelhos, braços e cristas de raio. |
| Aeronimbo | Dragão-serpente de nuvens, chifres, massas de nuvem e corpo curvo. |
| Lodinho | Criatura de lama ciclope, corpo baixo, poças, musgo e brotos. |
| Caudalume | Serpente espectral com rosto luminoso e cauda-lanterna curva. |
| Vagalumorte | Mariposa-fantasma de casulo luminoso, nervuras, ocelos e asas multilobadas. |
| Reinevoento | Rei espectral de manto, gola, coroa, braços e camadas de névoa. |
| Vaporino | Serpente-chaleira de cobre e pátina, tubos, curvas e volumes de vapor. |
| Magmaterra | Tartaruga vulcânica, casco em terraços, caldeira aparente e veios de lava. |
| Tempestália | Ave real azul-violeta, coroa e asas em camadas com leque amplo. |
| Nevoamusgo | Cervídeo de líquen com patas, focinho, galhadas e folhas pendentes. |
| Cinzavento | Wyvern de cinza, orelhas, mandíbula, pernas e asas próprias. |
| Fênix solar | Ave adulta de asas amplas em três camadas, peito creme, halo e caudas em fitas. |

As evoluções mudam proporções, postura e apêndices. O verificador compara a geometria normalizada entre estágios; aumentar somente a escala não passa. Aracnoflora, Colossodune e Vagalumorte tiveram uma segunda passagem estrutural após essa revisão.

## Estrutura, integração e resultados

As cinco bibliotecas `SculptOrganic`, `SculptTidal`, `SculptSky`, `SculptMystic` e `SculptDrakes` contêm as 30 receitas anatômicas. `SculptContext` constrói volumes, conectores, folhas e olhos. `ModelFactory` mantém a interface e o cache por espécie/estágio, clonando a geometria para cada uso.

Body e Head têm articulações; asas movem conjuntos inteiros, com penas ligadas à raiz de cada asa. Há validação de ligações, ciclos, referências entre clones, colisões, massa, tamanhos e transforms finitos. Partes visuais continuam sem colisão; a raiz fica ancorada. O animador agora usa limites por qualidade e um ajuste adaptativo no cliente.

- **30 espécies e 88 formas**, construídas com tipos Roblox nativos em Lune.
- **240 construções** na verificação de rigs e isolamento de clones.
- Até **190 peças** na Fênix; a cena de revisão com 40 criaturas continua abaixo do orçamento original de **3.200 peças**. Contagens são evidência estrutural, não medição de FPS.
- A galeria foi serializada, relida e teve os 88 rigs novamente validados.
- A regressão de combate, captura, aquisição, progressão e persistência continua no comando de testes.
- **58 arquivos de fontes anteriores permanecem byte a byte iguais** ao baseline: regras, serviços de jogo, save, mapa, economia e demais módulos. As mudanças ficam na apresentação das criaturas, nos caches dos previews, no animador e no verificador de design. [Hashes](GAMEPLAY_UNCHANGED.json).

Resultados detalhados: [rigs](RIG_METRICS.json), [geometria](../MODEL_METRICS.json) e [execução](TEST_RESULTS.txt).

## Modo leve e responsividade

O modo **Baixo** retira ornamentos pequenos, preservando corpo, cabeça, volumes principais e rigs. Nos 30 adultos, a contagem cai de 2.173 para 1.755 peças (cerca de 19%); a Fênix passa de 190 para 129. A galeria inteira passa de 5.200 para 4.224 peças. [Métricas](LOD_METRICS.json).

No mundo, o cliente oculta os detalhes e criaturas distantes; nos previews, a fábrica monta a variante com menos peças. O cache mantém no máximo **uma variante por espécie/estágio**, sem guardar cópias completa e leve simultaneamente.

- Baixo: até seis criaturas animadas,15 atualizações/s próximas e 8 distantes, ocultação após 180 studs.
- Médio: até 16 criaturas; pode reduzir detalhes automaticamente após amostras consistentes de baixo desempenho e restaurá-los após recuperação estável. Há aquecimento, histerese e intervalo entre mudanças para evitar alternância contínua.
- Alto: até 24 criaturas; a escolha manual é respeitada.
- Previews fora da área do scroll, ocultos ou destruídos não ocupam slots de animação. Espécie, estágio e qualidade fazem parte da chave do cache; subir um nível dentro do mesmo estágio não remonta o modelo.

O agendador foi testado com serviços simulados e CFrame nativo: tetos de 150/80 atualizações em 10s no modo leve, clipping, restauração de detalhes e ausência de reescritas contínuas de transparência. A galeria **[Galeria-Criaturas-3D-Leve.rbxl](../../releases/Galeria-Criaturas-3D-Leve.rbxl)** permite comparar as formas simplificadas no Studio.

Esses resultados medem geometria e agendamento. FPS, memória e fluidez precisam ser medidos no computador real; nenhum benchmark de hardware é apresentado como executado.

## Reproduzir

```bash
bash scripts/sculpt/test
python scripts/sculpt/render_models.py
```

O teste usa Python 3, Luau CLI/compiler, Lune, Rojo, Selene e StyLua. Executáveis podem ser indicados por `LUAU_BIN`, `LUAU_COMPILER_BIN`, `LUNE_BIN`, `ROJO_BIN`, `SELENE_BIN` e `STYLUA_BIN`. O render usa Blender 4.3 e Pillow; veja as instruções em `assets/sculpt`.

As imagens de revisão são **renders Blender da geometria exportada**, com luz de estúdio e sombras. Não são capturas do Roblox nem imagens conceituais apresentadas como modelos. A reconstrução do antigo mesh Head usa um elipsoide; os modelos novos usam as formas exportadas diretamente. Os PNGs intermediários podem ser regenerados; a distribuição usa WebP.

## Conferir no Roblox Studio

A montagem nativa, os rigs e os arquivos foram testados neste ambiente. O renderer Roblox, a física e o desempenho em aparelhos reais ainda precisam de conferência. Abra a galeria, confira frente/costas e cada evolução, depois use o jogo para verificar enquadramento do bestiário/combate, piscar, voo, caminhada, contato dos pés e movimento das caudas. A luz real do jogo pode apresentar diferenças em relação ao render Blender.
