# Guia de Importação das Ilhas no Roblox Studio

## Arquivos Disponíveis
Os seguintes arquivos FBX foram exportados do Blender e estão prontos para importação:
- `assets/islands/Island_StarterTown.fbx` (501 KB)
- `assets/islands/Island_FireForest.fbx` (1.5 MB)
- `assets/islands/Island_WaterCaves.fbx` (549 KB)
- `assets/islands/Island_NaturePlains.fbx` (749 KB)
- `assets/islands/Island_EarthDesert.fbx` (695 KB)
- `assets/islands/Island_AirPeaks.fbx` (498 KB)
- `assets/islands/Island_ShadowRuins.fbx` (526 KB)
- `assets/islands/Island_VolcanoIsle.fbx` (1.5 MB)
- `assets/islands/All_Islands.fbx` (5.5 MB - todas combinadas)

---

## Método 1: Asset Manager (RECOMENDADO)

### Passo a passo:

1. **Abra o Asset Manager**
   - No Roblox Studio: View → Asset Manager

2. **Importe os FBX**
   - Clique no botão "Import" (ícone de seta para baixo)
   - Selecione "Import 3D"
   - Navegue até `C:\Users\Zaion Araujo\ArquipelagoDasFeras\assets\islands\`
   - Selecione **todos os 8 arquivos Island_*.fbx** (não o All_Islands.fbx)
   - Clique em "Open"

3. **Configure as opções de importação**
   - **Import as**: Model (não Parts)
   - **Scale**: 1.0 (já exportado na escala correta)
   - **Up Axis**: Y (padrão Roblox)
   - **Forward Axis**: -Z (padrão Roblox)
   - Marque "Import Materials" se quiser tentar importar materiais
   - Clique em "Import"

4. **Organize no ReplicatedStorage**
   - Após importar, os modelos aparecerão em "Assets" no Asset Manager
   - No Game Explorer, crie a estrutura:
     ```
     ReplicatedStorage
       └── Assets
           └── Islands
               ├── StarterTown
               ├── FireForest
               ├── WaterCaves
               ├── NaturePlains
               ├── EarthDesert
               ├── AirPeaks
               ├── ShadowRuins
               └── VolcanoIsle
     ```
   - Arraste cada modelo importado para a pasta correspondente

---

## Método 2: Game Explorer (Alternativo)

1. No Game Explorer (View → Game Explorer)
2. Botão direito em `ReplicatedStorage` → Insert Object → Folder → Nome: `Assets`
3. Botão direito em `Assets` → Insert Object → Folder → Nome: `Islands`
4. Arraste os arquivos `.fbx` do Windows Explorer diretamente para a pasta `Islands` no Game Explorer
5. O Studio importará automaticamente

---

## Configuração Pós-Importação (OBRIGATÓRIO)

Para cada modelo de ilha importado, faça:

### 1. Definir PrimaryPart
```
Selecione o Model raiz da ilha → Properties → PrimaryPart
Clique no dropdown e selecione a parte central (geralmente "IslandCenter" ou "Terrain")
```

### 2. Ancorar todas as partes
```lua
-- Execute no Command Bar para cada ilha:
local model = game.ReplicatedStorage.Assets.Islands.NomeDaIlha
for _, part in ipairs(model:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = true
        -- Colisão apenas para chão/rochas
        if part.Name:find("Terrain") or part.Name:find("Ground") or part.Name:find("Rock") then
            part.CanCollide = true
        else
            part.CanCollide = false
        end
    end
end
```

### 3. Aplicar Materials por Bioma
| Bioma | Material Principal | Cor Base |
|-------|-------------------|----------|
| Nature (StarterTown, NaturePlains) | Grass, Forest | Verde floresta |
| Fire (FireForest, VolcanoIsle) | Basalt, Slate, Neon (laranja) | Vermelho/Preto |
| Water (WaterCaves) | Sand, SmoothPlastic (azul) | Areia/Azul |
| Earth (EarthDesert) | Sandstone, Slate, Basalt | Marrom/Bege |
| Air (AirPeaks) | SmoothPlastic, Neon (azul), ForceField | Branco/Azul claro |
| Shadow (ShadowRuins) | Slate, Basalt, Neon (roxo) | Roxo escuro/Preto |

### 4. Configurar Texturas PBR (se exportadas)
Se você fez bake das texturas no Blender:
- BaseColor → SurfaceAppearance.ColorMap
- Normal → SurfaceAppearance.NormalMap
- ORM (Roughness/Metallic/AO packed) → SurfaceAppearance.MetalnessMap + RoughnessMap
- Emissive → SurfaceAppearance.EmissiveMap (ou use Material.Neon com EmissiveColor)

---

## Estrutura Final Esperada

### ReplicatedStorage
```
ReplicatedStorage/
  Assets/
    Islands/
      StarterTown/ (Model com PrimaryPart = IslandCenter)
      FireForest/
      WaterCaves/
      NaturePlains/
      EarthDesert/
      AirPeaks/
      ShadowRuins/
      VolcanoIsle/
```

### Workspace (criado automaticamente pelo WorldController)
```
Workspace/
  Islands/
    StarterTown/ (clone posicionado em 0,0,0)
    FireForest/ (clone posicionado em 300,0,0)
    WaterCaves/ (clone posicionado em 0,-20,300)
    NaturePlains/ (clone posicionado em -300,0,0)
    EarthDesert/ (clone posicionado em 0,0,-300)
    AirPeaks/ (clone posicionado em 200,150,200)
    ShadowRuins/ (clone posicionado em -200,-20,-200)
    VolcanoIsle/ (clone posicionado em 350,0,350)
    Bridges/
      Bridge_StarterTown_to_FireForest/
      Bridge_StarterTown_to_WaterCaves/
      Bridge_StarterTown_to_NaturePlains/
      Bridge_StarterTown_to_EarthDesert/
      Bridge_FireForest_to_VolcanoIsle/
      Bridge_WaterCaves_to_AirPeaks/
      Bridge_NaturePlains_to_AirPeaks/
      Bridge_EarthDesert_to_ShadowRuins/
```

---

## Testando a Importação

Após configurar tudo, execute no Command Bar:

```lua
-- Teste rápido
local WorldController = require(game.ReplicatedStorage.Client.Controllers.WorldController)
WorldController.Initialize()
print("Ilhas carregadas:", game.Workspace.Islands:GetChildren())
```

Ou inicie o Play Solo e verifique se:
1. As ilhas aparecem no Workspace
2. O jogador nasce na StarterTown
3. Câmera mostra o terreno corretamente
4. Colisão funciona (não cai através do chão)
5. Notificações de zona aparecem ao mover entre ilhas

---

## Troubleshooting

### "Modelo não carrega / fica invisível"
- Verifique se PrimaryPart está definido
- Verifique se todas as partes têm Anchored = true
- Verifique se o modelo não está escalado para 0

### "Jogador cai através do chão"
- Partes do terreno precisam de CanCollide = true
- Verifique se não há partes transparentes bloqueando

### "Materiais não aparecem"
- Importe texturas separadamente como ImageLabels
- Use SurfaceAppearance para PBR
- Ou pinte manualmente no Studio (Material + Color)

### "Performance ruim"
- Use Decimate nos modelos no Blender antes de exportar
- Ative StreamingEnabled no Workspace
- Use LOD (Level of Detail) para ilhas distantes

---

## Próximos Passos Após Importação

1. ✅ Importar modelos FBX
2. ✅ Configurar PrimaryPart, Anchored, CanCollide
3. ✅ Aplicar Materials/Colors por bioma
4. ⏳ Importar 27 criaturas (já exportadas em `assets/models/`)
5. ⏳ Criar animações (Moon Animator ou Blender)
6. ⏳ Configurar SurfaceAppearances PBR
6. ⏳ Testar Play Solo completo
7. ⏳ Publicar no Roblox para teste multiplayer

---

## Scripts de Apoio

Execute estes scripts no Command Bar após importar:

**`scripts/import_islands_to_studio.luau`** - Configura Workspace automaticamente
**`scripts/setup_creature_assets.luau`** - Configura criaturas (SurfaceAppearance, hitboxes, morph targets)
**`scripts/create_animations.luau`** - Guia para criar animações de batalha