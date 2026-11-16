# Modelos Blender no jogo
A build de tester usa receitas locais completas quando não existem meshes importados. Cada modelo recebe GeometrySource: ProceduralFallback ou BlenderImported. Não há IDs inventados e o jogo inicia sem dependências de upload.

## Caminho recomendado — prefabs no Studio
1. Abra releases/Feras-Tester.rbxlx.
2. Use o 3D Importer / Asset Manager para importar OBJ/FBX de assets/blender/exports. Autorize os assets para o proprietário da experiência.
3. Monte um Model por espécie e estágio, com Root (BasePart invisível), PrimaryPart=Root e as partes conectadas por Motor6D ou WeldConstraint. Não inclua scripts.
4. Em ReplicatedStorage.ImportedRigs, nomeie o Model exatamente como o ID do catálogo seguido de _Stage1, _Stage2 ou _Stage3. O ID vem de src/shared/Creatures.luau.
5. Os Motor6D usam atributo Role: Body, Head, Leg1..., WingL/R, Tail1...; Phase é opcional. Mantenha o orçamento de peças de CreatureDesigns.
6. No Command Bar: `print(game:GetService("HttpService"):JSONEncode(require(game.ReplicatedStorage.Shared.ModelImporter).inspect()))`.
7. Confirme source=BlenderImported. Salve/publice o place que contém os prefabs. Um ZIP/Rojo build sem esses Models não contém o upload feito manualmente no Studio.

O Rojo preserva instâncias desconhecidas em ImportedRigs durante sincronização. Guarde/exporte seus prefabs antes de substituir o place.

## Caminho por IDs reais
Preencha BlenderModelsConfig.Creatures[id].Stages[stage].Parts com MeshId real, Size={x,y,z}, CFrame={12 componentes relativos ao Root}, Color={r,g,b}, Material="SmoothPlastic", e Parent opcional (nome da parte). Os modelos são criados por AssetService:CreateMeshPartAsync e ficam em cache. Falha/permissão de asset causa fallback local com aviso, sem derrubar o jogo.

Não use IDs simbólicos ou exemplos do briefing como se fossem assets publicados. A publicação/importação de meshes exige Roblox Studio e não é feita pelo GitHub.

## Limites desta correção
As 248 exportações OBJ são arquivos de autoria, não 248 espécies já publicadas. O catálogo jogável é contado automaticamente. Há receitas repetidas na expansão; a regressão visual antiga continua obrigatória e a aprovação estética das novas depende do Studio. Não se afirma arte única, animação de FBX ou FPS homologado sem inspeção real.
