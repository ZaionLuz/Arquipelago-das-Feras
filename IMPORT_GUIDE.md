# Guia de Importação de Modelos - Arquipélago das Feras

## Visão Geral
Este guia explica como importar os 27 modelos de criaturas (FBX/GLB) para o Roblox Studio e configurá-los para uso no jogo.

## Arquivos Disponíveis
Localizados em: `assets/models/`
- 27 arquivos `.fbx` (formato principal para Roblox)
- 27 arquivos `.glb` (backup/visualização)
- Total: 54 arquivos

## Criaturas por Elemento

### Fire (4)
- CINZELO_Roblox.fbx/glb
- MAGMARAU_Roblox.fbx/glb
- FENIXFULIGEM_Roblox.fbx/glb
- VULCANODRAGO_Roblox.fbx/glb

### Water (4)
- HIDROSONDA_Roblox.fbx/glb
- VAPORAL_Roblox.fbx/glb
- LEVIATHAN_Roblox.fbx/glb
- ABYSSALIS_Roblox.fbx/glb

### Nature (4)
- VERDANTIS_Roblox.fbx/glb
- DRYADUS_Roblox.fbx/glb
- YGGDRASIL_Roblox.fbx/glb
- GAIA_HEART_Roblox.fbx/glb

### Earth (4)
- GRAOZINHO_Roblox.fbx/glb
- ESCORPIODRA_Roblox.fbx/glb
- ESFINGEOLITO_Roblox.fbx/glb
- COLOSSODUNE_Roblox.fbx/glb

### Air (4)
- PENUGEM_Roblox.fbx/glb
- VENTANIL_Roblox.fbx/glb
- TROVORAPTOR_Roblox.fbx/glb
- AERONIMBO_Roblox.fbx/glb

### Shadow (4)
- LODINHO_Roblox.fbx/glb
- CAUDALUME_Roblox.fbx/glb
- VAGALUMORTE_Roblox.fbx/glb
- REINEVOENTO_Roblox.fbx/glb

### Hybrids (3)
- PIROHIDRO_Roblox.fbx/glb (Fire+Water)
- TERRAVENTO_Roblox.fbx/glb (Earth+Air)
- LUZSOMBRA_Roblox.fbx/glb (Nature+Shadow)

---

## Método 1: Importação via Asset Manager (Recomendado)

### Passo a Passo

1. **Abra o Roblox Studio com Rojo**
   ```bash
   cd ArquipelagoDasFeras
   rojo serve
   ```
   - No Studio: Plugin > Rojo > Connect

2. **Abra o Asset Manager**
   - View > Asset Manager (ou `Ctrl+Shift+A`)

3. **Importe os modelos**
   - Clique no botão **Import** > **Import 3D**
   - Selecione todos os arquivos `.fbx` da pasta `assets/models/`
   - Clique em **Open**

4. **Configure cada importação**
   Para cada modelo, nas configurações de importação:
   ```
   Scale: 1.0
   Import Materials: ✓ ON
   Import Animations: ✓ ON (para shape keys de evolução)
   Generate Collision: ✗ OFF
   Import Cameras: ✗ OFF
   Import Lights: ✗ OFF
   ```

5. **Organize na hierarquia**
   - Após importar, arraste cada modelo para:
     `ReplicatedStorage > Assets > Creatures`
   - Renomeie para o **SpeciesId** (ex: `CINZELO`, não `CINZELO_Roblox`)

6. **Defina PrimaryPart**
   - Selecione o modelo
   - Na janela Properties, encontre `PrimaryPart`
   - Clique no dropdown e selecione a parte principal (geralmente `Root`, `Body` ou `MeshPart` raiz)

---

## Método 2: Arrastar e Soltar (Alternativo)

1. No File Explorer, abra `assets/models/`
2. Selecione todos os `.fbx`
3. Arraste diretamente para a janela **Viewport** do Studio
4. Siga os mesmos passos de configuração do Método 1

---

## Especificações Técnicas dos Modelos

### Geometria
- **Triângulos**: ~5.000 - 10.000 por criatura
- **LODs**: Não incluídos (configurar no Studio se necessário)
- **Pivot**: Centralizado na base da criatura

### UVs & Texturas
- **Unwrap**: Smart UV Project (angle_limit=66°, island_margin=0.003)
- **Atlas**: 2048x2048 (BaseColor, Normal, ORM, Emissive)
- **ORM Packing**: R=Occlusion, G=Roughness, B=Metallic

### Rigging
- **Esqueleto**: R15-compatível (20-50 bones)
- **Nomes dos bones**: Padronizados (Root, Hips, Spine, Neck, Head, Left/Right Shoulder/Elbow/Wrist, Left/Right Hip/Knee/Ankle)
- **Skinning**: ARMATURE_ENVELOPE + proximity weights (100% vertex coverage)

### Shape Keys (Evolução)
3 estágios configurados como Blend Shapes:
1. **Filhote** (50% scale) - `ShapeKey_Filhote`
2. **Juvenil** (75% scale) - `ShapeKey_Juvenil`
3. **Adulto** (100% scale) - `ShapeKey_Adulto` (base)

> **Nota**: No Roblox, shape keys vêm como **MorphTargets** no MeshPart. Use `MeshPart:GetMorphTargets()` para acessar.

---

## Pós-Importação: Script de Configuração

Após importar todos os modelos, execute no **Command Bar** (`View > Command Bar`):

```lua
-- Carregar script de configuração
local script = game:GetService("ServerScriptService"):FindFirstChild("SetupCreatures")
if script then
    require(script).SetupAll()
end
```

Ou execute o script `scripts/setup_creature_assets.luau` que configura:

### 1. SurfaceAppearances (Materiais PBR)
```lua
-- Para cada MeshPart do modelo:
local surfaceApp = Instance.new("SurfaceAppearance")
surfaceApp.Name = "PBRMaterial"
surfaceApp.ColorMap = "rbxassetid://BASECOLOR_ID"
surfaceApp.NormalMap = "rbxassetid://NORMAL_ID"
surfaceApp.MetalnessMap = "rbxassetid://ORM_ID"  -- Canal B
surfaceApp.RoughnessMap = "rbxassetid://ORM_ID" -- Canal G
surfaceApp.Parent = meshPart
```

### 2. AnimationController + Animator
```lua
local animController = Instance.new("AnimationController")
animController.Parent = model

local animator = Instance.new("Animator")
animator.Parent = model
```

### 3. Battle Hitbox
```lua
local hitbox = Instance.new("Part")
hitbox.Name = "BattleHitbox"
hitbox.Size = Vector3.new(4, 4, 4) -- Ajustar por criatura
hitbox.Transparency = 1
hitbox.CanCollide = false
hitbox.CanTouch = true
hitbox.Anchored = true
hitbox.Massless = true
hitbox.Parent = model
CollectionService:AddTag(hitbox, "BattleHitbox")
```

### 4. Attachments para Efeitos
```lua
local attachments = {
    Root = Vector3.new(0, 0, 0),
    Head = Vector3.new(0, 2, 0),
    Body = Vector3.new(0, 0, 0),
    Front = Vector3.new(0, 1, 2),
    Back = Vector3.new(0, 1, -2),
    Left = Vector3.new(-2, 1, 0),
    Right = Vector3.new(2, 1, 0),
    Top = Vector3.new(0, 3, 0),
    Bottom = Vector3.new(0, -1, 0),
}

for name, pos in pairs(attachments) do
    local att = Instance.new("Attachment")
    att.Name = name .. "Attachment"
    att.Position = pos
    att.Parent = model.PrimaryPart
end
```

### 5. Configurações de Performance
```lua
for _, meshPart in ipairs(model:GetDescendants()) do
    if meshPart:IsA("MeshPart") then
        meshPart.RenderFidelity = Enum.RenderFidelity.Precise
        meshPart.CollisionFidelity = Enum.CollisionFidelity.Box
        meshPart.CastShadow = true
        meshPart.ReceiveShadow = true
    end
end
```

---

## Verificação Pós-Importação

### Checklist por Criatura
- [ ] Modelo em `ReplicatedStorage.Assets.Creatures.{SpeciesId}`
- [ ] Nome correto (SpeciesId exato)
- [ ] PrimaryPart definido
- [ ] SurfaceAppearances em todas as MeshParts
- [ ] AnimationController + Animator presentes
- [ ] BattleHitbox com tag "BattleHitbox"
- [ ] 9 Attachments criados
- [ ] MorphTargets acessíveis (3 estágios de evolução)
- [ ] Materiais PBR visuais corretos
- [ ] Sombra projetada corretamente

### Teste Rápido no Command Bar
```lua
-- Testar se modelo carrega
local model = game.ReplicatedStorage.Assets.Creatures.CINZELO
print("Modelo:", model.Name)
print("PrimaryPart:", model.PrimaryPart and model.PrimaryPart.Name or "NENHUM")
print("MeshParts:", #model:GetDescendants())
print("MorphTargets:", model.PrimaryPart and #model.PrimaryPart:GetMorphTargets() or 0)
print("SurfaceAppearances:", #model.PrimaryPart:GetChildren())
print("AnimationController:", model:FindFirstChild("AnimationController") and "OK" or "FALTANDO")
print("Animator:", model:FindFirstChild("Animator") and "OK" or "FALTANDO")
print("Hitbox:", model:FindFirstChild("BattleHitbox") and "OK" or "FALTANDO")
```

---

## Troubleshooting

### Modelo não aparece / invisível
- Verifique se `PrimaryPart` está definido
- Confira se `MeshPart.Transparency < 1`
- Verifique se há `SurfaceAppearance` ou `Material` válido

### Materiais rosa / quebrados
- Texturas não importadas: reimporte com "Import Materials: ON"
- Ou crie SurfaceAppearances manualmente com asset IDs das texturas

### Animações não funcionam
- Verifique se `AnimationController` e `Animator` existem
- Shape keys vêm como MorphTargets - use `TweenService` para interpolar
- Para animações esqueléticas: importe `.fbx` com "Import Animations: ON"

### Performance ruim
- Reduza `RenderFidelity` para `Automatic` em criaturas distantes
- Adicione LODs no Model (MeshPart > Create LOD)
- Use `StreamingEnabled` no Workspace

### Escala incorreta
- Modelos exportados com escala 1.0 (Blender units = Studs)
- Se muito grande/pequeno: ajuste `Scale` na importação ou use `Model:ScaleTo()`

---

## Próximos Passos Após Importação

1. **Upload das texturas** para Roblox (Asset Manager > Import Images)
   - BaseColor, Normal, ORM, Emissive para cada criatura
   - Copie os Asset IDs para o script de configuração

2. **Criar animações de batalha** (Idle, Attack, Hit, Faint)
   - Use Moon Animator ou Blender > export FBX com animações
   - Upload para Roblox > copie Animation IDs para `src/shared/Animations.luau`

3. **Configurar cries (gritos)** das criaturas
   - Upload de áudio > copie IDs para AudioController

4. **Teste de batalha completo**
   - Spawn creature > batalha > captura > evolução

---

## Comandos Úteis

```bash
# Sincronizar alterações de código (Rojo)
rojo serve

# Build para produção
rojo build -o ArquipelagoDasFeras.rbxlx

# Verificar tipos (Selene)
selene src/

# Formatar código (StyLua)
stylua src/
```

---

## Referências

- [Roblox 3D Importer Docs](https://create.roblox.com/docs/art/3d-importer)
- [SurfaceAppearance PBR](https://create.roblox.com/docs/art/materials/surface-appearance)
- [AnimationController](https://create.roblox.com/docs/reference/engine/classes/AnimationController)
- [MorphTargets](https://create.roblox.com/docs/reference/engine/classes/MeshPart#GetMorphTargets)
- [Rojo Documentation](https://rojo.space/docs/)