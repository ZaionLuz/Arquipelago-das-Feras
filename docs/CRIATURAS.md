# Criaturas V7 — 30 fichas de construção

✔ Estrutura: 91 construções validadas em `scripts/check_models.luau`. São 88 layouts únicos: 29 espécies com três estágios e a Fênix sempre adulta; pedidos nos níveis 1/7/15 da Fênix repetem seu adulto, além da verificação em 60. ◐ Arte, proporções em movimento e expressividade aguardam revisão humana na galeria.

As fichas abaixo descrevem as receitas implementadas. O processo desta execução começou pelas receitas anatômicas e só consolidou este documento após os testes; não alegamos que estas fichas foram escritas antes dos builders.

Limiar entre espécies: 0,12; mínimo medido 0.15218 (fenixfuligem/penugem:3). A métrica combina geometria normalizada (40%), aspecto (15%), componentes construídos (15%), tipos de peça/mesh (10%), paleta quantizada (10%) e tupla anatômica (10%). IDs de espécie não pontuam. Estágios precisam de distância geométrica ≥0,08; mudanças só de escala não passam.

## Cinzelo (`cinzelo`)

Família: **mineral/golem**. Inspiração: salamandra de fornalha. Silhueta: mineral/golem com cabeça `embermask`, apêndice `chimney` e terminação `cinder`.

Três marcas da combinação: cabeça `embermask`; apêndice `chimney`; cauda `cinder`. Rosto: olhos `emberslit` com inserção frontal/lateral definida pelo componente. Superfície: `cracks`. Motivo elemental: Fogo.

Um núcleo de carvão vivo protegido por pequenas placas mornas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 18 / 22**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Magmarau (`magmarau`)

Família: **quadrúpede**. Inspiração: javali de cerâmica. Silhueta: quadrúpede com cabeça `boar`, apêndice `tusks` e terminação `club`.

Três marcas da combinação: cabeça `boar`; apêndice `tusks`; cauda `club`. Rosto: olhos `vertical` com inserção frontal/lateral definida pelo componente. Superfície: `plates`. Motivo elemental: Fogo.

Fera de focinho largo e presas minerais que procura pedras aquecidas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **17 / 25 / 29**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Fênix Fuligem (`fenixfuligem`)

Família: **alado**. Inspiração: íbis de cinzas. Silhueta: alado com cabeça `hookbeak`, apêndice `ashcrest` e terminação `fan`.

Três marcas da combinação: cabeça `hookbeak`; apêndice `ashcrest`; cauda `fan`. Rosto: olhos `emberslit` com inserção frontal/lateral definida pelo componente. Superfície: `feathers`. Motivo elemental: Fogo.

Uma ave de penas escuras com uma crista que parece guardar as últimas brasas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **13 / 24 / 34**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Vulcanodrago (`vulcanodrago`)

Família: **dracônico**. Inspiração: dragão de basalto. Silhueta: dracônico com cabeça `hornjaw`, apêndice `basalthorns` e terminação `spade`.

Três marcas da combinação: cabeça `hornjaw`; apêndice `basalthorns`; cauda `spade`. Rosto: olhos `vertical` com inserção frontal/lateral definida pelo componente. Superfície: `scales`. Motivo elemental: Fogo.

Réptil alado com placas de basalto e um brilho quente entre as escamas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **18 / 31 / 41**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Bolhinho (`bolhinho`)

Família: **aquático**. Inspiração: baiacu de recife. Silhueta: aquático com cabeça `puffer`, apêndice `gillfans` e terminação `paddle`.

Três marcas da combinação: cabeça `puffer`; apêndice `gillfans`; cauda `paddle`. Rosto: olhos `fish` com inserção frontal/lateral definida pelo componente. Superfície: `spots`. Motivo elemental: Água.

Criatura arredondada com pequenas guelras que observa o mundo através de bolhas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 22 / 26**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Marilisco (`marilisco`)

Família: **serpentino**. Inspiração: basilisco de maré. Silhueta: serpentino com cabeça `narrow`, apêndice `dorsalsail` e terminação `sail`.

Três marcas da combinação: cabeça `narrow`; apêndice `dorsalsail`; cauda `sail`. Rosto: olhos `fish` com inserção frontal/lateral definida pelo componente. Superfície: `bands`. Motivo elemental: Água.

Serpente de nadadeiras altas que repousa entre corais cristalinos.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **13 / 18 / 23**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Caranguepérola (`carangueperola`)

Família: **artrópode**. Inspiração: caranguejo ermitão. Silhueta: artrópode com cabeça `crab`, apêndice `pearlclaws` e terminação `shell`.

Três marcas da combinação: cabeça `crab`; apêndice `pearlclaws`; cauda `shell`. Rosto: olhos `compound` com inserção frontal/lateral definida pelo componente. Superfície: `pearls`. Motivo elemental: Água.

Um guardião de pequenas pérolas com carapaça larga e pinças arredondadas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **21 / 31 / 35**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Abissauro (`abissauro`)

Família: **aquático**. Inspiração: peixe-pescador abissal. Silhueta: aquático com cabeça `angler`, apêndice `lure` e terminação `fork`.

Três marcas da combinação: cabeça `angler`; apêndice `lure`; cauda `fork`. Rosto: olhos `cyclops` com inserção frontal/lateral definida pelo componente. Superfície: `ridges`. Motivo elemental: Água.

Réptil marinho que ilumina seu caminho com uma pequena isca sobre a cabeça.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **14 / 20 / 24**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Brotinho (`brotinho`)

Família: **vegetal**. Inspiração: bulbo germinante. Silhueta: vegetal com cabeça `bud`, apêndice `seedleaves` e terminação `root`.

Três marcas da combinação: cabeça `bud`; apêndice `seedleaves`; cauda `root`. Rosto: olhos `round` com inserção frontal/lateral definida pelo componente. Superfície: `veins`. Motivo elemental: Natureza.

Um pequeno broto ambulante que abre suas folhas ao encontrar companhia.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 25 / 31**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Folhuço (`folhuco`)

Família: **quadrúpede**. Inspiração: raposa de folhas. Silhueta: quadrúpede com cabeça `fox`, apêndice `leafears` e terminação `leafbrush`.

Três marcas da combinação: cabeça `fox`; apêndice `leafears`; cauda `leafbrush`. Rosto: olhos `blindmarks` com inserção frontal/lateral definida pelo componente. Superfície: `veins`. Motivo elemental: Natureza.

Fera de corpo esguio e orelhas vegetais que se esconde entre folhas novas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 25 / 31**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Aracnoflora (`aracnoflora`)

Família: **artrópode**. Inspiração: aranha-orquídea. Silhueta: artrópode com cabeça `trilobe`, apêndice `flower` e terminação `petal`.

Três marcas da combinação: cabeça `trilobe`; apêndice `flower`; cauda `petal`. Rosto: olhos `compound` com inserção frontal/lateral definida pelo componente. Superfície: `leaves`. Motivo elemental: Natureza.

Aracnídeo com pétalas protetoras que se camufla como uma flor da floresta.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **23 / 36 / 42**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Ancestrávore (`ancestravore`)

Família: **bípede**. Inspiração: cervo de madeira antiga. Silhueta: bípede com cabeça `stagmask`, apêndice `antlers` e terminação `stump`.

Três marcas da combinação: cabeça `stagmask`; apêndice `antlers`; cauda `stump`. Rosto: olhos `barkmarks` com inserção frontal/lateral definida pelo componente. Superfície: `bark`. Motivo elemental: Natureza.

Fera robusta cujos galhos lembram a copa de árvores muito antigas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **13 / 23 / 27**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Grãozinho (`graozinho`)

Família: **mineral/golem**. Inspiração: geodo de areia. Silhueta: mineral/golem com cabeça `geode`, apêndice `geodecrown` e terminação `gravel`.

Três marcas da combinação: cabeça `geode`; apêndice `geodecrown`; cauda `gravel`. Rosto: olhos `crystal` com inserção frontal/lateral definida pelo componente. Superfície: `facets`. Motivo elemental: Terra.

Uma pequena geoda viva com um núcleo que pulsa sob sua carapaça de pedra.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 16 / 22**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Escorpiodra (`escorpiodra`)

Família: **artrópode**. Inspiração: escorpião de duna. Silhueta: artrópode com cabeça `mandible`, apêndice `pincers` e terminação `stinger`.

Três marcas da combinação: cabeça `mandible`; apêndice `pincers`; cauda `stinger`. Rosto: olhos `compound` com inserção frontal/lateral definida pelo componente. Superfície: `bands`. Motivo elemental: Terra.

Artrópode baixo de carapaça longa e cauda mineral erguida.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **22 / 34 / 38**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Esfingeolito (`esfingeolito`)

Família: **quadrúpede**. Inspiração: esfinge de arenito. Silhueta: quadrúpede com cabeça `sphinx`, apêndice `headdress` e terminação `tuft`.

Três marcas da combinação: cabeça `sphinx`; apêndice `headdress`; cauda `tuft`. Rosto: olhos `blindmarks` com inserção frontal/lateral definida pelo componente. Superfície: `runes`. Motivo elemental: Terra.

Fera de postura cerimonial e adornos que lembram as ruínas do deserto.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 24 / 28**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Colossodune (`colossodune`)

Família: **mineral/golem**. Inspiração: monólito guardião. Silhueta: mineral/golem com cabeça `obelisk`, apêndice `shoulderarches` e terminação `anchor`.

Três marcas da combinação: cabeça `obelisk`; apêndice `shoulderarches`; cauda `anchor`. Rosto: olhos `crystal` com inserção frontal/lateral definida pelo componente. Superfície: `runes`. Motivo elemental: Terra.

Um golem monumental que carrega marcas luminosas entre blocos de arenito.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **15 / 23 / 27**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Penugem (`penugem`)

Família: **alado**. Inspiração: coruja filhote. Silhueta: alado com cabeça `chick`, apêndice `earplumes` e terminação `tuftfan`.

Três marcas da combinação: cabeça `chick`; apêndice `earplumes`; cauda `tuftfan`. Rosto: olhos `round` com inserção frontal/lateral definida pelo componente. Superfície: `feathers`. Motivo elemental: Ar.

Ave pequena, de cabeça grande e penas leves que balançam com qualquer brisa.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **15 / 26 / 36**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Ventanil (`ventanil`)

Família: **alado**. Inspiração: beija-flor de fitas. Silhueta: alado com cabeça `needlebeak`, apêndice `ribboncrest` e terminação `ribbons`.

Três marcas da combinação: cabeça `needlebeak`; apêndice `ribboncrest`; cauda `ribbons`. Rosto: olhos `fish` com inserção frontal/lateral definida pelo componente. Superfície: `bands`. Motivo elemental: Ar.

Ave esguia de penas compridas, parecidas com fitas sopradas pelo vento.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 26 / 34**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Trovoraptor (`trovoraptor`)

Família: **dracônico**. Inspiração: raptor condutor. Silhueta: dracônico com cabeça `raptor`, apêndice `lightninghorns` e terminação `bolt`.

Três marcas da combinação: cabeça `raptor`; apêndice `lightninghorns`; cauda `bolt`. Rosto: olhos `electric` com inserção frontal/lateral definida pelo componente. Superfície: `zigzag`. Motivo elemental: Ar.

Réptil alado de crista angular e penas luminosas de tempestade.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **18 / 31 / 41**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Aeronimbo (`aeronimbo`)

Família: **serpentino**. Inspiração: serpente de nuvens. Silhueta: serpentino com cabeça `cloudcap`, apêndice `cloudcollar` e terminação `cloudfan`.

Três marcas da combinação: cabeça `cloudcap`; apêndice `cloudcollar`; cauda `cloudfan`. Rosto: olhos `round` com inserção frontal/lateral definida pelo componente. Superfície: `clouds`. Motivo elemental: Ar.

Serpente de cauda longa cercada por pequenas formações de nuvem.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **13 / 19 / 26**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Lodinho (`lodinho`)

Família: **espectral**. Inspiração: poça de turfa viva. Silhueta: espectral com cabeça `puddle`, apêndice `mossmantle` e terminação `drip`.

Três marcas da combinação: cabeça `puddle`; apêndice `mossmantle`; cauda `drip`. Rosto: olhos `cyclops` com inserção frontal/lateral definida pelo componente. Superfície: `moss`. Motivo elemental: Sombra.

Criatura baixa e arredondada com tufos que parecem musgo úmido.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 17 / 24**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Caudalume (`caudalume`)

Família: **serpentino**. Inspiração: enguia-lanterna. Silhueta: serpentino com cabeça `lanterncap`, apêndice `antennalure` e terminação `lantern`.

Três marcas da combinação: cabeça `lanterncap`; apêndice `antennalure`; cauda `lantern`. Rosto: olhos `lantern` com inserção frontal/lateral definida pelo componente. Superfície: `dots`. Motivo elemental: Sombra.

Serpente delgada que guia os passos de viajantes com sua pequena lanterna.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 16 / 21**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Vagalumorte (`vagalumorte`)

Família: **artrópode**. Inspiração: mariposa funerária. Silhueta: artrópode com cabeça `mothmask`, apêndice `mothwings` e terminação `glowbulb`.

Três marcas da combinação: cabeça `mothmask`; apêndice `mothwings`; cauda `glowbulb`. Rosto: olhos `compound` com inserção frontal/lateral definida pelo componente. Superfície: `eyespots`. Motivo elemental: Sombra.

Inseto de carapaça escura que produz uma luz suave, quase lunar.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **20 / 30 / 34**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Rei Nevoento (`reinevoento`)

Família: **espectral**. Inspiração: manto régio de névoa. Silhueta: espectral com cabeça `royalmask`, apêndice `royalcrown` e terminação `mantle`.

Três marcas da combinação: cabeça `royalmask`; apêndice `royalcrown`; cauda `mantle`. Rosto: olhos `blindmarks` com inserção frontal/lateral definida pelo componente. Superfície: `runes`. Motivo elemental: Sombra.

Espírito alto de manto fluido e coroa que emerge da névoa umbral.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 17 / 24**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Vaporino (`vaporino`)

Família: **serpentino**. Inspiração: espiral de vapor. Silhueta: serpentino com cabeça `steamcap`, apêndice `steamvents` e terminação `plume`.

Três marcas da combinação: cabeça `steamcap`; apêndice `steamvents`; cauda `plume`. Rosto: olhos `lantern` com inserção frontal/lateral definida pelo componente. Superfície: `spirals`. Motivo elemental: Fogo.

Serpente híbrida que transforma o encontro de fogo e água em vapor morno.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **11 / 17 / 24**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Magmaterra (`magmaterra`)

Família: **quadrúpede**. Inspiração: tatu de lava. Silhueta: quadrúpede com cabeça `armoredjaw`, apêndice `rockplates` e terminação `hammer`.

Três marcas da combinação: cabeça `armoredjaw`; apêndice `rockplates`; cauda `hammer`. Rosto: olhos `emberslit` com inserção frontal/lateral definida pelo componente. Superfície: `cracks`. Motivo elemental: Fogo.

Fera de placas grossas que combina o peso da terra ao calor das brasas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **14 / 23 / 29**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Tempestália (`tempestalia`)

Família: **alado**. Inspiração: ave-do-paraíso de chuva. Silhueta: alado com cabeça `crestbeak`, apêndice `stormcrown` e terminação `rainfan`.

Três marcas da combinação: cabeça `crestbeak`; apêndice `stormcrown`; cauda `rainfan`. Rosto: olhos `electric` com inserção frontal/lateral definida pelo componente. Superfície: `rain`. Motivo elemental: Ar.

Ave de penas vivas que acompanha as nuvens carregadas sobre o recife.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **16 / 28 / 36**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Névoamusgo (`nevoamusgo`)

Família: **vegetal**. Inspiração: líquen encapuzado. Silhueta: vegetal com cabeça `hood`, apêndice `lichenantlers` e terminação `vine`.

Três marcas da combinação: cabeça `hood`; apêndice `lichenantlers`; cauda `vine`. Rosto: olhos `barkmarks` com inserção frontal/lateral definida pelo componente. Superfície: `moss`. Motivo elemental: Sombra.

Espírito de galhos e líquens que surge onde a floresta encontra a sombra.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **14 / 24 / 28**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Cinzavento (`cinzavento`)

Família: **dracônico**. Inspiração: pterossauro de brasas. Silhueta: dracônico com cabeça `sweptjaw`, apêndice `ashwings` e terminação `comet`.

Três marcas da combinação: cabeça `sweptjaw`; apêndice `ashwings`; cauda `comet`. Rosto: olhos `vertical` com inserção frontal/lateral definida pelo componente. Superfície: `ash`. Motivo elemental: Fogo.

Réptil de asas compridas com penas que espalham um rastro de cinzas.

Estágio 1 (níveis 1–6): cabeça maior em proporção, membros curtos, uma seção de cauda, apêndices macios e sem padrão de superfície. Estágio 2 (7–14): pés e boca aparecem, cauda ganha segmento, primeiro padrão e apêndices se desenvolvem. Estágio 3 (15+): postura com membros mais longos, cauda completa, quatro unidades de padrão e maior ramificação do traço. Asas e corpos segmentados também mudam o número de componentes, conforme a família.

Peças medidas nos pedidos 1 / 7 / 15: **20 / 32 / 40**. Orçamento: 28 / 48 / 80. Modelos validados; avaliação estética: ◐.

## Fênix (`fenix`)

Família: **alado**. Inspiração: ave solar mitológica. Silhueta: alado com cabeça `solarbeak`, apêndice `solarcrest` e terminação `solartrain`.

Três marcas da combinação: cabeça `solarbeak`; apêndice `solarcrest`; cauda `solartrain`. Rosto: olhos `solar` com inserção frontal/lateral definida pelo componente. Superfície: `layeredplumage`. Motivo elemental: Fogo.

Ave lendária adulta de halo solar e cauda tripla. O segredo de seu renascimento ainda não foi descoberto.

Adulto desde a obtenção: 48 penas individuais nas asas (3×8 por lado), 11 penas na cauda com ponteiras, plumagem de peito e halo de 24 componentes. Gradiente carmim/laranja/dourado/branco, pescoço alongado e garras douradas. Estágio 4 continua desativado.

Peças medidas nos pedidos 1 / 7 / 15: **122 / 122 / 122**. Orçamento: 170 / 170 / 170. Modelos validados; avaliação estética: ◐.
