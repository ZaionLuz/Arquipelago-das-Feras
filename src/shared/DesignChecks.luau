--!nonstrict
-- Executar MANUALMENTE no Studio: require(game.ReplicatedStorage.Shared.DesignChecks).run()
local C=require(script.Parent.Creatures)
local Designs=require(script.Parent.CreatureDesigns)
local Factory=require(script.Parent.ModelFactory)
local Checks={}
function Checks.run()
 local count=0
 for _,def in C.List do
  assert(Designs[def.id],"Design ausente: "..def.id)
  for _,lv in {1,7,15} do
   local model=Factory.build(def,lv)
   assert(model.PrimaryPart,"Sem PrimaryPart: "..def.id)
   assert(model:GetAttribute("Species")==def.id)
   local parts=0
   for _,obj in model:GetDescendants() do
    if obj:IsA("BasePart") then
     parts+=1;assert(obj.Anchored and not obj.CanCollide and not obj.CanTouch)
     assert(obj.Size.X>0 and obj.Size.Y>0 and obj.Size.Z>0)
    end
   end
   assert(parts<=80,"Orçamento de partes excedido: "..def.id)
   local _,size=model:GetBoundingBox();assert(size.Magnitude>0)
   model:Destroy();count+=1
  end
 end
 for id in Designs do assert(C.ById[id],"Design órfão: "..id) end
 print("DesignChecks: "..count.." modelos construídos e destruídos")
 return count
end
return Checks
