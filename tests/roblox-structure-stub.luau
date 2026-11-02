-- Stub para testes estruturais. Não implementa render, física ou rotações Roblox.
local V={};V.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end;return V[k] end
local function vector(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V) end
V.__add=function(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__mul=function(a,b)
 if type(b)=="number" then return vector(a.X*b,a.Y*b,a.Z*b) end
 return vector(a.X*b.X,a.Y*b.Y,a.Z*b.Z)
end
local Vector3={new=vector}
local F={};F.__index=F;F.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},F) end
local CFrame={new=function(x,y,z) return setmetatable({Position=type(x)=="table" and x or vector(x,y,z)},F) end,Angles=function() return setmetatable({Position=vector()},F) end}
CFrame.identity=CFrame.new()
local Color={};Color.__index=Color
function Color:Lerp(other,alpha) return setmetatable({r=self.r+(other.r-self.r)*alpha,g=self.g+(other.g-self.g)*alpha,b=self.b+(other.b-self.b)*alpha},Color) end
local function color(r,g,b) return setmetatable({r=r,g=g,b=b},Color) end
local Color3={new=color,fromRGB=function(r,g,b) return color(r/255,g/255,b/255) end}
local enum=setmetatable({},{__index=function(_,k) return k end})
local Enum={PartType=enum,Material=enum,Font=enum,ModelStreamingMode=enum}
local UDim2={fromOffset=function(x,y) return {x,y} end,fromScale=function(x,y) return {x,y} end}
local Methods={}
function Methods:SetAttribute(k,v) self._props["attr_"..k]=v end
function Methods:GetAttribute(k) return self._props["attr_"..k] end
function Methods:IsA(name) return self._class==name or (name=="BasePart" and self._class=="Part") end
function Methods:GetDescendants()
 local out={};local function visit(o) for _,child in o._children do table.insert(out,child);visit(child) end end;visit(self);return out
end
function Methods:Destroy() self._destroyed=true end
function Methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or CFrame.identity end
function Methods:GetBoundingBox()
 local min=vector(math.huge,math.huge,math.huge);local max=vector(-math.huge,-math.huge,-math.huge)
 for _,p in self:GetDescendants() do if p:IsA("BasePart") then
  local pos=p.CFrame.Position;local size=p.Size
  min=vector(math.min(min.X,pos.X-size.X/2),math.min(min.Y,pos.Y-size.Y/2),math.min(min.Z,pos.Z-size.Z/2))
  max=vector(math.max(max.X,pos.X+size.X/2),math.max(max.Y,pos.Y+size.Y/2),math.max(max.Z,pos.Z+size.Z/2))
 end end
 return CFrame.new((min+max)*.5),max-min
end
local Instance={new=function(class)
 return setmetatable({_class=class,_children={},_props={}},{__index=function(t,k) return Methods[k] or t._props[k] end,__newindex=function(t,k,v)
  t._props[k]=v;if k=="Parent" and v then table.insert(v._children,t) end
 end})
end}
