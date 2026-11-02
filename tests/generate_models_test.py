from pathlib import Path
r=Path(__file__).resolve().parents[1]
mods=[('C','Creatures'),('E','Elements'),('Designs','CreatureDesigns'),('Features','CreatureFeatures'),('Factory','ModelFactory')]
parts=[(r/'tests/roblox-structure-stub.luau').read_text()]
for var,name in mods:
 s=(r/f'src/shared/{name}.luau').read_text()
 for old,new in [('Creatures','C'),('Elements','E'),('CreatureDesigns','Designs'),('CreatureFeatures','Features')]:s=s.replace(f'require(script.Parent.{old})',new)
 parts.append(f'local {var}=(function()\n{s}\nend)()')
parts.append('''local total,maxParts=0,0
for _,def in C.List do
 for _,lv in {1,7,15} do
  local m=Factory.build(def,lv,{preview=true});local count=0
  assert(m.PrimaryPart)
  for _,part in m:GetDescendants() do if part:IsA("BasePart") then
   count+=1
   assert(part.Anchored and not part.CanCollide and not part.CanTouch)
   assert(part.Size.X>0 and part.Size.Y>0 and part.Size.Z>0)
  end end
  assert(count<=80,def.id.." excedeu orçamento: "..count)
  maxParts=math.max(maxParts,count);total+=1;m:Destroy()
 end
end
print("PASS: "..total.." modelos em stub estrutural (sem render/física); máximo "..maxParts.." partes")
''')
(r/'tests/models.generated.luau').write_text('\n'.join(parts))
