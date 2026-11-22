"""
Creature Pipeline - Arquipélago das Feras
Blender -> Roblox | Nivel Palworld
Uso: exec(open(pipeline_path).read()) no Blender
"""

import bpy
import bmesh
from mathutils import Vector, Euler, Matrix
import math
import random
import os

# ============================================================
# CONFIGURACOES GLOBAIS - 30 CRIATURAS IMPLEMENTADAS
# ============================================================

CREATURE_SPECS = {
    # FAMILIA FOGO
    "cinzelo": {
        "element": "fire", "rarity": "common",
        "body_type": "coal_ember",
        "scale": 1.0, "height": 1.2,
        "colors": {"body": (0.1, 0.05, 0.03), "glow": (1.0, 0.4, 0.0)},
        "features": ["dorsal_plates", "embers", "small_tail"],
        "personality": "curious"
    },
    "magmarau": {
        "element": "fire", "rarity": "rare",
        "body_type": "volcanic_beast",
        "scale": 1.3, "height": 1.5,
        "colors": {"body": (0.15, 0.08, 0.04), "glow": (1.0, 0.5, 0.1)},
        "features": ["mineral_fangs", "lava_veins", "rock_plates", "thick_tail"],
        "personality": "protective"
    },
    "fenixfuligem": {
        "element": "fire", "rarity": "epic",
        "body_type": "ash_bird",
        "scale": 1.1, "height": 1.3,
        "colors": {"body": (0.12, 0.1, 0.1), "glow": (1.0, 0.6, 0.0)},
        "features": ["ash_feathers", "ember_crest", "wings", "triple_tail"],
        "personality": "observant"
    },
    "vulcanodrago": {
        "element": "fire", "rarity": "legendary",
        "body_type": "basalt_dragon",
        "scale": 1.8, "height": 2.2,
        "colors": {"body": (0.08, 0.06, 0.06), "glow": (1.0, 0.3, 0.0)},
        "features": ["basalt_plates", "magma_core", "wings", "long_tail", "horns"],
        "personality": "territorial"
    },
    
    # FAMILIA AGUA
    "bolhinho": {
        "element": "water", "rarity": "common",
        "body_type": "bubble_amphibian",
        "scale": 0.9, "height": 0.9,
        "colors": {"body": (0.2, 0.5, 0.9), "glow": (0.4, 0.8, 1.0)},
        "features": ["bubble_skin", "gills", "round_body", "webbed_feet"],
        "personality": "playful"
    },
    "marilisco": {
        "element": "water", "rarity": "rare",
        "body_type": "sea_serpent",
        "scale": 1.4, "height": 0.6,
        "colors": {"body": (0.1, 0.3, 0.7), "glow": (0.3, 0.7, 1.0)},
        "features": ["high_fins", "coral_rest", "streamlined", "whiskers"],
        "personality": "reserved"
    },
    "carangueperola": {
        "element": "water", "rarity": "epic",
        "body_type": "pearl_crustacean",
        "scale": 1.2, "height": 1.0,
        "colors": {"body": (0.9, 0.9, 1.0), "glow": (0.8, 0.9, 1.0)},
        "features": ["pearl_shell", "rounded_claws", "pearl_accents", "iridescent"],
        "personality": "cautious"
    },
    "abissauro": {
        "element": "water", "rarity": "legendary",
        "body_type": "abyssal_reptile",
        "scale": 2.0, "height": 1.5,
        "colors": {"body": (0.02, 0.05, 0.15), "glow": (0.0, 0.5, 1.0)},
        "features": ["bioluminescent_lure", "deep_pressure_body", "transparent_fins", "long_tail"],
        "personality": "patient"
    },
    
    # FAMILIA NATUREZA
    "brotinho": {
        "element": "nature", "rarity": "common",
        "body_type": "living_sprout",
        "scale": 0.7, "height": 0.7,
        "colors": {"body": (0.2, 0.6, 0.2), "glow": (0.4, 1.0, 0.3)},
        "features": ["leaf_head", "opening_leaves", "root_feet", "tiny_flowers"],
        "personality": "affectionate"
    },
    "folhuco": {
        "element": "nature", "rarity": "rare",
        "body_type": "leafy_beast",
        "scale": 1.1, "height": 1.2,
        "colors": {"body": (0.15, 0.5, 0.2), "glow": (0.3, 0.9, 0.3)},
        "features": ["vegetal_ears", "vine_body", "camouflage_leaves", "alert_posture"],
        "personality": "alert"
    },
    "aracnoflora": {
        "element": "nature", "rarity": "epic",
        "body_type": "plant_arachnid",
        "scale": 1.3, "height": 0.9,
        "colors": {"body": (0.2, 0.4, 0.15), "glow": (0.5, 1.0, 0.2)},
        "features": ["petal_legs", "flower_camouflage", "8_legs", "pollen_cloud"],
        "personality": "shy"
    },
    "ancestravore": {
        "element": "nature", "rarity": "legendary",
        "body_type": "arboreal_guardian",
        "scale": 2.2, "height": 2.5,
        "colors": {"body": (0.1, 0.35, 0.1), "glow": (0.3, 0.8, 0.2)},
        "features": ["ancient_branches", "canopy_wings", "root_feet", "moss_beard", "glowing_fruit"],
        "personality": "serene"
    },
    
    # FAMILIA TERRA
    "graozinho": {
        "element": "earth", "rarity": "common",
        "body_type": "living_geode",
        "scale": 0.8, "height": 0.8,
        "colors": {"body": (0.4, 0.35, 0.3), "glow": (0.8, 0.6, 0.2)},
        "features": ["stone_shell", "pulsing_core", "crystal_facets", "stubby_legs"],
        "personality": "persistent"
    },
    "escorpiodra": {
        "element": "earth", "rarity": "rare",
        "body_type": "dune_arthropod",
        "scale": 1.2, "height": 0.7,
        "colors": {"body": (0.5, 0.4, 0.3), "glow": (0.9, 0.7, 0.3)},
        "features": ["long_carapace", "mineral_tail", "sand_camouflage", "pincers"],
        "personality": "defensive"
    },
    "esfingeolito": {
        "element": "earth", "rarity": "epic",
        "body_type": "ruin_beast",
        "scale": 1.5, "height": 1.6,
        "colors": {"body": (0.45, 0.4, 0.35), "glow": (1.0, 0.8, 0.4)},
        "features": ["ceremonial_posture", "ruin_adornments", "sandstone_body", "hieroglyph_glow"],
        "personality": "proud"
    },
    "colossodune": {
        "element": "earth", "rarity": "legendary",
        "body_type": "sandstone_golem",
        "scale": 2.5, "height": 3.0,
        "colors": {"body": (0.55, 0.5, 0.4), "glow": (1.0, 0.9, 0.5)},
        "features": ["monumental_size", "luminous_marks", "dune_stride", "core_heart"],
        "personality": "calm"
    },
    
    # FAMILIA AR
    "penugem": {
        "element": "air", "rarity": "common",
        "body_type": "down_bird",
        "scale": 0.6, "height": 0.7,
        "colors": {"body": (0.9, 0.9, 0.95), "glow": (1.0, 1.0, 1.0)},
        "features": ["big_head", "fluffy_feathers", "tiny_beak", "cloud_trail"],
        "personality": "sociable"
    },
    "ventanil": {
        "element": "air", "rarity": "rare",
        "body_type": "current_bird",
        "scale": 1.0, "height": 1.1,
        "colors": {"body": (0.7, 0.85, 1.0), "glow": (0.8, 0.95, 1.0)},
        "features": ["ribbon_feathers", "streamlined", "wind_aura", "long_tail_feathers"],
        "personality": "restless"
    },
    "trovoraptor": {
        "element": "air", "rarity": "epic",
        "body_type": "storm_reptile",
        "scale": 1.4, "height": 1.3,
        "colors": {"body": (0.3, 0.4, 0.6), "glow": (0.6, 0.8, 1.0)},
        "features": ["angular_crest", "lightning_feathers", "storm_aura", "electric_eyes"],
        "personality": "impulsive"
    },
    "aeronimbo": {
        "element": "air", "rarity": "legendary",
        "body_type": "cloud_serpent",
        "scale": 2.0, "height": 1.0,
        "colors": {"body": (0.8, 0.85, 0.95), "glow": (1.0, 1.0, 1.0)},
        "features": ["cloud_formations", "long_body", "weather_control", "nimbus_trail"],
        "personality": "distracted"
    },
    
    # FAMILIA SOMBRA
    "lodinho": {
        "element": "shadow", "rarity": "common",
        "body_type": "slime_spirit",
        "scale": 0.5, "height": 0.5,
        "colors": {"body": (0.15, 0.2, 0.15), "glow": (0.3, 0.5, 0.3)},
        "features": ["moss_tufts", "rounded", "ooze_trail", "big_eyes"],
        "personality": "docile"
    },
    "caudalume": {
        "element": "shadow", "rarity": "rare",
        "body_type": "lantern_serpent",
        "scale": 1.3, "height": 0.5,
        "colors": {"body": (0.1, 0.1, 0.15), "glow": (0.6, 0.5, 0.9)},
        "features": ["lantern_tail", "guide_light", "slender", "mist_walker"],
        "personality": "attentive"
    },
    "vagalumorte": {
        "element": "shadow", "rarity": "epic",
        "body_type": "luminescent_insect",
        "scale": 0.9, "height": 0.8,
        "colors": {"body": (0.05, 0.05, 0.1), "glow": (0.8, 0.7, 1.0)},
        "features": ["dark_carapace", "moonlight_glow", "wings", "nocturnal_aura"],
        "personality": "nocturnal"
    },
    "reinevoento": {
        "element": "shadow", "rarity": "legendary",
        "body_type": "crowned_spirit",
        "scale": 2.0, "height": 2.2,
        "colors": {"body": (0.08, 0.08, 0.12), "glow": (0.5, 0.4, 0.8)},
        "features": ["fog_mantle", "crown", "floating", "mystery_aura", "void_eyes"],
        "personality": "enigmatic"
    },
}

# ============================================================
# BODY TYPE GENERATORS MAP
# ============================================================

BODY_GENERATORS = {
    "coal_ember": "create_coal_ember_body",
    "volcanic_beast": "create_volcanic_beast_body",
    "ash_bird": "create_ash_bird_body",
    "basalt_dragon": "create_basalt_dragon_body",
    "bubble_amphibian": "create_bubble_amphibian_body",
    "sea_serpent": "create_sea_serpent_body",
    "pearl_crustacean": "create_pearl_crustacean_body",
    "abyssal_reptile": "create_abyssal_reptile_body",
    "living_sprout": "create_living_sprout_body",
    "leafy_beast": "create_leafy_beast_body",
    "plant_arachnid": "create_plant_arachnid_body",
    "arboreal_guardian": "create_arboreal_guardian_body",
    "living_geode": "create_living_geode_body",
    "dune_arthropod": "create_dune_arthropod_body",
    "ruin_beast": "create_ruin_beast_body",
    "sandstone_golem": "create_sandstone_golem_body",
    "down_bird": "create_down_bird_body",
    "current_bird": "create_current_bird_body",
    "storm_reptile": "create_storm_reptile_body",
    "cloud_serpent": "create_cloud_serpent_body",
    "slime_spirit": "create_slime_spirit_body",
    "lantern_serpent": "create_lantern_serpent_body",
    "luminescent_insect": "create_luminescent_insect_body",
    "crowned_spirit": "create_crowned_spirit_body",
}

# ============================================================
# PIPELINE FUNCTIONS (Stubs - implementar conforme necessario)
# ============================================================

def setup_collections(creature_id):
    """Cria colecoes organizadas para a criatura"""
    cols = {}
    for suffix in ['_HIGH', '_LOW', '_RIG', '_UV', '_TEX', '_EXPORT']:
        name = f"{creature_id.upper()}{suffix}"
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
        cols[name] = col
    return cols

def link_to_collection(obj, col_name, collections):
    for col in obj.users_collection:
        col.objects.unlink(obj)
    collections[col_name].objects.link(obj)

def generate_creature(creature_id, output_folder):
    """Pipeline completo para uma criatura"""
    spec = CREATURE_SPECS[creature_id]
    print(f"\n{'='*60}")
    print(f"GERANDO: {creature_id.upper()} ({spec['element']}/{spec['rarity']})")
    print(f"{'='*60}")
    
    collections = setup_collections(creature_id)
    
    # TODO: Implementar cada etapa
    # 1. High-poly procedural
    # 2. Retopologia
    # 3. UV Unwrap
    # 4. Materiais PBR
    # 5. Baking setup
    # 6. Rigging R15
    # 7. Shape Keys 3 estagios
    # 8. Export FBX
    
    print(f"✅ {creature_id} pipeline structure ready!")

def generate_all_creatures(output_base=r"C:\Users\Zaion Araujo\CREATURES_EXPORT"):
    """Gera todas as 30 criaturas implementadas"""
    os.makedirs(output_base, exist_ok=True)
    
    for creature_id in CREATURE_SPECS.keys():
        creature_folder = os.path.join(output_base, creature_id.upper())
        os.makedirs(creature_folder, exist_ok=True)
        try:
            generate_creature(creature_id, creature_folder)
        except Exception as e:
            print(f"❌ Erro em {creature_id}: {e}")
    
    print("\n🎉 TODAS CRIATURAS ESTRUTURADAS!")

if __name__ == "__main__":
    print("Pipeline carregado.")
    print("Use: generate_creature('magmarau', 'pasta')")
    print("Ou: generate_all_creatures()")
