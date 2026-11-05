# Bestiário de 40 espécies — revisão e expansão

Esta entrega refina os 30 modelos anteriores e adiciona dez criaturas originais. São 116 formas: três estágios para 38 espécies, mais as formas adultas da Fênix e do Kraken. O foco desta passagem é modelagem; mapa, exploração, interface e sistemas de batalha não receberam uma nova reforma.

## Arquivos prontos

- `releases/Feras-Bestiario-40.rbxlx`: jogo completo com o catálogo ampliado.
- `releases/Galeria-40-Feras.rbxl`: 116 modelos nativos prontos para inspeção, sem DataStore e sem scripts de jogo.
- `releases/Galeria-40-Feras-Leve.rbxl`: a mesma galeria com menos ornamentos.
- [Pranchas offline](../../assets/bestiary40/review.html): adultos, estágios e vistas de costas.
- [Meshes estáticos GLB](../../assets/bestiary40/meshes.zip): os 40 adultos para inspeção em ferramentas 3D, com mapa das articulações nativas.

## Dez anatomias novas

| Espécie | Região | Elemento | Design |
| --- | --- | --- | --- |
| Bambunim | Floresta | Natureza | Capivara de bambu: focinho largo, incisivos, patas curtas e brotos dorsais. |
| Brasebode | Brasa | Fogo | Bode de brasa: chifres curvos de cobre, cascos divididos, barba e crina incandescente. |
| Coralote | Recife | Água | Axolote coralino: guelras ramificadas, quatro patas e cauda com membrana. |
| Dunatatu | Dunas | Terra | Tatu das dunas: carapaça segmentada, focinho comprido, garras e placas de cerâmica. |
| Nimburso | Picos | Ar | Urso de nuvens: ombros altos, focinho projetado, patas largas e gola de nuvens. |
| Lumissapo | Pantano | Sombra | Sapo luminoso: coxas dobradas, dedos espalhados e saco vocal com marcações. |
| Nectarim | Floresta | Natureza | Abelha-orquídea: seis membros, tórax peludo, asas e abdômen com flor. |
| Cristalince | Dunas | Terra | Lince de cristal: orelhas pontudas, tufos, mandíbula, patas e cristais dorsais. |
| Maritromba | Recife | Água | Elefante-marinho: tromba, bigodes, nadadeiras espalmadas e cauda bipartida. |
| Kraken | Recife | Água | Lendário abissal: oito braços curvos, ventosas, bico, manto alto e coroa de coral. |

As formas juvenis e adultas possuem alterações em cabeça, postura, membros e apêndices. O Kraken começa adulto, usa encontros selvagens do Recife com peso reduzido e pode ser capturado pelos sistemas existentes. Não entra nos ovos comerciais nem na reprodução. A Fênix mantém sua aquisição especial e a evolução futura continua desativada.

## Refinamento dos 30 anteriores

Quadrúpedes ganharam transições entre tórax, pescoço e mandíbula, apoio das patas e perfis mais definidos. Serpentes e criaturas aquáticas receberam guelras, escalas abdominais, mandíbulas e nadadeiras conectadas. Aracnídeos e escorpiões têm postura e articulações mais claras. Nas aves há cotovelo e punho sob a plumagem, rêmiges afiladas, bicos com profundidade e caudas curvas; a Fênix preserva as 16 rêmiges, 28 segmentos de cauda e o halo de 16 arcos/8 raios.

As esculturas usam assemblies estilizados de volumes nativos com Motor6D. Não são meshes orgânicos contínuos ou GLBs com skin. Os GLBs e renders Blender reconstruem exatamente os volumes exportados para revisão estática; a aparência pode diferir com a iluminação e renderização do Roblox. Nenhum asset de jogos de referência foi incorporado. Veja as [fontes consultadas](REFERENCIAS.md).

## Desempenho e integridade

A cena headless com um adulto de cada uma das 40 espécies totaliza **3191 peças**, dentro do limite de 3.200. O modo leve reduz para **2599 peças** (18.6% a menos), preservando os volumes essenciais e os rigs. São contagens, sem simulação de física nem medição real de FPS.

O cache mantém uma variante por espécie/estágio, no máximo 116 templates. Permanecem as otimizações anteriores para animação por distância, teto de modelos animados, pausa fora da tela e previews visíveis. O Kraken completo tem 185 peças; o leve tem 105, preservando os oito braços e seus 40 segmentos.

As 88 formas anteriores têm mudanças geométricas verificadas, sem depender de nomes ou cores. Os registros e atributos das 30 espécies legadas são idênticos. A expansão acrescenta dez entradas, descrição e anatomia, peso de encontro e uma guarda de reprodução que impede cobrança em pares inválidos. Nenhuma migração ou reset de save foi introduzido: o DataStore ArquipelagoV1 e o esquema 6 permanecem. A conferência de escopo em [SOURCE_SCOPE.json](SOURCE_SCOPE.json) registra as fontes preservadas; [REFINEMENT_METRICS.json](REFINEMENT_METRICS.json) compara geometria, ignorando nomes e cores.

## Verificação

`bash scripts/bestiary40/test` executa regressão, round-trip de perfis com as novas espécies, catálogo, encontros, reprodução, anatomia do Kraken, comparação geométrica, rigs, clones, versões leves, cache, animação simulada, escopo, galerias, lint e bundle. `python scripts/bestiary40/check_assets.py` confere a entrega de meshes e imagens após a renderização.

Resultados em [TEST_RESULTS.txt](TEST_RESULTS.txt), [RIG_METRICS.json](RIG_METRICS.json), [LOD_METRICS.json](LOD_METRICS.json) e [ANATOMY_METRICS.json](ANATOMY_METRICS.json). Os testes headless não homologam a estética, física, multiplayer ou o desempenho de um computador real. A conferência final usa o [roteiro do Studio](STUDIO_QA.md).
