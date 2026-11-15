"""
Geometry Utilities for Arquipelago Starters
Low-poly procedural primitives, joining, shading, triangle counting
"

import bpy
import bmesh
from mathutils import Vector, Matrix, Euler
from math import radians, sin, cos, pi
import random


# =============================================================================
# PRIMITIVES
# =============================================================================

def create_box(size=(1, 1, 1), location=(0, 0, 0), name="Box"):
    """Create a cube with given dimensions"""
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj


def create_sphere(radius=1, location=(0, 0, 0), name="Sphere", segments=12):
    """Create a low-poly icosphere"""
    bpy.ops.mesh.primitive_ico_sphere_add(radius=radius, location=location, subdivisions=1)
    obj = bpy.context.active_object
    obj.name = name
    return obj


def create_cone(radius1=1, radius2=0, depth=2, location=(0, 0, 0), name="Cone", vertices=8):
    """Create a low-poly cone"""
    bpy.ops.mesh.primitive_cone_add(radius1=radius1, radius2=radius2, depth=depth, location=location, vertices=vertices)
    obj = bpy.context.active_object
    obj.name = name
    return obj


def create_cylinder(radius=1, depth=2, location=(0, 0, 0), name="Cylinder", vertices=8):
    """Create a low-poly cylinder"""
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth, location=location, vertices=vertices)
    obj = bpy.context.active_object
    obj.name = name
    return obj


def create_plane(size=1, location=(0, 0, 0), name="Plane"):
    """Create a plane"""
    bpy.ops.mesh.primitive_plane_add(size=size, location=location)
    obj = bpy.context.active_object
    obj.name = name
    return obj


# =============================================================================
# TRANSFORM HELPERS
# =============================================================================

def move_obj(obj, offset):
    obj.location += Vector(offset)


def scale_obj(obj, factor):
    obj.scale *= Vector(factor) if isinstance(factor, (list, tuple)) else factor
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


def rotate_obj(obj, euler_deg):
    obj.rotation_euler = Euler(tuple(radians(a) for a in euler_deg))
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)


def join_objects(objs, name="Joined"):
    """Join multiple objects into one"""
    if not objs:
        return None
    if len(objs) == 1:
        objs[0].name = name
        return objs[0]
    
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    joined = bpy.context.active_object
    joined.name = name
    return joined


def duplicate_obj(obj, name=None):
    """Duplicate an object"""
    new_obj = obj.copy()
    new_obj.data = obj.data.copy()
    bpy.context.collection.objects.link(new_obj)
    if name:
        new_obj.name = name
    return new_obj


# =============================================================================
# MESH OPERATIONS
# =============================================================================

def triangulate(obj):
    """Triangulate mesh"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.quads_convert_to_tris()
    bpy.ops.object.mode_set(mode='OBJECT')


def shade_flat(obj):
    """Set flat shading"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.faces_shade_flat()
    bpy.ops.object.mode_set(mode='OBJECT')


def shade_smooth(obj, angle=30):
    """Set smooth shading with auto-smooth"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.faces_shade_smooth()
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.data.use_auto_smooth = True
    obj.data.auto_smooth_angle = radians(angle)


def recalculate_normals(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode='OBJECT')


def apply_subdivision(obj, levels=1):
    """Apply subdivision surface modifier"""
    mod = obj.modifiers.new(name="Subdiv", type='SUBSURF')
    mod.levels = levels
    mod.render_levels = levels
    mod.subdivision_type = 'SIMPLE'
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


def decimate(obj, ratio=0.5):
    """Reduce triangle count"""
    mod = obj.modifiers.new(name="Decimate", type='DECIMATE')
    mod.ratio = ratio
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


# =============================================================================
# VERTEX COLORS
# =============================================================================

def set_vertex_colors(obj, color, face_indices=None):
    """Set vertex colors on mesh (color = (r,g,b,a) 0-1)"""
    mesh = obj.data
    if not mesh.vertex_colors:
        mesh.vertex_colors.new(name="Col")
    vc_layer = mesh.vertex_colors.active
    
    if face_indices is None:
        face_indices = range(len(mesh.polygons))
    
    for poly_idx in face_indices:
        poly = mesh.polygons[poly_idx]
        for loop_idx in poly.loop_indices:
            vc_layer.data[loop_idx].color = color


def paint_gradient(obj, color_bottom, color_top, axis='Z'):
    """Paint vertical gradient on mesh"""
    mesh = obj.data
    if not mesh.vertex_colors:
        mesh.vertex_colors.new(name="Col")
    vc_layer = mesh.vertex_colors.active
    
    axis_idx = {'X': 0, 'Y': 1, 'Z': 2}[axis]
    verts = [obj.matrix_world @ v.co for v in mesh.vertices]
    min_v = min(v[axis_idx] for v in verts)
    max_v = max(v[axis_idx] for v in verts)
    range_v = max_v - min_v if max_v != min_v else 1
    
    for poly in mesh.polygons:
        for loop_idx in poly.loop_indices:
            vert_idx = mesh.loops[loop_idx].vertex_index
            v = verts[vert_idx]
            t = (v[axis_idx] - min_v) / range_v
            r = color_bottom[0] + (color_top[0] - color_bottom[0]) * t
            g = color_bottom[1] + (color_top[1] - color_bottom[1]) * t
            b = color_bottom[2] + (color_top[2] - color_bottom[2]) * t
            a = color_bottom[3] + (color_top[3] - color_bottom[3]) * t
            vc_layer.data[loop_idx].color = (r, g, b, a)


# =============================================================================
# TRIANGLE COUNTING
# =============================================================================

def count_triangles(obj):
    """Return triangle count of mesh"""
    mesh = obj.data
    if obj.mode == 'EDIT':
        bm = bmesh.from_edit_mesh(mesh)
        return len(bm.faces)
    return sum(len(p.vertices) - 2 for p in mesh.polygons)


def count_vertices(obj):
    return len(obj.data.vertices)


def validate_triangle_budget(obj, budget_min, budget_max, name="Model"):
    tris = count_triangles(obj)
    if tris < budget_min:
        print(f"⚠️ {name}: {tris} tris < minimum {budget_min}")
    elif tris > budget_max:
        print(f"⚠️ {name}: {tris} tris > maximum {budget_max}")
    else:
        print(f"✅ {name}: {tris} tris (budget {budget_min}-{budget_max})")
    return tris


# =============================================================================
# SYMMETRY
# =============================================================================

def mirror_object(obj, axis='X', name=None):
    """Create mirrored copy"""
    new_obj = duplicate_obj(obj, name or f"{obj.name}_Mirrored")
    new_obj.scale[{'X': 0, 'Y': 1, 'Z': 2}[axis]] *= -1
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Fix normals after mirror
    recalculate_normals(new_obj)
    return new_obj


def make_symmetric(obj, axis='X'):
    """Apply mirror modifier and apply"""
    mod = obj.modifiers.new(name="Mirror", type='MIRROR')
    mod.use_axis[{'X': 0, 'Y': 1, 'Z': 2}[axis]] = True
    mod.use_clip = True
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


# =============================================================================
# ORIGIN & CENTERING
# =============================================================================

def center_origin(obj, bottom=True):
    """Set origin to center of bounds (bottom=True puts it at feet)"""
    bpy.context.view_layer.objects.active = obj
    if bottom:
        # Calculate bottom center
        min_z = min((obj.matrix_world @ v.co).z for v in obj.data.vertices)
        center_xy = Vector((0, 0, min_z))
        # Move geometry up so bottom is at origin
        for v in obj.data.vertices:
            v.co.z -= min_z
    else:
        bpy.ops.object.origin_set(type='ORIGIN_CENTER_OF_MASS', center='BOUNDS')
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)


def center_geometry(obj):
    """Center geometry at object origin"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.origin_set(type='ORIGIN_CENTER_OF_MASS', center='BOUNDS')
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)


# =============================================================================
# EXTRUSION & MODIFICATION
# =============================================================================

def extrude_faces(obj, face_indices, distance, normal=True):
    """Extrude specific faces"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    bm = bmesh.from_edit_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    for idx in face_indices:
        if idx < len(bm.faces):
            bm.faces[idx].select = True
    bmesh.update_edit_mesh(obj.data)
    if normal:
        bpy.ops.mesh.extrude_region_move(TRANSFORM_OT_translate={"value": (0, 0, distance)})
    else:
        bpy.ops.mesh.extrude_region_move(TRANSFORM_OT_translate={"value": (0, 0, distance)})
    bpy.ops.object.mode_set(mode='OBJECT')


def inset_faces(obj, face_indices, thickness):
    """Inset specific faces"""
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    bm = bmesh.from_edit_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    for idx in face_indices:
        if idx < len(bm.faces):
            bm.faces[idx].select = True
    bmesh.update_edit_mesh(obj.data)
    bpy.ops.mesh.inset(thickness=thickness)
    bpy.ops.object.mode_set(mode='OBJECT')


# =============================================================================
# CLEANUP
# =============================================================================

def remove_doubles(obj, threshold=0.0001):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.remove_doubles(threshold=threshold)
    bpy.ops.object.mode_set(mode='OBJECT')


def delete_loose_geometry(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.delete_loose()
    bpy.ops.object.mode_set(mode='OBJECT')


# =============================================================================
# UTILITY
# =============================================================================

def get_bounding_box(obj):
    """Return (min, max) vectors in world space"""
    coords = [obj.matrix_world @ v.co for v in obj.data.vertices]
    min_v = Vector((min(c.x for c in coords), min(c.y for c in coords), min(c.z for c in coords)))
    max_v = Vector((max(c.x for c in coords), max(c.y for c in coords), max(c.z for c in coords)))
    return min_v, max_v


def get_dimensions(obj):
    min_v, max_v = get_bounding_box(obj)
    return max_v - min_v


def random_seed(seed=42):
    random.seed(seed)


if __name__ == "__main__":
    # Quick test
    print("geometry_utils.py loaded")
    print("Available functions:")
    for name in dir():
        if not name.startswith('_'):
            print(f"  {name}")