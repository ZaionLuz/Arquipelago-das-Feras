#!/usr/bin/env python3
"""
Generate BlenderModels.luau from export_manifest.json
Converts the Blender export manifest to Lua format for Roblox runtime.
Run after exporting FBX files from Blender.
"""

import json
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[3]
MANIFEST_PATH = PROJECT_ROOT / "assets" / "fbx" / "export_manifest.json"
OUTPUT_PATH = PROJECT_ROOT / "src" / "shared" / "BlenderModels.generated.luau"

# Creature metadata from CreatureDesigns.luau
CREATURE_META = {
    "cinzelo": {"name": "Cinzelo", "element": "Fogo", "family": "mineral", "animator": "Quadruped"},
    "magmarau": {"name": "Magmarau", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "fenixfuligem": {"name": "Fênix Fuligem", "element": "Fogo", "family": "winged", "animator": "Bird"},
    "vulcanodrago": {"name": "Vulcanodrago", "element": "Fogo", "family": "draconic", "animator": "Draconic"},
    "bolhinho": {"name": "Bolhinho", "element": "Água", "family": "aquatic", "animator": "Aquatic"},
    "marilisco": {"name": "Marilisco", "element": "Água", "family": "serpentine", "animator": "Serpentine"},
    "carangueperola": {"name": "Carangue Pérola", "element": "Água", "family": "arthropod", "animator": "Arthropod"},
    "abissauro": {"name": "Abissauro", "element": "Água", "family": "aquatic", "animator": "Aquatic"},
    "brotinho": {"name": "Brotinho", "element": "Natureza", "family": "vegetal", "animator": "Quadruped"},
    "folhuco": {"name": "Folhuco", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "aracnoflora": {"name": "Aracnoflora", "element": "Natureza", "family": "arthropod", "animator": "Arthropod"},
    "ancestravore": {"name": "Ancestravore", "element": "Natureza", "family": "biped", "animator": "Biped"},
    "graozinho": {"name": "Gráozinho", "element": "Terra", "family": "mineral", "animator": "Quadruped"},
    "escorpiodra": {"name": "Escorpiodra", "element": "Terra", "family": "arthropod", "animator": "Arthropod"},
    "esfingeolito": {"name": "Esfingeolito", "element": "Terra", "family": "quadruped", "animator": "Quadruped"},
    "colossodune": {"name": "Colossodune", "element": "Terra", "family": "mineral", "animator": "Quadruped"},
    "penugem": {"name": "Penugem", "element": "Ar", "family": "winged", "animator": "Bird"},
    "ventanil": {"name": "Ventanil", "element": "Ar", "family": "winged", "animator": "Bird"},
    "trovoraptor": {"name": "Trovoraptor", "element": "Ar", "family": "draconic", "animator": "Draconic"},
    "aeronimbo": {"name": "Aeronimbo", "element": "Ar", "family": "serpentine", "animator": "Serpentine"},
    "lodinho": {"name": "Lodinho", "element": "Sombra", "family": "spectral", "animator": "Quadruped"},
    "caudalume": {"name": "Caudalume", "element": "Sombra", "family": "serpentine", "animator": "Serpentine"},
    "vagalumorte": {"name": "Vagalumorte", "element": "Sombra", "family": "arthropod", "animator": "Arthropod"},
    "reinevoento": {"name": "Rei Nevoento", "element": "Sombra", "family": "spectral", "animator": "Biped"},
    "vaporino": {"name": "Vaporino", "element": "Fogo", "family": "serpentine", "animator": "Serpentine"},
    "magmaterra": {"name": "Magmaterra", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "tempestalia": {"name": "Tempestalia", "element": "Ar", "family": "winged", "animator": "Bird"},
    "nevoamusgo": {"name": "Nevoamusgo", "element": "Natureza", "family": "vegetal", "animator": "Quadruped"},
    "cinzavento": {"name": "Cinzavento", "element": "Fogo", "family": "draconic", "animator": "Draconic"},
    "fenix": {"name": "Fênix", "element": "Fogo", "family": "winged", "animator": "Bird"},

    "flamiris": {"name": "Flamiris", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "carvunio": {"name": "Carvúnio", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "brasegato": {"name": "Brasegato", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "orvalume": {"name": "Orvalume", "element": "Água", "family": "quadruped", "animator": "Quadruped"},
    "coralina": {"name": "Coralina", "element": "Água", "family": "quadruped", "animator": "Quadruped"},
    "pelaguir": {"name": "Pelaguir", "element": "Água", "family": "aquatic", "animator": "Aquatic"},
    "musgalte": {"name": "Musgalte", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "bambuja": {"name": "Bambujá", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "florabelha": {"name": "Florabelha", "element": "Natureza", "family": "arthropod", "animator": "Arthropod"},
    "marmure": {"name": "Marmuré", "element": "Terra", "family": "quadruped", "animator": "Quadruped"},
    "litorisco": {"name": "Litorisco", "element": "Terra", "family": "mineral", "animator": "Quadruped"},
    "sementauro": {"name": "Sementauro", "element": "Terra", "family": "quadruped", "animator": "Quadruped"},
    "sibilobo": {"name": "Sibilobo", "element": "Ar", "family": "quadruped", "animator": "Quadruped"},
    "cirrandor": {"name": "Cirrandor", "element": "Ar", "family": "winged", "animator": "Bird"},
    "nimboreo": {"name": "Nimbóreo", "element": "Ar", "family": "draconic", "animator": "Draconic"},
    "velune": {"name": "Veluné", "element": "Sombra", "family": "quadruped", "animator": "Quadruped"},
    "obsidauro": {"name": "Obsidauro", "element": "Sombra", "family": "quadruped", "animator": "Quadruped"},
    "velumosa": {"name": "Velumosa", "element": "Sombra", "family": "winged", "animator": "Bird"},
    "glaurina": {"name": "Glaurina", "element": "Gelo", "family": "quadruped", "animator": "Quadruped"},
    "niveor": {"name": "Níveor", "element": "Gelo", "family": "quadruped", "animator": "Quadruped"},
    "gelifoca": {"name": "Gelifoca", "element": "Gelo", "family": "aquatic", "animator": "Aquatic"},
    "fulgarru": {"name": "Fulgarru", "element": "Elétrico", "family": "quadruped", "animator": "Quadruped"},
    "ampelince": {"name": "Ampelince", "element": "Elétrico", "family": "quadruped", "animator": "Quadruped"},
    "trovissideo": {"name": "Trovissídeo", "element": "Elétrico", "family": "arthropod", "animator": "Arthropod"},
    "aurifita": {"name": "Aurifita", "element": "Luz", "family": "quadruped", "animator": "Quadruped"},
    "lunarru": {"name": "Lunarru", "element": "Luz", "family": "quadruped", "animator": "Quadruped"},
    "candeira": {"name": "Candeíra", "element": "Luz", "family": "arthropod", "animator": "Arthropod"},
    "ferrunila": {"name": "Ferrunila", "element": "Metal", "family": "quadruped", "animator": "Quadruped"},
    "fiaranha": {"name": "Fiaranha", "element": "Metal", "family": "arthropod", "animator": "Arthropod"},
    "metafalcao": {"name": "Metafalcão", "element": "Metal", "family": "winged", "animator": "Bird"},
    "cindrel": {"name": "Cindrel", "element": "Fogo", "family": "mineral", "animator": "Quadruped"},
    "emberkit": {"name": "Emberkit", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "sparkpup": {"name": "Sparkpup", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "flamecub": {"name": "Flamecub", "element": "Fogo", "family": "quadruped", "animator": "Quadruped"},
    "coalcrawler": {"name": "Coalcrawler", "element": "Fogo", "family": "arthropod", "animator": "Arthropod"},
    "aquasprite": {"name": "Aqua Sprite", "element": "Água", "family": "aquatic", "animator": "Aquatic"},
    "droplet": {"name": "Droplet", "element": "Água", "family": "mineral", "animator": "Quadruped"},
    "finling": {"name": "Finling", "element": "Água", "family": "quadruped", "animator": "Quadruped"},
    "tidepup": {"name": "Tidepup", "element": "Água", "family": "quadruped", "animator": "Quadruped"},
    "coralkit": {"name": "Coralkit", "element": "Água", "family": "quadruped", "animator": "Quadruped"},
    "leaflet": {"name": "Leaflet", "element": "Natureza", "family": "vegetal", "animator": "Quadruped"},
    "seedling": {"name": "Seedling", "element": "Natureza", "family": "mineral", "animator": "Quadruped"},
    "sprou": {"name": "Sprou", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "vinecub": {"name": "Vinecub", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "petalpaw": {"name": "Petalpaw", "element": "Natureza", "family": "quadruped", "animator": "Quadruped"},
    "pebblin": {"name": "Pebblin", "element": "Terra", "family": "mineral", "animator": "Quadruped"},
    "rockling": {"name": "Rockling", "element": "Terra", "family": "mineral", "animator": "Quadruped"},
    "sandpup": {"name": "Sandpup", "element": "Terra", "family": "quadruped", "animator": "Quadruped"},
    "dunecub": {"name": "Dunecub", "element": "Terra", "family": "quadruped", "animator": "Quadruped"},
    "geodette": {"name": "Geodette", "element": "Terra", "family": "arthropod", "animator": "Arthropod"},
    "zephyr": {"name": "Zephyr", "element": "Ar", "family": "winged", "animator": "Bird"},
    "cloudpuff": {"name": "Cloudpuff", "element": "Ar", "family": "mineral", "animator": "Quadruped"},
    "breezekit": {"name": "Breezekit", "element": "Ar", "family": "quadruped", "animator": "Quadruped"},
    "galehatch": {"name": "Galehatch", "element": "Ar", "family": "quadruped", "animator": "Quadruped"},
    "windling": {"name": "Windling", "element": "Ar", "family": "winged", "animator": "Bird"},
    "shade": {"name": "Shade", "element": "Sombra", "family": "spectral", "animator": "Quadruped"},
    "shadowmite": {"name": "Shadowmite", "element": "Sombra", "family": "mineral", "animator": "Quadruped"},
    "gloomkit": {"name": "Gloomkit", "element": "Sombra", "family": "quadruped", "animator": "Quadruped"},
    "duskpup": {"name": "Duskpup", "element": "Sombra", "family": "quadruped", "animator": "Quadruped"},
    "nightmoth": {"name": "Nightmoth", "element": "Sombra", "family": "arthropod", "animator": "Arthropod"},
    "frostbit": {"name": "Frostbit", "element": "Gelo", "family": "mineral", "animator": "Quadruped"},
    "icecrystal": {"name": "Icecrystal", "element": "Gelo", "family": "mineral", "animator": "Quadruped"},
    "snowkit": {"name": "Snowkit", "element": "Gelo", "family": "quadruped", "animator": "Quadruped"},
    "glaciercub": {"name": "Glaciercub", "element": "Gelo", "family": "quadruped", "animator": "Quadruped"},
    "frostling": {"name": "Frostling", "element": "Gelo", "family": "winged", "animator": "Bird"},
    "voltkit": {"name": "Voltkit", "element": "Elétrico", "family": "quadruped", "animator": "Quadruped"},
    "sparkling": {"name": "Sparkling", "element": "Elétrico", "family": "mineral", "animator": "Quadruped"},
    "jolteon": {"name": "Jolteon", "element": "Elétrico", "family": "quadruped", "animator": "Quadruped"},
    "zapcub": {"name": "Zapcub", "element": "Elétrico", "family": "quadruped", "animator": "Quadruped"},
    "buzzbug": {"name": "Buzzbug", "element": "Elétrico", "family": "arthropod", "animator": "Arthropod"},
    "lumikit": {"name": "Lumikit", "element": "Luz", "family": "quadruped", "animator": "Quadruped"},
    "gloworb": {"name": "Gloworb", "element": "Luz", "family": "mineral", "animator": "Quadruped"},
    "solarpup": {"name": "Solarpup", "element": "Luz", "family": "quadruped", "animator": "Quadruped"},
    "raycub": {"name": "Raycub", "element": "Luz", "family": "quadruped", "animator": "Quadruped"},
    "prismfly": {"name": "Prismfly", "element": "Luz", "family": "arthropod", "animator": "Arthropod"},
    "ironkit": {"name": "Ironkit", "element": "Metal", "family": "quadruped", "animator": "Quadruped"},
    "scraplet": {"name": "Scraplet", "element": "Metal", "family": "mineral", "animator": "Quadruped"},
    "boltpup": {"name": "Boltpup", "element": "Metal", "family": "quadruped", "animator": "Quadruped"},
    "gearcub": {"name": "Gearcub", "element": "Metal", "family": "quadruped", "animator": "Quadruped"},
    "rivetbug": {"name": "Rivetbug", "element": "Metal", "family": "arthropod", "animator": "Arthropod"},
    "gemling": {"name": "Gemling", "element": "Cristal", "family": "mineral", "animator": "Quadruped"},
    "shardlet": {"name": "Shardlet", "element": "Cristal", "family": "mineral", "animator": "Quadruped"},
    "crystalkit": {"name": "Crystalkit", "element": "Cristal", "family": "quadruped", "animator": "Quadruped"},
    "prismpup": {"name": "Prismpup", "element": "Cristal", "family": "quadruped", "animator": "Quadruped"},
    "facetbug": {"name": "Facetbug", "element": "Cristal", "family": "arthropod", "animator": "Arthropod"},
    "runeling": {"name": "Runeling", "element": "Arcano", "family": "spectral", "animator": "Quadruped"},
    "mysticorb": {"name": "Mysticorb", "element": "Arcano", "family": "mineral", "animator": "Quadruped"},
    "arcankit": {"name": "Arcankit", "element": "Arcano", "family": "quadruped", "animator": "Quadruped"},
    "voidpup": {"name": "Voidpup", "element": "Arcano", "family": "quadruped", "animator": "Quadruped"},
    "sigilbug": {"name": "Sigilbug", "element": "Arcano", "family": "arthropod", "animator": "Arthropod"},
}

def generate_lua(manifest: dict) -> str:
    """Generate Lua table from manifest."""

    lines = [
        "--!strict",
        "-- @generated by scripts/blender/generate_manifest.py",
        "-- DO NOT EDIT MANUALLY - changes will be overwritten",
        "",
        "local BlenderModels = {}",
        "",
        "export type VertexColorData = { [number]: { r: number, g: number, b: number, a: number } }",
        "",
        "export type MeshPartData = {",
        "	MeshId: string,",
        "	Size: { number },",
        "	CFrame: { number },",
        "	Color: { number },",
        "	Material: string,",
        "	Transparency: number?,",
        "	VertexColors: VertexColorData?,",
        "	LOD1MeshId: string?,",
        "	LOD2MeshId: string?,",
        "}",
        "",
        "export type CreatureStageData = {",
        "	Parts: { [string]: MeshPartData },",
        "	AnimatorType: string,",
        "	Scale: number,",
        "	Bounds: {",
        "		Min: { number },",
        "		Max: { number },",
        "	},",
        "}",
        "",
        "export type CreatureData = {",
        "	Species: string,",
        "	DisplayName: string,",
        "	Element: string,",
        "	Family: string,",
        "	Stages: { [number]: CreatureStageData },",
        "	RigTemplate: string,",
        "	ExportVersion: number,",
        "	ExportTimestamp: number,",
        "}",
        "",
        "export type BlenderModelsRegistry = {",
        "	Creatures: { [string]: CreatureData },",
        "	MeshIdMap: { [string]: string },",
        "	Version: number,",
        "	GeneratedAt: number,",
        "	GitCommit: string?,",
        "}",
        "",
        f"BlenderModels.VERSION = {manifest.get('version', 1)}",
        f"BlenderModels.GENERATED_AT = {manifest.get('timestamp', 0)}",
        "",
        "BlenderModels.Creatures = {",
    ]

    for species_id, species_data in manifest.get("creatures", {}).items():
        meta = CREATURE_META.get(species_id, {})
        display_name = meta.get("name", species_id.capitalize())
        element = meta.get("element", "Desconhecido")
        family = meta.get("family", "unknown")
        animator = meta.get("animator", "Generic")

        lines.append(f"	{species_id} = {{")
        lines.append(f'		Species = "{species_id}",')
        lines.append(f'		DisplayName = "{display_name}",')
        lines.append(f'		Element = "{element}",')
        lines.append(f'		Family = "{family}",')
        lines.append("		Stages = {")

        for stage_str, stage_data in species_data.get("stages", {}).items():
            stage = int(stage_str.replace("stage", ""))
            scale = {1: 0.65, 2: 1.0, 3: 1.35}.get(stage, 1.0)

            lines.append(f"			[{stage}] = {{")
            lines.append("				Parts = {")

            parts = stage_data.get("parts", [])
            for part_name in sorted(parts):
                # Generate placeholder data - real data comes from FBX import
                lod0 = f"rbxassetid://{species_id}_stage{stage}_{part_name}_LOD0"
                lod1 = f"rbxassetid://{species_id}_stage{stage}_{part_name}_LOD1"
                lod2 = f"rbxassetid://{species_id}_stage{stage}_{part_name}_LOD2"

                # Determine material from part name
                material = "SmoothPlastic"
                if "Wing" in part_name or "Tail" in part_name and "Tip" in part_name:
                    material = "Neon"
                elif "Crystal" in part_name or "Gem" in part_name:
                    material = "Glass"
                elif "Slate" in part_name or "Mineral" in part_name:
                    material = "Slate"

                lines.append(f"					{part_name} = {{")
                lines.append(f'						MeshId = "{lod0}",')
                lines.append(f'						LOD1MeshId = "{lod1}",')
                lines.append(f'						LOD2MeshId = "{lod2}",')
                lines.append("						Size = { 1, 1, 1 }, -- Placeholder, updated on import")
                lines.append("						CFrame = { 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 }, -- Placeholder")
                lines.append("						Color = { 0.5, 0.5, 0.5 }, -- Placeholder")
                lines.append(f'						Material = "{material}",')
                lines.append("						Transparency = 0,")
                lines.append("					},")

            lines.append("				},")
            lines.append(f'				AnimatorType = "{animator}",')
            lines.append(f"				Scale = {scale},")
            lines.append("				Bounds = { Min = { -5, -5, -5 }, Max = { 5, 5, 5 } }, -- Placeholder")
            lines.append("			},")

        lines.append("		},")
        lines.append('		RigTemplate = "CreatureRig_v1",')
        lines.append("		ExportVersion = 1,")
        lines.append(f"		ExportTimestamp = {manifest.get('timestamp', 0)},")
        lines.append("	},")

    lines.append("}")
    lines.append("")
    lines.append("BlenderModels.MeshIdMap = {} -- Populated after Roblox upload")
    lines.append("")

    # Add helper functions (same as BlenderModels.luau)
    lines.append("""function BlenderModels.GetCreature(speciesId: string): CreatureData?
	return BlenderModels.Creatures[speciesId]
end

function BlenderModels.GetStage(speciesId: string, stage: number): CreatureStageData?
	local creature = BlenderModels.Creatures[speciesId]
	if not creature then return nil end
	return creature.Stages[stage]
end

function BlenderModels.GetPart(speciesId: string, stage: number, partName: string): MeshPartData?
	local stageData = BlenderModels.GetStage(speciesId, stage)
	if not stageData then return nil end
	return stageData.Parts[partName]
end

function BlenderModels.GetMeshId(speciesId: string, stage: number, partName: string, lod: number?): string?
	local part = BlenderModels.GetPart(speciesId, stage, partName)
	if not part then return nil end

	lod = lod or 0
	if lod == 1 and part.LOD1MeshId then
		return part.LOD1MeshId
	elseif lod == 2 and part.LOD2MeshId then
		return part.LOD2MeshId
	end
	return part.MeshId
end

function BlenderModels.ListSpecies(): { string }
	local species = {}
	for id, _ in BlenderModels.Creatures do
		table.insert(species, id)
	end
	table.sort(species)
	return species
end

function BlenderModels.ListStages(speciesId: string): { number }
	local creature = BlenderModels.Creatures[speciesId]
	if not creature then return {} end

	local stages = {}
	for stage, _ in creature.Stages do
		table.insert(stages, stage)
	end
	table.sort(stages)
	return stages
end

function BlenderModels.GetPartsForStage(speciesId: string, stage: number): { string }
	local stageData = BlenderModels.GetStage(speciesId, stage)
	if not stageData then return {} end

	local parts = {}
	for partName, _ in stageData.Parts do
		table.insert(parts, partName)
	end
	table.sort(parts)
	return parts
end

function BlenderModels.Validate(): { valid: boolean, errors: { string } }
	local errors = {}

	for speciesId, creature in BlenderModels.Creatures do
		if creature.Species ~= speciesId then
			table.insert(errors, string.format("Species ID mismatch: key=%s, data=%s", speciesId, creature.Species))
		end

		if not creature.Stages or next(creature.Stages) == nil then
			table.insert(errors, string.format("Species %s has no stages", speciesId))
		end

		for stage, stageData in creature.Stages do
			if not stageData.Parts or next(stageData.Parts) == nil then
				table.insert(errors, string.format("Species %s stage %d has no parts", speciesId, stage))
			end

			for partName, partData in stageData.Parts do
				if not partData.MeshId or partData.MeshId == "" then
					table.insert(errors, string.format("Part %s_%s_%s missing MeshId", speciesId, stage, partName))
				end

				if not partData.Size or #partData.Size ~= 3 then
					table.insert(errors, string.format("Part %s_%s_%s invalid Size", speciesId, stage, partName))
				end

				if not partData.CFrame or #partData.CFrame ~= 12 then
					table.insert(errors, string.format("Part %s_%s_%s invalid CFrame", speciesId, stage, partName))
				end

				if not partData.Color or #partData.Color ~= 3 then
					table.insert(errors, string.format("Part %s_%s_%s invalid Color", speciesId, stage, partName))
				end

				if not partData.Material or partData.Material == "" then
					table.insert(errors, string.format("Part %s_%s_%s missing Material", speciesId, stage, partName))
				end
			end
		end
	end

	return { valid = #errors == 0, errors = errors }
end

return BlenderModels""")

    return "\n".join(lines)

def main():
    if not MANIFEST_PATH.exists():
        print(f"Manifest not found: {MANIFEST_PATH}")
        print("Run scripts/blender/export_creatures.py first to generate the manifest.")
        sys.exit(1)

    with open(MANIFEST_PATH, 'r') as f:
        manifest = json.load(f)

    lua_content = generate_lua(manifest)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(lua_content, encoding="utf-8")

    print(f"Generated {OUTPUT_PATH}")
    print(f"Species: {len(manifest.get('creatures', {}))}")

if __name__ == "__main__":
    main()