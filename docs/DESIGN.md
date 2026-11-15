# DESIGN.md — Arquipélago das Feras: Total Overhaul

**Version**: 8.0.0 (art-overhaul branch)  
**Status**: In Development  
**Target**: Roblox (Luau, Rojo workflow)  
**Aesthetic**: Cassette Beasts — low-poly stylized, flat-shaded, vertex-colored, expedition notebook vibe

---

## 1. VISION & CORE PILLARS

### 1.1 The Feeling We Want
> *\"UAU, CHEGUEI NA ILHA DE NEVE\"* — Every island arrival is a moment.  
> *\"KRL, A FÊNIX BOLADONA\"* — Every legendary encounter is memorable.

### 1.2 Core Pillars
| Pillar | Description |
|--------|-------------|
| **Unique Silhouettes** | Every monster readable at 50 studs, distinct personality |
| **Living Islands** | 10 massive seamless worlds, verticality, dynamic events |
| **Deep Evolution** | 8 methods, 4-stage legendaries, meaningful choices |
| **Cassette Beasts Visuals** | Flat-shaded, vertex colors from 48-color palette, no external textures |
| **Roblox-Native** | MeshParts + Motor6D, LODs, StreamingEnabled, <50MB place size |

---

## 2. MONSTER SYSTEM — 151 SPECIES

### 2.1 Rarity Distribution
| Rarity | Count | Stages | Evolution Methods |
|--------|-------|--------|-------------------|
| **Starters** | 3 lines × 3 = 9 | 3 | Level (16/36) |
| **Legendaries** | 10 | 4 (Ascension at 100) | Special quest + unique item |
| **Epics** | 26 | 3 | Level, Item, Location, Move |
| **Rares** | 30 | 2–3 | Level, Item, Friendship, Trade |
| **Commons** | 76 | 1–2 | Level only |

**Total: 151 species** across 12 elements.

### 2.2 Element System (12 Elements)
| Element | Ramp Name | Strong Against | Weak Against | Palette Theme |
|---------|-----------|----------------|--------------|---------------|
| Fogo | Ember | Natureza, Gelo, Metal | Água, Terra, Pedra | Warm oranges/reds |
| Água | Tidal | Fogo, Terra, Pedra | Natureza, Elétrico | Deep blues/cyans |
| Natureza | Leaf | Água, Terra, Pedra | Fogo, Gelo, Ar, Veneno | Greens/limes |
| Terra | Loam | Fogo, Elétrico, Pedra, Metal | Água, Natureza, Gelo | Browns/ochres |
| Ar | Breeze | Natureza, Lutador, Inseto | Elétrico, Gelo, Pedra | Whites/pale blues |
| Sombra | Void | Psíquico, Fantasma, Luz | Sombra, Fada | Purples/blacks |
| **Gelo** | **Frost** | Ar, Terra, Natureza, Dragão | Fogo, Metal, Pedra, Lutador | **Ice blues/whites** |
| **Elétrico** | **Spark** | Água, Ar, Voador | Terra | **Yellows/electric blues** |
| **Luz** | **Glow** | Sombra, Fantasma, Dragão | Metal, Cristal | **Golds/pale yellows** |
| **Metal** | **Steel** | Gelo, Pedra, Fada | Fogo, Lutador, Terra | **Grays/metallics** |
| **Cristal** | **Prism** | Luz, Sombra, Dragão | Metal, Pedra | **Rainbow/iridescent** |
| **Arcano** | **Void** | (Neutral — special) | (Neutral) | **Cosmic purples** |

### 2.3 Starter Lines (9 Total)
| Line | Stage 1 (Lv.1) | Stage 2 (Lv.16) | Stage 3 (Lv.36) | Concept |
|------|----------------|-----------------|-----------------|---------|
| **Fogo** | Ignisprow | Vulpenkind | Infernine | Fox → 3-tailed fire spirit → Fire wolf deity |
| **Água** | Aquafin | Naiadrake | Oceansovereign | Otter → Naga-like → Ocean guardian serpent |
| **Natureza** | Terrasprout | Sylvanhart | WorldtreeAvatar | Fawn → Branch-antlered stag → Walking world-tree |

### 2.4 Legendary Quartet (10 Total, All 4-Stage)
| Legendary | Element | Base Form | Stage 2 | Stage 3 | **Stage 4 (Lv.100 Ascension)** |
|-----------|---------|-----------|---------|---------|-------------------------------|
| **Fênix Fuligem** | Fogo | Cinza | Brasa | Chama Eterna | **Fênix Primordial** (reborn from ash) |
| **Tempestália** | Ar | Brisa | Vendaval | Furacão | **Olho da Tempestade** (calm center) |
| **Caranguepérola** | Água | Concha | Coral | Abissal | **Mãe das Marés** (tide controller) |
| **Esfingeolito** | Terra | Areia | Rochas | Monolito | **Guardião do Núcleo** (planet heart) |
| **Trovoraptor** | Elétrico | Faísca | Raio | Tempestade | **Arconte das Nuvens** (storm lord) |
| **Vagalumorte** | Sombra | Sussurro | Vazio | Eclipse | **Fim das Sombras** (void given form) |
| **Aracnoflora** | Natureza | Broto | Teia | Floresta | **Mãe da Selva** (nature incarnate) |
| **Glaciarte** | Gelo | Neve | Geada | Glacial | **Aurora Eterna** (living aurora) |
| **Voltwisp** | Elétrico | Estática | Choque | Plasma | **Faísca Primordial** (first lightning) |
| **Lumifae** | Luz | Brilho | Raio | Estrela | **Alvorada** (first light) |

**Ascension Quest**: Unique per legendary — 3-part questline (investigate → trial → ritual) requiring max friendship, specific location, time of day, and a unique **Ascension Fragment** (11 per legendary = 110 fragments total).

### 2.5 Evolution Methods (8 Total)
| Method | Trigger | Examples |
|--------|---------|----------|
| **Level** | Reach level X | Most commons/rares |
| **Item** | Use evolution stone/item | Pedra Fogo, Pedra Gelo, etc. |
| **Friendship** | Max amizade + level up | Eevee-likes, baby forms |
| **Trade** | Trade with another player | Gengar-likes, metal-coat users |
| **Time** | Level up at day/night | Lunatone/Solrock style |
| **Location** | Level up in specific zone | Magnetic zone, mossy rock |
| **Move** | Learn specific move + level | Ancient Power, Rollout |
| **Special (Ascension)** | Lv.100 + quest + fragment + battle | Legendaries only |

### 2.6 Hybrid Evolutions (5 Lines)
| Hybrid | Parents | Method | Result |
|--------|---------|--------|--------|
| **Magmaterra** | Fogo + Terra | Item (Pedra Magma) | Lava golem |
| **Cinzavento** | Fogo + Ar | Location (Vulcão Ativo) | Ash phoenix |
| **Vaporino** | Água + Ar | Time (Chuva + Tarde) | Mist spirit |
| **Ferrowurm** | Terra + Metal | Move (Metal Claw + Dig) | Iron wyrm |
| **Crystalis** | Luz + Cristal | Friendship + Day | Prism dragon |

---

## 3. ISLAND SYSTEM — 10 MASSIVE ISLANDS

### 3.1 Island Overview
| # | Island | Element Theme | Status | Key Landmark | Guardian |
|---|--------|---------------|--------|--------------|----------|
| 1 | **Ilha Inicial (Verdantis)** | Natureza | Reformulated | Árvore Mãe (World Tree) | Sylvanhart |
| 2 | **Vulcânia** | Fogo | Reformulated | Caldeira Eterna | Infernine |
| 3 | **Maré Azul** | Água | Reformulated | Recife de Cristal | Oceansovereign |
| 4 | **Pico Terroso** | Terra | Reformulated | Cânion Profundo | Esfingeolito |
| 5 | **Céu Ventoso** | Ar | Reformulated | Ilhas Flutuantes | Tempestália |
| 6 | **Vale Sombrio** | Sombra | Reformulated | Ruínas Antigas | Vagalumorte |
| 7 | **Planície Dourada** | Luz | Reformulated | Templo Solar | Lumifae |
| 8 | **🆕 Inverno Eterno** | **Gelo** | **NEW** | **Cidadela de Gelo** | **Glaciarte** |
| 9 | **🆕 Ilha do Trovão** | **Elétrico** | **NEW** | **Pico do Raio** | **Trovoraptor** |
| 10 | **🆕 Reino Celestial** | **Luz/Arcano** | **NEW** | **Catedral das Estrelas** | **Fênix Primordial** |

### 3.2 Island Structure (Per Island)
`
Island (512×512 to 1024×1024 studs)
├── Surface Biomes (3–5 per island)
│   ├── Major Landmark (1–2 per biome)
│   ├── POIs: Sanctuaries, Shrines, Ruins, Villages
│   └── Dynamic Events: Weather, Migrations, Rare Spawns
├── Cave Systems (2–4 layers)
│   ├── Upper: Common spawns, resources
│   ├── Middle: Rare spawns, puzzles
│   └── Deep: Epic/Legendary dens, Ascension altars
├── Verticality Features
│   ├── Floating islands (Ar, Luz)
│   ├── Underwater zones (Água)
│   ├── Vertical shafts (Terra, Metal)
│   └── Ice caverns (Gelo)
└── World Events (hourly/daily)
    ├── Boss spawns (guardians)
    ├── Migration waves
    ├── Weather phenomena
    └── Rare monster outbreaks
`

### 3.3 New Islands Detail

#### **Ilha 8: Inverno Eterno (Gelo)**
- **Biomes**: Tundra, Floresta de Gelo, Cavernas Cristalinas, Pico Glaciar
- **Landmark**: *Cidadela de Gelo* — massive ice fortress, internal aurora lighting
- **Verticality**: Ice caves descend to bedrock; floating icebergs above
- **Unique Mechanic**: *Congelamento Progressivo* — players without cold resist take stacking damage
- **Guardian**: **Glaciarte** (roams tundra) → Ascension at *Altar da Aurora* (cavern depth 3)

#### **Ilha 9: Ilha do Trovão (Elétrico)**
- **Biomes**: Planície Carregada, Floresta Magnética, Tempestade Perpétua, Núcleo Íonico
- **Landmark**: *Pico do Raio* — perpetual lightning storm, magnetic levitation rocks
- **Verticality**: Floating magnetic islands; underground ion tunnels
- **Unique Mechanic**: *Carga Estática* — builds up while moving, discharges on interaction
- **Guardian**: **Trovoraptor** (circles peak) → Ascension at *Olho da Tempestade* (floating island)

#### **Ilha 10: Reino Celestial (Luz/Arcano)**
- **Biomes**: Jardins Estelares, Arquipélago Flutuante, Vale da Ascensão, Núcleo Cósmico
- **Landmark**: *Catedral das Estrelas* — massive structure reaching into clouds
- **Verticality**: Entire island is floating; cloud-layer navigation; stardust rivers
- **Unique Mechanic**: *Gravidade Variável* — low-gravity zones, reverse-gravity tunnels
- **Guardian**: **Fênix Primordial** (final boss) → Ascension at *Núcleo Cósmico* (requires all 9 other Ascensions)

---

## 4. EVOLUTION SYSTEM — TECHNICAL SPEC

### 4.1 Data Structure (EvolutionData.luau)
`luau
type EvolutionMethod = 
    | { type: "Level", level: number }
    | { type: "Item", itemId: string, consume: boolean }
    | { type: "Friendship", minFriendship: number, level: number? }
    | { type: "Trade", requiresItem: string? }
    | { type: "Time", timeOfDay: "Day" | "Night" | "Dusk" | "Dawn" }
    | { type: "Location", placeId: number, regionName: string }
    | { type: "Move", moveId: string }
    | { type: "Ascension", questId: string, fragmentId: string, bossId: string }

type EvolutionStage = {
    from: string,
    to: string,
    method: EvolutionMethod,
    cutsceneId: string,
    requirementsMet: (player: Player, creature: CreatureData) -> boolean
}

type EvolutionChain = {
    speciesId: string,
    stages: { EvolutionStage },
    ascension: EvolutionStage?  -- Only for legendaries
}
`

### 4.2 Server Authority (EvolutionService.luau)
- **RemoteFunction**: RequestEvolution(player, creatureId, method) → validates, consumes items, updates data
- **RemoteEvent**: TriggerEvolutionCutscene(player, data) → fires client cutscene
- **Auto-Evolution**: On level-up, checkAutoEvolution() runs server-side
- **Trade Evolution**: Handled via ProcessTradeEvolution(sender, receiver, creatureId)
- **Rate Limiting**: 10 requests/minute per player
- **Anti-Cheat**: Validates ownership, item existence, location, time, move knowledge, quest completion

### 4.3 Client Cutscene (EvolutionUI.luau — 4 Phases)
| Phase | Duration | Visuals |
|-------|----------|---------|
| **Charge** | 1.5s | Particle spiral, screen shake, color drain |
| **Glow** | 2.0s | Model emits element color, rings expand |
| **Transform** | 3.0s | **ViewportFrame + WorldModel** morph: LOD0→LOD0 crossfade, mesh swap |
| **Reveal** | 2.5s | New model pose, name banner, confetti/shockwave, stat roll-up |

**Particle Systems**: Sparkles, Elemental Rings, Burst, Confetti, Shockwave — all vertex-colored from ArtTokens.

---

## 5. BLENDER → ROBLOX PIPELINE

### 5.1 Modeling Standards
| Spec | Value |
|------|-------|
| **Style** | Low-poly, flat-shaded, Cassette Beasts aesthetic |
| **Triangle Budget** | Commons: 300–600 \| Rares: 600–1000 \| Epics: 1000–1500 \| Legendaries: 1500–2500 |
| **Scale** | 1 Blender Unit = 1 Roblox Stud |
| **Origin** | Centered at feet (Root joint) |
| **Naming** | {species}_{stage}_{part} (e.g., enix_adult_wingL) |
| **Materials** | Vertex colors only — **no external textures** |
| **Palette** | 48 colors (8 ramps × 6 + neutrals) from ArtTokens.luau |

### 5.2 Rig Hierarchy (Motor6D Compatible)
`
Root (PrimaryPart)
└── J_Body
    ├── J_Head
    │   └── J_Neck (optional)
    ├── J_Leg1 (FL)
    ├── J_Leg2 (FR)
    ├── J_Leg3 (BL)
    ├── J_Leg4 (BR)
    ├── J_WingL (optional)
    ├── J_WingR (optional)
    ├── J_Tail1
    │   └── J_Tail2
    │       └── J_Tail3
    │           └── J_Tail4
    └── J_Special (horns, crystals, etc.)
`
**Joint Naming**: J_ prefix = Motor6D joint name in Roblox.

### 5.3 LOD System (3 Levels)
| LOD | Tri % | Distance | Use Case |
|-----|-------|----------|----------|
| **LOD0** | 100% | 0–50 studs | Close combat, cutscenes |
| **LOD1** | 50% | 50–150 studs | Exploration, mid-range |
| **LOD2** | 25% | 150+ studs | Far view, swarms |

**Naming**: {species}_{stage}_{part}_LOD{0-2}

### 5.4 Export Pipeline
`
1. Model in Blender (rig_template.blend + material_template.blend)
2. Export FBX: scripts/blender/export_creatures.py → assets/fbx/
3. Upload FBX via Roblox Asset Manager (bulk)
4. Generate Manifest: scripts/blender/generate_manifest.py → BlenderModels.generated.luau
5. Fill Asset IDs in generated file
6. Import in Studio: scripts/roblox/import_meshes.luau → MeshParts + Motor6Ds + LODs
7. Runtime: src/shared/BlenderModels.luau (registry with validation)
`

### 5.5 Animation Set (Per Species)
| Animation | Duration | Priority | Notes |
|-----------|----------|----------|-------|
| Idle | 4.0s | Core | Breathing, subtle sway |
| Walk | 1.0s | Core | Loop, foot sync |
| Run | 0.7s | Core | Faster loop |
| Attack | 1.2s | Action | 3 variants per species |
| Damage | 0.5s | Action | Flinch + knockback |
| Faint | 2.0s | Action | Collapse, despawn |
| Special | 3.0s | Action | Signature move, unique |

---

## 6. ART DIRECTION — CASSETTE BEASTS AESTHETIC

### 6.1 Visual Identity (from ART_BIBLE.md)
- **Expedition Notebook**: UI looks like hand-drawn field notes
- **Patinated Metal**: Buttons, frames — aged brass/copper
- **Cream Paper**: Backgrounds — warm off-white (#F5F0E1)
- **Lilac Sky**: Global ambient — twilight purple (#B8A9D6)
- **Ink Lines**: 1px dark outlines on UI, subtle on 3D

### 6.2 Color System (ArtTokens.luau)
- **8 Element Ramps** × 7 colors = 56 + 6 neutrals = **62 colors**
- **Usage**: Vertex colors, UI accents, particle emission, environment tint
- **Matching**: Nearest-color algorithm for procedural assignment

### 6.3 Creature Design Rules
1. **Silhouette First** — readable at 50 studs, no texture dependency
2. **Element Tells** — fire = flame parts, water = fins/bubbles, etc.
3. **Stage Progression** — size 1.0x → 1.35x → 1.7x; complexity increases
4. **Personality Poses** — idle animation tells story (proud, skittish, lazy)
5. **Color Ramp Discipline** — 3–4 colors per creature from assigned ramp

### 6.4 Environment Rules
- **No Photorealism** — stylized geology, blocky but organic
- **Vertex-Colored Foliage** — same palette as creatures
- **Landmarks as Silhouettes** — recognizable from across island
- **Dynamic Sky** — lilac base, shifts per biome (aurora in Gelo, storm in Elétrico)

---

## 7. TECHNICAL ARCHITECTURE (ROBLOX/LUAU)

### 7.1 Repository Structure (Rojo)
`
Arquipelago-das-Feras/
├── default.project.json
├── src/
│   ├── client/          -- Client controllers, UI, effects
│   ├── server/          -- Services, data stores, authority
│   └── shared/          -- Types, constants, utilities, registries
├── assets/
│   ├── blender/         -- .blend files, export scripts
│   └── fbx/             -- Exported FBX (gitignored, CI artifacts)
├── scripts/
│   ├── blender/         -- Python export/generation
│   └── roblox/          -- Studio import scripts
├── docs/                -- DESIGN.md, ART_BIBLE.md, specs
└── tests/               -- TestEZ unit tests
`

### 7.2 Key Shared Modules
| Module | Purpose |
|--------|---------|
| Types.luau | Strict type definitions (--!strict) |
| ArtTokens.luau | 62-color palette, biome/element mapping |
| CreatureDesigns.luau | 151 anatomical recipes |
| EvolutionData.luau | All evolution chains + ascension |
| EvolutionItems.luau | 50+ items (stones, fragments, consumables) |
| BlenderModels.luau | Runtime MeshPart registry + validation |
| Strings.luau | All display names (i18n-ready) |
| Creatures.luau | Species registry (stats, rarity, island, family) |

### 7.3 Server Services
| Service | Responsibility |
|---------|----------------|
| GameService | Core loop, player join/leave, level up → evolution check |
| EvolutionService | All evolution logic, validation, cutscene triggers |
| CreatureService | Spawning, behavior, capture, breeding, sanctuary |
| IslandService | Zone management, dynamic events, world bosses |
| DataService | DataStore v2, session locking, schema migration |

### 7.4 Client Controllers
| Controller | Responsibility |
|------------|----------------|
| CreatureController | Local replication, prediction, input |
| EvolutionUI | Cutscene system, evolution panel, toasts |
| IslandController | Streaming, biome transitions, landmark POIs |
| BattleController | Turn-based UI, move selection, animations |
| SanctuaryController | Habitat UI, visitor mode, breeding |

### 7.5 Performance Targets
| Metric | Target |
|--------|--------|
| Place Size | < 50 MB |
| MeshPart Count (loaded) | < 2,000 |
| Triangle Budget (scene) | < 500k tris |
| Script Activity | < 3% average |
| Memory | < 600 MB |
| Network | < 50 KB/s per player |
| FPS (mid-tier) | 60 FPS stable |

---

## 8. IMPLEMENTATION PHASES

### Phase 1: Foundation ✅ **COMPLETE**
- [x] Evolution System (5 files, 1768 lines)
- [x] Blender Pipeline (7 files, templates + export + import)
- [x] ArtTokens + Palette System

### Phase 2: Monster Models 🟡 **IN PROGRESS**
- [x] Starters scripts (9 models) — **scripts written, need Blender execution**
- [x] Epics (26 × 3 = 78 OBJ/MTL) — **generated via MCP**
- [x] Rares (30, 74 files) + Commons (60, 96 files) — **generated via MCP**
- [ ] **Legendaries (10 × 4 = 40 models)** — **PENDING (blender-legendaries failed)**
- [ ] FBX Export & Manifest Generation
- [ ] Studio Import + Motor6D Rigging

### Phase 3: Island Architecture 🔴 **FAILED (needs retry)**
- [ ] 10 Island Layouts (terrain, biomes, landmarks, caves)
- [ ] Dynamic Event System
- [ ] Guardian Boss AI
- [ ] Ascension Altar Placement

### Phase 4: Luau Implementation 🔴 **FAILED (5 agents, need retry)**
- [ ] creatures-impl — Spawning, capture, breeding, sanctuary
- [ ] iomes-impl — Decoration, weather, migration, POIs
- [ ] attle-impl — Turn system, moves, type chart, status effects
- [ ] ui-impl — HUD, menus, evolution panel, notebook UI
- [ ] data-impl — DataStore v2, profiles, schema migration

### Phase 5: Polish & Deploy 🔴 **FAILED (needs retry)**
- [ ] Integration Testing (multi-client)
- [ ] Performance Profiling & Optimization
- [ ] Build Place File (Rojo)
- [ ] Push to rt-overhaul branch
- [ ] Create Release v8.0.0

---

## 9. IMMEDIATE NEXT ACTIONS

| Priority | Task | Owner | Status |
|----------|------|-------|--------|
| **P0** | Wait for design-doc agent completion | Workflow | Running |
| **P0** | Fix blender starter scripts (4 empty files) | Me | **Done** |
| **P0** | Execute uild_all_starters.py in Blender | User/Me | Pending scripts |
| **P1** | Retry blender-legendaries agent | Workflow | Queued |
| **P1** | Retry island-architecture agent | Workflow | Queued |
| **P1** | Retry 5 Luau impl agents | Workflow | Queued |
| **P1** | Retry polish-deploy agent | Workflow | Queued |
| **P2** | Upload FBX to Roblox, fill Asset IDs | User | After exports |
| **P2** | Build place file, test in Studio | Me/User | After imports |
| **P3** | Push to GitHub rt-overhaul branch | Me | Final step |

---

## 10. GOLDEN RULES (from ART_SPEC.md)

1. **No external textures** — Vertex colors only, from ArtTokens palette
2. **Motor6D hierarchy** — J_ prefix joints, Root at feet
3. **LODs mandatory** — 3 levels, proper naming
4. **Scale: 1 BU = 1 Stud** — Origin at feet
5. **Triangle budgets enforced** — Validation in BlenderModels.luau
6. **Server-authoritative** — Never trust client for evolution, capture, currency
7. **StreamingEnabled** — Islands load progressively
8. **DataStore v2** — Session locking, autosave, migration
9. **--!strict everywhere** — Type safety first
10. **Cassette Beasts aesthetic** — Flat, stylized, notebook charm

---

*This DESIGN.md is the single source of truth for the art-overhaul branch. All agents and implementation reference this document.*