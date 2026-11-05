# Revisão das esculturas

As imagens são renders em Blender da geometria estática exportada dos modelos Roblox nativos. Não são screenshots do Studio nem pinturas geradas para substituir os modelos.

- `creatures-30-adults.webp`: as 30 formas adultas.
- `stages/`: frente e costas dos estágios de cada espécie, com escala de câmera adulta compartilhada.
- `heroes/`: detalhes de Cinzelo, Folhuco, Caranguepérola e Fênix.
- `before-after.webp`: comparação de quatro espécies sob a mesma câmera, iluminação e enquadramento.

A reconstrução mantém dimensões, transforms, nomes e cores das peças. Esferas, cilindros e cunhas são reconstruídos geometricamente; o antigo primitivo Roblox Head é aproximado por um elipsoide. Iluminação, reflexos e sombras são do renderer, não uma promessa de aparência idêntica dentro do Roblox.

`assets/sculpt/meshes.zip` contém 30 GLBs adultos para edição em DCC, mais o mapa de joints nativos. Os GLBs não são MeshParts publicados nem rigs esqueléticos animados; o jogo usa os conjuntos correspondentes de peças com Motor6D em ModelFactory. Não há IDs externos inventados.

As pranchas de distribuição usam WebP em qualidade 88 para manter o ZIP leve. O pipeline conserva renders PNG sem perda como intermediários reproduzíveis; a conversão não altera a geometria.
