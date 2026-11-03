--!nonstrict
local RS=game:GetService("ReplicatedStorage");local I=require(RS.Shared.Islands);local Rules=require(RS.Shared.SanctuaryRules)
local Theme=require(script.Parent.UITheme)
local U={};local slot=5
function U.render(parent,d,call,render)
 local function card(height)
  local f=Instance.new("Frame");f.Size=UDim2.new(1,-8,0,height);f.BackgroundColor3=Theme.Card;f.Parent=parent;Theme.round(f);return f
 end
 local info=card(70);local t=Theme.label(info,"Seu santuário • 9 posições\nSelecione uma posição e construa ou mova um habitat.",14);t.Size=UDim2.fromScale(1,1)
 local travel=card(48);local home=Theme.button(travel,"Visitar meu santuário",function() call("Home") end);home.Size=UDim2.fromScale(.5,1)
 local pet=Theme.button(travel,"Acariciar companheiro",function() call("Pet") end);pet.Size=UDim2.fromScale(.5,1);pet.Position=UDim2.fromScale(.5,0)
 local grid=card(164);grid.BackgroundTransparency=1;local layout=Instance.new("UIGridLayout");layout.CellSize=UDim2.new(1/3,-6,0,50);layout.CellPadding=UDim2.fromOffset(6,6);layout.Parent=grid
 for index=1,9 do
  local occupied
  for id,entry in d.sanctuary do if entry.slot==index then occupied=I.ById[id].el end end
  local b=Theme.button(grid,index.." • "..(occupied or "Livre"),function() slot=index;render() end)
  if slot==index then b.BackgroundColor3=Color3.fromRGB(78,110,94) end
 end
 for _,def in I.List do
  local entry=d.sanctuary[def.id];local f=card(156)
  local label=Theme.label(f,def.name.." • "..def.el.."\n"..(entry and "Nível "..entry.level.." • Posição "..entry.slot.." • "..#(d.habitat[def.id] or {}).."/"..Rules.capacity(def,entry).." feras" or "Construir: "..Rules.buildCost(def).." ouro"),14)
  label.Size=UDim2.new(1,-12,0,90);label.Position=UDim2.fromOffset(6,0)
  local buttons=entry and {{"Mover → "..slot,function() call("MoveHabitat",def.id,slot) end},{"Melhorar • "..Rules.upgradeCost(entry),function() call("UpgradeHabitat",def.id) end},{"Remover",function() call("RemoveHabitat",def.id) end}} or {{d.unlocked[def.id] and "Construir na posição "..slot or "Desbloqueie a ilha",function() call("BuildHabitat",def.id,slot) end}}
  for k,button in buttons do
   local b=Theme.button(f,button[1],button[2]);b.Size=UDim2.new(1/#buttons,-6,0,48);b.Position=UDim2.new((k-1)/#buttons,3,1,-54)
  end
 end
end
return U
