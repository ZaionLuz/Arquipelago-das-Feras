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
function I.prepare(source,species,stage)
 local C=require(script.Parent.Creatures)
 local F=require(script.Parent.ModelFactory)
 local Imported=require(script.Parent.ImportedModelFactory)
 local def=assert(C.ById[species],"Espécie não existe no catálogo")
 assert(stage==1 or stage==2 or stage==3,"Estágio deve ser 1, 2 ou 3")
 assert(C.stage(({1,7,15})[stage],species)==stage,"Estágio não disponível para esta espécie")
 assert(source and (source:IsA("Model") or source:IsA("BasePart")),"Selecione um Model ou MeshPart importado")
 local model=source:IsA("Model") and source:Clone() or Instance.new("Model")
 if source:IsA("BasePart") then source:Clone().Parent=model end
 local ok,result=pcall(function()
  local parts={}
  for _,obj in model:GetDescendants() do
   assert(not obj:IsA("LuaSourceContainer"),"Remova scripts do asset importado antes de prepará-lo")
   if obj:IsA("BasePart") then table.insert(parts,obj) end
  end
  assert(#parts>0,"Nenhuma geometria no asset")
  local root=model:FindFirstChild("Root",true)
  local body=model:FindFirstChild("Body",true)
  if not body then for _,p in parts do if p~=root then body=p;body.Name="Body";break end end end
  assert(body and body:IsA("BasePart"),"Body ausente")
  if not root then root=Instance.new("Part");root.Name="Root";root.Size=Vector3.new(.1,.1,.1);root.CFrame=body.CFrame;root.Parent=model end
  local connected={[root]=true}
  local edges={}
  for _,obj in model:GetDescendants() do
   if obj:IsA("Motor6D") or obj:IsA("WeldConstraint") then
    assert(obj.Part0 and obj.Part1 and obj.Part0:IsDescendantOf(model) and obj.Part1:IsDescendantOf(model),"Joint externo ou incompleto")
    table.insert(edges,{obj.Part0,obj.Part1})
   end
  end
  for index=0,#parts do
   for _,edge in edges do if connected[edge[1]] or connected[edge[2]] then connected[edge[1]]=true;connected[edge[2]]=true end end
   local part=index==0 and body or parts[index]
   if part and part~=root and not connected[part] then
    local parent=part==body and root or body
    local joint=Instance.new("Motor6D");joint.Name="J_Imported"..index
    joint.Part0=parent;joint.Part1=part;joint.C0=parent.CFrame:ToObjectSpace(part.CFrame);joint.C1=CFrame.identity
    joint:SetAttribute("Role",part==body and "Body" or part.Name:gsub("^"..species.."_stage%d+_",""))
    joint:SetAttribute("Phase",index*.27);joint.Parent=part
    table.insert(edges,{parent,part});connected[part]=true
   end
  end
  pcall(function() game:GetService("PhysicsService"):RegisterCollisionGroup("Creatures") end)
  Imported.normalizePrefab(model,def,stage,F.validate)
  local rs=game:GetService("ReplicatedStorage")
  local folder=rs:FindFirstChild("ImportedRigs")
  if not folder then folder=Instance.new("Folder");folder.Name="ImportedRigs";folder.Parent=rs end
  model.Name=species.."_Stage"..stage
  local previous=folder:FindFirstChild(model.Name)
  if previous then previous:Destroy() end
  model.Parent=folder
  return model
 end)
 if not ok then model:Destroy();error(result) end
 return result
end
return I
