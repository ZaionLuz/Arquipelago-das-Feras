# Conferência no Roblox Studio

Abra `releases/Galeria-40-Feras.rbxl` para inspecionar as 116 formas já montadas. A variante `Galeria-40-Feras-Leve.rbxl` usa a mesma anatomia essencial com menos ornamentos. Para jogar, abra `releases/Feras-Bestiario-40.rbxlx`.

1. Compare rostos, perfis e costas das 40 espécies. Observe as transições entre patas, tronco, pescoço e cabeça, e o encaixe das asas e caudas. Confira especialmente Fênix, Caranguepérola, Cristalince, Maritromba e Kraken.
2. Em Play, confira caminhada, voo, caudas, asas e os oito braços do Kraken. Os GLBs são referências estáticas; os rigs que o jogo anima estão nos modelos nativos com Motor6D.
3. Abra e feche o bestiário, role a lista, alterne entre espécies e redimensione a janela. Verifique no modo Baixo e Médio que previews escondidos param de atualizar e que os volumes essenciais permanecem visíveis.
4. No place do jogo, confira os novos encontros em seus biomas, captura, equipe, companheiro e ficha no bestiário. Kraken deve aparecer adulto no Recife e não aceitar cruzamento. Fênix mantém seu fluxo especial anterior.
5. Em uma experiência privada com acesso a API Services, carregue um perfil existente, adquira uma espécie nova, saia e entre novamente. O DataStore e o esquema 6 são os mesmos; a suíte verifica serialização simulada, mas não substitui a persistência real da plataforma.
6. Meça o tempo de frame e memória no MicroProfiler e nas estatísticas do Roblox em um computador de entrada. Compare Alto, Médio e Baixo com vários monstros próximos. Contagens de peças e testes headless não são uma medição de FPS.

A aprovação visual no renderer Roblox, física, multiplayer e desempenho de hardware permanecem dependentes dessa execução no Studio. O ambiente de desenvolvimento desta entrega disponibiliza Lune e Blender, sem cliente/Studio Roblox.
