# CINZELO - Technical Art Bible
## Arquipélago das Feras | Pipeline Blender → Roblox

---

## 📐 Especificações Técnicas

### Modelo Base (Cinzelo - Fogo/Comum)
| Parâmetro | Valor |
|-----------|-------|
| **Triângulos (Low-poly)** | ~5,708 tris |
| **Vértices** | 4,804 |
| **UV Layout** | Atlas único 2044×2044 |
| **Escala** | 1 Blender Unit = 1m (Roblox) |
| **Altura** | ~1.2m (Adulto) |
| **Pivot** | Base dos pés (0, 0, 0) |

### Hierarquia de Bones (R15 Compatible)
```
Root
└── Hips
    ├── LowerTorso
    │   └── UpperTorso
    │       ├── Head
    │       ├── LeftUpperArm → LeftLowerArm → LeftHand
    │       └── RightUpperArm → RightLowerArm → RightHand
    ├── LeftUpperLeg → LeftLowerLeg → LeftFoot
    ├── RightUpperLeg → RightLowerLeg → RightFoot
    └── Tail1 → Tail2 → Tail3
```

**20 bones total** - Compatível com Roblox Animator/RigBuilder

---

## 🎨 Materiais PBR (SurfaceAppearance)

### Texture Maps (2044×2044 PNG)
| Map | Canal | Descrição |
|-----|-------|-----------|
| **BaseColor** | RGB | Cor base: carvão escuro (#1a1a1a) com rachaduras laranja brasas |
| **Normal** | RGB | Detalhes: placas dorsais, poros de carvão, brasas salientes |
| **ORM** | R=Roughness, G=Metallic, B=AO | Roughness: 0.7-0.9 (fosco), Metallic: 0.1 (leve brilho mineral), AO: cavidades |
| **Emissive** | RGB+A | Braças/placas dorsais: laranja quente (#ff6600), Alpha = intensidade |

### Roblox SurfaceAppearance Properties
```lua
local sa = Instance.new("SurfaceAppearance")
sa.BaseColorMap = "rbxassetid://[BASECOLOR_ID]"
sa.NormalMap = "rbxassetid://[NORMAL_ID]"
sa.RoughnessMap = "rbxassetid://[ORM_ID]"  -- R channel
sa.MetalnessMap = "rbxassetid://[ORM_ID]"  -- G channel
sa.Parent = meshPart
```

---

## 🔄 Shape Keys - Evolução (3 Estágios)

| Estágio | Shape Key | Escala | Características |
|---------|-----------|--------|-----------------|
| **1. Filhote** | `Stage_Filhote` | 50% | Cabeça 130%, membros 40%, placas invisíveis |
| **2. Juvenil** | `Stage_Juvenil` | 70% | Cabeça 85%, placas 50% desenvolvidas |
| **3. Adulto** | `Basis` | 100% | Forma completa, placas 100%, brasas ativas |

### Implementação no Roblox
```lua
-- Usar MeshPart.MeshId swap OU MorphTarget (se suportado)
-- Recomendado: 3 MeshParts separados (Filhote/Juvenil/Adulto)
-- Trocar via script na evolução
```

---

## 📁 Estrutura de Arquivos

```
CINZELO_EXPORT/
├── CINZELO_Roblox.fbx      # Mesh + Armature (280 KB)
├── CINZELO_Roblox.glb      # Preview rápido (1 MB)
├── textures/
│   ├── CINZELO_BaseColor.png
│   ├── CINZELO_Normal.png
│   ├── CINZELO_ORM.png
│   └── CINZELO_Emissive.png
└── TECHNICAL_ART_BIBLE.md  # Este arquivo
```

---

## ⚙️ Import no Roblox Studio

### 1. Import FBX
```lua
-- Game Settings > Avatar > Import FBX
-- Selecionar CINZELO_Roblox.fbx
-- Importar como: Rig (R15) + MeshParts
```

### 2. Configurar MeshParts
```lua
local meshPart = script.Parent
meshPart.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition
meshPart.RenderFidelity = Enum.RenderFidelity.Automatic
meshPart.CanCollide = true
```

### 3. Aplicar SurfaceAppearance
```lua
local sa = Instance.new("SurfaceAppearance")
sa.BaseColorMap = "rbxassetid://[UPLOAD_BASECOLOR]"
sa.NormalMap = "rbxassetid://[UPLOAD_NORMAL]"
sa.RoughnessMap = "rbxassetid://[UPLOAD_ORM]"
sa.MetalnessMap = "rbxassetid://[UPLOAD_ORM]"
sa.Parent = meshPart
```

### 4. Animator Setup
```lua
local animator = Instance.new("Animator")
animator.Parent = rig.Humanoid

-- Carregar animações
local idle = Instance.new("Animation")
idle.AnimationId = "rbxassetid://[IDLE_ANIM_ID]"
local idleTrack = animator:LoadAnimation(idle)
idleTrack:Play()
```

---

## 🎭 Animações Necessárias (Próximos Passos)

| Animação | Frames | Prioridade |
|----------|--------|------------|
| Idle | 60 | Loop |
| Walk | 30 | Loop |
| Run | 24 | Loop |
| Attack | 20 | Action |
| Evolve | 60 | Action (Filhote→Juvenil→Adulto) |
| Hit | 15 | Action |
| Death | 30 | Action |

**Dica**: Animar no Blender (Action Editor) → Export FBX com `bake_anim=True` → Import no Roblox

---

## 🔧 Pipeline Automatizado (Blender Python)

```python
# Script completo disponível em: pipeline/cinzel_pipeline.py
# Etapas:
# 1. create_high_poly()      # Metaball + sculpt
# 2. retopologize()          # Low-poly ~6k tris
# 3. unwrap_uv()             # Smart UV Project + pack
# 4. create_materials()      # PBR nodes
# 5. bake_textures()         # BaseColor, Normal, ORM, Emissive
# 6. rig_armature()          # R15 hierarchy + envelope weights
# 7. create_shape_keys()     # 3 estágios evolução
# 8. export_fbx()            # Roblox-ready
```

---

## ✅ Checklist de Qualidade

- [x] Tri count < 10k ✓ (5.7k)
- [x] UV sem overlapping ✓
- [x] Texel density consistente ✓
- [x] Pivot na base ✓
- [x] Bones R15 compatible ✓
- [x] Weights normalizados ✓ (100% verts)
- [x] Shape keys 3 estágios ✓
- [x] FBX export testado ✓
- [x] GLB preview ✓
- [ ] Texturas bakeadas (Normal, ORM, Emissive) - *fazer no Blender GUI*
- [ ] Animações criadas
- [ ] Testado no Roblox Studio mobile

---

## 📝 Notas para Próximas Criaturas

1. **Reutilizar rig**: Mesma hierarquia para todas criaturas bípedes/quadrúpedes
2. **Template material**: Duplicar MAT_CINZELO_MAIN e trocar texturas
3. **Scale reference**: Cinzelo = 1.2m → usar como referência de escala
4. **Naming convention**: `CREATURENAME_PART_TYPE` (ex: MAGMARAU_BODY_LOW)

---

*Gerado automaticamente pelo pipeline Blender → Roblox*
*Diretor de Arte 3D / Character Artist / Technical Artist*
*Arquipélago das Feras - v1.0*
