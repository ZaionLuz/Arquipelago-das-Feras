"""
Ignisprow Evolution Line — Fire Starter
Ignisprow (Lv.1) → Vulpenkind (Lv.16) → Infernine (Lv.36)
Fox-like fire creatures with ember tails and fire mane
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
# COLOR ASSIGNMENTS (from Ember ramp)
# =============================================================================

# Stage 1: Ignisprow - mostly cinder/smolder with ember accents
IGNISPROW_COLORS = {
    "body_main": EMBER_RAMP["cinder"],
    "body_dark": EMBER_RAMP["charcoal"],
    "belly": EMBER_RAMP["smolder"],
    "tail_base": EMBER_RAMP["smolder"],
    "tail_tip": EMBER_RAMP["ember"],
    "ear_inner": EMBER_RAMP["flare"],
    "eye": (0.05, 0.03, 0.02, 1.0),
    "nose": EMBER_RAMP["charcoal"],
    "paw": EMBER_RAMP["charcoal"],
    "flame": EMBER_RAMP["blaze"],
}

# Stage 2: Vulpenkind - smolder/ember body, flare/blaze accents, 2 tails
VULPENKIND_COLORS = {
    "body_main": EMBER_RAMP["smolder"],
    "body_dark": EMBER_RAMP["cinder"],
    "belly": EMBER_RAMP["ember"],
    "mane": EMBER_RAMP["flare"],
    "tail1_base": EMBER_RAMP["smolder"],
    "tail1_tip": EMBER_RAMP["blaze"],
    "tail2_base": EMBER_RAMP["ember"],
    "tail2_tip": EMBER_RAMP["flare"],
    "ear_inner": EMBER_RAMP["white_hot"],
    "eye": (0.05, 0.03, 0.02, 1.0),
    "nose": EMBER_RAMP["charcoal"],
    "paw": EMBER_RAMP["cinder"],
    "flame": EMBER_RAMP["white_hot"],
}

# Stage 3: Infernine - ember/flare body, blaze/white_hot accents, 3 tails, fire mane
INFERNINE_COLORS = {
    "body_main": EMBER_RAMP["ember"],
    "body_dark": EMBER_RAMP["smolder"],
    "belly": EMBER_RAMP["flare"],
    "mane": EMBER_RAMP["blaze"],
    "tail1_base": EMBER_RAMP["flare"],
    "tail1_tip": EMBER_RAMP["white_hot"],
    "tail2_base": EMBER_RAMP["flare"],
    "tail2_tip": EMBER_RAMP["white_hot"],
    "tail3_base": EMBER_RAMP["blaze"],
    "tail3_tip": EMBER_RAMP["white_hot"],
    "ear_inner": EMBER_RAMP["white_hot"],
    "eye": (0.05, 0.03, 0.02, 1.0),
    "nose": EMBER_RAMP["charcoal"],
    "paw": EMBER_RAMP["smolder"],
    "flame": EMBER_RAMP["white_hot"],
}


# =============================================================================
# BUILD FUNCTIONS
# =============================================================================

def build_ignisprow():
    """Stage 1: Small fox cub with single ember tail (~600 tris)"""
    random_seed(100)
    parts = []
    
    # Body (main torso)
    body = create_box(size=(1.0, 1.4, 0.7), location=(0, 0, 0.8), name="Body")
    parts.append(body)
    
    # Head
    head = create_box(size=(0.7, 0.7, 0.65), location=(0, 1.1, 1.3), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.45, 0.5, 0.35), location=(0, 1.5, 1.2), name="Snout")
    parts.append(snout)
    
    # Ears (2)
    ear_l = create_cone(radius1=0.18, radius2=0.02, depth=0.45, location=(-0.25, 1.0, 1.7), name="Ear_L")
    ear_r = create_cone(radius1=0.18, radius2=0.02, depth=0.45, location=(0.25, 1.0, 1.7), name="Ear_R")
    rotate_obj(ear_l, (0, -15, 0))
    rotate_obj(ear_r, (0, 15, 0))
    parts.extend([ear_l, ear_r])
    
    # Legs (4)
    leg_positions = [(-0.35, -0.5, 0.35), (0.35, -0.5, 0.35), (-0.35, 0.5, 0.35), (0.35, 0.5, 0.35)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.12, depth=0.7, location=pos, name=f"Leg_{i+1}", vertices=6)
        parts.append(leg)
    
    # Paws
    for i, pos in enumerate(leg_positions):
        paw = create_sphere(radius=0.14, location=(pos[0], pos[1], 0.0), name=f"Paw_{i+1}")
        parts.append(paw)
    
    # Tail (single, curved up)
    tail = create_cone(radius1=0.25, radius2=0.05, depth=1.2, location=(0, -0.8, 1.0), name="Tail", vertices=6)
    rotate_obj(tail, (-30, 0, 0))
    parts.append(tail)
    
    # Tail flame tip
    flame = create_cone(radius1=0.12, radius2=0.0, depth=0.35, location=(0, -1.5, 1.6), name="Tail_Flame", vertices=5)
    parts.append(flame)
    
    # Join all
    creature = join_objects(parts, "Ignisprow")
    
    # Apply colors
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 400, 800, "Ignisprow")
    
    return creature


def build_vulpenkind():
    """Stage 2: Adolescent fox with fire mane and 2 tails (~1000 tris)"""
    random_seed(200)
    parts = []
    
    # Body (larger, more muscular)
    body = create_box(size=(1.3, 1.8, 0.9), location=(0, 0, 1.0), name="Body")
    parts.append(body)
    
    # Chest fluff / mane base
    mane = create_box(size=(1.4, 0.6, 0.5), location=(0, 1.2, 1.3), name="Mane")
    parts.append(mane)
    
    # Head
    head = create_box(size=(0.85, 0.85, 0.75), location=(0, 1.4, 1.6), name="Head")
    parts.append(head)
    
    # Snout (longer)
    snout = create_box(size=(0.5, 0.6, 0.4), location=(0, 1.9, 1.5), name="Snout")
    parts.append(snout)
    
    # Ears (larger, pointed)
    ear_l = create_cone(radius1=0.22, radius2=0.02, depth=0.55, location=(-0.3, 1.2, 2.0), name="Ear_L")
    ear_r = create_cone(radius1=0.22, radius2=0.02, depth=0.55, location=(0.3, 1.2, 2.0), name="Ear_R")
    rotate_obj(ear_l, (0, -20, 0))
    rotate_obj(ear_r, (0, 20, 0))
    parts.extend([ear_l, ear_r])
    
    # Legs (longer, thicker)
    leg_positions = [(-0.45, -0.65, 0.45), (0.45, -0.65, 0.45), (-0.45, 0.65, 0.45), (0.45, 0.65, 0.45)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.15, depth=0.9, location=pos, name=f"Leg_{i+1}", vertices=6)
        parts.append(leg)
    
    # Paws
    for i, pos in enumerate(leg_positions):
        paw = create_sphere(radius=0.17, location=(pos[0], pos[1], 0.0), name=f"Paw_{i+1}")
        parts.append(paw)
    
    # Tails (2, split)
    tail1 = create_cone(radius1=0.3, radius2=0.05, depth=1.5, location=(-0.2, -1.0, 1.2), name="Tail_1", vertices=6)
    tail2 = create_cone(radius1=0.3, radius2=0.05, depth=1.5, location=(0.2, -1.0, 1.2), name="Tail_2", vertices=6)
    rotate_obj(tail1, (-25, 0, -10))
    rotate_obj(tail2, (-25, 0, 10))
    parts.extend([tail1, tail2])
    
    # Tail flames
    for i, base in enumerate([(-0.2, -1.8, 1.8), (0.2, -1.8, 1.8)]):
        flame = create_cone(radius1=0.15, radius2=0.0, depth=0.45, location=base, name=f"Tail_Flame_{i+1}", vertices=5)
        parts.append(flame)
    
    # Join
    creature = join_objects(parts, "Vulpenkind")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 800, 1400, "Vulpenkind")
    
    return creature


def build_infernine():
    """Stage 3: Majestic fire wolf deity with 3 tails and blazing mane (~1800 tris)"""
    random_seed(300)
    parts = []
    
    # Body (large, powerful)
    body = create_box(size=(1.6, 2.2, 1.1), location=(0, 0, 1.2), name="Body")
    parts.append(body)
    
    # Majestic fire mane (large, flowing)
    mane = create_box(size=(1.8, 0.8, 0.7), location=(0, 1.4, 1.7), name="Mane")
    parts.append(mane)
    # Mane side flares
    for side in [-1, 1]:
        flare = create_cone(radius1=0.35, radius2=0.05, depth=0.6, location=(side*0.9, 1.4, 1.6), name=f"Mane_Flare_{side}", vertices=6)
        rotate_obj(flare, (0, side*30, 0))
        parts.append(flare)
    
    # Head (noble)
    head = create_box(size=(1.0, 1.0, 0.9), location=(0, 1.7, 2.0), name="Head")
    parts.append(head)
    
    # Snout
    snout = create_box(size=(0.6, 0.7, 0.5), location=(0, 2.3, 1.9), name="Snout")
    parts.append(snout)
    
    # Ears (tall, regal)
    ear_l = create_cone(radius1=0.25, radius2=0.02, depth=0.7, location=(-0.35, 1.4, 2.4), name="Ear_L")
    ear_r = create_cone(radius1=0.25, radius2=0.02, depth=0.7, location=(0.35, 1.4, 2.4), name="Ear_R")
    rotate_obj(ear_l, (0, -25, 0))
    rotate_obj(ear_r, (0, 25, 0))
    parts.extend([ear_l, ear_r])
    
    # Legs (powerful)
    leg_positions = [(-0.55, -0.8, 0.55), (0.55, -0.8, 0.55), (-0.55, 0.8, 0.55), (0.55, 0.8, 0.55)]
    for i, pos in enumerate(leg_positions):
        leg = create_cylinder(radius=0.18, depth=1.1, location=pos, name=f"Leg_{i+1}", vertices=8)
        # Thigh thicker
        thigh = create_cylinder(radius=0.22, depth=0.4, location=(pos[0], pos[1], 1.0), name=f"Thigh_{i+1}", vertices=8)
        parts.extend([leg, thigh])
    
    # Paws (large, clawed)
    for i, pos in enumerate(leg_positions):
        paw = create_sphere(radius=0.22, location=(pos[0], pos[1], 0.0), name=f"Paw_{i+1}")
        parts.append(paw)
    
    # Three Tails (grand, flowing)
    tail_positions = [(-0.25, -1.2, 1.4), (0, -1.2, 1.5), (0.25, -1.2, 1.4)]
    tail_rotations = [(-20, 0, -15), (-20, 0, 0), (-20, 0, 15)]
    for i, (pos, rot) in enumerate(zip(tail_positions, tail_rotations)):
        tail = create_cone(radius1=0.35, radius2=0.05, depth=1.8, location=pos, name=f"Tail_{i+1}", vertices=8)
        rotate_obj(tail, rot)
        parts.append(tail)
        # Flame tip
        flame = create_cone(radius1=0.18, radius2=0.0, depth=0.55, location=(pos[0], pos[1]-2.0, pos[2]+1.5), name=f"Tail_Flame_{i+1}", vertices=6)
        parts.append(flame)
    
    # Join
    creature = join_objects(parts, "Infernine")
    shade_flat(creature)
    center_origin(creature, bottom=True)
    validate_triangle_budget(creature, 1400, 2200, "Infernine")
    
    return creature


def build_all_ignisprow():
    """Build all 3 stages of Ignisprow line"""
    print("Building Ignisprow line...")
    
    # Clear scene
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    
    # Build each stage
    s1 = build_ignisprow()
    bpy.ops.object.select_all(action='DESELECT')
    
    s2 = build_vulpenkind()
    bpy.ops.object.select_all(action='DESELECT')
    
    s3 = build_infernine()
    bpy.ops.object.select_all(action='DESELECT')
    
    print("Ignisprow line complete!")
    return [s1, s2, s3]


if __name__ == "__main__":
    build_all_ignisprow()