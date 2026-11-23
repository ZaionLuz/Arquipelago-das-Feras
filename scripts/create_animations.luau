--!strict
-- create_animations.luau - Guia para criar animações de batalha no Roblox
-- Use Moon Animator Plugin ou Blender para criar, depois importe

local AnimationGuide = {}

-- Lista de animações necessárias por criatura
AnimationGuide.RequiredAnimations = {
	-- Base (compartilhadas)
	"Idle",
	"Walk",
	"Run",
	"Jump",
	"Fall",
	"Swim",
	"Fly",
	"BattleIdle",
	"AttackPhysical",
	"AttackSpecial",
	"AttackStatus",
	"Hit",
	"Faint",
	"Evolve",
	"Capture",
	"LevelUp",
}

-- Animações específicas por elemento (override visual)
AnimationGuide.ElementAnimations = {
	Fire = {
		AttackPhysical = "FireBite",      -- Mordida com brasas
		AttackSpecial = "Flamethrower",   -- Lança-chamas
		Hit = "BurnHit",                  -- Recoil com faíscas
		Faint = "AshCollapse",            -- Vira cinzas
	},
	Water = {
		AttackPhysical = "WaterSlash",    -- Corte de água
		AttackSpecial = "HydroPump",      -- Jato forte
		Hit = "SplashHit",                -- Respingos
		Faint = "PuddleCollapse",         -- Vira poça
	},
	Nature = {
		AttackPhysical = "VineWhip",      -- Chicote de videira
		AttackSpecial = "SeedBomb",       -- Bomba de sementes
		Hit = "LeafHit",                  -- Folhas voando
		Faint = "WitherCollapse",         -- Murcha
	},
	Earth = {
		AttackPhysical = "RockThrow",     -- Lança pedra
		AttackSpecial = "Earthquake",     -- Tremor
		Hit = "DustHit",                  -- Poeira
		Faint = "CrumbleCollapse",        -- Desmorona
	},
	Air = {
		AttackPhysical = "WingStrike",    -- Golpe de asa
		AttackSpecial = "AirSlash",       -- Corte de vento
		Hit = "GustHit",                  -- Rajada
		Faint = "FeatherFall",            -- Penas caindo
	},
	Shadow = {
		AttackPhysical = "ShadowClaw",    -- Garra sombria
		AttackSpecial = "ShadowBall",     -- Esfera negra
		Hit = "VoidHit",                  -- Distorção
		Faint = "FadeCollapse",           -- Desvanece
	},
	FireWater = {
		AttackPhysical = "SteamPunch",    -- Soco de vapor
		AttackSpecial = "GeyserBurst",    -- Géiser de magma
		Hit = "SteamHit",                 -- Vapor
		Faint = "MistCollapse",           -- Névoa
	},
	EarthAir = {
		AttackPhysical = "SandSlash",     -- Corte de areia
		AttackSpecial = "DustDevil",      -- Redemoinho
		Hit = "SandHit",                  -- Areia
		Faint = "DustCollapse",           -- Pó
	},
	NatureShadow = {
		AttackPhysical = "ThornShadow",   -- Espinho sombrio
		AttackSpecial = "TwilightBeam",   -- Raio crepuscular
		Hit = "PetalVoidHit",             -- Pétalas negras
		Faint = "WitherFade",             -- Murcha e some
	},
}

-- Como criar no Moon Animator (Plugin gratuito no Roblox)
AnimationGuide.MoonAnimatorSteps = [[
=== CRIANDO ANIMAÇÕES COM MOON ANIMATOR ===

1. INSTALAÇÃO
   - No Roblox Studio: Plugins > Moon Animator 2 (instalar)
   - Ou: Toolbox > Plugins > Moon Animator

2. PREPARAÇÃO
   - Arraste seu modelo de criatura (ex: CINZELO) para o Workspace
   - Selecione o modelo
   - Abra Moon Animator (View > Moon Animator)

3. CRIAR ANIMAÇÃO
   - Clique em "New Animation"
   - Nome: "CINZELO_Idle"
   - Tipo: "Loop" (para Idle, Walk, Run, BattleIdle, Swim, Fly)
   - Tipo: "Once" (para Attack, Hit, Faint, Evolve, Capture, LevelUp)
   - Frame Rate: 30 FPS (padrão)

4. ANIMAR (Idle - 2 segundos / 60 frames)
   - Frame 1: Pose neutra
   - Frame 30: Leve inclinação (respiração)
   - Frame 60: Volta ao frame 1 (loop perfeito)
   - Dica: Use "Auto Key" (tecla K) para keyframes automáticos

5. ANIMAR (AttackPhysical - 1 segundo / 30 frames)
   - Frame 1: Pose de preparação (agachar/carregar)
   - Frame 10: Extensão máxima (golpe)
   - Frame 15: Impacto (HIT FRAME - marco importante!)
   - Frame 20: Retração
   - Frame 30: Volta à pose neutra

6. MARCAR HIT FRAME
   - No frame de impacto (ex: frame 15 de 30)
   - Clique com botão direito no timeline > "Add Event"
   - Nome: "Hit"
   - Parâmetro: frame number (ex: 15)
   - Isso permite sincronizar dano no servidor!

7. EXPORTAR
   - File > Export > Roblox Animation
   - Salva como .rbxmanim (formato Moon)
   - Ou: Export > FBX com animações (para Blender)

8. UPLOAD PARA ROBLOX
   - No Asset Manager: Import > Animation
   - Ou: Crie Animation no Studio > AnimationId = "rbxassetid://..."
   - Copie o Asset ID gerado

9. REGISTRAR EM Animations.luau
   - Abra src/shared/Animations.luau
   - Substitua "rbxassetid://0" pelo seu Asset ID
   - Ex: Idle = "rbxassetid://1234567890"
]]

-- Como criar no Blender (para exportar FBX com animações)
AnimationGuide.BlenderSteps = [[
=== CRIANDO ANIMAÇÕES NO BLENDER ===

1. PREPARAÇÃO
   - Importe seu modelo .fbx no Blender
   - Verifique se Armature está ligada ao Mesh (Armature Deform)
   - Modo: Pose Mode (Ctrl+Tab)

2. CRIAR ACTIONS (Animações)
   - Dope Sheet > Action Editor > New Action
   - Nomeie: "CINZELO_Idle", "CINZELO_AttackPhysical", etc.
   - Cada action = uma animação separada

3. KEYFRAMES ESSENCIAIS
   Idle (60 frames, loop):
   - Frame 1: Rest pose
   - Frame 30: Peito expande (respiração), cabeça levemente baixa
   - Frame 60: Copy frame 1 (Shift+D > Enter)

   AttackPhysical (30 frames):
   - Frame 1: Windup (preparação - antenas/cauda recuam)
   - Frame 10: Anticipation (corpo tensionado)
   - Frame 15: HIT FRAME - Extensão total do ataque
   - Frame 20: Follow through
   - Frame 30: Return to rest

   Hit (15 frames):
   - Frame 1: Impact pose (corpo curvado para trás)
   - Frame 8: Recoil máximo
   - Frame 15: Return to rest

   Faint (30 frames):
   - Frame 1: Standing
   - Frame 15: Knees buckle, head drops
   - Frame 30: Lying down (flat)

4. NLA EDITOR (Non-Linear Animation)
   - Combine actions em tracks
   - Permite transições suaves (blending)

4. EXPORT FBX
   - File > Export > FBX (.fbx)
   - Settings:
     - Apply Scalings: FBX Units Scale
     - Forward: -Z Forward, Up: Y Up
     - Armature: Add Leaf Bones: OFF
     - Animation: ✓ Animated, ✓ NLA Strips, ✓ All Actions
     - Bake Animation: ✓, Start: 1, End: 60, Step: 1
     - Simplify: 0 (manter todos keyframes)

5. IMPORT NO ROBLOX
   - Asset Manager > Import 3D > Selecione FBX
   - "Import Animations: ON"
   - Cria Animation objetos automaticamente
   - Copie AnimationIds para Animations.luau
]]

-- Template de script para testar animação no Command Bar
AnimationGuide.TestScript = [[
-- Cole no Command Bar para testar animação
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local model = ReplicatedStorage.Assets.Creatures.CINZELO:Clone()
model.Parent = workspace
model:PivotTo(CFrame.new(0, 5, 0))

local animator = model:FindFirstChild("Animator") or Instance.new("Animator")
animator.Parent = model

local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://SEU_ANIMATION_ID_AQUI"

local track = animator:LoadAnimation(anim)
track:Play()
track.Looped = true

-- Para testar hit frame:
track:GetMarkerReachedSignal("Hit"):Connect(function(param)
    print("HIT FRAME ATINGIDO!", param)
end)
]]

-- Exportar
return AnimationGuide