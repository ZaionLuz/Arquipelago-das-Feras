--!nonstrict
local R={MaxLevel=3,Slots=9,BuildBase=120}
function R.slot(index)
 if typeof(index)~="number" or index%1~=0 or index<1 or index>9 then return nil end
 return ((index-1)%3-1)*36,(math.floor((index-1)/3)-1)*36
end
function R.available(structures,slot,ignore)
 if not R.slot(slot) then return false end
 for id,entry in structures do if id~=ignore and entry.slot==slot then return false end end
 return true
end
function R.capacity(def,entry) return def.slots+((entry and entry.level or 1)-1)*2 end
function R.buildCost(def) return R.BuildBase*def.idx end
function R.upgradeCost(entry) return 180*entry.level end
function R.validate(raw,unlocked,islands)
 local out={};local occupied={}
 if typeof(raw)=="table" then
  for _,def in islands do local entry=raw[def.id]
   if unlocked[def.id] and typeof(entry)=="table" and R.slot(entry.slot) and not occupied[entry.slot] then
    local level=typeof(entry.level)=="number" and entry.level==entry.level and math.clamp(math.floor(entry.level),1,3) or 1
    out[def.id]={slot=entry.slot,level=level};occupied[entry.slot]=true
   end
  end
 end
 return out
end
return R
