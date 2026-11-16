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
safe:Destroy();rs:Destroy()
print("PASS: catálogo",#C.List,"IDs únicos, fichas, marcos por nível, prefab preferido, clone local e fallback seguro")
