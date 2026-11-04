from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
def shared(names):
 out=[];seen=set()
 def add(name):
  if name in seen:return
  s=(ROOT/f'src/shared/{name}.luau').read_text()
  for dep in re.findall(r'require\(script.Parent.(\w+)\)',s):add(dep)
  seen.add(name)
  s=re.sub(r'require\(script.Parent.(\w+)\)',r'M_\1',s)
  out.append(f'local M_{name}=(function()\n{s}\nend)()')
 for name in names:add(name)
 return '\n'.join(out)
def replace(s):
 s=s.replace('require(game:GetService("ReplicatedStorage").Shared.Strings)','M_Strings')
 return re.sub(r'require\(RS.Shared.(\w+)\)',r'M_\1',s)
