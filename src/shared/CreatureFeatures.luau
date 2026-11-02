--!nonstrict
-- Pequenos conjuntos anatômicos, em vez de emissores, luzes ou acessórios externos.
local F={};local V=Vector3.new;local CF=CFrame.Angles;local T=Enum.PartType
function F.add(p,def,design,stage,y,z,col,dark,accent)
 local motif=design.motif
 local function ball(name,size,pos,color,glow) return p(name,T.Ball,size,pos,color,nil,glow) end
 if motif=="coal" or motif=="geode" or motif=="plates" or motif=="magma" then
  for i=1,stage+1 do p("Plate",T.Block,V(1,.35,1.1),V(0,2+i*.35,-i*.7),dark,CF(.15,0,.25*(i%2)),false) end
  ball("Core",V(.6,.8,.3),V(0,2,1.5),accent,true)
 elseif motif=="gills" or motif=="sail" or motif=="angler" then
  for _,side in {-1,1} do for i=1,2 do
   p("Fin",T.Ball,V(.25,1.1,.9),V(side*1.3,y+(i-1)*.45,z-.5),accent,CF(0,0,side*.5))
  end end
  if motif=="angler" then ball("Lure",V(.5,.5,.5),V(0,y+1.8,z+1),accent,true) end
 elseif motif=="sprout" or motif=="flower" or motif=="leafears" or motif=="lichen" then
  for i=1,(stage==1 and 3 or 5) do
   local a=i*math.pi*2/(stage==1 and 3 or 5)
   p("Petal",T.Ball,V(.6,1.2,.35),V(math.cos(a)*.8,y+1+math.sin(a)*.6,z-.4),accent,CF(0,0,-a))
  end
  ball("Bud",V(.6,.6,.6),V(0,y+1,z-.4),col)
 elseif motif=="tree" or motif=="headdress" or motif=="mantle" then
  for _,side in {-1,1} do
   p("Mantle",T.Ball,V(.6,stage==3 and 2.6 or 1.4,1.4),V(side*1.15,y-.2,z-.6),accent,CF(0,0,side*.25))
   if stage>=2 then p("Branch",T.Block,V(1.1,.3,.3),V(side*1.5,y+1.5,z),dark,CF(0,0,side*.3)) end
  end
 elseif motif=="pearl" or motif=="carapace" or motif=="firefly" then
  local shell=ball("Shell",V(3.2,.9,3.5),V(0,3,0),dark)
  if motif=="pearl" then ball("Pearl",V(1,1,1),V(0,3.65,0),Color3.fromRGB(239,226,240))
  elseif motif=="firefly" then ball("Lantern",V(1.3,1,1.2),V(0,2,-1.6),accent,true) end
 elseif motif=="tusk" or motif=="runes" then
  for _,side in {-1,1} do
   p("Tusk",T.Block,V(.3,stage==3 and 1.7 or .7,.3),V(side*.9,y-.1,z+1),accent,CF(-.3,0,side*.2))
  end
  if motif=="runes" then ball("Rune",V(.4,1.4,.2),V(0,3.8,1.7),accent,true) end
 elseif motif=="cloud" or motif=="steam" or motif=="moss" then
  for i=1,stage+1 do ball("Cloud",V(1,.6,1),V((i-2)*.6,y+.8,z-.6),accent,motif=="steam") end
 elseif motif=="lantern" then
  p("Antenna",T.Block,V(.15,1.3,.15),V(0,y+1,z+.2),dark,CF(.4,0,0));ball("Lantern",V(.7,.7,.7),V(0,y+1.8,z+.6),accent,true)
 elseif motif=="solar" then
  -- Halo e cauda solar próprios já são gerados pelo ModelFactory.
 else
  -- Feathers, ribbons, lightning, ashwings, tuft e storm têm penas distintas.
  for _,side in {-1,1} do for i=1,stage+1 do
   p("Feather",T.Ball,V(.35,1.2+i*.35,.4),V(side*(.5+i*.35),y+.6,z-i*.4),i%2==0 and accent or dark,CF(.2,0,side*.55),motif=="lightning" or motif=="storm")
  end end
 end
end
return F
