#!/usr/bin/env python3
"""
Create rig_template.blend - Base rig template compatible with Roblox Motor6D
Run in Blender: blender -b --python scripts/blender/create_rig_template.py
"""

import bpy
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[3]
TEMPLATE_PATH = PROJECT_ROOT / "scripts" / "blender" / "rig_template.blend"

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

def create_rig_template():
    """Create base armature template compatible with Roblox Motor6D."""
    # Create armature
    armature_data = bpy.data.armatures.new("CreatureRig")
    armature_obj = bpy.data.objects.new("Root", armature_data)
    bpy.context.collection.objects.link(armature_obj)

    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode='EDIT')

    # Roblox-compatible bone hierarchy
    # Naming: J_ prefix for joints that become Motor6D
    bones_data = [
        # (name, head, tail, parent, roll, use_connect)
        ("Root", (0, 0, 0), (0, 0.1, 0), None, 0, False),
        ("J_Body", (0, 0.1, 0), (0, 1.5, 0), "Root", 0, True),
        ("J_Head", (0, 1.5, 0), (0, 2.0, 0), "J_Body", 0, True),
        ("J_Neck", (0, 1.5, 0), (0, 1.8, 0), "J_Body", 0, True),
        # Front legs
        ("J_Leg1", (0.3, 0.5, 0.5), (0.3, -0.5, 0.5), "J_Body", 0, False),
        ("J_Leg2", (-0.3, 0.5, 0.5), (-0.3, -0.5, 0.5), "J_Body", 0, False),
        # Back legs
        ("J_Leg3", (0.3, 0.5, -0.8), (0.3, -0.5, -0.8), "J_Body", 0, False),
        ("J_Leg4", (-0.3, 0.5, -0.8), (-0.3, -0.5, -0.8), "J_Body", 0, False),
        # Wings
        ("J_WingL", (-0.4, 1.2, 0), (-2.0, 1.5, 0), "J_Body", 0, False),
        ("J_WingR", (0.4, 1.2, 0), (2.0, 1.5, 0), "J_Body", 0, False),
        # Tail segments
        ("J_Tail1", (0, 0.5, -1.0), (0, 0.3, -1.8), "J_Body", 0, True),
        ("J_Tail2", (0, 0.3, -1.8), (0, 0.2, -2.5), "J_Tail1", 0, True),
        ("J_Tail3", (0, 0.2, -2.5), (0, 0.1, -3.0), "J_Tail2", 0, True),
        ("J_Tail4", (0, 0.1, -3.0), (0, 0.0, -3.5), "J_Tail3", 0, True),
        # Wing feathers (for birds/dragons)
        ("J_WingL_1", (-0.8, 1.3, 0), (-1.5, 1.6, -0.2), "J_WingL", 0, True),
        ("J_WingL_2", (-1.5, 1.6, -0.2), (-2.2, 1.8, -0.4), "J_WingL_1", 0, True),
        ("J_WingL_3", (-2.2, 1.8, -0.4), (-2.8, 2.0, -0.6), "J_WingL_2", 0, True),
        ("J_WingR_1", (0.8, 1.3, 0), (1.5, 1.6, -0.2), "J_WingR", 0, True),
        ("J_WingR_2", (1.5, 1.6, -0.2), (2.2, 1.8, -0.4), "J_WingR_1", 0, True),
        ("J_WingR_3", (2.2, 1.8, -0.4), (2.8, 2.0, -0.6), "J_WingR_2", 0, True),
    ]

    for name, head, tail, parent_name, roll, use_connect in bones_data:
        bone = armature_data.edit_bones.new(name)
        bone.head = head
        bone.tail = tail
        bone.roll = roll
        if parent_name:
            bone.parent = armature_data.edit_bones[parent_name]
            bone.use_connect = use_connect

    bpy.ops.object.mode_set(mode='OBJECT')

    # Set display to wireframe for easier editing
    armature_obj.display_type = 'WIRE'
    armature_data.display_type = 'OCTAHEDRAL'

    # Add custom properties for Roblox export
    armature_obj["roblox_rig"] = True
    armature_obj["motor6d_prefix"] = "J_"
    armature_obj["root_bone"] = "Root"
    armature_obj["unit_scale"] = 1.0  # 1 Blender unit = 1 stud

    return armature_obj

def create_sample_mesh():
    """Create a sample creature mesh parented to the rig."""
    # Create body parts as separate meshes (like Roblox MeshParts)
    parts = [
        ("Body", "SPHERE", (1.2, 0.9, 1.5), (0, 0.8, 0), "J_Body"),
        ("Head", "SPHERE", (0.7, 0.7, 0.7), (0, 1.6, 0.5), "J_Head"),
        ("Leg1", "CYLINDER", (0.25, 0.8, 0.25), (0.4, 0.2, 0.5), "J_Leg1"),
        ("Leg2", "CYLINDER", (0.25, 0.8, 0.25), (-0.4, 0.2, 0.5), "J_Leg2"),
        ("Leg3", "CYLINDER", (0.25, 0.8, 0.25), (0.4, 0.2, -0.8), "J_Leg3"),
        ("Leg4", "CYLINDER", (0.25, 0.8, 0.25), (-0.4, 0.2, -0.8), "J_Leg4"),
        ("Tail1", "CONE", (0.3, 0.3, 1.0), (0, 0.3, -1.5), "J_Tail1"),
    ]

    # Create a material
    mat = bpy.data.materials.new(name="SmoothPlastic_Base")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (0.5, 0.5, 0.5, 1.0)
        bsdf.inputs['Roughness'].default_value = 0.7
        bsdf.inputs['Metallic'].default_value = 0.0

    for name, prim_type, size, loc, bone in parts:
        if prim_type == "SPHERE":
            bpy.ops.mesh.primitive_uv_sphere_add(radius=0.5, segments=12, ring_count=6)
        elif prim_type == "CYLINDER":
            bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=1)
        elif prim_type == "CONE":
            bpy.ops.mesh.primitive_cone_add(radius1=0.5, radius2=0, depth=1)
        else:
            bpy.ops.mesh.primitive_cube_add(size=1)

        obj = bpy.context.active_object
        obj.name = name
        obj.scale = size
        obj.location = loc
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

        # Assign material
        if obj.data.materials:
            obj.data.materials[0] = mat
        else:
            obj.data.materials.append(mat)

        # Add armature modifier
        mod = obj.modifiers.new(name="Armature", type='ARMATURE')
        mod.object = bpy.data.objects["Root"]

        # Create vertex group for bone
        vg = obj.vertex_groups.new(name=bone)
        vg.add(list(range(len(obj.data.vertices))), 1.0, 'REPLACE')

def main():
    clean_scene()
    create_rig_template()
    create_sample_mesh()

    # Save template
    TEMPLATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(TEMPLATE_PATH))
    print(f"Saved rig template to {TEMPLATE_PATH}")

if __name__ == "__main__":
    main()