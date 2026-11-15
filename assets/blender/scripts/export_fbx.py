"""
FBX Export for Arquipelago Starters
Exports models with game-engine settings: Y-forward, Z-up, triangulated
"""

import bpy
import os
import sys

sys.path.append(os.path.dirname(__file__))
from geometry_utils import *


# =============================================================================
# EXPORT SETTINGS
# =============================================================================

EXPORT_DIR = os.path.join(os.path.dirname(__file__), "..", "exports", "starters")

FBX_SETTINGS = {
    # Axis conversion
    "axis_forward": "Y",
    "axis_up": "Z",
    
    # Mesh
    "apply_unit_scale": True,
    "apply_scale_options": "FBX_SCALE_ALL",
    "use_space_transform": True,
    "mesh_smooth_type": "FACE",  # Preserve flat shading
    "use_mesh_modifiers": True,
    "use_mesh_modifiers_render": True,
    "use_triangles": True,  # Triangulate on export
    
    # Armature (if rigged)
    "add_leaf_bones": False,
    "primary_bone_axis": "Y",
    "secondary_bone_axis": "X",
    "use_armature_deform_only": False,
    
    # Animation
    "bake_anim": False,
    "bake_anim_use_all_bones": False,
    "bake_anim_use_nla_strips": False,
    "bake_anim_use_all_actions": False,
    "bake_anim_force_startend_keying": False,
    "bake_anim_step": 1.0,
    "bake_anim_simplify_factor": 1.0,
    
    # Other
    "use_metadata": True,
    "path_mode": "COPY",
    "embed_textures": False,
}


def prepare_for_export(obj):
    """Prepare object for FBX export"""
    # Ensure object is in object mode
    if obj.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    
    # Select only this object
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    
    # Apply all transforms
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    # Ensure mesh is triangulated
    if obj.type == "MESH":
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.mesh.quads_convert_to_tris()
        bpy.ops.object.mode_set(mode="OBJECT")
    
    # Ensure origin is at feet (bottom center)
    center_origin(obj, bottom=True)
    
    # Validate
    tris = count_triangles(obj)
    print(f"  {obj.name}: {tris} triangles, ready for export")


def export_single_fbx(obj, filename):
    """Export a single object as FBX"""
    filepath = os.path.join(EXPORT_DIR, filename)
    
    # Ensure export directory exists
    os.makedirs(EXPORT_DIR, exist_ok=True)
    
    # Prepare
    prepare_for_export(obj)
    
    # Export
    bpy.ops.export_scene.fbx(
        filepath=filepath,
        use_selection=True,
        **FBX_SETTINGS
    )
    
    print(f"  Exported: {filename}")
    return filepath


def export_all_fbx(objects_dict):
    """Export multiple objects as separate FBX files"""
    results = {}
    for name, obj in objects_dict.items():
        filename = f"{name}.fbx"
        results[name] = export_single_fbx(obj, filename)
    return results


def export_with_lods(base_name, lod0_obj, lod1_obj=None, lod2_obj=None):
    """Export a model with LOD variants"""
    results = {}
    
    # LOD0 (full detail)
    results["LOD0"] = export_single_fbx(lod0_obj, f"{base_name}_LOD0.fbx")
    
    # LOD1 (50% tris) - create if not provided
    if lod1_obj is None:
        lod1_obj = lod0_obj.copy()
        lod1_obj.data = lod0_obj.data.copy()
        bpy.context.collection.objects.link(lod1_obj)
        decimate(lod1_obj, ratio=0.5)
        lod1_obj.name = f"{base_name}_LOD1"
    
    results["LOD1"] = export_single_fbx(lod1_obj, f"{base_name}_LOD1.fbx")
    
    # LOD2 (25% tris) - create if not provided
    if lod2_obj is None:
        lod2_obj = lod0_obj.copy()
        lod2_obj.data = lod0_obj.data.copy()
        bpy.context.collection.objects.link(lod2_obj)
        decimate(lod2_obj, ratio=0.25)
        lod2_obj.name = f"{base_name}_LOD2"
    
    results["LOD2"] = export_single_fbx(lod2_obj, f"{base_name}_LOD2.fbx")
    
    return results


def setup_export_collection():
    """Create or get the export collection"""
    coll_name = "Export_Starters"
    if coll_name in bpy.data.collections:
        coll = bpy.data.collections[coll_name]
    else:
        coll = bpy.data.collections.new(coll_name)
        bpy.context.scene.collection.children.link(coll)
    return coll


def move_to_export_collection(obj, coll):
    """Move object to export collection"""
    for c in obj.users_collection:
        c.objects.unlink(obj)
    coll.objects.link(obj)


if __name__ == "__main__":
    print("FBX Export module loaded")
    print(f"Export directory: {EXPORT_DIR}")
    print("Available functions:")
    for name in dir():
        if not name.startswith("_"):
            print(f"  {name}")