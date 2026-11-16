import base64,hashlib,json,sys
from pathlib import Path
p=Path(sys.argv[1])
data=p.read_bytes()
print('FERAS_BUILD_META='+json.dumps({'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}))
s=base64.b64encode(data).decode()
print('FERAS_BUILD_BEGIN')
for n,i in enumerate(range(0,len(s),12000)):print(f'FERAS_BUILD_{n:04d}='+s[i:i+12000])
print('FERAS_BUILD_END')
