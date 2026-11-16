--!nonstrict
-- Prefabs importados têm prioridade. Sem assets, o chamador usa a receita local.
local Registry=require(script.Parent.BlenderModels)
local Designs=require(script.Parent.CreatureDesigns)
local I={}
local cache,failed={},{}
local function metadata(model,def,stage)
 local d=Designs[def.id]
 model.Name=def.name
 model:SetAttribute("Species",def.id);model:SetAttribute("Stage",stage)
 model:SetAttribute("Family",d.family);model:SetAttribute("EyeType",d.eyes)
 model:SetAttribute("HeadType",d.head);model:SetAttribute("TailType",d.tail)
 model:SetAttribute("LimbCount",d.limbs);model:SetAttribute("ArtStyle","BlenderImported")
 model:SetAttribute("GeometrySource","BlenderImported");model:SetAttribute("Expression",d.expression.mouth)
 model:SetAttribute("BlinkOffset",#def.id*.2)
 return model
end
local function normalize(model,def,stage)
 assert(model:IsA("Model"),"Prefab precisa ser Model")
 local root=model:FindFirstChild("Root",true)
 assert(root and root:IsA("BasePart"),"Root ausente")
 model.PrimaryPart=root;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local count=0
 local edges={}
 for _,obj in model:GetDescendants() do
  assert(not obj:IsA("LuaSourceContainer"),"Script não permitido dentro de uma criatura")
  if obj:IsA("BasePart") then
   count+=1
   obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false;obj.Massless=true;obj.Anchored=obj==root
   obj.CollisionGroup="Creatures"
   assert(obj.Size.X>0 and obj.Size.Y>0 and obj.Size.Z>0,"Tamanho inválido")
  elseif obj:IsA("Motor6D") then
   assert(obj.Part0 and obj.Part1 and obj.Part0:IsDescendantOf(model) and obj.Part1:IsDescendantOf(model),"Joint desconectado ou externo")
   table.insert(edges,{obj.Part0,obj.Part1})
   if not obj:GetAttribute("Role") then obj:SetAttribute("Role",obj.Name:gsub("^J_","")) end
   if not obj:GetAttribute("Phase") then obj:SetAttribute("Phase",0) end
  elseif obj:IsA("WeldConstraint") then
   assert(obj.Part0 and obj.Part1 and obj.Part0:IsDescendantOf(model) and obj.Part1:IsDescendantOf(model),"Weld desconectado ou externo")
   table.insert(edges,{obj.Part0,obj.Part1})
  end
 end
 local linked={[root]=true}
 for _=1,count do
  for _,edge in edges do if linked[edge[1]] or linked[edge[2]] then linked[edge[1]]=true;linked[edge[2]]=true end end
 end
 for _,obj in model:GetDescendants() do if obj:IsA("BasePart") then assert(linked[obj],"Parte visual sem ligação ao Root") end end
 assert(count>1 and count<=Designs[def.id].budget[stage],"Orçamento de peças excedido")
 root.Transparency=1
 return metadata(model,def,stage)
end
local function registryModel(def,stage,assetService)
 local s=Registry.GetStage(def.id,stage)
 if not s then return nil end
 local m=Instance.new("Model")
 local ok,result=pcall(function()
  local root=Instance.new("Part");root.Name="Root";root.Size=Vector3.new(.1,.1,.1);root.Transparency=1;root.CFrame=CFrame.new(0,2,0);root.Parent=m
  local parts={Root=root}
  for name,p in s.Parts do
   assert(name~="Root","Root é reservado")
   local id=assert(Registry.assetId(p.MeshId),"MeshId precisa ser um asset real do Roblox")
   -- MeshId não é atribuído diretamente: é uma propriedade protegida no Studio/runtime.
   local part=assetService:CreateMeshPartAsync(id,{CollisionFidelity=Enum.CollisionFidelity.Box,RenderFidelity=Enum.RenderFidelity.Automatic})
   part.Name=name;part.Size=Vector3.new(table.unpack(p.Size));part.CFrame=root.CFrame*CFrame.new(table.unpack(p.CFrame))
   part.Color=Color3.new(table.unpack(p.Color));part.Material=Enum.Material[p.Material or "SmoothPlastic"] or Enum.Material.SmoothPlastic
   part.Transparency=p.Transparency or 0;part.Parent=m;parts[name]=part
  end
  for name,p in s.Parts do
   local parent=parts[p.Parent or (name=="Body" and "Root" or "Body")] or root
   local joint=Instance.new("Motor6D");joint.Name="J_"..name; joint.Part0=parent;joint.Part1=parts[name]
   joint.C0=parent.CFrame:ToObjectSpace(parts[name].CFrame);joint.C1=CFrame.identity
   joint:SetAttribute("Role",p.Role or name);joint:SetAttribute("Phase",0);joint.Parent=parts[name]
  end
  return normalize(m,def,stage)
 end)
 if not ok then m:Destroy();error(result) end
 return result
end
function I.tryBuild(def,stage,validate)
 if not game or not game.GetService then return nil end
 local ok,rs=pcall(function() return game:GetService("ReplicatedStorage") end)
 if not ok or not rs or typeof(rs.FindFirstChild)~="function" then return nil end
 local folder=rs:FindFirstChild("ImportedRigs")
 local prefab=folder and folder:FindFirstChild(def.id.."_Stage"..stage)
 if prefab then
  local clone=prefab:Clone()
  local good,model=pcall(function()
   normalize(clone,def,stage)
   if validate then validate(clone) end
   return clone
  end)
  if good then return model end
  clone:Destroy()
  local key=def.id..":"..stage..":prefab"
  if not failed[key] then failed[key]=true;warn("Prefab inválido; usando receita local:",key,model) end
 end
 local key=def.id..":"..stage
 if cache[key] then return cache[key]:Clone() end
 if failed[key] or not Registry.GetStage(def.id,stage) then return nil end
 local good,model=pcall(function() local result=registryModel(def,stage,game:GetService("AssetService")); if result and validate then validate(result) end;return result end)
 if good and model then cache[key]=model;return model:Clone() end
 failed[key]=true
 warn("Mesh indisponível; usando receita local:",key,model)
 return nil
end
return I
