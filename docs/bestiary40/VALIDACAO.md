# Validação do bestiário de 40 espécies

O teste completo é `bash scripts/bestiary40/test`. Ele usa Luau, Lune, Rojo, Selene, StyLua, Python e Pillow. Os executáveis podem ser indicados por `LUAU_BIN`, `LUAU_COMPILER_BIN`, `LUNE_BIN`, `ROJO_BIN`, `SELENE_BIN` e `STYLUA_BIN`.

Para validar o código e os bundles enquanto os renders estão sendo produzidos, use `bash scripts/bestiary40/test --native-only`. Esse modo declara os assets pendentes; depois execute `python3 scripts/bestiary40/check_assets.py` ou repita o teste completo.

## Verificações automatizadas

- Regressão dos sistemas existentes, migração, leases, batalha, encontros, reprodução e ações do servidor.
- Preservação dos 30 IDs anteriores, adição das dez espécies e alcance das novas espécies nos encontros. Kraken é um lendário adulto do Recife, com peso próprio e sem reprodução; o fluxo especial da Fênix foi preservado.
- Round-trip em DataStore simulado das dez novas espécies, Kraken como companheiro, nove ovos elegíveis, níveis, XP e metadados. Criaturas, habitats e recursos antigos continuam presentes no schema6.
- 116 formas distintas, transformações finitas, peças positivas, conexões próprias, rigs e clones isolados.
- Versões completas/leves, preservação dos volumes essenciais e cache com uma variante por espécie/estágio.
- Política de animação e visibilidade com tempo/serviços simulados. Isso verifica cadência e limites de trabalho; não mede FPS real.
- Comparação das 88 formas anteriores por geometria, com volumes adicionados, removidos ou movidos em todas elas e ao menos três alterações por adulto; nomes e cores não contam como remodelagem.
- Escopo comparado com a entrega anterior: os arquivos fora da modelagem/catálogo permanecem iguais; em `GameService`, somente a ação de reprodução recebe a validação de elegibilidade antes de cobrar ouro. O armazenamento mantém chave e versão.
- Galerias completas/leves nativas e bundle Rojo desserializável com fontes iguais ao `src`.
- 40 GLBs autocontidos, 116 formas exportadas, 47 imagens WebP, integridade de ZIP, hashes de origem e mapas de articulações. A geometria distribuída também é comparada com uma exportação nova do código atual, para recusar renders desatualizados.

`TEST_RESULTS.txt` registra a execução; `RIG_METRICS.json`, `LOD_METRICS.json` e `SOURCE_SCOPE.json` registram as medidas e o escopo. A comparação visual está em `images/` e o visualizador local em `assets/bestiary40/review.html`.

## Revisão no Roblox Studio

Abra `releases/Galeria-40-Feras.rbxl` e `releases/Galeria-40-Feras-Leve.rbxl` para comparar as formas sem precisar jogar. Abra `releases/Feras-Bestiario-40.rbxlx` para executar o projeto completo.

Confira a leitura de frente, costas e perfil; a conexão dos membros durante animação; o enquadramento em celular; e o Kraken nos encontros e na coleção. Compare as opções Baixo, Médio e Alto em um computador de entrada e registre FPS, memória e tempo de quadro. Esses resultados não foram medidos no ambiente automatizado e não devem ser inferidos das contagens de peças.
