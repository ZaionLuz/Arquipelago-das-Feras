# Modelagem das 30 feras

Abra **review.html** no navegador para revisar as imagens das 30 espécies e suas evoluções. As imagens são renders Blender da geometria exportada do jogo, sem retoque de anatomia. O comparativo conserva câmera e luz entre os modelos anteriores e os novos.

Para ver os assemblies editáveis no Roblox Studio, abra **releases/Galeria-Criaturas-3D.rbxl** na raiz do projeto. Uma galeria adicional **releases/Galeria-Criaturas-3D-Leve.rbxl** contém as variantes simplificadas. O jogo integrado está em **releases/Feras-Creature-Sculpt.rbxlx**.

**meshes.zip** contém os 30 adultos em GLB, materiais, nomes das peças e um mapa dos joints nativos. Importe um GLB no Blender ou em outra ferramenta 3D. Esses GLBs são estáticos; as animações do jogo usam os assemblies Motor6D construídos pela ModelFactory, sem depender da publicação de MeshParts ou de IDs externos.

**geometry.json** registra as 88 formas exportadas da fábrica nativa; **baseline_geometry.json** conserva os quatro adultos usados na comparação. **manifest.json** identifica a origem e os hashes do arquivo de meshes.

Para regenerar os renders na pasta raiz:

```bash
python -m pip install -r scripts/sculpt/requirements.txt
python scripts/sculpt/render_models.py
python scripts/sculpt/check_assets.py
```

Requer Python 3, Blender 4.3 e Lune. Se os executáveis estiverem fora do PATH, indique `BLENDER_BIN` e `LUNE_BIN`. Os PNGs sem perda e os GLBs individuais são intermediários regeneráveis; a distribuição inclui 36 WebPs e o ZIP de meshes. A iluminação do Roblox pode diferir da iluminação de revisão do Blender.
