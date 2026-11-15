"""
ArtTokens Color Palettes for Arquipelago Starters
Ember (Fire), Tidal (Water), Leaf (Nature)
Each ramp has 7 colors + emission variants for bright accents
"""

import bpy
from mathutils import Color


EMBER_RAMP = {
    "charcoal": (0.08, 0.06, 0.05, 1.0),
    "cinder": (0.18, 0.10, 0.06, 1.0),
    "smolder": (0.35, 0.15, 0.05, 1.0),
    "ember": (0.75, 0.30, 0.08, 1.0),
    "flare": (0.95, 0.55, 0.12, 1.0),
    "blaze": (1.0, 0.75, 0.25, 1.0),
    "white_hot": (1.0, 0.95, 0.70, 1.0),
}

TIDAL_RAMP = {
    "abyss": (0.02, 0.05, 0.12, 1.0),
    "deep": (0.05, 0.12, 0.25, 1.0),
    "trench": (0.08, 0.22, 0.40, 1.0),
    "tidal": (0.12, 0.45, 0.70, 1.0),
    "wave": (0.25, 0.70, 0.95, 1.0),
    "foam": (0.55, 0.90, 1.0, 1.0),
    "prism": (0.85, 1.0, 1.0, 1.0),
}

LEAF_RAMP = {
    "loam": (0.06, 0.08, 0.03, 1.0),
    "moss_dark": (0.10, 0.18, 0.06, 1.0),
    "moss": (0.18, 0.35, 0.10, 1.0),
    "leaf": (0.28, 0.65, 0.18, 1.0),
    "sprout": (0.50, 0.85, 0.30, 1.0),
    "bloom": (0.75, 1.0, 0.50, 1.0),
    "vitality": (0.95, 1.0, 0.80, 1.0),
}


def create_material(name, base_color, roughness=0.7, metallic=0.0, emission_strength=0.0, emission_color=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    
    nodes.clear()
    
    output = nodes.new(type='ShaderNodeOutputMaterial')
    output.location = (400, 0)
    
    principled = nodes.new(type='ShaderNodeBsdfPrincipled')
    principled.location = (0, 0)
    principled.inputs['Base Color'].default_value = base_color
    principled.inputs['Roughness'].default_value = roughness
    principled.inputs['Metallic'].default_value = metallic
    principled.inputs['Specular'].default_value = 0.3
    
    if emission_strength > 0:
        if emission_color is None:
            emission_color = base_color
        principled.inputs['Emission Color'].default_value = (*emission_color[:3], 1.0)
        principled.inputs['Emission Strength'].default_value = emission_strength
    
    links.new(principled.outputs['BSDF'], output.inputs['Surface'])
    
    mat.blend_method = 'OPAQUE'
    mat.shadow_method = 'OPAQUE'
    
    return mat


def get_ember_materials():
    return {
        "Ember_Charcoal": create_material("Ember_Charcoal", EMBER_RAMP["charcoal"], roughness=0.9),
        "Ember_Cinder": create_material("Ember_Cinder", EMBER_RAMP["cinder"], roughness=0.8),
        "Ember_Smolder": create_material("Ember_Smolder", EMBER_RAMP["smolder"], roughness=0.7),
        "Ember_Core": create_material("Ember_Core", EMBER_RAMP["ember"], roughness=0.6),
        "Ember_Flare": create_material("Ember_Flare", EMBER_RAMP["flare"], roughness=0.5, emission_strength=1.5, emission_color=EMBER_RAMP["flare"]),
        "Ember_Blaze": create_material("Ember_Blaze", EMBER_RAMP["blaze"], roughness=0.4, emission_strength=3.0, emission_color=EMBER_RAMP["blaze"]),
        "Ember_WhiteHot": create_material("Ember_WhiteHot", EMBER_RAMP["white_hot"], roughness=0.3, emission_strength=6.0, emission_color=EMBER_RAMP["white_hot"]),
    }


def get_tidal_materials():
    return {
        "Tidal_Abyss": create_material("Tidal_Abyss", TIDAL_RAMP["abyss"], roughness=0.8),
        "Tidal_Deep": create_material("Tidal_Deep", TIDAL_RAMP["deep"], roughness=0.7),
        "Tidal_Trench": create_material("Tidal_Trench", TIDAL_RAMP["trench"], roughness=0.6),
        "Tidal_Core": create_material("Tidal_Core", TIDAL_RAMP["tidal"], roughness=0.5),
        "Tidal_Wave": create_material("Tidal_Wave", TIDAL_RAMP["wave"], roughness=0.4, emission_strength=1.2, emission_color=TIDAL_RAMP["wave"]),
        "Tidal_Foam": create_material("Tidal_Foam", TIDAL_RAMP["foam"], roughness=0.3, emission_strength=2.5, emission_color=TIDAL_RAMP["foam"]),
        "Tidal_Prism": create_material("Tidal_Prism", TIDAL_RAMP["prism"], roughness=0.2, emission_strength=4.0, emission_color=TIDAL_RAMP["prism"]),
    }


def get_leaf_materials():
    return {
        "Leaf_Loam": create_material("Leaf_Loam", LEAF_RAMP["loam"], roughness=0.9),
        "Leaf_MossDark": create_material("Leaf_MossDark", LEAF_RAMP["moss_dark"], roughness=0.8),
        "Leaf_Moss": create_material("Leaf_Moss", LEAF_RAMP["moss"], roughness=0.7),
        "Leaf_Core": create_material("Leaf_Core", LEAF_RAMP["leaf"], roughness=0.6),
        "Leaf_Sprout": create_material("Leaf_Sprout", LEAF_RAMP["sprout"], roughness=0.5, emission_strength=1.0, emission_color=LEAF_RAMP["sprout"]),
        "Leaf_Bloom": create_material("Leaf_Bloom", LEAF_RAMP["bloom"], roughness=0.4, emission_strength=2.0, emission_color=LEAF_RAMP["bloom"]),
        "Leaf_Vitality": create_material("Leaf_Vitality", LEAF_RAMP["vitality"], roughness=0.3, emission_strength=3.5, emission_color=LEAF_RAMP["vitality"]),
    }


if __name__ == "__main__":
    mats = get_ember_materials()
    for name, mat in mats.items():
        print(f"Created: {name}")
    mats = get_tidal_materials()
    for name, mat in mats.items():
        print(f"Created: {name}")
    mats = get_leaf_materials()
    for name, mat in mats.items():
        print(f"Created: {name}")
