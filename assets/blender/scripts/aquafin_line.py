"""
Aquafin Evolution Line — Water Starter
Aquafin (Lv.1) → Naiadrake (Lv.16) → Oceansovereign (Lv.36)
Otter-like water creatures with bubbles, crystals, and coral crown
"""

import bpy
from mathutils import Vector, Euler
from math import radians
import sys
import os

sys.path.append(os.path.dirname(__file__))
from geometry_utils import *
from color_palettes import *


# =============================================================================
# COLOR ASSIGNMENTS (from Tidal ramp)
# =============================================================================

AQUAFIN_COLORS = {
    "body_main": TIDAL_RAMP["trench"],
    "body_dark": TIDAL_RAMP["deep"],
    "belly": TIDAL_RAMP["tidal"],
    "head": TIDAL_RAMP["trench"],
    "tail_base": TIDAL_RAMP["trench"],
    "tail_tip": TIDAL_RAMP["wave"],
    "fin": TIDAL_RAMP["wave"],
    "bubble": TIDAL_RAMP["foam"],
    "eye": (0.02, 0.05, 0.1, 1.0),
    "nose": TIDAL_RAMP["abyss"],
    "paw": TIDAL_RAMP["deep"],
    "crystal": TIDAL_RAMP["prism"],
}

NAIADRAKE_COLORS = {
    "body_main": TIDAL_RAMP["tidal"],
    "body_dark": TIDAL_RAMP["trench"],
    "belly": TIDAL_RAMP["wave"],
    "head": TIDAL_RAMP["tidal"],
    "torso_fin": TIDAL_RAMP["foam"],
    "tail_base": TIDAL_RAMP["tidal"],
    "tail_mid": TIDAL_RAMP["wave"],
    "tail_tip": TIDAL_RAMP["foam"],
    "fin": TIDAL_RAMP["foam"],
    "bubble": TIDAL_RAMP["prism"],
    "crystal_1": TIDAL_RAMP["prism"],
    "crystal_2": TIDAL_RAMP["wave"],
    "eye": (0.02, 0.05, 0.1, 1.0),
    "nose": TIDAL_RAMP["abyss"],
    "paw": TIDAL_RAMP["trench"],
}

OCEANSOVEREIGN_COLORS = {
    "body_main": TIDAL_RAMP["wave"],
    "body_dark": TIDAL_RAMP["tidal"],
    "belly": TIDAL_RAMP["foam"],
    "head": TIDAL_RAMP["wave"],
    "coral_crown": TIDAL_RAMP["prism"],
    "tail_base": TIDAL_RAMP["wave"],
    "tail_1": TIDAL_RAMP["foam"],
    "tail_2": TIDAL_RAMP["prism"],
    "tail_3": TIDAL_RAMP["wave"],
    "tail_4": TIDAL_RAMP["foam"],
    "tail_5": TIDAL_RAMP["prism"],
    "fin": TIDAL_RAMP["prism"],
    "bubble": TIDAL_RAMP["prism"],
    "crystal": TIDAL_RAMP["prism"],
    "eye": (0.02, 0.05, 0.1, 1.0),
    "nose": TIDAL_RAMP["abyss"],
    "paw": TIDAL_RAMP["tidal"],
}


# =============================================================================
# BUILD FUNCTIONS
# =============================================================================

def build_aquafin():
    """Stage 1: Small otter pup with bubble tail (~600 tris)"""
    random_seed(101)
    parts = []
    
    # Body (streamlined)
    body = create_box(size=(1.1, 1.5, 0.6), location=(0, 0, 0.7), name="Body")
    parts.append(body)
    
    # Head (round)
    head = create_sphere(radius=0.5, location=(0, 1.0, 1.1), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.35, 0.4, 0.3), location=(0, 1.4, 1.0), name="Snout")
    parts.append(snout)
    
    # Ears (small, rounded)
    ear_l = create_sphere(radius=0.15, location=(-0.25, 0.8, 1.3), name="Ear_L")
    ear_r = create_sphere(radius=0.15, location=(0.25, 0.8, 1.3), name="Ear_R")
    parts.extend([ear_l, ear_r])
    
    # Legs (short, webbed)
    leg_positions = [(-0.3, -0.5, 0.3), (0.3, -0.5, 0.3), (-0.3, 0.5, 0.3), (0.3, 0.5, 0.3)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.1, depth=0.5, location=pos, name=f"Leg_{i+1}", vertices=5)
        parts.append(leg)
    
    # Webbed paws
    for i, pos in enumerate(leg_positions):
        paw = create_sphere(radius=0.16, location=(pos[0], pos[1], 0.0), name=f"Paw_{i+1}")
        scale_obj(paw, (1.3, 1.0, 0.7))  # flattened for webbing
        parts.append(paw)
    
    # Tail (flat, beaver-like)
    tail = create_box(size=(0.5, 0.15, 0.8), location=(0, -0.9, 0.8), name="Tail")
    parts.append(tail)
    
    # Bubble trail (3 bubbles)
    for i in range(3):
        bubble = create_sphere(radius=0.12 - i*0.03, location=(0, -1.1 - i*0.2, 0.9 + i*0.1), name=f"Bubble_{i+1}")
        parts.append(bubble)
    
    # Whiskers (thin cylinders)
    for side in [-1, 1]:
        for j in range(3):
            whisker = create_cylinder(radius=0.015, depth=0.25, location=(side*0.2, 1.3, 1.0 + j*0.08), name=f"Whisker_{side}_{j}", vertices=3)
            rotate_obj(whisker, (0, side*20, 0))
            parts.append(whisker)
    
    creature = join_objects(parts, "Aquafin")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 400, 800, "Aquafin")
    return creature


def build_naiadrake():
    """Stage 2: Naga-like adolescent with crystals and dorsal fin (~1000 tris)"""
    random_seed(201)
    parts = []
    
    # Lower body (serpentine)
    lower_body = create_cylinder(radius=0.7, depth=2.5, location=(0, -0.3, 0.8), name="Lower_Body", vertices=8)
    parts.append(lower_body)
    
    # Torso (humanoid upper)
    torso = create_box(size=(1.0, 0.9, 1.2), location=(0, 1.3, 1.5), name="Torso")
    parts.append(torso)
    
    # Dorsal fin
    dorsal = create_cone(radius1=0.4, radius2=0.05, depth=0.6, location=(0, 1.0, 2.2), name="Dorsal_Fin", vertices=6)
    rotate_obj(dorsal, (-90, 0, 0))
    parts.append(dorsal)
    
    # Side fins (pectoral)
    for side in [-1, 1]:
        fin = create_cone(radius1=0.35, radius2=0.05, depth=0.5, location=(side*0.7, 1.3, 1.6), name=f"Pectoral_Fin_{side}", vertices=5)
        rotate_obj(fin, (0, 0, side*45))
        parts.append(fin)
    
    # Head
    head = create_box(size=(0.7, 0.7, 0.7), location=(0, 1.8, 2.2), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.4, 0.5, 0.35), location=(0, 2.2, 2.1), name="Snout")
    parts.append(snout)
    
    # Ear fins
    for side in [-1, 1]:
        ear = create_cone(radius1=0.2, radius2=0.02, depth=0.4, location=(side*0.3, 1.6, 2.5), name=f"Ear_Fin_{side}", vertices=5)
        rotate_obj(ear, (0, side*30, 0))
        parts.append(ear)
    
    # Arms (with webbed hands)
    for side in [-1, 1]:
        arm = create_cylinder(radius=0.12, depth=0.8, location=(side*0.7, 1.3, 1.8), name=f"Arm_{side}", vertices=6)
        rotate_obj(arm, (0, 0, side*30))
        parts.append(arm)
        hand = create_sphere(radius=0.15, location=(side*1.1, 1.3, 1.5), name=f"Hand_{side}")
        scale_obj(hand, (1.4, 1.0, 0.8))
        parts.append(hand)
    
    # Tail (split into 2 flukes)
    tail1 = create_cone(radius1=0.3, radius2=0.05, depth=1.0, location=(-0.2, -1.8, 0.6), name="Tail_1", vertices=6)
    tail2 = create_cone(radius1=0.3, radius2=0.05, depth=1.0, location=(0.2, -1.8, 0.6), name="Tail_2", vertices=6)
    rotate_obj(tail1, (15, 0, -20))
    rotate_obj(tail2, (15, 0, 20))
    parts.extend([tail1, tail2])
    
    # Crystals (3 on back)
    for i in range(3):
        crystal = create_cone(radius1=0.12, radius2=0.0, depth=0.3, location=(0, 0.5 - i*0.4, 1.8), name=f"Crystal_{i+1}", vertices=5)
        rotate_obj(crystal, (-90, 0, 0))
        parts.append(crystal)
    
    # Bubbles (trail)
    for i in range(4):
        bubble = create_sphere(radius=0.1 - i*0.015, location=(0, -2.2 - i*0.25, 0.5 + i*0.1), name=f"Bubble_{i+1}")
        parts.append(bubble)
    
    creature = join_objects(parts, "Naiadrake")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 800, 1400, "Naiadrake")
    return creature


def build_oceansovereign():
    """Stage 3: Majestic sea serpent guardian with coral crown and 5 current tails (~2000 tris)"""
    random_seed(301)
    parts = []
    
    # Long serpentine body
    segments = 6
    for i in range(segments):
        radius = 0.9 - i*0.1
        seg = create_cylinder(radius=radius, depth=1.2, location=(0, i*1.1 - 2.0, 0.9), name=f"Body_Seg_{i+1}", vertices=10)
        parts.append(seg)
    
    # Chest/Torso area (wider)
    chest = create_box(size=(1.4, 1.0, 1.5), location=(0, 4.0, 1.5), name="Chest")
    parts.append(chest)
    
    # Coral Crown (on head)
    crown_base = create_box(size=(0.8, 0.3, 0.8), location=(0, 5.2, 2.3), name="Crown_Base")
    parts.append(crown_base)
    for i in range(5):
        angle = i * 72
        x = 0.4 * cos(radians(angle))
        y = 5.2 + 0.4 * sin(radians(angle))
        coral = create_cone(radius1=0.12, radius2=0.0, depth=0.5, location=(x, y, 2.5), name=f"Coral_{i+1}", vertices=5)
        parts.append(coral)
    
    # Head (regal)
    head = create_box(size=(0.9, 0.9, 0.85), location=(0, 5.0, 2.5), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.5, 0.6, 0.4), location=(0, 5.5, 2.4), name="Snout")
    parts.append(snout)
    
    # Head fins (large, flowing)
    for side in [-1, 1]:
        fin = create_cone(radius1=0.4, radius2=0.05, depth=0.7, location=(side*0.5, 4.8, 2.7), name=f"Head_Fin_{side}", vertices=6)
        rotate_obj(fin, (0, side*20, side*15))
        parts.append(fin)
    
    # Arms (powerful, webbed claws)
    for side in [-1, 1]:
        arm = create_cylinder(radius=0.18, depth=1.0, location=(side*0.9, 4.0, 1.8), name=f"Arm_{side}", vertices=8)
        rotate_obj(arm, (0, 0, side*25))
        parts.append(arm)
        claw = create_box(size=(0.3, 0.2, 0.6), location=(side*1.4, 4.0, 1.3), name=f"Claw_{side}")
        parts.append(claw)
    
    # 5 Current Tails (split from end)
    tail_angles = [-30, -15, 0, 15, 30]
    for i, angle in enumerate(tail_angles):
        tail = create_cone(radius1=0.25, radius2=0.03, depth=1.8, location=(0, -3.0, 0.5), name=f"Current_Tail_{i+1}", vertices=8)
        rotate_obj(tail, (20, 0, angle))
        parts.append(tail)
        # Fin on tail
        tfin = create_cone(radius1=0.3, radius2=0.05, depth=0.4, location=(0, -4.0, 0.5), name=f"Tail_Fin_{i+1}", vertices=6)
        rotate_obj(tfin, (20, 0, angle))
        parts.append(tfin)
    
    # Crystals along spine (5)
    for i in range(5):
        crystal = create_cone(radius1=0.15, radius2=0.0, depth=0.4, location=(0, -1.0 + i*1.2, 1.4), name=f"Spine_Crystal_{i+1}", vertices=6)
        rotate_obj(crystal, (-90, 0, 0))
        parts.append(crystal)
    
    # Bubble trail (continuous)
    for i in range(8):
        bubble = create_sphere(radius=0.15 - i*0.015, location=(0, -4.5 - i*0.3, 0.3 + i*0.05), name=f"Bubble_{i+1}")
        parts.append(bubble)
    
    creature = join_objects(parts, "Oceansovereign")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 1600, 2500, "Oceansovereign")
    return creature


def build_all_aquafin():
    """Build all 3 stages of Aquafin line"""
    print("Building Aquafin line...")
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    
    s1 = build_aquafin()
    bpy.ops.object.select_all(action='DESELECT')
    
    s2 = build_naiadrake()
    bpy.ops.object.select_all(action='DESELECT')
    
    s3 = build_oceansovereign()
    bpy.ops.object.select_all(action='DESELECT')
    
    print("Aquafin line complete!")
    return [s1, s2, s3]


if __name__ == "__main__":
    build_all_aquafin()