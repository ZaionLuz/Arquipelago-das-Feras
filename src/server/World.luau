--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local I=require(RS.Shared.Islands);local C=require(RS.Shared.Creatures);local MF=require(RS.Shared.ModelFactory)
local Data=require(script.Parent.DataService)
local Sanctuary=require(script.Parent.SanctuaryService)
local W={};local rng=Random.new(7)
function W.pos(i) local a=(i-1)/#I.List*math.pi*2;return Vector3.new(math.cos(a)*150,10,math.sin(a)*150) end
function W.build()
 local old=workspace:FindFirstChild("Arquipelago");if old then old:Destroy() end
	local f=Instance.new("Folder");f.Name="Arquipelago";f.Parent=workspace
	for i,def in I.List do
		local p=W.pos(i)
		local base=Instance.new("Part");base.Shape=Enum.PartType.Cylinder;base.Size=Vector3.new(8,80,80);base.CFrame=CFrame.new(p)*CFrame.Angles(0,0,math.rad(90))
		base.Anchored=true;base.Color=def.ground;base.Material=Enum.Material.Slate;base.Name=def.name;base.Parent=f
		require(script.Parent.IslandArchitecture).build(f,p,def)
		require(script.Parent.Biomes).decorate(f,p,def)
	end
	for i=1,#I.List do -- pontes ligam as ilhas em anel
		local p1,p2=W.pos(i),W.pos(i%#I.List+1);local mid=(p1+p2)/2+Vector3.new(0,3.6,0)
		local b=Instance.new("Part");b.Anchored=true;b.Size=Vector3.new(9,1,(p2-p1).Magnitude);b.CFrame=CFrame.lookAt(mid,mid+(p2-p1))
		b.Material=Enum.Material.WoodPlanks;b.Color=Color3.fromRGB(150,105,60);b.Parent=f
	end
	local w=Instance.new("Part");w.Anchored=true;w.CanCollide=false;w.Size=Vector3.new(1200,2,1200);w.Position=Vector3.new(0,-4,0)
	w.Material=Enum.Material.Glass;w.Color=Color3.fromRGB(60,140,210);w.Transparency=.35;w.Parent=f
	local L=game:GetService("Lighting")
 L.Brightness=2;L.EnvironmentDiffuseScale=.6;L.EnvironmentSpecularScale=.4;L.ClockTime=14;L.GlobalShadows=true
	local at=Instance.new("Atmosphere");at.Density=0.25;at.Haze=1.2;at.Color=Color3.fromRGB(200,190,255);at.Parent=L
	local bl=Instance.new("BloomEffect");bl.Intensity=0.5;bl.Size=24;bl.Threshold=1.8;bl.Parent=L
	local cc=Instance.new("ColorCorrectionEffect");cc.Saturation=0.2;cc.Contrast=0.08;cc.Parent=L
	local s=Instance.new("SpawnLocation");s.Anchored=true;s.Size=Vector3.new(10,1,10);s.Position=W.pos(1)+Vector3.new(0,5,30);s.Parent=f
end
function W.refresh(p)
	local root=workspace:FindFirstChild("Criaturas") or Instance.new("Folder",workspace);root.Name="Criaturas"
	local old=root:FindFirstChild(tostring(p.UserId));if old then old:Destroy() end
	local d=Data.get(p);if not d then return end
	Sanctuary.refresh(p)
 local visualCount=0;local occupied=0
 for id,list in d.habitat do if d.sanctuary[id] and #list>0 then occupied+=1 end end
 local perHabitat=math.min(2,math.max(1,math.floor(12/math.max(1,occupied))))
 local mine=Instance.new("Folder");mine.Name=tostring(p.UserId)
	for isl,list in d.habitat do
		local center=Sanctuary.position(p,isl)
  if not center then continue end
		for k,uid in list do
   if k>perHabitat or visualCount>=12 then continue end -- Representantes visuais; todas as feras seguem produzindo.
			local cr=d.creatures[uid]
			if cr and uid~=d.companion then
    visualCount+=1
				local displayed=math.min(#list,perHabitat)
    local radius=displayed==1 and 0 or 8
    local a=k/displayed*math.pi*2;local m=MF.build(C.ById[cr.id],cr.lv)
				local _,dimensions=m:GetBoundingBox();local largest=math.max(dimensions.X,dimensions.Y,dimensions.Z)
    if largest>9 then m:ScaleTo(m:GetScale()*9/largest) end
    local bc,bs=m:GetBoundingBox();local lift=m:GetPivot().Position.Y-(bc.Position.Y-bs.Y/2)
				m:PivotTo(CFrame.new(center+Vector3.new(math.cos(a)*radius,.5+lift,math.sin(a)*radius),center+Vector3.new(0,.5+lift,0)));if d.pass and d.pass.Aura then local h=Instance.new("Highlight");h.FillTransparency=1;h.OutlineColor=Color3.fromRGB(255,215,0);h.Parent=m end
				m:SetAttribute("Family",C.ById[cr.id].shape);m:SetAttribute("OwnerUserId",p.UserId);m:SetAttribute("CreatureUid",uid)
				m.Parent=mine
			end
		end
	end
	mine.Parent=root
 require(script.Parent.CompanionService).sync(p)
end
return W
