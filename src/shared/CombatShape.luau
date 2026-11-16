-- Perfis antigos preservados; os nomes anatômicos novos usam equivalentes de combate.
local aliases={Blob="Blob",Beast="Beast",Bird="Bird",Dragon="Dragon",Serpent="Serpent",Insect="Insect",
 Quadruped="Beast",Winged="Bird",Aquatic="Serpent",Arthropod="Insect",Mineral="Blob",Vegetal="Blob",Spectral="Blob",
 Draconic="Dragon",Serpentine="Serpent",Biped="Beast"}
return { Aliases=aliases, resolve=function(shape) return assert(aliases[shape],"Perfil de combate desconhecido: "..tostring(shape)) end }
