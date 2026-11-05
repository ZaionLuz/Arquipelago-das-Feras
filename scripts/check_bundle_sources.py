from pathlib import Path
import sys,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
sources={p.name.replace('.server.luau','').replace('.client.luau','').replace('.luau',''):p.read_text() for p in (root/'src').rglob('*.luau')}
path=Path(sys.argv[1]) if len(sys.argv)>1 else next(root/'releases'/name for name in ('Feras-Bestiario-40.rbxlx','Feras-Creature-Sculpt.rbxlx','Feras-Open-World.rbxlx','Feras-Art-Overhaul.rbxlx','Feras-V7.rbxlx') if (root/'releases'/name).exists())
count=0
for item in ET.parse(path).iter('Item'):
 node=item.find('./Properties/*[@name="Source"]')
 if node is None:continue
 name=item.find('./Properties/string[@name="Name"]').text
 assert node.text==sources[name],f'Bundle desatualizado: {name}'
 count+=1
assert count==len(sources)
print('PASS:',count,'fontes do bundle correspondem ao src:',path.name)
