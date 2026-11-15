"""
Master Build Script for All Starter Lines
Builds all 9 starter models and exports as FBX
"""

import bpy
import os
import sys

sys.path.append(os.path.dirname(__file__))
from geometry_utils import *
from color_palettes import *
from ignisprow_line import build_all_ignisprow
from aquafin_line import build_all_aquafin
from terrasprout_line import build_all_terrasprout
from export_fbx import export_all_fbx, export_with_lods, EXPORT_DIR, setup_export_collection, move_to_export_collection


def clear_scene():
    """Clear all mesh objects from scene"""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    # Clear orphaned data
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)


def apply_materials(creature, color_dict, material_funcs):
    """Apply vertex colors from palette to creature parts"""
    # This would apply vertex colors based on part names
    # For now, we just ensure the mesh has vertex color layer
    if not creature.data.vertex_colors:
        creature.data.vertex_colors.new(name="Col")
    print(f"  {creature.name}: Vertex color layer ready")


def build_and_export_line(line_name, build_func, color_dicts, material_funcs):
    """Build a full evolution line and export all stages with LODs"""
    print(f"\n=== Building {line_name} Line ===")
    
    # Build all stages
    stages = build_func()
    
    export_collection = setup_export_collection()
    
    for i, (stage, colors) in enumerate(zip(stages, color_dicts)):
        stage_name = stage.name
        print(f"  Processing {stage_name}...")
        
        # Apply vertex colors
        apply_materials(stage, colors, material_funcs)
        
        # Move to export collection
        move_to_export_collection(stage, export_collection)
        
        # Export with LODs
        export_with_lods(stage_name, stage)
    
    return stages


def main():
    print("=" * 60)
    print("ARQUIPÉLAGO DAS FERAS — STARTER BUILD & EXPORT")
    print("=" * 60)
    
    # Clear scene
    clear_scene()
    
    # Create materials from palettes
    ember_mats = get_ember_materials()
    tidal_mats = get_tidal_materials()
    leaf_mats = get_leaf_materials()
    
    # Build and export all 3 lines
    all_stages = []
    
    # Ignisprow (Fire)
    ignis_stages = build_and_export_line(
        "Ignisprow (Fire)",
        build_all_ignisprow,
        [IGNISPROW_COLORS, VULPENKIND_COLORS, INFERNINE_COLORS],
        [ember_mats, ember_mats, ember_mats]
    )
    all_stages.extend(ignis_stages)
    
    # Clear for next line
    clear_scene()
    
    # Aquafin (Water)
    aqua_stages = build_and_export_line(
        "Aquafin (Water)",
        build_all_aquafin,
        [AQUAFIN_COLORS, NAIADRAKE_COLORS, OCEANSOVEREIGN_COLORS],
        [tidal_mats, tidal_mats, tidal_mats]
    )
    all_stages.extend(aqua_stages)
    
    # Clear for next line
    clear_scene()
    
    # Terrasprout (Nature)
    terra_stages = build_and_export_line(
        "Terrasprout (Nature)",
        build_all_terrasprout,
        [TERRASPROUT_COLORS, SYLVANHART_COLORS, WORLDTREEAVATAR_COLORS],
        [leaf_mats, leaf_mats, leaf_mats]
    )
    all_stages.extend(terra_stages)
    
    # Summary
    print("\n" + "=" * 60)
    print("BUILD COMPLETE — 9 STARTER MODELS EXPORTED")
    print("=" * 60)
    print(f"Export directory: {EXPORT_DIR}")
    print("\nFiles created:")
    for stage in all_stages:
        for lod in ["LOD0", "LOD1", "LOD2"]:
            print(f"  {stage.name}_{lod}.fbx")
    
    print(f"\nTotal: 9 models × 3 LODs = 27 FBX files")
    print("\nNext steps:")
    print("1. Upload FBX files to Roblox via Asset Manager")
    print("2. Run generate_manifest.py to create BlenderModels.generated.luau")
    print("3. Fill in Asset IDs in generated file")
    print("4. Run import_meshes.luau in Roblox Studio")


if __name__ == "__main__":
    main()