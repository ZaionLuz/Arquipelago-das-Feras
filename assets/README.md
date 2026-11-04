# Arte original e revisão

- `_legacy/`: arquivos e imagens anteriores preservados; não são carregados pelo Rojo.
- `concepts/direction-board.png`: estudo original gerado por IA, referência visual; não é screenshot.
- `generated/creature-atlas.png`: 2520 células CPU derivadas dos modelos/poses nativos. Não publicado como asset Roblox.
- `manifest.json`: retângulos, origem e limitações da exportação.
- `review.html`: seletor offline de espécie/nível/vista/pose, sem dependência externa.

Recriar com `python scripts/art/build_assets.py`. O runtime Roblox usa ModelFactory e PixelIcons; nenhum ImageId inventado. As comparações estão em docs/art e o relatório em docs/ART_REPORT.md.
