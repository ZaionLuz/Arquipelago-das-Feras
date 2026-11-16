# Correções da integração

Base: 31c94bec76ce9680004a96aa4263c4d938def82c.

- 90 linhas duplicadas removidas; inserção duplicada agora causa erro explícito.
- Evolução ativa por nível preservada. Remotes possuem respostas, ownership, validação de UID e rate limit. Não há consumo de itens futuros nem concessão de estágio 4.
- Factory aceita ImportedRigs e registro de IDs reais, rejeita scripts internos, aplica física segura e usa cache/fallback quando assets faltam.
- Expressões padrão e fichas de catálogo adicionadas à expansão; galeria não sobrepõe a Fênix com índice fixo.
- IDs de migração, chaves de saves e restrições da Fênix preservados.
- Testes estruturais contam o catálogo real e mantêm os requisitos visuais das 30 espécies anteriores. A expansão toda é construída nos três estágios e validada nos mesmos orçamentos.
- Os novos visuais reutilizam receitas: isso é registrado como limitação, não uma aprovação estética automática.
- Compilação, execução de suites e arquivos gerados são publicados pelo workflow Validate Roblox build. Resultado final registrado junto da build.

Roblox Studio, renderização, física multiplayer e FPS não foram executados neste ambiente. Importar/publicar os OBJ/FBX é uma etapa necessária para os visuais Blender exatos; a build headless contém as receitas locais e a integração pronta.

Compatibilidade adicional: categorias anatômicas da expansão usam perfis de combate legados; seis elementos novos têm nomes/cores válidos e relações neutras, sem alterar o multiplicador entre os elementos antigos. Um erro de vírgula em Strings foi corrigido. Importações com scripts, partes soltas ou joints externos são recusadas com fallback.

## Resultado executado

[Regressão e build aprovadas](https://github.com/ZaionLuz/Arquipelago-das-Feras/actions/runs/43799007047) para o código 5df497aaa5a1f521397728990c8007066b4ba435.

- Catálogo: 120 IDs únicos.
- Modelos: 361 construções nativas headless; cena de 40 criaturas com 1553 peças (limite 3200).
- Bundle: 74 scripts/módulos, comparados com src após o build.
- Sintaxe Luau, combate/captura, concessão e débito únicos, leases/migração, dados corrompidos, remotes, perfis herdados, prefab/fallback, controle de origem da Fênix, progressão e simulações aprovados.
- Três arquivos de releases com SHA256 52ee1de8f4f596084327eb8d3195038c451dc8598e6af5fec0ce16c71749d18e; o manifesto de proveniência está em releases/BUILD-MANIFEST.json.

Liberado para teste funcional controlado no Studio, **não** como homologação visual/performance. Para avaliar os meshes Blender exatos, conclua a importação descrita em IMPORTAR-MODELOS.md.
