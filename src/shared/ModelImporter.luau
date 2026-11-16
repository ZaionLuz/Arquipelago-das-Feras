--!nonstrict
-- Ferramenta para o Command Bar do Studio. Nunca roda automaticamente.
local I={}
function I.inspect()
 local rs=game:GetService("ReplicatedStorage")
 local folder=rs:FindFirstChild("ImportedRigs")
 local report={}
 if not folder then return report end
 local C=require(script.Parent.Creatures)
 local F=require(script.Parent.ModelFactory)
 for _,prefab in folder:GetChildren() do
  local id,stage=prefab.Name:match("^(.+)_Stage([123])$")
  stage=tonumber(stage)
  if id and C.ById[id] then
   local model=F.build(C.ById[id],({1,7,15})[stage],{preview=true})
   table.insert(report,{species=id,stage=stage,source=model:GetAttribute("GeometrySource")})
   model:Destroy()
  else
   table.insert(report,{name=prefab.Name,error="Nome esperado: species_Stage1/2/3 e species precisa existir no catálogo"})
  end
 end
 return report
end
return I
