# Revisão do bestiário em 3D

Abra **review.html** após extrair o projeto para ver as pranchas das espécies, suas evoluções e as vistas de costas. As imagens são renders Blender da geometria exportada dos modelos nativos do jogo; não são screenshots do Roblox Studio nem pinturas conceituais apresentadas como modelos.

- **geometry.json**: formas e articulações exportadas da ModelFactory atual.
- **baseline_geometry.json**: as 30 espécies/88 formas da entrega anterior, congeladas antes desta revisão.
- **meshes.zip**: adultos em GLB, nomes dos volumes e mapa das articulações nativas. Os GLBs são meshes estáticos para ferramentas 3D; o jogo continua usando os assemblies com Motor6D.
- **manifest.json**: contagens, origem e hashes dos meshes e da geometria usada no render.

Na raiz do projeto, com Python 3, Pillow, Blender 4.3 e Lune disponíveis:

```bash
python -m pip install -r scripts/sculpt/requirements.txt
python scripts/sculpt/render_models.py --expected-species 40 --expected-forms 116
```

`BLENDER_BIN` e `LUNE_BIN` podem indicar executáveis fora do PATH. O comando preserva os artefatos da revisão anterior em `assets/sculpt` e `docs/sculpt`; os novos resultados ficam em `assets/bestiary40` e `docs/bestiary40/images`.

Para revisar um modelo durante a edição:

```bash
python scripts/sculpt/render_models.py --ids kraken --quick
```

O cache considera a geometria, o enquadramento e a amostragem. Mudanças de anatomia invalidam as imagens afetadas. Os PNGs sem perda e os GLBs individuais são intermediários regeneráveis; a distribuição inclui WebPs e o arquivo de meshes. A luz e a aparência no renderer Roblox podem diferir da iluminação de revisão do Blender.
