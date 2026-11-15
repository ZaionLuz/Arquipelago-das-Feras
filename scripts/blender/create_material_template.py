#!/usr/bin/env python3
"""
Create material_template.blend - Material setup for Roblox (SmoothPlastic + Neon + Glass)
Run in Blender: blender -b --python scripts/blender/create_material_template.py
"""

import bpy
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[3]
TEMPLATE_PATH = PROJECT_ROOT / "scripts" / "blender" / "material_template.blend"

def clean_scene():
    """Remove all objects from the scene."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)

def create_material(name: str, base_color: tuple, material_type: str = "SmoothPlastic",
                    emission_color: tuple = None, emission_strength: float = 0.0,
                    alpha: float = 1.0) -> bpy.types.Material:
    """Create a material matching Roblox material types."""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links

    # Clear default nodes
    for node in nodes:
        nodes.remove(node)

    # Create output node
    output = nodes.new(type='ShaderNodeOutputMaterial')
    output.location = (400, 0)

    if material_type == "Neon":
        # Pure emission for Neon
        emission = nodes.new(type='ShaderNodeEmission')
        emission.location = (0, 0)
        emission.inputs['Color'].default_value = (*(emission_color or base_color), alpha)
        emission.inputs['Strength'].default_value = emission_strength
        links.new(emission.outputs['Emission'], output.inputs['Surface'])

        # Also add a Principled BSDF for viewport display
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, -200)
        bsdf.inputs['Base Color'].default_value = (*base_color, alpha)
        bsdf.inputs['Emission Color'].default_value = (*(emission_color or base_color), 1.0)
        bsdf.inputs['Emission Strength'].default_value = emission_strength
        bsdf.inputs['Roughness'].default_value = 0.0
        bsdf.inputs['Metallic'].default_value = 0.0

    elif material_type == "Glass":
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs['Base Color'].default_value = (*base_color, alpha)
        bsdf.inputs['Roughness'].default_value = 0.0
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.5
        bsdf.inputs['Transmission'].default_value = 0.9
        bsdf.inputs['Alpha'].default_value = 0.3
        bsdf.inputs['IOR'].default_value = 1.5
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

        mat.blend_method = 'BLENDED'
        mat.shadow_method = 'HASHED'
        mat.use_screen_refraction = True

    elif material_type == "Slate":
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs['Base Color'].default_value = (*base_color, alpha)
        bsdf.inputs['Roughness'].default_value = 0.9
        bsdf.inputs['Metallic'].default_value = 0.1
        bsdf.inputs['Specular'].default_value = 0.2
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    elif material_type == "Fabric":
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs['Base Color'].default_value = (*base_color, alpha)
        bsdf.inputs['Roughness'].default_value = 0.95
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.1
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    else:  # SmoothPlastic (default)
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs['Base Color'].default_value = (*base_color, alpha)
        bsdf.inputs['Roughness'].default_value = 0.7
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.3
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    # Add vertex color attribute input for palette-driven colors
    vc = nodes.new(type='ShaderNodeAttribute')
    vc.location = (-300, 0)
    vc.attribute_name = "Col"
    links.new(vc.outputs['Color'], bsdf.inputs['Base Color'])

    # Add custom properties for Roblox export
    mat["roblox_material"] = material_type
    mat["vertex_color_attr"] = "Col"
    if material_type == "Neon":
        mat["emission_strength"] = emission_strength

    return mat

def create_palette_materials():
    """Create materials for each color in the ArtTokens palette."""
    # ArtTokens palette colors (from the Lua file)
    ramps = {
        "Ember": [0x3D2948, 0x79384B, 0xBD5750, 0xED9765, 0xFFD6A0],
        "Tidal": [0x253B57, 0x356580, 0x489BBA, 0x80CFCC, 0xC6EBCF],
        "Leaf": [0x293E4B, 0x416358, 0x61966B, 0x9FC477, 0xDDE7AA],
        "Sand": [0x453A54, 0x7C5860, 0xAD8270, 0xD8B482, 0xF4D9A0],
        "Sky": [0x333B63, 0x576392, 0x849AC3, 0xB1CEE0, 0xEBE9D6],
        "Veil": [0x302D4F, 0x55446E, 0x866594, 0xB293BC, 0xE3BCD0],
        "Metal": [0x273746, 0x4C6573, 0x7B969E, 0xB2BFB4, 0xE8DEC3],
        "Rose": [0x482E4E, 0x824862, 0xB97588, 0xE3A3A1, 0xFAD7BD],
    }

    neutrals = [0x192B36, 0x283C46, 0x3B5159, 0x587078, 0x8C9D9C, 0xB7C5B8, 0xDEDAC0, 0xFFF0CF]

    def hex_to_rgb(hex_val):
        r = (hex_val >> 16) & 0xFF
        g = (hex_val >> 8) & 0xFF
        b = hex_val & 0xFF
        return (r / 255.0, g / 255.0, b / 255.0)

    # Create materials for each ramp
    for ramp_name, colors in ramps.items():
        for i, hex_val in enumerate(colors):
            rgb = hex_to_rgb(hex_val)
            # SmoothPlastic version
            create_material(f"{ramp_name}_{i}_SmoothPlastic", rgb, "SmoothPlastic")
            # Neon version (for elemental accents)
            create_material(f"{ramp_name}_{i}_Neon", rgb, "Neon", rgb, 5.0)

    # Neutral materials
    for i, hex_val in enumerate(neutrals):
        rgb = hex_to_rgb(hex_val)
        create_material(f"Neutral_{i}_SmoothPlastic", rgb, "SmoothPlastic")

    # Special materials
    create_material("Glass_Crystal", (0.7, 0.85, 1.0), "Glass")
    create_material("Glass_Gem", (0.5, 0.7, 1.0), "Glass")
    create_material("Slate_Mineral", hex_to_rgb(0x273746), "Slate")
    create_material("Fabric_Spectral", hex_to_rgb(0x302D4F), "Fabric")

def create_demo_scene():
    """Create a demo scene showing all materials."""
    # Create a grid of spheres, each with a different material
    materials = [m for m in bpy.data.materials if m.name.endswith(("_SmoothPlastic", "_Neon", "_Crystal", "_Gem", "_Mineral", "_Spectral"))]

    cols = 10
    for i, mat in enumerate(materials):
        row = i // cols
        col = i % cols

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.4, segments=16, ring_count=8)
        obj = bpy.context.active_object
        obj.name = f"Demo_{mat.name}"
        obj.location = (col * 1.0, -row * 1.0, 0)

        if obj.data.materials:
            obj.data.materials[0] = mat
        else:
            obj.data.materials.append(mat)

        # Add vertex colors
        if not obj.data.vertex_colors:
            vc = obj.data.vertex_colors.new(name="Col")
        else:
            vc = obj.data.vertex_colors["Col"]

        # Use material's base color for vertex colors
        base_color = mat.node_tree.nodes.get("Principled BSDF")
        if base_color:
            color = base_color.inputs['Base Color'].default_value
            for poly in obj.data.polygons:
                for loop_idx in poly.loop_indices:
                    vc.data[loop_idx].color = color

def main():
    clean_scene()
    create_palette_materials()
    create_demo_scene()

    TEMPLATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(TEMPLATE_PATH))
    print(f"Saved material template to {TEMPLATE_PATH}")
    print(f"Created {len(bpy.data.materials)} materials")

if __name__ == "__main__":
    main()