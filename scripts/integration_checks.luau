local Loader=require("./loader")
local rb=require("@lune/roblox")
local C=Loader.load("src/shared/Creatures.luau")
local Lore=Loader.load("src/shared/SpeciesLore.luau")
local Evo=Loader.load("src/shared/EvolutionSystem.luau")
local Registry=Loader.load("src/shared/BlenderModels.luau")
local F=Loader.load("src/shared/ModelFactory.luau")
local Elements=Loader.load("src/shared/Elements.luau")
local Skills=Loader.load("src/shared/Skills.luau")
local seen={}
for _,def in C.List do
 assert(not seen[def.id]);seen[def.id]=true
 assert(typeof(def.name)=="string" and #def.name>0 and typeof(def.el)=="string")
 assert(Elements.Color[def.el] and Skills[def.shape],"Elemento ou habilidade ausente: "..def.id)
 assert(Lore[def.id] and typeof(Lore[def.id].description)=="string")
 for _,lv in {1,6,7,14,15,100} do
  local info=assert(Evo.info({id=def.id,lv=lv}))
  assert(info.stage==C.stage(lv,def.id) and info.maxStage==3 and not info.ascensionEnabled)
 end
end
assert(not Evo.info({id="unknown",lv=1}) and not Evo.info({id=C.List[1].id,lv=0/0}))
assert(not Registry.assetId("example") and not Registry.assetId("rbxassetid://...") and not Registry.assetId("rbxassetid://0"))
assert(Registry.assetId("42")=="rbxassetid://42")
-- Um prefab nativo permite testar prioridade e isolamento sem publicar mesh ou chamar a rede.
local rs=rb.Instance.new("Folder")
local folder=rb.Instance.new("Folder");folder.Name="ImportedRigs";folder.Parent=rs
local def=C.List[1]
local prefab=F.build(def,1,{preview=true,proceduralOnly=true})
prefab.Name=def.id.."_Stage1";prefab.Parent=folder
local loader=Loader.new({game={GetService=function(_,name) if name=="ReplicatedStorage" then return rs end;error("Rede não deve ser usada para prefab") end}})
local factory=loader("src/shared/ModelFactory.luau")
local model=factory.build(def,1,{preview=true})
assert(model~=prefab and model:GetAttribute("GeometrySource")=="BlenderImported")
factory.validate(model)
model:Destroy()
local fallback=factory.build(def,7,{preview=true})
assert(fallback:GetAttribute("GeometrySource")=="ProceduralFallback")
fallback:Destroy()
local unsafe=rb.Instance.new("Script");unsafe.Parent=prefab
local safe=factory.build(def,1,{preview=true})
assert(safe:GetAttribute("GeometrySource")=="ProceduralFallback")
safe:Destroy();unsafe:Destroy()
local dangling=rb.Instance.new("Part");dangling.Name="Unlinked";dangling.Parent=prefab
local rejected=factory.build(def,1,{preview=true});assert(rejected:GetAttribute("GeometrySource")=="ProceduralFallback");rejected:Destroy();dangling:Destroy()
local joint
for _,obj in prefab:GetDescendants() do if obj:IsA("Motor6D") then joint=obj;break end end
local original=joint.Part0
local external=rb.Instance.new("Part");joint.Part0=external
rejected=factory.build(def,1,{preview=true});assert(rejected:GetAttribute("GeometrySource")=="ProceduralFallback");rejected:Destroy()
joint.Part0=original;external:Destroy()
local importer=loader("src/shared/ModelImporter.luau")
local loose=rb.Instance.new("Part");loose.Size=rb.Vector3.new(1,1,1)
local prepared=importer.prepare(loose,def.id,1)
assert(prepared.Parent==folder and prepared.PrimaryPart.Name=="Root")
local displayed=factory.build(def,1,{preview=true})
assert(displayed:GetAttribute("GeometrySource")=="BlenderImported")
factory.validate(displayed);displayed:Destroy();loose:Destroy();rs:Destroy()
print("PASS: catálogo",#C.List,"IDs únicos, fichas, marcos por nível, prefab preferido, clone local e fallback seguro")

-- O contrato atual de CreateMeshPartAsync recebe Content, sem tocar na rede neste teste.
local emptyRS=rb.Instance.new("Folder")
local meshCalls=0
local config={Creatures={[def.id]={Stages={[1]={Parts={Body={
 MeshId="42",Size={1,1,1},CFrame={0,0,0,1,0,0,0,1,0,0,0,1},Color={.5,.6,.7},Material="SmoothPlastic"
}}}}}},MeshIdMap={}}
local asset={CreateMeshPartAsync=function(_,content)
 assert(type(content)=="table" and content.uri=="rbxassetid://42")
 meshCalls+=1;return rb.Instance.new("Part")
end}
local registryLoader=Loader.new({
 Content={fromUri=function(uri) return {uri=uri} end},
 game={GetService=function(_,name) return name=="ReplicatedStorage" and emptyRS or asset end}
},{["src/shared/BlenderModelsConfig.luau"]=config})
local rf=registryLoader("src/shared/ModelFactory.luau")
for _=1,2 do
 local meshModel=rf.build(def,1,{preview=true})
 assert(meshModel:GetAttribute("GeometrySource")=="BlenderImported")
 rf.validate(meshModel);meshModel:Destroy()
end
assert(meshCalls==1,"Mesh não deve ser recriado a cada spawn")
emptyRS:Destroy()
print("PASS: Content.fromUri, criação de mesh por serviço simulado e cache sem rede")
