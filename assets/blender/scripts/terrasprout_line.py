"""
Terrasprout Evolution Line — Nature Starter
Terrasprout (Lv.1) → Sylvanhart (Lv.16) → WorldtreeAvatar (Lv.36)
Deer-like nature creatures with sprout/branch/canopy antlers and tree on back
"""

import bpy
from mathutils import Vector, Euler
from math import radians, cos, sin
import sys
import os

sys.path.append(os.path.dirname(__file__))
from geometry_utils import *
from color_palettes import *


# =============================================================================
# COLOR ASSIGNMENTS (from Leaf ramp)
# =============================================================================

TERRASPROUT_COLORS = {
    "body_main": LEAF_RAMP["moss"],
    "body_dark": LEAF_RAMP["loam"],
    "belly": LEAF_RAMP["leaf"],
    "head": LEAF_RAMP["moss"],
    "sprout": LEAF_RAMP["sprout"],
    "antler_nub": LEAF_RAMP["moss_dark"],
    "tail": LEAF_RAMP["moss"],
    "leaf_accents": LEAF_RAMP["bloom"],
    "eye": (0.05, 0.08, 0.02, 1.0),
    "nose": LEAF_RAMP["loam"],
    "hoof": LEAF_RAMP["loam"],
    "flower": LEAF_RAMP["vitality"],
}

SYLVANHART_COLORS = {
    "body_main": LEAF_RAMP["leaf"],
    "body_dark": LEAF_RAMP["moss"],
    "belly": LEAF_RAMP["sprout"],
    "head": LEAF_RAMP["leaf"],
    "antler_branch": LEAF_RAMP["moss_dark"],
    "antler_leaves": LEAF_RAMP["bloom"],
    "back_tree_trunk": LEAF_RAMP["loam"],
    "back_tree_leaves": LEAF_RAMP["bloom"],
    "tail": LEAF_RAMP["moss"],
    "leg_accent": LEAF_RAMP["sprout"],
    "eye": (0.05, 0.08, 0.02, 1.0),
    "nose": LEAF_RAMP["loam"],
    "hoof": LEAF_RAMP["moss_dark"],
    "flower": LEAF_RAMP["vitality"],
}

WORLDTREEAVATAR_COLORS = {
    "body_main": LEAF_RAMP["sprout"],
    "body_dark": LEAF_RAMP["leaf"],
    "belly": LEAF_RAMP["bloom"],
    "head": LEAF_RAMP["sprout"],
    "antler_canopy": LEAF_RAMP["vitality"],
    "antler_branches": LEAF_RAMP["leaf"],
    "world_tree_trunk": LEAF_RAMP["loam"],
    "world_tree_canopy": LEAF_RAMP["vitality"],
    "world_tree_roots": LEAF_RAMP["moss_dark"],
    "tail": LEAF_RAMP["leaf"],
    "leg_accent": LEAF_RAMP["bloom"],
    "eye": (0.05, 0.08, 0.02, 1.0),
    "nose": LEAF_RAMP["loam"],
    "hoof": LEAF_RAMP["moss"],
    "flower": LEAF_RAMP["vitality"],
}


# =============================================================================
# BUILD FUNCTIONS
# =============================================================================

def build_terrasprout():
    """Stage 1: Small fawn with leaf sprout on forehead (~600 tris)"""
    random_seed(102)
    parts = []
    
    # Body (compact, fawn-like)
    body = create_box(size=(0.9, 1.2, 0.7), location=(0, 0, 0.8), name="Body")
    parts.append(body)
    
    # Neck
    neck = create_cylinder(radius=0.25, depth=0.6, location=(0, 0.75, 1.2), name="Neck", vertices=6)
    rotate_obj(neck, (-20, 0, 0))
    parts.append(neck)
    
    # Head
    head = create_box(size=(0.55, 0.6, 0.55), location=(0, 1.2, 1.5), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.3, 0.35, 0.25), location=(0, 1.5, 1.4), name="Snout")
    parts.append(snout)
    
    # Ears (large, leaf-shaped)
    for side in [-1, 1]:
        ear = create_cone(radius1=0.18, radius2=0.02, depth=0.4, location=(side*0.2, 1.0, 1.7), name=f"Ear_{side}", vertices=4)
        rotate_obj(ear, (0, side*20, 0))
        parts.append(ear)
    
    # Sprout on forehead (single leaf)
    sprout = create_cone(radius1=0.12, radius2=0.0, depth=0.35, location=(0, 1.2, 1.8), name="Sprout", vertices=4)
    rotate_obj(sprout, (-10, 0, 0))
    parts.append(sprout)
    
    # Antler nubs (tiny)
    for side in [-1, 1]:
        nub = create_cone(radius1=0.06, radius2=0.0, depth=0.15, location=(side*0.12, 1.0, 1.75), name=f"Antler_Nub_{side}", vertices=4)
        parts.append(nub)
    
    # Legs (thin, delicate)
    leg_positions = [(-0.25, -0.4, 0.35), (0.25, -0.4, 0.35), (-0.25, 0.4, 0.35), (0.25, 0.4, 0.35)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.08, depth=0.7, location=pos, name=f"Leg_{i+1}", vertices=5)
        parts.append(leg)
        hoof = create_cone(radius1=0.1, radius2=0.04, depth=0.12, location=(pos[0], pos[1], 0.0), name=f"Hoof_{i+1}", vertices=5)
        parts.append(hoof)
    
    # Tail (short, fluffy)
    tail = create_cone(radius1=0.15, radius2=0.03, depth=0.3, location=(0, -0.7, 0.9), name="Tail", vertices=5)
    rotate_obj(tail, (20, 0, 0))
    parts.append(tail)
    
    # Leaf accents on back (2 small leaves)
    for i in range(2):
        leaf = create_plane(size=0.25, location=(0, 0.2 - i*0.3, 1.3), name=f"Back_Leaf_{i+1}")
        rotate_obj(leaf, (-30, 0, i*15))
        parts.append(leaf)
    
    # Flower on chest (single)
    flower = create_sphere(radius=0.08, location=(0, 1.0, 1.0), name="Chest_Flower")
    parts.append(flower)
    
    creature = join_objects(parts, "Terrasprout")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 400, 800, "Terrasprout")
    return creature


def build_sylvanhart():
    """Stage 2: Adolescent stag with branch antlers and sapling on back (~1100 tris)"""
    random_seed(202)
    parts = []
    
    # Body (larger, muscular)
    body = create_box(size=(1.2, 1.6, 0.9), location=(0, 0, 1.0), name="Body")
    parts.append(body)
    
    # Neck (longer, proud)
    neck = create_cylinder(radius=0.3, depth=0.9, location=(0, 0.95, 1.4), name="Neck", vertices=8)
    rotate_obj(neck, (-25, 0, 0))
    parts.append(neck)
    
    # Head
    head = create_box(size=(0.7, 0.75, 0.65), location=(0, 1.6, 1.8), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.4, 0.45, 0.35), location=(0, 2.0, 1.7), name="Snout")
    parts.append(snout)
    
    # Ears
    for side in [-1, 1]:
        ear = create_cone(radius1=0.22, radius2=0.02, depth=0.5, location=(side*0.25, 1.3, 2.1), name=f"Ear_{side}", vertices=4)
        rotate_obj(ear, (0, side*25, 0))
        parts.append(ear)
    
    # Branch Antlers (2 main branches, each with 3 tines)
    for side in [-1, 1]:
        base_x = side * 0.15
        # Main beam
        main = create_cylinder(radius=0.08, depth=0.7, location=(base_x, 1.2, 2.1), name=f"Antler_Main_{side}", vertices=5)
        rotate_obj(main, (-30, 0, side*15))
        parts.append(main)
        # Tines (3 per antler)
        for t in range(3):
            tine = create_cone(radius1=0.05, radius2=0.0, depth=0.25, location=(base_x + side*t*0.08, 1.4 + t*0.15, 2.4 + t*0.1), name=f"Antler_Tine_{side}_{t+1}", vertices=4)
            rotate_obj(tine, (-20, 0, side*10))
            parts.append(tine)
        # Leaves on antlers
        for t in range(3):
            leaf = create_plane(size=0.18, location=(base_x + side*t*0.08, 1.45 + t*0.15, 2.5 + t*0.1), name=f"Antler_Leaf_{side}_{t+1}")
            rotate_obj(leaf, (-40, 0, side*5))
            parts.append(leaf)
    
    # Sapling on Back (small tree)
    trunk = create_cylinder(radius=0.08, depth=0.8, location=(0, 0.2, 1.7), name="Sapling_Trunk", vertices=6)
    parts.append(trunk)
    # Canopy (3 layers)
    for i in range(3):
        canopy = create_sphere(radius=0.35 - i*0.05, location=(0, 0.2, 2.1 + i*0.3), name=f"Sapling_Canopy_{i+1}")
        parts.append(canopy)
    
    # Legs (strong)
    leg_positions = [(-0.35, -0.55, 0.4), (0.35, -0.55, 0.4), (-0.35, 0.55, 0.4), (0.35, 0.55, 0.4)]
    for i, pos in enumerate(leg_positions):
        thigh = create_cylinder(radius=0.12, depth=0.4, location=(pos[0], pos[1], 1.0), name=f"Thigh_{i+1}", vertices=6)
        parts.append(thigh)
        leg = create_cylinder(radius=0.1, depth=0.8, location=pos, name=f"Leg_{i+1}", vertices=6)
        parts.append(leg)
        hoof = create_cone(radius1=0.13, radius2=0.05, depth=0.15, location=(pos[0], pos[1], 0.0), name=f"Hoof_{i+1}", vertices=6)
        parts.append(hoof)
    
    # Leg leaf accents
    for pos in leg_positions:
        leaf = create_plane(size=0.2, location=(pos[0], pos[1], 0.7), name=f"Leg_Leaf_{pos[0]}_{pos[1]}")
        rotate_obj(leaf, (-10, 0, 0))
        parts.append(leaf)
    
    # Tail (longer, with leaf tuft)
    tail = create_cone(radius1=0.2, radius2=0.03, depth=0.5, location=(0, -0.9, 1.0), name="Tail", vertices=6)
    rotate_obj(tail, (15, 0, 0))
    parts.append(tail)
    # Tail leaf tuft
    for i in range(3):
        leaf = create_plane(size=0.15, location=(0, -1.2 - i*0.1, 1.1 + i*0.1), name=f"Tail_Leaf_{i+1}")
        rotate_obj(leaf, (10, 0, i*20))
        parts.append(leaf)
    
    # Flowers on flanks (2 per side)
    for side in [-1, 1]:
        for j in range(2):
            flower = create_sphere(radius=0.08, location=(side*0.7, 0.0, 1.0 + j*0.3), name=f"Flank_Flower_{side}_{j+1}")
            parts.append(flower)
    
    creature = join_objects(parts, "Sylvanhart")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 900, 1500, "Sylvanhart")
    return creature


def build_worldtreeavatar():
    """Stage 3: Ancient forest guardian with canopy antlers and World Tree on back (~2200 tris)"""
    random_seed(302)
    parts = []
    
    # Body (massive, ancient)
    body = create_box(size=(1.8, 2.2, 1.3), location=(0, 0, 1.4), name="Body")
    parts.append(body)
    
    # Neck (thick, strong)
    neck = create_cylinder(radius=0.4, depth=1.1, location=(0, 1.2, 1.9), name="Neck", vertices=10)
    rotate_obj(neck, (-20, 0, 0))
    parts.append(neck)
    
    # Head (wise, ancient)
    head = create_box(size=(0.95, 0.95, 0.85), location=(0, 2.0, 2.5), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.5, 0.55, 0.45), location=(0, 2.5, 2.4), name="Snout")
    parts.append(snout)
    
    # Ears (large, tattered)
    for side in [-1, 1]:
        ear = create_cone(radius1=0.28, radius2=0.02, depth=0.6, location=(side*0.35, 1.7, 2.9), name=f"Ear_{side}", vertices=5)
        rotate_obj(ear, (0, side*30, side*10))
        parts.append(ear)
    
    # Canopy Antlers (massive, 4 main branches each, covered in leaves)
    for side in [-1, 1]:
        base_x = side * 0.2
        # 4 main branches
        for b in range(4):
            angle = -40 + b * 25
            main = create_cylinder(radius=0.12, depth=1.0, location=(base_x, 1.5, 2.6), name=f"Antler_Branch_{side}_{b+1}", vertices=6)
            rotate_obj(main, (angle, 0, side*15 + b*5))
            parts.append(main)
            # Sub-branches
            for sb in range(2):
                sub = create_cylinder(radius=0.07, depth=0.5, location=(base_x + sin(radians(angle))*0.6, 1.5 + cos(radians(angle))*0.6, 2.6 + 0.6), name=f"Antler_Sub_{side}_{b+1}_{sb+1}", vertices=5)
                rotate_obj(sub, (angle + 20, 0, side*10))
                parts.append(sub)
            # Leaves (many)
            for l in range(5):
                leaf = create_plane(size=0.22, location=(base_x + sin(radians(angle))*l*0.2, 1.5 + cos(radians(angle))*l*0.2, 2.6 + l*0.15), name=f"Antler_Leaf_{side}_{b+1}_{l+1}")
                rotate_obj(leaf, (angle - 10, 0, side*l*8))
                parts.append(leaf)
    
    # WORLD TREE ON BACK (magnificent)
    # Roots (entwined with body)
    for i in range(6):
        angle = i * 60
        root = create_cylinder(radius=0.06, depth=1.2, location=(0.4*cos(radians(angle)), 0.3*sin(radians(angle)), 1.0), name=f"WorldTree_Root_{i+1}", vertices=5)
        rotate_obj(root, (0, 0, angle))
        parts.append(root)
    
    # Main Trunk
    trunk = create_cylinder(radius=0.25, depth=2.5, location=(0, 0.3, 2.0), name="WorldTree_Trunk", vertices=10)
    parts.append(trunk)
    
    # Branches (3 tiers)
    for tier in range(3):
        y_pos = 0.3 + tier * 0.6
        z_pos = 2.5 + tier * 0.8
        radius = 0.8 - tier * 0.15
        for b in range(4 + tier):
            angle = b * (360 / (4 + tier))
            branch = create_cylinder(radius=0.1, depth=radius, location=(0, y_pos, z_pos), name=f"WorldTree_Branch_{tier}_{b+1}", vertices=6)
            rotate_obj(branch, (0, 0, angle))
            parts.append(branch)
    
    # Canopy Layers (5 layers, decreasing)
    for i in range(5):
        canopy = create_sphere(radius=1.2 - i*0.2, location=(0, 0.3, 3.8 + i*0.5), name=f"WorldTree_Canopy_{i+1}")
        parts.append(canopy)
    
    # Glowing fruit/flowers on tree
    for i in range(12):
        angle = i * 30
        radius = 0.6 + (i % 3) * 0.2
        fruit = create_sphere(radius=0.08, location=(radius*cos(radians(angle)), 0.3 + radius*sin(radians(angle)), 3.5 + (i % 5)*0.4), name=f"WorldTree_Fruit_{i+1}")
        parts.append(fruit)
    
    # Legs (tree-trunk thick)
    leg_positions = [(-0.5, -0.7, 0.5), (0.5, -0.7, 0.5), (-0.5, 0.7, 0.5), (0.5, 0.7, 0.5)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.18, depth=1.2, location=pos, name=f"Leg_{i+1}", vertices=8)
        parts.append(leg)
        hoof = create_cone(radius1=0.22, radius2=0.08, depth=0.2, location=(pos[0], pos[1], 0.0), name=f"Hoof_{i+1}", vertices=8)
        parts.append(hoof)
    
    # Root feet (tree roots as feet)
    for pos in leg_positions:
        for r in range(3):
            root = create_cylinder(radius=0.04, depth=0.3, location=(pos[0] + (r-1)*0.08, pos[1], 0.1), name=f"Root_Foot_{pos[0]}_{pos[1]}_{r}", vertices=4)
            parts.append(root)
    
    # Tail (vine-like, with leaves)
    tail = create_cylinder(radius=0.12, depth=1.0, location=(0, -1.1, 1.2), name="Tail", vertices=6)
    rotate_obj(tail, (10, 0, 0))
    parts.append(tail)
    for i in range(6):
        leaf = create_plane(size=0.25, location=(0, -1.4 - i*0.15, 1.3 + i*0.1), name=f"Tail_Leaf_{i+1}")
        rotate_obj(leaf, (0, 0, i*30))
        parts.append(leaf)
    
    # Vines hanging from body
    for i in range(8):
        vine = create_cylinder(radius=0.03, depth=1.5, location=(cos(radians(i*45))*0.8, sin(radians(i*45))*0.8, 2.0), name=f"Vine_{i+1}", vertices=4)
        parts.append(vine)
    
    creature = join_objects(parts, "WorldtreeAvatar")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 1800, 2800, "WorldtreeAvatar")
    return creature


def build_all_terrasprout():
    """Build all 3 stages of Terrasprout line"""
    print("Building Terrasprout line...")
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    
    s1 = build_terrasprout()
    bpy.ops.object.select_all(action='DESELECT')
    
    s2 = build_sylvanhart()
    bpy.ops.object.select_all(action='DESELECT')
    
    s3 = build_worldtreeavatar()
    bpy.ops.object.select_all(action='DESELECT')
    
    print("Terrasprout line complete!")
    return [s1, s2, s3]


if __name__ == "__main__":
    build_all_terrasprout()