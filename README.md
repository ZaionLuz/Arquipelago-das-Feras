# Arquipélago das Feras — build de teste integrada

Abra **releases/Feras-Tester.rbxlx** no Roblox Studio. Essa build é gerada dos fontes atuais por Rojo e comparada módulo a módulo. Feras-Art-Overhaul.rbxlx e Feras-V7.rbxlx são aliases compatíveis da mesma build atualizada.

## Correções para o tester
- Inicialização e remotes de evolução completos para o comportamento ativo: estágios por nível (7/15), Fênix adulta e estágio 4 desativado.
- Duplicatas do catálogo removidas, IDs legados e perfis preservados.
- Receitas da expansão com expressão válida e fichas disponíveis.
- Factory prioriza prefabs/meshes importados; usa receitas locais quando faltam assets e marca GeometrySource.
- CI executa Luau, testes de dados/combate/serviços, modelos nativos headless e build Rojo.

## Testar
Use uma experiência privada de teste isolada dos dados reais. Publique nela e habilite API Services para testar saves; o jogo recusa dados indisponíveis/corrompidos em vez de resetá-los.

1. Play: confirmar carregamento, HUD e duas criaturas iniciais.
2. Capturar, batalhar, alimentar e verificar estágios 7/15.
3. Abrir coleção, santuário e acompanhar uma criatura.
4. Sair/entrar: conferir preservação dos dados.
5. No servidor do Studio, Command Bar: `require(game.ServerScriptService.Server.CreatureGallery).build()`. A galeria permite comparar todos os estágios; não é carregada em produção.
6. Validar celular, multiplayer, física, estética e desempenho no Studio. Os testes headless não substituem essas verificações.

**Modelos OBJ/FBX ainda precisam de importação/publicação no Roblox** para aparecerem exatamente como no Blender. O jogo funciona com as receitas locais sem esses uploads. Veja [IMPORTAR-MODELOS.md](IMPORTAR-MODELOS.md).

## Desenvolvimento
`rojo serve` sincroniza src com o Studio. `bash scripts/test` executa a regressão e gera um place temporário; requer Python 3, Luau, Lune e Rojo. O workflow instala versões fixas verificadas por SHA256 e disponibiliza o artefato Feras-Tester.rbxlx.

Configurações de assets: src/shared/BlenderModelsConfig.luau. Não há IDs externos inventados nem produtos pagos habilitados. A chave de DataStore continua ArquipelagoV1; não use uma conta comercial para ensaiar migrações.

## Escopo real
Os oito métodos de evolução, novas ilhas e demais itens de docs/DESIGN.md são especificação de expansão, não funcionalidades declaradas prontas nesta build. A evolução visual por nível e os sistemas existentes são preservados. Estágio 4 da Fênix permanece desativado. Consulte CORRECOES-TESTER.md para o resultado das validações.
