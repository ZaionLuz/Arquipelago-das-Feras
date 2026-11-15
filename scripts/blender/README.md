# Blender → Roblox Pipeline

Complete pipeline for exporting creatures from Blender to Roblox as MeshParts with Motor6D rigs.

## Pipeline Overview

```
Blender (.blend) 
    │
    ▼ export_creatures.py
assets/fbx/{species}_stage{1,2,3}.fbx (+ LODs)
    │
    ▼ Upload to Roblox (Asset Manager)
rbxassetid://...
    │
    ▼ generate_manifest.py
src/shared/BlenderModels.generated.luau
    │
    ▼ import_meshes.luau (in Studio)
ReplicatedStorage/ImportedRigs/{species}_Stage{1,2,3}
```

## Files

| File | Purpose |
|------|---------|
| `export_creatures.py` | Export all creatures from Blender as FBX with LODs |
| `create_rig_template.py` | Create `rig_template.blend` with Motor6D-compatible armature |
| `create_material_template.py` | Create `material_template.blend` with Roblox materials |
| `generate_manifest.py` | Convert export manifest to Lua registry |
| `../roblox/import_meshes.luau` | Import FBX as MeshParts and create Motor6D rigs in Studio |
| `../../src/shared/BlenderModels.luau` | Runtime registry of MeshPart IDs and rig data |

## Quick Start

### 1. Create Templates (run once)

```bash
# In Blender directory
blender -b --python create_rig_template.py
blender -b --python create_material_template.py
```

### 2. Model Creatures in Blender

1. Open `rig_template.blend`
2. Append `material_template.blend` materials
3. Model each creature using the rig:
   - Parent meshes to armature bones
   - Name parts: `{species}_{stage}_{part}` (e.g., `fenix_adult_wingL`)
   - Assign materials: SmoothPlastic, Neon, Glass
   - Use vertex colors for palette (attribute name: `Col`)

### 3. Export FBX

```bash
blender -b --python export_creatures.py -- assets/fbx
# Or specific species/stage:
blender -b --python export_creatures.py -- assets/fbx --species fenix --stage 3
```

### 4. Upload to Roblox

1. Open Roblox Studio
2. Use Asset Manager → Bulk Import → Select all FBX files
3. Note the uploaded asset IDs

### 5. Generate Manifest

```bash
python generate_manifest.py
```

This creates `src/shared/BlenderModels.generated.luau` with placeholder asset IDs.

### 6. Update Asset IDs

Edit `src/shared/BlenderModels.generated.luau` and replace placeholder `rbxassetid://...` with actual uploaded asset IDs.

### 7. Import in Studio

```lua
-- In a Script in ServerScriptService
local ImportMeshes = require(ReplicatedStorage.Scripts.Roblox.ImportMeshes)
ImportMeshes.ImportAll()
```

## Naming Convention

| Component | Format | Example |
|-----------|--------|---------|
| FBX file | `{species}_stage{stage}.fbx` | `fenix_stage3.fbx` |
| MeshPart | `{species}_{stage}_{part}` | `fenix_3_wingL` |
| Motor6D | `J_{PartName}` | `J_WingL` |
| LOD meshes | `{name}_LOD{0,1,2}` | `fenix_3_wingL_LOD1` |

## Hierarchy

```
Root (Part, anchored, invisible)
└── Rig (Model)
    ├── Body (MeshPart) ← J_Body
    ├── Head (MeshPart) ← J_Head
    ├── Neck (MeshPart) ← J_Neck
    ├── Leg1 (MeshPart) ← J_Leg1
    ├── Leg2 (MeshPart) ← J_Leg2
    ├── Leg3 (MeshPart) ← J_Leg3
    ├── Leg4 (MeshPart) ← J_Leg4
    ├── WingL (MeshPart) ← J_WingL
    │   ├── WingL_1 ← J_WingL_1
    │   ├── WingL_2 ← J_WingL_2
    │   └── WingL_3 ← J_WingL_3
    ├── WingR (MeshPart) ← J_WingR
    │   ├── WingR_1 ← J_WingR_1
    │   ├── WingR_2 ← J_WingR_2
    │   └── WingR_3 ← J_WingR_3
    ├── Tail1 (MeshPart) ← J_Tail1
    ├── Tail2 (MeshPart) ← J_Tail2
    ├── Tail3 (MeshPart) ← J_Tail3
    └── Tail4 (MeshPart) ← J_Tail4
```

## Materials

| Blender Material | Roblox Enum.Material | Use Case |
|------------------|---------------------|----------|
| SmoothPlastic | `SmoothPlastic` | Base body parts |
| Neon | `Neon` | Elemental accents (wings, eyes, tail tips) |
| Glass | `Glass` | Crystals, gems, lanterns |
| Slate | `Slate` | Mineral/stone creatures |
| Fabric | `Fabric` | Spectral/ghostly creatures |

**No external textures** - all coloring via vertex colors from ArtTokens palette.

## LODs

| LOD | Triangle Ratio | Suffix |
|-----|----------------|--------|
| LOD0 | 100% (full) | (none) |
| LOD1 | 50% | `_LOD1` |
| LOD2 | 25% | `_LOD2` |

Roblox automatically streams LODs based on distance.

## Scale

**1 Blender unit = 1 stud**

Creature scales by stage:
- Stage 1 (Baby): 0.65x
- Stage 2 (Juvenile): 1.0x  
- Stage 3 (Adult): 1.35x

## ArtTokens Palette

Vertex colors use the 48-color palette from `src/shared/ArtTokens.luau`:

- **Ember** (Fire): Dark purple → Red → Orange → Light orange → Cream
- **Tidal** (Water): Dark blue → Blue → Cyan → Light cyan → Mint
- **Leaf** (Nature): Dark green → Green → Light green → Lime → Pale yellow
- **Sand** (Earth): Dark brown → Brown → Tan → Light tan → Cream
- **Sky** (Air): Dark indigo → Blue → Light blue → Pale blue → Off-white
- **Veil** (Shadow): Dark purple → Purple → Lavender → Pink → Light pink
- **Metal** (Steel): Dark slate → Slate → Grey → Light grey → Cream
- **Rose** (Hybrid): Dark rose → Rose → Pink → Light pink → Cream

## Troubleshooting

### FBX Import Fails
- Ensure Blender version ≥ 4.0
- Check `trimesh` is installed: `pip install trimesh`
- Verify FBX export settings: `bake_space_transform=True`, `global_scale=1.0`

### Motor6D Not Working
- Joint names must match exactly: `J_Body`, `J_Head`, `J_Leg1`, etc.
- Motor6D must be parented to `Part1` (the child part)
- C0 = Part0.CFrame:ToObjectSpace(Part1.CFrame)
- C1 = CFrame.identity (usually)

### Materials Wrong in Studio
- Material names in Blender must match `MATERIAL_MAP` in `import_meshes.luau`
- Vertex color attribute must be named `Col`

### LODs Not Streaming
- Ensure LOD meshes are named with `_LOD1`, `_LOD2` suffixes
- Parent LOD meshes to same bone as LOD0
- Set `ModelStreamingMode = Atomic` on the Model

## Pipeline Scripts

### export_creatures.py
```bash
# Full export
blender -b --python export_creatures.py -- assets/fbx

# Specific species
blender -b --python export_creatures.py -- assets/fbx --species fenix

# Specific stage
blender -b --python export_creatures.py -- assets/fbx --stage 3

# Create templates only
blender -b --python export_creatures.py -- --create-templates
```

### generate_manifest.py
```bash
python generate_manifest.py
```

Outputs `src/shared/BlenderModels.generated.luau`

## Integration with build_assets.py

The art build script supports FBX preview:

```bash
python scripts/art/build_assets.py --with-fbx
```

This renders creatures using both native Roblox parts AND imported FBX MeshParts.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024 | Initial pipeline |

## License

Part of Arquipélago das Feras project.