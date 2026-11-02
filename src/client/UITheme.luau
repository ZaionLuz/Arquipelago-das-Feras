--!nonstrict
local T={Ink=Color3.fromRGB(231,240,237),Muted=Color3.fromRGB(173,193,191),Panel=Color3.fromRGB(18,35,42),Card=Color3.fromRGB(32,53,61),Accent=Color3.fromRGB(239,191,95),Mint=Color3.fromRGB(105,210,165)}
function T.round(o,radius) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,radius or 10);c.Parent=o end
function T.stroke(o) local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(111,145,150);s.Transparency=.6;s.Thickness=1;s.Parent=o end
function T.label(parent,text,size)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.TextColor3=T.Ink;l.TextSize=size or 15;l.TextWrapped=true;l.Font=Enum.Font.GothamMedium;l.Parent=parent;return l
end
function T.button(parent,text,callback)
 local b=Instance.new("TextButton");b.Text=text;b.Font=Enum.Font.GothamBold;b.TextSize=14;b.TextWrapped=true;b.BackgroundColor3=T.Card;b.TextColor3=T.Ink;b.AutoButtonColor=true;b.Selectable=true;b.Parent=parent;T.round(b);T.stroke(b);b.Activated:Connect(callback);return b
end
return T
