#!/usr/bin/env python3
"""
Blender → Roblox Pipeline: Export Creatures as FBX
Exports all creature models from Blender with proper naming, hierarchy, materials, and LODs.
Requires: Blender 4.0+, bpy
Usage: blender -b --python scripts/blender/export_creatures.py -- <output_dir>
"""

import bpy
import os
import sys
import json
import math
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# ─── Configuration ──────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).resolve().parents[3]  # Arquipelago root
CREATURES_SOURCE = PROJECT_ROOT / "src" / "shared" / "CreatureDesigns.luau"
ART_TOKENS_SOURCE = PROJECT_ROOT / "src" / "shared" / "ArtTokens.luau"
EXPORT_DIR = PROJECT_ROOT / "assets" / "fbx"
LOD_LEVELS = {
    "LOD0": 1.0,   # Full detail
    "LOD1": 0.5,   # 50% triangles
    "LOD2": 0.25,  # 25% triangles
}

# Scale: 1 Blender unit = 1 stud
UNIT_SCALE = 1.0

# Naming convention: {species}_{stage}_{part}
# Hierarchy: Root → Body → Head/Neck → Limbs → Tail/Wings
# Motor6D joints: J_Body, J_Head, J_Leg1, J_WingL, etc.
# Materials: SmoothPlastic base, Neon for elemental accents, Glass for crystals
# Texture: Vertex colors only (palette from ArtTokens), no external textures

# ─── Utility Functions ──────────────────────────────────────────────────────────

def hex_to_rgb(hex_val: int) -> Tuple[float, float, float]:
    """Convert hex color to normalized RGB tuple."""
    r = (hex_val >> 16) & 0xFF
    g = (hex_val >> 8) & 0xFF
    b = hex_val & 0xFF
    return (r / 255.0, g / 255.0, b / 255.0)

def parse_luau_designs(lua_path: Path) -> Dict:
    """Parse CreatureDesigns.luau to extract creature definitions."""
    import re
    content = lua_path.read_text(encoding="utf-8")

    # Extract the rows table
    rows_match = re.search(r'local rows = \{(.*?)\n\}', content, re.DOTALL)
    if not rows_match:
        raise ValueError("Could not find rows table in CreatureDesigns.luau")

    rows_content = rows_match.group(1)

    creatures = {}
    # Parse each creature entry
    # Format: {"id", "family", "head", "eyes", "tail", limbs, "trait", "surface", {dimensions}, {colors}}
    pattern = r'\{\s*"([^"]+)",\s*"([^"]+)",\s*"([^"]+)",\s*"([^"]+)",\s*"([^"]+)",\s*(\d+),\s*"([^"]+)",\s*"([^"]+)",\s*\{([^}]+)\},\s*\{([^}]+)\}'

    for match in re.finditer(pattern, rows_content):
        species_id, family, head, eyes, tail, limbs, trait, surface, dims_str, colors_str = match.groups()

        dimensions = [float(x.strip()) for x in dims_str.split(",")]
        colors = [int(x.strip(), 0) for x in colors_str.split(",")]

        creatures[species_id] = {
            "id": species_id,
            "family": family,
            "head": head,
            "eyes": eyes,
            "tail": tail,
            "limbs": int(limbs),
            "trait": trait,
            "surface": surface,
            "dimensions": dimensions,
            "palette": [hex_to_rgb(c) for c in colors],
        }

    return creatures

def parse_art_tokens(lua_path: Path) -> Dict:
    """Parse ArtTokens.luau to extract element ramps and materials."""
    import re
    content = lua_path.read_text(encoding="utf-8")

    tokens = {"ramps": {}, "elements": {}}

    # Extract ramps
    ramps_match = re.search(r'local ramps = \{(.*?)\n\}', content, re.DOTALL)
    if ramps_match:
        ramps_content = ramps_match.group(1)
        ramp_pattern = r'(\w+)\s*=\s*\{([^}]+)\}'
        for match in re.finditer(ramp_pattern, ramps_content):
            name, colors_str = match.groups()
            colors = [int(x.strip(), 0) for x in colors_str.split(",")]
            tokens["ramps"][name] = [hex_to_rgb(c) for c in colors]

    # Extract Elements mapping
    elements_match = re.search(r'T\.Elements = \{(.*?)\n\}', content, re.DOTALL)
    if elements_match:
        elements_content = elements_match.group(1)
        elem_pattern = r'(\w+)\s*=\s*T\.Ramps\.(\w+)'
        for match in re.finditer(elem_pattern, elements_content):
            elem_name, ramp_name = match.groups()
            tokens["elements"][elem_name] = ramp_name

    return tokens

def clean_scene():
    """Remove all objects from the scene."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    # Clean up orphaned data
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)
    for block in bpy.data.armatures:
        if block.users == 0:
            bpy.data.armatures.remove(block)

def create_material(name: str, base_color: Tuple[float, float, float],
                    material_type: str = "SmoothPlastic",
                    emission_color: Optional[Tuple[float, float, float]] = None,
                    emission_strength: float = 0.0,
                    alpha: float = 1.0) -> bpy.types.Material:
    """Create a material matching Roblox material types."""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links

    # Clear default nodes
    for node in nodes:
        nodes.remove(node)

    # Create principled BSDF
    bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf.location = (0, 0)

    # Output
    output = nodes.new(type='ShaderNodeOutputMaterial')
    output.location = (300, 0)
    links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    # Set base color
    bsdf.inputs['Base Color'].default_value = (*base_color, alpha)

    if material_type == "SmoothPlastic":
        bsdf.inputs['Roughness'].default_value = 0.7
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.3
    elif material_type == "Neon":
        bsdf.inputs['Roughness'].default_value = 0.0
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.0
        bsdf.inputs['Emission Strength'].default_value = emission_strength
        if emission_color:
            bsdf.inputs['Emission Color'].default_value = (*emission_color, 1.0)
        # Use emission shader for true neon
        emission = nodes.new(type='ShaderNodeEmission')
        emission.location = (-300, 0)
        emission.inputs['Color'].default_value = (*emission_color, 1.0) if emission_color else (*base_color, 1.0)
        emission.inputs['Strength'].default_value = emission_strength
        links.new(emission.outputs['Emission'], output.inputs['Surface'])
    elif material_type == "Glass":
        bsdf.inputs['Roughness'].default_value = 0.0
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.5
        bsdf.inputs['Transmission'].default_value = 0.9
        bsdf.inputs['Alpha'].default_value = 0.3
        mat.blend_method = 'BLENDED'
        mat.shadow_method = 'HASHED'
    elif material_type == "Slate":
        bsdf.inputs['Roughness'].default_value = 0.9
        bsdf.inputs['Metallic'].default_value = 0.1
        bsdf.inputs['Specular'].default_value = 0.2
    elif material_type == "Fabric":
        bsdf.inputs['Roughness'].default_value = 0.95
        bsdf.inputs['Metallic'].default_value = 0.0
        bsdf.inputs['Specular'].default_value = 0.1

    # Vertex color attribute for palette colors
    vc = nodes.new(type='ShaderNodeAttribute')
    vc.location = (-300, -200)
    vc.attribute_name = "Col"
    links.new(vc.outputs['Color'], bsdf.inputs['Base Color'])

    return mat

def apply_vertex_colors(obj: bpy.types.Object, colors: List[Tuple[float, float, float]],
                        part_name: str, palette: List[Tuple[float, float, float]]):
    """Apply vertex colors from palette to mesh."""
    mesh = obj.data
    if not mesh.vertex_colors:
        vc_layer = mesh.vertex_colors.new(name="Col")
    else:
        vc_layer = mesh.vertex_colors["Col"]

    # Find best matching palette color for this part
    # For now, use the first palette color as base
    base_color = palette[0] if palette else (1.0, 1.0, 1.0)

    # Apply to all loops
    for poly in mesh.polygons:
        for loop_idx in poly.loop_indices:
            vc_layer.data[loop_idx].color = (*base_color, 1.0)

def create_rig_template() -> bpy.types.Object:
    """Create base armature template compatible with Roblox Motor6D."""
    # Create armature
    armature_data = bpy.data.armatures.new("CreatureRig")
    armature_obj = bpy.data.objects.new("Root", armature_data)
    bpy.context.collection.objects.link(armature_obj)

    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode='EDIT')

    bones_data = [
        # (name, head, tail, parent, roll)
        ("Root", (0, 0, 0), (0, 0.1, 0), None, 0),
        ("Body", (0, 0.1, 0), (0, 1.5, 0), "Root", 0),
        ("Head", (0, 1.5, 0), (0, 2.0, 0), "Body", 0),
        ("Neck", (0, 1.5, 0), (0, 2.0, 0), "Body", 0),
        ("Leg1", (0.3, 0.3, 0), (0.3, -0.5, 0), "Body", 0),
        ("Leg2", (-0.3, 0.3, 0), (-0.3, -0.5, 0), "Body", 0),
        ("Leg3", (0.3, 0.3, -1.0), (0.3, -0.5, -1.0), "Body", 0),
        ("Leg4", (-0.3, 0.3, -1.0), (-0.3, -0.5, -1.0), "Body", 0),
        ("WingL", (-0.5, 1.0, 0), (-2.0, 1.5, 0), "Body", 0),
        ("WingR", (0.5, 1.0, 0), (2.0, 1.5, 0), "Body", 0),
        ("Tail1", (0, 0.5, -1.2), (0, 0.3, -2.0), "Body", 0),
        ("Tail2", (0, 0.3, -2.0), (0, 0.2, -2.8), "Tail1", 0),
        ("Tail3", (0, 0.2, -2.8), (0, 0.1, -3.5), "Tail2", 0),
        ("Tail4", (0, 0.1, -3.5), (0, 0.0, -4.0), "Tail3", 0),
    ]

    for name, head, tail, parent_name, roll in bones_data:
        bone = armature_data.edit_bones.new(name)
        bone.head = head
        bone.tail = tail
        bone.roll = roll
        if parent_name:
            bone.parent = armature_data.edit_bones[parent_name]
            bone.use_connect = True

    bpy.ops.object.mode_set(mode='OBJECT')
    return armature_obj

def create_creature_mesh(species: Dict, stage: int) -> bpy.types.Object:
    """Create a creature mesh based on design data."""
    # This is a simplified version - in reality, you'd model each creature in Blender
    # For the pipeline, we create proxy geometry that matches the Roblox parts

    palette = species["palette"]
    dims = species["dimensions"]
    family = species["family"]

    # Create a collection for this creature
    coll_name = f"{species['id']}_stage{stage}"
    if coll_name not in bpy.data.collections:
        collection = bpy.data.collections.new(coll_name)
        bpy.context.scene.collection.children.link(collection)
    else:
        collection = bpy.data.collections[coll_name]

    # Create root object
    root = bpy.data.objects.new("Root", None)
    root.empty_display_size = 0.1
    root.empty_display_type = 'PLAIN_AXES'
    collection.objects.link(root)

    # Scale based on stage
    stage_scales = {1: 0.65, 2: 1.0, 3: 1.35}
    scale = stage_scales.get(stage, 1.0)

    w, h, l = [d * scale for d in dims]

    # Create body parts based on family
    parts = create_body_parts(species, stage, scale, palette, collection, root)

    # Create armature and parent parts
    armature = create_rig_template()
    armature.name = f"Armature_{species['id']}_stage{stage}"
    collection.objects.link(armature)

    # Parent parts to armature with vertex groups
    for part_obj, bone_name in parts:
        # Add armature modifier
        mod = part_obj.modifiers.new(name="Armature", type='ARMATURE')
        mod.object = armature

        # Create vertex group for bone
        vg = part_obj.vertex_groups.new(name=bone_name)
        vg.add(list(range(len(part_obj.data.vertices))), 1.0, 'REPLACE')

    # Parent armature to root
    armature.parent = root

    return root

def create_body_parts(species: Dict, stage: int, scale: float,
                      palette: List, collection: bpy.types.Collection,
                      root: bpy.types.Object) -> List[Tuple[bpy.types.Object, str]]:
    """Create body parts for a creature. Returns list of (object, bone_name)."""
    parts = []
    dims = species["dimensions"]
    w, h, l = [d * scale for d in dims]
    family = species["family"]

    # Materials
    mat_smooth = create_material("SmoothPlastic", palette[0], "SmoothPlastic")
    mat_neon = create_material("Neon", palette[1], "Neon", palette[1], 5.0)
    mat_glass = create_material("Glass", palette[2], "Glass")

    # Body
    body = create_primitive("Body", "SPHERE", (w * 0.9, h * 0.7, l), (0, h * 0.5, 0))
    body.data.materials.append(mat_smooth)
    apply_vertex_colors(body, palette, "Body", palette)
    collection.objects.link(body)
    parts.append((body, "Body"))

    # Head
    head_size = (w * 0.6, h * 0.6, w * 0.6)
    head_pos = (0, h * 1.0, l * 0.5)
    head = create_primitive("Head", "SPHERE", head_size, head_pos)
    head.data.materials.append(mat_smooth)
    apply_vertex_colors(head, palette, "Head", palette)
    collection.objects.link(head)
    parts.append((head, "Head"))

    # Limbs
    limb_count = species["limbs"]
    if family in ["quadruped", "draconic"]:
        limb_count = 4
    elif family == "winged":
        limb_count = 2
    elif family == "biped":
        limb_count = 2
    elif family == "serpentine":
        limb_count = 0
    elif family == "aquatic":
        limb_count = 0
    elif family == "arthropod":
        limb_count = species["limbs"]

    for i in range(limb_count):
        side = -1 if i % 2 == 0 else 1
        pair = i // 2
        z = (pair - (limb_count / 4 - 0.5)) * l * 0.3 if limb_count >= 4 else 0
        x = side * w * 0.4
        y = h * 0.3

        leg = create_primitive(f"Leg{i+1}", "CYLINDER", (0.3, h * 0.6, 0.3), (x, y, z))
        leg.data.materials.append(mat_smooth)
        apply_vertex_colors(leg, palette, f"Leg{i+1}", palette)
        collection.objects.link(leg)
        parts.append((leg, f"Leg{i+1}"))

    # Wings (for winged and draconic families)
    if family in ["winged", "draconic"]:
        wing_count = 5 if stage == 3 else (3 if stage == 2 else 1)
        if species.get("acquisition") == "special":
            wing_count = 8

        for side_mult, side_name in [(-1, "L"), (1, "R")]:
            for row in range(1, (3 if species.get("acquisition") == "special" else 1) + 1):
                for i in range(wing_count):
                    wing = create_primitive(
                        f"Wing{side_name}_{row}_{i+1}", "WEDGE",
                        (0.4, 0.2, 1.5 + i * 0.2),
                        (side_mult * (w * 0.5 + i * 0.5), h * 0.8 - row * 0.1, -row * 0.3 - i * 0.1)
                    )
                    wing_color = palette[min(3, row)]
                    wing_mat = create_material(f"Wing_{row}", wing_color, "SmoothPlastic")
                    if species.get("acquisition") == "special":
                        wing_mat = create_material(f"Wing_{row}_neon", wing_color, "Neon", wing_color, 3.0)
                    wing.data.materials.append(wing_mat)
                    apply_vertex_colors(wing, palette, f"Wing{side_name}_{row}_{i+1}", palette)
                    collection.objects.link(wing)
                    parts.append((wing, f"Wing{side_name}_{row}_{i+1}"))

    # Tail
    tail_count = stage + 1
    if species.get("acquisition") == "special":
        tail_count = 11

    for i in range(tail_count):
        tail = create_primitive(f"Tail{i+1}", "WEDGE" if family == "winged" else "SPHERE",
                               (0.4, 0.3, 1.5 + i * 0.2),
                               (0, h * 0.3, -l * 0.5 - i * 0.5))
        tail.data.materials.append(mat_smooth)
        apply_vertex_colors(tail, palette, f"Tail{i+1}", palette)
        collection.objects.link(tail)
        parts.append((tail, f"Tail{i+1}"))

    return parts

def create_primitive(name: str, prim_type: str, size: Tuple[float, float, float],
                     location: Tuple[float, float, float]) -> bpy.types.Object:
    """Create a primitive mesh object."""
    if prim_type == "SPHERE":
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.5, segments=16, ring_count=8)
    elif prim_type == "CYLINDER":
        bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=1)
    elif prim_type == "WEDGE":
        bpy.ops.mesh.primitive_cone_add(radius1=0.5, radius2=0, depth=1)
    elif prim_type == "CUBE":
        bpy.ops.mesh.primitive_cube_add(size=1)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1)

    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    obj.location = location
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    return obj

def generate_lods(root_obj: bpy.types.Object, species_id: str, stage: int):
    """Generate LOD meshes for a creature."""
    # For each mesh in the hierarchy, create LOD versions
    for obj in root_obj.children_recursive:
        if obj.type != 'MESH':
            continue

        original_mesh = obj.data
        original_name = obj.name

        for lod_name, ratio in LOD_LEVELS.items():
            if ratio == 1.0:
                continue  # LOD0 is the original

            # Create decimated version
            lod_obj = obj.copy()
            lod_obj.data = original_mesh.copy()
            lod_obj.name = f"{original_name}_{lod_name}"

            # Add decimate modifier
            decimate = lod_obj.modifiers.new(name="Decimate", type='DECIMATE')
            decimate.ratio = ratio
            decimate.use_collapse_triangulate = True

            # Apply modifier
            bpy.context.view_layer.objects.active = lod_obj
            bpy.ops.object.modifier_apply(modifier="Decimate")

            # Link to same collection
            bpy.context.collection.objects.link(lod_obj)
            lod_obj.parent = obj.parent

def export_fbx(output_path: Path, root_obj: bpy.types.Object):
    """Export creature as FBX with proper settings for Roblox."""
    # Select root and all children
    bpy.ops.object.select_all(action='DESELECT')
    root_obj.select_set(True)
    for child in root_obj.children_recursive:
        child.select_set(True)

    bpy.context.view_layer.objects.active = root_obj

    # Export settings for Roblox
    bpy.ops.export_scene.fbx(
        filepath=str(output_path),
        use_selection=True,
        apply_unit_scale=True,
        apply_scale_options='FBX_SCALE_ALL',
        global_scale=UNIT_SCALE,
        bake_space_transform=True,
        object_types={'ARMATURE', 'MESH', 'EMPTY'},
        use_mesh_modifiers=True,
        use_mesh_modifiers_render=True,
        mesh_smooth_type='FACE',
        use_subsurf=False,
        use_mesh_edges=False,
        use_tspace=True,
        use_custom_props=True,
        add_leaf_bones=False,
        primary_bone_axis='Y',
        secondary_bone_axis='X',
        armature_nodetype='NULL',
        bake_anim=False,
    )

def save_rig_template():
    """Save the rig template as a .blend file."""
    template_path = PROJECT_ROOT / "scripts" / "blender" / "rig_template.blend"
    clean_scene()
    create_rig_template()
    bpy.ops.wm.save_as_mainfile(filepath=str(template_path))
    print(f"Saved rig template to {template_path}")

def save_material_template():
    """Save material template as a .blend file."""
    template_path = PROJECT_ROOT / "scripts" / "blender" / "material_template.blend"
    clean_scene()

    # Create sample materials
    materials = [
        ("SmoothPlastic_Base", (0.5, 0.5, 0.5), "SmoothPlastic"),
        ("Neon_Ember", (1.0, 0.4, 0.1), "Neon"),
        ("Neon_Tidal", (0.2, 0.6, 1.0), "Neon"),
        ("Neon_Leaf", (0.3, 0.8, 0.3), "Neon"),
        ("Neon_Sand", (0.9, 0.7, 0.4), "Neon"),
        ("Glass_Crystal", (0.7, 0.9, 1.0), "Glass"),
        ("Slate_Mineral", (0.3, 0.3, 0.35), "Slate"),
        ("Fabric_Spectral", (0.4, 0.4, 0.5), "Fabric"),
    ]

    for name, color, mat_type in materials:
        create_material(name, color, mat_type, color if mat_type == "Neon" else None,
                       5.0 if mat_type == "Neon" else 0.0)

    bpy.ops.wm.save_as_mainfile(filepath=str(template_path))
    print(f"Saved material template to {template_path}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Export creatures from Blender to FBX for Roblox")
    parser.add_argument("output_dir", nargs="?", default=str(EXPORT_DIR), help="Output directory for FBX files")
    parser.add_argument("--create-templates", action="store_true", help="Create rig and material templates only")
    parser.add_argument("--species", help="Export specific species only")
    parser.add_argument("--stage", type=int, help="Export specific stage only (1, 2, or 3)")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Create templates if requested
    if args.create_templates:
        save_rig_template()
        save_material_template()
        return

    # Parse creature designs
    try:
        creatures = parse_luau_designs(CREATURES_SOURCE)
        tokens = parse_art_tokens(ART_TOKENS_SOURCE)
        print(f"Loaded {len(creatures)} creature designs")
        print(f"Loaded element ramps: {list(tokens['ramps'].keys())}")
    except Exception as e:
        print(f"Error parsing Lua files: {e}")
        return

    # Filter species if specified
    if args.species:
        if args.species not in creatures:
            print(f"Species {args.species} not found")
            return
        creatures = {args.species: creatures[args.species]}

    # Filter stage if specified
    stages = [args.stage] if args.stage else [1, 2, 3]

    # Export each creature
    export_manifest = {}

    for species_id, species_data in creatures.items():
        print(f"\nProcessing {species_id}...")
        export_manifest[species_id] = {}

        for stage in stages:
            print(f"  Stage {stage}...")
            clean_scene()

            # Create creature
            root = create_creature_mesh(species_data, stage)

            # Generate LODs
            generate_lods(root, species_id, stage)

            # Export FBX
            fbx_name = f"{species_id}_stage{stage}.fbx"
            fbx_path = output_dir / fbx_name

            try:
                export_fbx(fbx_path, root)
                print(f"    Exported: {fbx_path}")

                # Record in manifest
                export_manifest[species_id][f"stage{stage}"] = {
                    "fbx": fbx_name,
                    "parts": [obj.name for obj in root.children_recursive if obj.type == 'MESH'],
                    "lod0": sum(1 for obj in root.children_recursive if obj.type == 'MESH' and not obj.name.endswith(('_LOD1', '_LOD2'))),
                    "lod1": sum(1 for obj in root.children_recursive if obj.type == 'MESH' and obj.name.endswith('_LOD1')),
                    "lod2": sum(1 for obj in root.children_recursive if obj.type == 'MESH' and obj.name.endswith('_LOD2')),
                }
            except Exception as e:
                print(f"    Error exporting {fbx_name}: {e}")

    # Save manifest
    manifest_path = output_dir / "export_manifest.json"
    with open(manifest_path, 'w') as f:
        json.dump(export_manifest, f, indent=2)
    print(f"\nExport manifest saved to {manifest_path}")
    print("Done!")

if __name__ == "__main__":
    main()