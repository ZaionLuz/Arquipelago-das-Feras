--!nonstrict
local Config = require(script.Parent.BlenderModelsConfig)
local B = { VERSION=2, Creatures=Config.Creatures, MeshIdMap=Config.MeshIdMap }
function B.assetId(id)
 if typeof(id)~="string" then return nil end
 local digits=id:match("^rbxassetid://([1-9]%d*)$") or id:match("^([1-9]%d*)$")
 return digits and ("rbxassetid://"..digits) or nil
end
function B.GetCreature(id) return B.Creatures[id] end
function B.GetStage(id,stage)
 local c=B.GetCreature(id)
 return c and c.Stages and c.Stages[stage] or nil
end
function B.GetPart(id,stage,name)
 local s=B.GetStage(id,stage)
 return s and s.Parts and s.Parts[name] or nil
end
function B.ListSpecies()
 local ids={};for id in B.Creatures do table.insert(ids,id) end;table.sort(ids);return ids
end
function B.ListStages(id)
 local out={};local c=B.GetCreature(id)
 if c and c.Stages then for stage in c.Stages do table.insert(out,stage) end end
 table.sort(out);return out
end
function B.GetPartsForStage(id,stage)
 local out={};local s=B.GetStage(id,stage)
 if s and s.Parts then for name in s.Parts do table.insert(out,name) end end
 table.sort(out);return out
end
function B.GetMeshId(id,stage,name,lod)
 local p=B.GetPart(id,stage,name)
 return p and B.assetId((lod==1 and p.LOD1MeshId) or (lod==2 and p.LOD2MeshId) or p.MeshId) or nil
end
function B.Validate()
 local errors,count={},0
 for id,c in B.Creatures do
  count+=1
  if typeof(c)~="table" or typeof(c.Stages)~="table" then table.insert(errors,id..": Stages ausente");continue end
  for stage,s in c.Stages do
   if typeof(stage)~="number" or stage<1 or stage>3 or stage%1~=0 or typeof(s.Parts)~="table" or not next(s.Parts) then
    table.insert(errors,id..": estágio inválido");continue
   end
   for name,p in s.Parts do
    if typeof(p)~="table" or not B.assetId(p.MeshId) then table.insert(errors,id..":"..name..": MeshId inválido") end
    for key,n in {Size=3,CFrame=12,Color=3} do
     local value=p[key]
     if typeof(value)~="table" or #value~=n then table.insert(errors,id..":"..name..":"..key.." inválido")
     else for _,v in value do if typeof(v)~="number" or v~=v or math.abs(v)==math.huge then table.insert(errors,id..":"..name..": valor não finito") end end end
    end
   end
  end
 end
 return {valid=#errors==0 and count>0,configured=count>0,errors=errors,count=count}
end
return B
