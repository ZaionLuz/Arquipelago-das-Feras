#!/usr/bin/env python3
"""Build reproducible DCC previews and GLBs from actual native Roblox part data.

Not Studio screenshots. Sphere/cylinder/wedge geometry is reconstructed; the legacy
Roblox Head primitive is approximated by an ellipsoid. Native runtime parts and
Motor6D rigs remain the implementation used by the game; GLBs are DCC assets.
Run with Python 3/Pillow and Blender 4.3+: python scripts/sculpt/render_models.py
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import os
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HEROES = ("cinzelo", "folhuco", "carangueperola", "fenix")


def srgb_linear(x):
    return x / 12.92 if x <= 0.04045 else ((x + .055) / 1.055) ** 2.4


def blender_worker(job):
    import bpy
    from mathutils import Matrix, Vector

    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = job.get("samples", 64)
    # Debian's Blender build has no OpenImageDenoise; regular multisampling works.
    scene.cycles.use_denoising = False
    scene.cycles.max_bounces = 4
    scene.cycles.use_adaptive_sampling = True
    scene.cycles.adaptive_threshold = .035
    scene.cycles.adaptive_min_samples = 16
    scene.cycles.diffuse_bounces = 2
    scene.cycles.glossy_bounces = 2
    scene.cycles.transparent_max_bounces = 2
    scene.render.threads_mode = "FIXED"
    scene.render.threads = job.get("threads", 3)
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    scene.view_settings.exposure = -.25
    scene.view_settings.gamma = 1
    scene.world = bpy.data.worlds.new("Atelier world")
    scene.world.use_nodes = True
    scene.world.node_tree.nodes["Background"].inputs[0].default_value = (.23, .25, .36, 1)
    scene.world.node_tree.nodes["Background"].inputs[1].default_value = .5

    def mat(name, rgb, rough=.6, metal=0):
        m = bpy.data.materials.get(name)
        if m:
            return m
        m = bpy.data.materials.new(name)
        m.diffuse_color = tuple(srgb_linear(x) for x in rgb) + (1,)
        m.use_nodes = True
        bsdf = m.node_tree.nodes.get("Principled BSDF")
        bsdf.inputs["Base Color"].default_value = m.diffuse_color
        bsdf.inputs["Roughness"].default_value = rough
        bsdf.inputs["Metallic"].default_value = metal
        return m

    floor_mat = mat("gallery parchment", (.78, .75, .67), .9)
    pedestal_mat = mat("gallery plum", (.16, .18, .28), .7)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -.18))
    floor = bpy.context.object
    floor.name = "GalleryFloor"
    floor.data.materials.append(floor_mat)
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=2, depth=.15, location=(0, 0, -.075))
    pedestal = bpy.context.object
    pedestal.name = "GalleryPedestal"
    pedestal.data.materials.append(pedestal_mat)
    bevel = pedestal.modifiers.new("soft pedestal edge", "BEVEL")
    bevel.width = .045
    bevel.segments = 2
    bpy.ops.object.camera_add()
    camera = bpy.context.object
    camera.name = "ReviewCamera"
    camera.data.type = "ORTHO"
    camera.data.lens = 55
    scene.camera = camera

    def light(name, location, energy, color, size):
        data = bpy.data.lights.new(name, "AREA")
        data.energy = energy
        data.color = color
        data.shape = "DISK"
        data.size = size
        obj = bpy.data.objects.new(name, data)
        scene.collection.objects.link(obj)
        obj.location = location
        obj.rotation_euler = (Vector((0, 0, 2)) - obj.location).to_track_quat("-Z", "Y").to_euler()
        return obj

    key = light("warm sun", (6, -8, 12), 1600, (1, .84, .65), 8)
    fill = light("violet sky", (-7, -1, 7), 1100, (.65, .72, 1), 7)
    rim = light("cream rim", (3, 6, 10), 1800, (1, .89, .69), 6)
    conversion = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
    cache = {}

    def geometry(kind):
        if kind in cache:
            return cache[kind]
        if kind in {"wedge", "corner"}:
            if kind == "wedge":
                verts = [(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
                faces = [(0,1,2),(0,2,3),(3,2,5),(3,5,4),(0,4,5),(0,5,1),(0,3,4),(1,5,2)]
            else:
                verts = [(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5)]
                faces = [(0,1,2),(0,2,3),(0,3,4),(3,2,4),(2,1,4),(1,0,4)]
            # Orient convex faces outward; native wedges face the same local axes.
            center = sum((Vector(v) for v in verts), Vector()) / len(verts)
            corrected = []
            for face in faces:
                a,b,c = (Vector(verts[i]) for i in face)
                outward = ((b-a).cross(c-a)).dot((a+b+c)/3-center)
                corrected.append(face if outward >= 0 else tuple(reversed(face)))
            mesh = bpy.data.meshes.new(kind)
            mesh.from_pydata(verts, [], corrected)
        else:
            if kind in {"sphere", "head"}:
                bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=.5)
            elif kind == "cylinder":
                bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=.5, depth=1)
                # Roblox cylinders have their longitudinal axis on local X.
                for vertex in bpy.context.object.data.vertices:
                    x,y,z = vertex.co
                    vertex.co = (z,y,-x)
            else:
                bpy.ops.mesh.primitive_cube_add(size=1)
            obj = bpy.context.object
            mesh = obj.data.copy()
            bpy.data.objects.remove(obj, do_unlink=True)
        if kind in {"sphere", "head"}:
            for p in mesh.polygons:
                p.use_smooth = True
        mesh.update()
        cache[kind] = mesh
        return mesh

    def build(row):
        root = bpy.data.objects.new(row["id"] + "_stage" + str(row["stage"]), None)
        scene.collection.objects.link(root)
        meshes = []
        for part in row["parts"]:
            if part["class"] not in {"Part","WedgePart","CornerWedgePart"}:
                raise ValueError("Unsupported native geometry: "+part["class"]+" / "+part["name"])
            if part.get("alpha", 1) < .05:
                continue
            kind = ("corner" if part["class"] == "CornerWedgePart" else "wedge" if part["class"] == "WedgePart" else
                    "head" if "Head" in part["mesh"] else "sphere" if "Sphere" in part["mesh"] or "Ball" in part["shape"] else
                    "cylinder" if "Cylinder" in part["shape"] else "block")
            obj = bpy.data.objects.new(part["name"], geometry(kind).copy())
            scene.collection.objects.link(obj)
            obj.parent = root
            cf = part["cf"]
            rotation = Matrix((cf[3:6], cf[6:9], cf[9:12]))
            size = [a*b for a,b in zip(part["size"], part.get("meshScale", (1,1,1)))]
            obj.matrix_world = (conversion @ rotation).to_4x4() @ Matrix.Diagonal((*size,1))
            obj.location = conversion @ Vector(cf[:3])
            rgb = part["color"]
            color_key = "rgb " + ":".join(str(round(v*255)) for v in rgb)
            shiny = any(w in part["name"].lower() for w in ("eye", "iris", "pearl", "glint"))
            material = mat(color_key + (" shine" if shiny else ""), rgb, .28 if shiny else .65)
            obj.data.materials.clear()
            obj.data.materials.append(material)
            obj["RuntimeFeature"] = part["name"]
            meshes.append(obj)
        return root, meshes

    current = None
    objects = []
    for index, task in enumerate(job["tasks"]):
        row = task["row"]
        key_row = (row["id"],row["stage"])
        if current != key_row:
            for obj in objects:
                mesh = obj.data if obj.type == "MESH" else None
                bpy.data.objects.remove(obj, do_unlink=True)
                if mesh and mesh.users == 0:
                    bpy.data.meshes.remove(mesh)
            root, meshes = build(row)
            objects = meshes + [root]
            current = key_row
        bounds = task.get("frame", row["bounds"])
        low, high = Vector(bounds["low"]), Vector(bounds["high"])
        extent = high-low
        center = conversion @ ((low+high)*.5)
        # Actual grounding; shared adult framing leaves young stages visibly smaller.
        ground = row["bounds"]["low"][1]
        for obj in objects:
            if obj.parent is None:
                obj.location.z = -ground
        center.z -= ground
        span = max(extent.x, extent.y, extent.z*.85)
        radius = max(extent.x, extent.z)*.56
        pedestal.scale = (radius/2, radius/2, 1)
        if task.get("glb"):
            bpy.ops.object.select_all(action="DESELECT")
            for obj in objects:
                obj.select_set(True)
            bpy.context.view_layer.objects.active = objects[0]
            path = Path(task["glb"])
            path.parent.mkdir(parents=True, exist_ok=True)
            bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_extras=True,
                                      export_yup=True, export_materials="EXPORT", export_apply=True)
        side = task.get("side", "front")
        direction = Vector((.7,-1,.48) if side == "front" else (-.7,1,.48)).normalized()
        camera.location = center + direction*max(20,span*3)
        camera.rotation_euler = (center-camera.location).to_track_quat("-Z","Y").to_euler()
        camera.data.ortho_scale = span*1.45
        # Place key/fill/rim relative to framing to keep lighting comparable at all scales.
        for light_obj, offset in ((key,(.7,-1,1.4)),(fill,(-1,-.1,.8)),(rim,(.3,1,1.2))):
            light_obj.location = center + Vector(offset)*span
            light_obj.rotation_euler = (center-light_obj.location).to_track_quat("-Z","Y").to_euler()
            light_obj.data.energy = (1600 if light_obj==key else 1100 if light_obj==fill else 1800)*(span/6)**2
            light_obj.data.size = span*.8
        scene.render.resolution_x = scene.render.resolution_y = task.get("size",320)
        scene.cycles.samples = task.get("samples",job.get("samples",64))
        path = Path(task["path"])
        path.parent.mkdir(parents=True, exist_ok=True)
        scene.render.filepath = str(path)
        fingerprint = hashlib.sha256(json.dumps({"version":2,"row":row,"frame":bounds,"side":side,"size":task.get("size",320),"samples":scene.cycles.samples},sort_keys=True).encode()).hexdigest()
        stamp = path.with_suffix(".sha256")
        if not path.exists() or not stamp.exists() or stamp.read_text().strip()!=fingerprint or job.get("force",False):
            bpy.ops.render.render(write_still=True)
            stamp.write_text(fingerprint+"\n")
        print("SCULPT_RENDER",index+1,len(job["tasks"]),row["id"],row["stage"],side,flush=True)
    print("SCULPT_WORKER_COMPLETE",len(job["tasks"]),flush=True)


def font(size, bold=False):
    from PIL import ImageFont
    name = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    path = Path("/usr/share/fonts/truetype/dejavu")/name
    return ImageFont.truetype(str(path),size)


def compose(data, before=None):
    from PIL import Image, ImageDraw, ImageOps
    dest = ROOT/"docs/sculpt/images"
    adults = [row for row in data["models"] if row["stage"]==3]
    adults.sort(key=lambda row:row["id"])
    sheet = Image.new("RGB",(1600,2300),(27,30,47))
    d = ImageDraw.Draw(sheet)
    d.text((36,24),"ARQUIPÉLAGO DAS FERAS",font=font(36,True),fill=(255,235,193))
    d.text((36,74),"30 esculturas 3D · formas adultas · geometria real dos modelos",font=font(21),fill=(201,202,210))
    d.text((36,108),"Revisão em Blender, não screenshot do Roblox Studio.",font=font(18),fill=(168,176,195))
    for i,row in enumerate(adults):
        x=(i%5)*320;y=160+(i//5)*350
        img=Image.open(dest/"adults"/(row["id"]+".png")).convert("RGB")
        sheet.paste(img.resize((310,310),Image.Resampling.LANCZOS),(x+5,y))
        d.text((x+12,y+316),row["name"],font=font(17,True),fill=(255,235,193))
    sheet.save(dest/"creatures-30-adults.png",optimize=True)
    for adult in adults:
        rows = sorted([r for r in data["models"] if r["id"]==adult["id"]],key=lambda r:r["stage"])
        board = Image.new("RGB",(960,788),(27,30,47));bd=ImageDraw.Draw(board)
        bd.text((24,20),adult["name"],font=font(30,True),fill=(255,235,193))
        bd.text((24,60),"Formas e volumes · frente / costas",font=font(18),fill=(190,194,208))
        for j,row in enumerate(rows):
            x=j*320 if len(rows)>1 else 320
            for k,side in enumerate(("front","back")):
                path=dest/"forms"/(row["id"]+"-"+str(row["stage"])+"-"+side+".png")
                img=Image.open(path).convert("RGB").resize((310,310),Image.Resampling.LANCZOS)
                board.paste(img,(x+5,118+k*330))
            label=("Filhote","Jovem","Adulto")[row["stage"]-1]
            bd.text((x+14,92),label+" · "+str(len(row["parts"]))+" peças",font=font(18,True),fill=(235,216,171))
        board.save(dest/"stages"/(adult["id"]+".png"),optimize=True)
    if before:
        board=Image.new("RGB",(1440,1180),(27,30,47));bd=ImageDraw.Draw(board)
        bd.text((30,24),"ANTES / DEPOIS · MESMA CÂMERA E LUZ",font=font(30,True),fill=(255,235,193))
        bd.text((30,68),"Geometria nativa reconstruída no Blender. Sem retoque de anatomia na imagem.",font=font(19),fill=(190,194,208))
        for i,id in enumerate(HEROES):
            for j,label in enumerate(("before","after")):
                path=(ROOT/"assets/sculpt/baseline"/(id+".png")) if label=="before" else (dest/"comparison"/(id+".png"))
                img=Image.open(path).convert("RGB").resize((350,350),Image.Resampling.LANCZOS)
                x=(i%2)*720+j*350+10;y=150+(i//2)*520
                board.paste(img,(x,y))
                bd.text((x+10,y-30),"ANTES" if j==0 else "DEPOIS",font=font(20,True),fill=(235,216,171))
            row=next(r for r in adults if r["id"]==id)
            bd.text(((i%2)*720+24,y+370),row["name"],font=font(24,True),fill=(255,235,193))
        board.save(dest/"before-after.png",optimize=True)
    # Distribution copies; the lossless PNG renders remain reproducible intermediates.
    finals=[dest/"creatures-30-adults.png",*(dest/"stages").glob("*.png"),*(dest/"heroes").glob("*.png")]
    if before:
        finals.append(dest/"before-after.png")
    for path in finals:
        Image.open(path).convert("RGB").save(path.with_suffix(".webp"),format="WEBP",quality=88,method=6)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--geometry",type=Path)
    parser.add_argument("--baseline",type=Path,default=ROOT/"assets/sculpt/baseline_geometry.json")
    parser.add_argument("--baseline-only",action="store_true")
    parser.add_argument("--quick",action="store_true",help="Only four hero previews, useful during modeling")
    parser.add_argument("--skip-forms",action="store_true")
    parser.add_argument("--ids",help="Comma-separated species for incremental review; no final boards until a complete run")
    parser.add_argument("--compose-only",action="store_true",help="Assemble already-rendered boards and mesh archive")
    parser.add_argument("--force",action="store_true")
    parser.add_argument("--blender",default=os.environ.get("BLENDER_BIN","blender"))
    parser.add_argument("--lune",default=os.environ.get("LUNE_BIN","lune"))
    args=parser.parse_args()
    dest=ROOT/"docs/sculpt/images"
    for folder in (dest/"stages",ROOT/"assets/sculpt/baseline"):
        folder.mkdir(parents=True,exist_ok=True)
    if args.geometry:
        data=json.loads(args.geometry.read_text())
    elif not args.baseline_only:
        geometry=ROOT/"assets/sculpt/geometry.json"
        subprocess.run([args.lune,"run","scripts/sculpt/export_models.luau",str(ROOT),str(geometry)],cwd=ROOT,check=True)
        data=json.loads(geometry.read_text())
    else:
        data={"models":[]}
    baseline=json.loads(args.baseline.read_text()) if args.baseline else None
    adults={r["id"]:r for r in data["models"] if r["stage"]==3}
    old_adults={r["id"]:r for r in baseline["models"] if r["stage"]==3} if baseline else {}
    frames={}
    for id,row in adults.items():
        old=old_adults.get(id,row)
        frames[id]={"low":[min(a,b) for a,b in zip(row["bounds"]["low"],old["bounds"]["low"])],
                    "high":[max(a,b) for a,b in zip(row["bounds"]["high"],old["bounds"]["high"])]}
    tasks=[]
    wanted=set(args.ids.split(",")) if args.ids else None
    if baseline:
        for id in HEROES:
            if wanted and id not in wanted:
                continue
            row=old_adults[id]
            tasks.append({"row":row,"frame":frames.get(id,row["bounds"]),"path":str(ROOT/"assets/sculpt/baseline"/(id+".png")),"size":320 if args.quick else 700,"samples":16 if args.quick else 96})
            if args.quick:
                break
    if not args.baseline_only:
        for id,row in adults.items():
            if wanted and id not in wanted:
                continue
            if args.quick and id not in HEROES:
                continue
            tasks.append({"row":row,"path":str(dest/"adults"/(id+".png")),"size":320,"samples":64,
                          "glb":str(ROOT/"assets/sculpt/glb"/(id+".glb"))})
            if id in HEROES:
                tasks.append({"row":row,"path":str(dest/"heroes"/(id+".png")),"size":700,"samples":128})
                if baseline:
                    tasks.append({"row":row,"frame":frames[id],"path":str(dest/"comparison"/(id+".png")),"size":700,"samples":96})
        if not args.quick and not args.skip_forms:
            for row in data["models"]:
                if wanted and row["id"] not in wanted:
                    continue
                for side in ("front","back"):
                    tasks.append({"row":row,"frame":adults[row["id"]]["bounds"],"side":side,"path":str(dest/"forms"/(row["id"]+"-"+str(row["stage"])+"-"+side+".png")),"size":310,"samples":40})
    job={"tasks":tasks,"force":args.force,"samples":64,"threads":3}
    if not args.compose_only:
        with tempfile.TemporaryDirectory(prefix="feras-sculpt-render-") as temp:
            job_path=Path(temp)/"job.json";job_path.write_text(json.dumps(job))
            env=os.environ.copy();env["XDG_CACHE_HOME"]="/tmp/feras-blender-cache";env["MESA_SHADER_CACHE_DIR"]="/tmp/feras-blender-cache"
            subprocess.run([args.blender,"-b","--factory-startup","--threads","3","--python-exit-code","1","--python",str(Path(__file__).resolve()),"--","--worker",str(job_path)],cwd=ROOT,env=env,check=True)
    if not args.baseline_only and not args.quick and not args.skip_forms and not args.ids:
        assert len(adults)==30 and len(data["models"])==88, "Incomplete sculpture export"
        compose(data,baseline)
        archive=ROOT/"assets/sculpt/meshes.zip"
        with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as z:
            for p in sorted((ROOT/"assets/sculpt/glb").glob("*.glb")):
                z.write(p,p.name)
            z.writestr("README.txt", "ARQUIPELAGO DAS FERAS - 30 adult DCC meshes\n\nThese GLBs reconstruct the actual native runtime part geometry.\nThey preserve feature names and material colors, with Y-up glTF coordinates.\nThey are not uploaded Roblox MeshParts or skinned/animated GLB rigs.\nThe game uses the matching ModelFactory assemblies with Motor6D rigs.\nrig-map.json documents the native joint connections and C0 matrices.\nGenerate with scripts/sculpt/render_models.py; no asset IDs are invented.\n")
            z.writestr("rig-map.json",json.dumps({r["id"]:{"stage":3,"nativeJoints":r["joints"]} for r in data["models"] if r["stage"]==3},separators=(",",":")))
        manifest={"format":1,"source":"native Roblox ModelFactory static geometry","renderer":"Blender Cycles CPU","studioScreenshots":False,
                  "legacyHeadApproximation":"The old Roblox Head mesh is reconstructed as an ellipsoid; new sculpts use exported sphere/wedge/cylinder parts.",
                  "forms":len(data["models"]),"adults":len(adults),"meshArchive":archive.name,"meshArchiveSha256":hashlib.sha256(archive.read_bytes()).hexdigest(),
                  "sourceGeometryCanonicalSha256":hashlib.sha256(json.dumps(data,sort_keys=True,separators=(",",":")).encode()).hexdigest(),
                  "models":[{"id":r["id"],"name":r["name"],"parts":len(r["parts"]),"nativeJoints":len(r["joints"]),
                             "glbSha256":hashlib.sha256((ROOT/"assets/sculpt/glb"/(r["id"]+".glb")).read_bytes()).hexdigest()} for r in adults.values()]}
        manifest["reviewImages"]={"encoding":"WebP quality88; PNG source renders remain reproducible", "files":[str(p.relative_to(ROOT)) for p in sorted((ROOT/"docs/sculpt/images").rglob("*.webp"))]}
        (ROOT/"assets/sculpt/manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n")
        print("PASS DCC review:",len(adults),"adult meshes,",len(data["models"]),"forms",archive.stat().st_size,"bytes")


if __name__=="__main__":
    if "--worker" in sys.argv:
        i=sys.argv.index("--worker")
        blender_worker(json.loads(Path(sys.argv[i+1]).read_text()))
    else:
        main()
