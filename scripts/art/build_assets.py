#!/usr/bin/env python3
"""
Reproducible CPU preview/atlas from native Roblox geometry AND Blender FBX imports.
Supports both native Roblox parts and imported MeshParts from Blender.
Requires: Python 3, Pillow, numpy, Lune, trimesh (for FBX), pygltflib (optional).
"""
from pathlib import Path
import argparse, json, math, os, subprocess, tempfile, tarfile, io, hashlib, copy, shutil
from functools import lru_cache
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Optional FBX support
try:
    import trimesh
    HAS_TRIMESH = True
except ImportError:
    HAS_TRIMESH = False
    print("Warning: trimesh not installed. FBX import disabled. Install with: pip install trimesh")

ROOT = Path(__file__).resolve().parents[2]
BASELINE = 'c5a3860d77a68b6f8a18c771bfd07c5aaef5669d'
FONT_PATH = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
FBX_DIR = ROOT / "assets" / "fbx"
MANIFEST_PATH = FBX_DIR / "export_manifest.json"

def font(size):
    try: return ImageFont.truetype(FONT_PATH, size)
    except OSError: return ImageFont.load_default()

def baseline_root():
    destination = Path(tempfile.gettempdir()) / 'feras-art-baseline'
    destination.mkdir(exist_ok=True)
    known = None
    for ref in ([BASELINE, '9ece1fd6a35b7bbd8cd871bb2a265652ce0c8033'] if shutil.which('git') else []):
        if subprocess.run(['git', 'cat-file', '-e', ref], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
            known = ref
            break
    if known:
        blob = subprocess.check_output(['git', 'archive', known, 'src/shared', 'src/client/CreatureAnimator.luau'], cwd=ROOT)
        with tarfile.open(fileobj=io.BytesIO(blob)) as archive:
            archive.extractall(destination, filter='data')
    else:
        shutil.copytree(ROOT / 'src/shared', destination / 'src/shared', dirs_exist_ok=True)
        (destination / 'src/client').mkdir(parents=True, exist_ok=True)
        for name in ['ModelFactory', 'CreatureDesigns', 'CreatureFeatures']:
            shutil.copy2(ROOT / f'assets/_legacy/monsters/{name}.luau', destination / f'src/shared/{name}.luau')
        shutil.copy2(ROOT / 'assets/_legacy/monsters/CreatureAnimator.luau', destination / 'src/client/CreatureAnimator.luau')
        token = destination / 'src/shared/ArtTokens.luau'
        if token.exists(): token.unlink()
    return destination

def export(root, destination, lune):
    subprocess.run([lune, 'run', 'scripts/art/export_models.luau', str(root), str(destination)], cwd=ROOT, check=True)
    return json.loads(destination.read_text())

def load_fbx_manifest():
    """Load the Blender export manifest."""
    if MANIFEST_PATH.exists():
        return json.loads(MANIFEST_PATH.read_text())
    return {}

def fbx_to_parts(fbx_path: Path, species_id: str, stage: int):
    """Convert FBX mesh to parts format compatible with native geometry renderer."""
    if not HAS_TRIMESH:
        return []

    try:
        scene = trimesh.load(str(fbx_path), force='scene')
        parts = []

        for name, mesh in scene.geometry.items():
            # Skip armature/empty objects
            if not hasattr(mesh, 'vertices') or len(mesh.vertices) == 0:
                continue

            # Extract transform from mesh metadata or name
            # FBX export should preserve object names like {species}_{stage}_{part}
            part_name = name.split('_')[-1] if '_' in name else name

            # Compute bounding box for size
            bounds = mesh.bounds
            size = bounds[1] - bounds[0]
            center = (bounds[1] + bounds[0]) * 0.5

            # Get vertex colors if available
            colors = None
            if hasattr(mesh.visual, 'vertex_colors') and mesh.visual.vertex_colors is not None:
                colors = mesh.visual.vertex_colors[:, :3] / 255.0
                avg_color = colors.mean(axis=0)
            else:
                avg_color = np.array([0.5, 0.5, 0.5])

            # Determine material from name
            material = "SmoothPlastic"
            if "Neon" in name or "Wing" in name or "Tail" in name and "Tip" in name:
                material = "Neon"
            elif "Crystal" in name or "Gem" in name or "Glass" in name:
                material = "Glass"
            elif "Slate" in name or "Mineral" in name:
                material = "Slate"

            # Create part dict matching native format
            part = {
                'name': part_name,
                'class': 'MeshPart',
                'size': size.tolist(),
                'cf': np.eye(4).flatten().tolist(),  # Identity, will be positioned by rig
                'color': avg_color.tolist(),
                'material': material,
                'shape': 'Block',
                'mesh': 'FileMesh',
                'meshScale': [1.0, 1.0, 1.0],
                'alpha': 1.0,
                'meshId': f"rbxassetid://{fbx_path.stem}_{part_name}",  # Placeholder
            }
            parts.append(part)

        return parts
    except Exception as e:
        print(f"Error loading FBX {fbx_path}: {e}")
        return []

def export_with_fbx(root, destination, lune):
    """Export geometry including FBX meshes."""
    # First run native export
    data = export(root, destination, lune)

    # Load FBX manifest
    fbx_manifest = load_fbx_manifest()

    # For each model, try to load FBX parts
    for model in data['models']:
        species_id = model['id']
        stage = model['stage']

        if species_id in fbx_manifest and f'stage{stage}' in fbx_manifest[species_id]:
            fbx_info = fbx_manifest[species_id][f'stage{stage}']
            fbx_path = FBX_DIR / fbx_info['fbx']

            if fbx_path.exists():
                fbx_parts = fbx_to_parts(fbx_path, species_id, stage)
                if fbx_parts:
                    # Add FBX parts to first frame
                    for frame in model['frames']:
                        frame.extend(fbx_parts)
                    print(f"  Loaded {len(fbx_parts)} FBX parts for {species_id} stage {stage}")

    return data

@lru_cache(None)
def primitive(kind):
    if kind in {'sphere', 'head', 'ball'}:
        verts = []; faces = []; lat, lon = 6, 12
        for j in range(lat + 1):
            a = math.pi * j / lat
            for i in range(lon):
                b = 2 * math.pi * i / lon
                verts.append((math.sin(a) * math.cos(b) * .5, math.cos(a) * .5, math.sin(a) * math.sin(b) * .5))
        for j in range(lat):
            for i in range(lon):
                a = j * lon + i; b = j * lon + (i + 1) % lon; c = (j + 1) * lon + i; d = (j + 1) * lon + (i + 1) % lon
                if j > 0: faces.append((a, c, b))
                if j < lat - 1: faces.append((b, c, d))
    elif kind == 'cylinder':
        verts = []; faces = []; n = 12
        for side in [-.5, .5]:
            verts.append((side, 0, 0))
            for i in range(n):
                a = i * 2 * math.pi / n
                verts.append((side, math.cos(a) * .5, math.sin(a) * .5))
        for i in range(n):
            a = 1 + i; b = 1 + (i + 1) % n; c = a + n + 1; d = b + n + 1
            faces.extend([(0, b, a), (n + 1, c, d), (a, b, c), (b, d, c)])
    elif kind == 'wedge':
        verts = [(-.5, -.5, -.5), (.5, -.5, -.5), (.5, -.5, .5), (-.5, -.5, .5), (-.5, .5, .5), (.5, .5, .5)]
        faces = [(0, 1, 2), (0, 2, 3), (3, 2, 5), (3, 5, 4), (0, 4, 5), (0, 5, 1), (0, 3, 4), (1, 5, 2)]
    elif kind == 'corner':
        verts = [(-.5, -.5, -.5), (.5, -.5, -.5), (.5, -.5, .5), (-.5, -.5, .5), (-.5, .5, .5)]
        faces = [(0, 1, 2), (0, 2, 3), (0, 3, 4), (3, 2, 4), (2, 1, 4), (1, 0, 4)]
    else:
        verts = [(-.5, -.5, -.5), (.5, -.5, -.5), (.5, .5, -.5), (-.5, .5, -.5), (-.5, -.5, .5), (.5, -.5, .5), (.5, .5, .5), (-.5, .5, .5)]
        faces = [(0, 1, 2), (0, 2, 3), (4, 7, 6), (4, 6, 5), (0, 4, 5), (0, 5, 1), (3, 2, 6), (3, 6, 7), (0, 3, 7), (0, 7, 4), (1, 5, 6), (1, 6, 2)]
    v = np.array(verts, dtype=float); f = np.array(faces, dtype=int)
    triangles = v[f]; normals = np.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0]); center = triangles.mean(axis=1) - v.mean(axis=0)
    reverse = (normals * center).sum(axis=1) < 0
    f[reverse] = f[reverse][:, ::-1]
    return v, f

def geometry(parts):
    triangles = []; colors = []; alpha = []
    for p in parts:
        if p.get('class') == 'MeshPart':
            # For MeshParts, create a simple box proxy for rendering
            kind = 'block'
        else:
            kind = 'corner' if p['class'] == 'CornerWedgePart' else 'wedge' if p['class'] == 'WedgePart' else 'head' if 'Head' in p['mesh'] else 'sphere' if 'Sphere' in p['mesh'] else 'ball' if 'Ball' in p['shape'] else 'cylinder' if 'Cylinder' in p['shape'] else 'block'
        v, f = primitive(kind)
        size = np.array(p['size']) * np.array(p['meshScale'])
        cf = np.array(p['cf'])
        world = (v * size) @ cf[3:].reshape(3, 3).T + cf[:3]
        triangles.append(world[f])
        colors.extend([p['color']] * len(f))
        alpha.extend([p['alpha']] * len(f))
    return np.concatenate(triangles), np.array(colors), np.array(alpha)

VIEW = {
    'front': np.array([.55, .28, 1.0]),
    'back': np.array([-.55, .28, -1.0]),
    'battle': np.array([0, .237, 1.0]),
}
LIGHT = np.array([-.5, .9, .6]); LIGHT /= np.linalg.norm(LIGHT)

def bounds(parts):
    t, _, _ = geometry(parts)
    return t.min(axis=(0, 1)), t.max(axis=(0, 1))

def render(parts, size=64, side='front', reference=None, palette=None, canvas=None, focus=None):
    tris, colors, alpha = geometry(parts)
    normals = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
    normals /= np.maximum(np.linalg.norm(normals, axis=1)[:, None], 1e-8)
    camera = VIEW[side] / np.linalg.norm(VIEW[side])
    right = np.cross([0., 1., 0.], camera); right /= np.linalg.norm(right)
    up = np.cross(camera, right)
    front = (normals @ camera) > .0001
    tris = tris[front]; normals = normals[front]; colors = colors[front]; alpha = alpha[front]
    low, high = reference or bounds(parts)
    center = (low + high) * .5
    corners = np.array([[x, y, z] for x in [low[0], high[0]] for y in [low[1], high[1]] for z in [low[2], high[2]]])
    extX = np.ptp(corners @ right)
    extY = np.ptp(corners @ up)
    scale = (size - 9) / max(extX, extY, 1)
    w, h = canvas or (size, size)
    if focus is not None:
        center = np.array(focus[0]); scale = w / focus[1]
    projected = np.stack(((tris - center) @ right, -(tris - center) @ up), axis=2) * scale + np.array([w * .5, h * .48])
    shade = np.maximum(0, normals @ LIGHT)
    bands = np.digitize(shade, [.18, .45, .78])
    factor = np.array([.55, .73, .9, 1.07])[bands]
    shadow = np.array([.18, .16, .26])
    lit = colors * factor[:, None] + shadow[None, :] * (1 - factor[:, None]) * .35
    lit = np.clip(lit, 0, 1)
    if palette is not None:
        pal = np.array(palette)
        distance = ((lit[:, None, :] - pal[None, :, :]) ** 2).sum(axis=2)
        lit = pal[np.argmin(distance, axis=1)]
    rgb = (lit * 255).astype(np.uint8)
    image = Image.new('RGBA', (w, h))
    draw = ImageDraw.Draw(image)
    for index in np.argsort(tris.mean(axis=1) @ camera):
        xy = projected[index]
        draw.polygon([tuple(v) for v in xy], fill=tuple(rgb[index]) + (int(alpha[index] * 255),))
    mask = image.getchannel('A')
    outline = mask.filter(ImageFilter.MaxFilter(3))
    outline_image = Image.new('RGBA', (w, h), (39, 37, 61, 0))
    outline_image.putalpha(outline)
    outline_image.alpha_composite(image)
    return outline_image

def contact(data, destination, title):
    models = data['models']
    groups = {}
    for m in models:
        groups.setdefault(m['id'], []).append(m)
    width, height = 5 * 210, 6 * 116 + 50
    sheet = Image.new('RGB', (width, height), (25, 43, 54))
    d = ImageDraw.Draw(sheet)
    d.text((12, 9), title, font=font(14), fill=(255, 240, 207))
    d.text((12, 29), 'CPU preview of native parts + FBX MeshParts · not a Roblox Studio screenshot', font=font(9), fill=(183, 197, 184))
    for index, (species, rows) in enumerate(groups.items()):
        x = (index % 5) * 210
        y = 50 + (index // 5) * 116
        d.rectangle((x + 3, y + 2, x + 206, y + 111), fill=(40, 60, 70))
        d.rectangle((x + 3, y + 108, x + 206, y + 111), fill=(76, 101, 115))
        reference = bounds(rows[-1]['frames'][0])
        d.text((x + 9, y + 8), rows[0]['name'], font=font(10), fill=(255, 240, 207))
        for stage, row in enumerate(rows):
            icon = render(row['frames'][0], 64, reference=reference, palette=data.get('palette'))
            sheet.paste(icon, (x + 7 + stage * 65, y + 28), icon)
            d.text((x + 13 + stage * 65, y + 95), f"Lv.{row['level']:02}", font=font(8), fill=(183, 197, 184))
    sheet.resize((width * 2, height * 2), Image.Resampling.NEAREST).save(destination)

def atlas(data, destination, manifest):
    cell = 64
    frames = len(data['frames'])
    models = data['models']
    image = Image.new('RGBA', (frames * cell, len(models) * 2 * cell))
    entries = []
    for index, row in enumerate(models):
        reference = bounds(next(m for m in models if m['id'] == row['id'] and m['level'] == 15)['frames'][0])
        for side_index, side in enumerate(['front', 'back']):
            for frame_index, parts in enumerate(row['frames']):
                sprite = render(parts, cell, side, reference, palette=data.get('palette'))
                x = frame_index * cell
                y = (index * 2 + side_index) * cell
                image.alpha_composite(sprite, (x, y))
                entries.append({'species': row['id'], 'requestedLevel': row['level'], 'stage': row['stage'], 'side': side, 'pose': data['frames'][frame_index]['pose'], 'time': data['frames'][frame_index]['time'], 'rect': [x, y, cell, cell]})
    image.save(destination, optimize=True)
    manifest.update({'atlas': str(destination.relative_to(ROOT)), 'cell': [cell, cell], 'pixelScale': 'integer nearest-neighbor only', 'rectangles': entries, 'views': ['front', 'back'], 'nativeAnimationSamples': len(models) * frames, 'softwarePreviewOnly': True, 'robloxAssetId': None})

def showcase(data, destination):
    rows = {m['id']: m for m in data['models'] if m['level'] == 15}
    chosen = ['cinzelo', 'folhuco', 'carangueperola', 'fenix']
    image = Image.new('RGB', (576, 208), (25, 43, 54))
    d = ImageDraw.Draw(image)
    d.text((14, 9), 'ARQUIPELAGO DAS FERAS / pixel-sculpt studies', font=font(12), fill=(255, 240, 207))
    for i, id in enumerate(chosen):
        row = rows[id]
        sprite = render(row['frames'][0], 128, palette=data.get('palette'))
        image.paste(sprite, (i * 144 + 8, 37), sprite)
        d.text((i * 144 + 8, 178), row['name'], font=font(10), fill=(255, 240, 207))
    image.resize((1152, 416), Image.Resampling.NEAREST).save(destination)

def transformed(parts, x, yaw):
    parts = copy.deepcopy(parts)
    rotation = np.array([[math.cos(yaw), 0, math.sin(yaw)], [0, 1, 0], [-math.sin(yaw), 0, math.cos(yaw)]])
    low, _ = bounds(parts)
    for p in parts:
        cf = np.array(p['cf'])
        position = rotation @ cf[:3] + np.array([x, -low[1] + .4, 0])
        matrix = rotation @ cf[3:].reshape(3, 3)
        p['cf'] = list(position) + list(matrix.flatten())
    return parts

def battles(data, destination):
    if not data.get('battles'): return
    creatures = {m['id']: m for m in data['models'] if m['level'] == 15}
    foe_ids = {'Alvorecer': 'penugem', 'Brasa': 'magmarau', 'Recife': 'bolhinho', 'Floresta': 'aracnoflora', 'Dunas': 'esfingeolito', 'Picos': 'ventanil', 'Pantano': 'vagalumorte'}
    sheet = Image.new('RGB', (1008, 706), (25, 43, 54))
    d = ImageDraw.Draw(sheet)
    d.text((12, 10), 'SEVEN BATTLE DIORAMAS / actual BattleStage + creature geometry', font=font(12), fill=(255, 240, 207))
    d.text((12, 29), 'Offline orthographic preview · approximate lighting/mesh · no Studio screenshot', font=font(9), fill=(183, 197, 184))
    for index, scene in enumerate(data['battles']):
        x = index % 3 * 336 + 8
        y = index // 3 * 216 + 54
        parts = scene['parts'] + transformed(creatures['folhuco']['frames'][0], -8, math.pi / 2) + transformed(creatures[foe_ids[scene['id']]]['frames'][0], 8, -math.pi / 2)
        image = render(parts, side='battle', palette=data.get('palette'), canvas=(320, 180), focus=([0, 5, 0], 66))
        sheet.paste(image, (x, y), image)
        d.text((x + 5, y + 185), scene['id'] + ' / ' + str(scene['count']) + ' scenery parts', font=font(10), fill=(255, 240, 207))
    sheet.resize((2016, 1412), Image.Resampling.NEAREST).save(destination)

def icon_sheet(data, destination):
    icons = data.get('icons', {})
    tokens = data.get('tokens', {})
    if not icons: return
    canvas = Image.new('RGB', (640, 288), (25, 43, 54))
    d = ImageDraw.Draw(canvas)
    d.text((12, 9), 'ORIGINAL 16 x 16 PIXEL GLYPHS / Frame grids used in game', font=font(12), fill=(255, 240, 207))
    colors = {'a': (25, 43, 54, 255), 'b': (124, 88, 96, 255), 'c': (216, 180, 130, 255), 'd': (244, 217, 160, 255)}
    names = sorted(icons)
    for index, name in enumerate(names):
        x = 8 + index % 10 * 63
        y = 42 + index // 10 * 60
        im = Image.new('RGBA', (16, 16))
        pixels = im.load()
        for gy, row in enumerate(icons[name]):
            for gx, c in enumerate(row):
                if c in colors:
                    pixels[gx, gy] = colors[c]
        im = im.resize((32, 32), Image.Resampling.NEAREST)
        canvas.paste(im, (x + 12, y), im)
        d.text((x, y + 36), name[:10], font=font(8), fill=(255, 240, 207))
    canvas.resize((1280, 576), Image.Resampling.NEAREST).save(destination)

def palette_sheet(data, destination):
    colors = data.get('palette', [])
    if not colors: return
    image = Image.new('RGB', (480, 180), (25, 43, 54))
    d = ImageDraw.Draw(image)
    d.text((10, 8), 'GLOBAL 48-COLOR PALETTE / art tokens', font=font(12), fill=(255, 240, 207))
    for index, color in enumerate(colors):
        rgb = tuple(int(c * 255) for c in color)
        x = 10 + index % 12 * 39
        y = 35 + index // 12 * 35
        d.rectangle((x, y, x + 34, y + 23), fill=rgb)
        d.text((x, y + 24), '#' + ''.join(f'{c:02X}' for c in rgb), font=font(6), fill=(255, 240, 207))
    image.resize((960, 360), Image.Resampling.NEAREST).save(destination)

def review_page(manifest, data):
    import html
    compact = [{k: r[k] for k in ['species', 'requestedLevel', 'stage', 'side', 'pose', 'time', 'rect']} for r in manifest.get('rectangles', [])]
    text = """<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Feras · revisão de arte</title><style>
:root{color-scheme:dark}body{margin:0;background:#192b36;color:#fff0cf;font:16px ui-monospace,monospace;line-height:1.5}main{max-width:1120px;margin:auto;padding:24px}h1{font-size:28px}p{max-width:850px;color:#b7c5b8}a{color:#d8b482}section{padding:20px;margin:20px 0;border:2px solid #587078;background:#283c46;box-shadow:6px 6px #0f202c}img{max-width:100%;height:auto;image-rendering:pixelated}canvas{width:256px;height:256px;image-rendering:pixelated;background:#192b36;border:2px solid #587078}label{display:inline-block;margin:8px}select,button{font:inherit;min-height:44px;background:#192b36;color:#fff0cf;border:2px solid #587078;padding:8px}.tag{font-size:12px;color:#d8b482}.viewer{display:flex;flex-wrap:wrap;align-items:center;gap:24px}details{margin-top:12px}
</style><main><span class="tag">ART-OVERHAUL · REVISÃO OFFLINE</span><h1>Arquipélago das Feras</h1><p>Pranchas e atlas gerados da geometria e das poses dos módulos Roblox + FBX MeshParts. Este documento não é uma captura do jogo nem uma homologação do Studio. O runtime usa modelos 3D e ícones em Frames; o PNG exportado não possui ID de asset Roblox.</p>
<section><h2>Espécies, estágios e poses</h2><div class="viewer"><canvas id="sprite" width="256" height="256"></canvas><div><label>Espécie <select id="species"></select></label><label>Nível de referência <select id="level"><option>1</option><option>7</option><option selected>15</option></select></label><br><label>Vista <select id="side"><option value="front">Frente</option><option value="back">Costas</option></select></label><label>Pose <select id="pose"><option value="idle">Idle</option><option value="attack">Ataque</option><option value="damage">Dano</option><option value="faint">Derrota</option></select></label><p id="caption"></p></div></div></section>
<section><h2>Antes / depois</h2><details><summary>Baseline V7</summary><img src="../docs/art/creatures-before.png" alt="Geometria da V7 em três níveis"></details><img src="../docs/art/creatures-after.png" alt="Geometria após reforma"></section>
<section><h2>Sete cenários de batalha</h2><img src="../docs/art/battles-after.png" alt="Cenários de batalha exportados"></section><section><h2>Ícones e paleta</h2><img src="../docs/art/icons.png" alt="Ícones originais"><img src="../docs/art/palette.png" alt="48 cores"></section><p><a href="../docs/ART_REPORT.md">Relatório e limitações</a></p></main><script>
const rows=__ROWS__, defs=__DEFS__;const species=document.querySelector('#species');for(const d of defs){const o=document.createElement('option');o.value=d.id;o.textContent=d.name;species.append(o)}
const img=new Image();img.src='generated/creature-atlas.png';const ctx=document.querySelector('#sprite').getContext('2d');ctx.imageSmoothingEnabled=false;let tick=0;
function draw(){const id=species.value,level=+document.querySelector('#level').value,side=document.querySelector('#side').value,pose=document.querySelector('#pose').value;const frames=rows.filter(r=>r.species===id&&r.requestedLevel===level&&r.side===side&&r.pose===pose);const row=frames[Math.floor(tick/3)%frames.length];ctx.clearRect(0,0,256,256);if(row&&img.complete){ctx.drawImage(img,...row.rect,0,0,256,256);document.querySelector('#caption').textContent='Estágio '+row.stage+' · '+pose+' · amostra '+row.time+'s · 4× nearest-neighbor'}tick++}setInterval(draw,1000/18);img.onload=draw;
</script></html>"""
    defs = [{'id': m['id'], 'name': m['name']} for m in data['models'] if m['level'] == 15]
    (ROOT / 'assets/review.html').write_text(text.replace('__ROWS__', json.dumps(compact, ensure_ascii=False)).replace('__DEFS__', json.dumps(defs, ensure_ascii=False)))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--baseline-only', action='store_true')
    parser.add_argument('--no-atlas', action='store_true')
    parser.add_argument('--with-fbx', action='store_true', help='Include Blender FBX MeshParts in preview')
    parser.add_argument('--lune', default=os.environ.get('LUNE_BIN', 'lune'))
    args = parser.parse_args()

    (ROOT / 'docs/art').mkdir(parents=True, exist_ok=True)
    (ROOT / 'assets/generated').mkdir(parents=True, exist_ok=True)

    if args.with_fbx:
        print("Building assets with FBX MeshParts...")
        old = export_with_fbx(baseline_root(), Path(tempfile.gettempdir()) / 'feras-art-before.json', args.lune)
    else:
        old = export(baseline_root(), Path(tempfile.gettempdir()) / 'feras-art-before.json', args.lune)

    contact(old, ROOT / 'docs/art/creatures-before.png', 'V7 BASELINE / 30 species x 3 requested levels')
    (ROOT / 'assets/_legacy/previews').mkdir(parents=True, exist_ok=True)
    shutil.copy2(ROOT / 'docs/art/creatures-before.png', ROOT / 'assets/_legacy/previews/creatures-before.png')

    if args.baseline_only: return

    if args.with_fbx:
        current = export_with_fbx(ROOT, Path(tempfile.gettempdir()) / 'feras-art-after.json', args.lune)
    else:
        current = export(ROOT, Path(tempfile.gettempdir()) / 'feras-art-after.json', args.lune)

    contact(current, ROOT / 'docs/art/creatures-after.png', 'ART OVERHAUL / 30 species x 3 requested levels' + (' + FBX' if args.with_fbx else ''))
    showcase(current, ROOT / 'docs/art/creature-showcase.png')
    battles(current, ROOT / 'docs/art/battles-after.png')
    icon_sheet(current, ROOT / 'docs/art/icons.png')
    palette_sheet(current, ROOT / 'docs/art/palette.png')

    manifest = {'schema': 1, 'source': 'native Roblox CFrames/Size/Color + sampled CreatureAnimator transforms' + (' + Blender FBX MeshParts' if args.with_fbx else ''), 'baselineCommit': BASELINE, 'rendering': 'offline CPU approximations of primitive meshes + FBX proxies; no live Roblox rendering, physics or API validation', 'generator': 'python scripts/art/build_assets.py', 'runtime': 'procedural Roblox 3D and Frame icons; exported PNGs are preview/artist pipeline, not uploaded Roblox images'}

    if not args.no_atlas:
        atlas(current, ROOT / 'assets/generated/creature-atlas.png', manifest)
    (ROOT / 'assets/manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2))
    if not args.no_atlas:
        review_page(manifest, current)

    print('PASS assets: before/after contact sheets, showcase' + (' and ' + str(len(manifest['rectangles'])) + ' atlas cells' if not args.no_atlas else '') + (' with FBX' if args.with_fbx else ''))

if __name__ == '__main__':
    main()