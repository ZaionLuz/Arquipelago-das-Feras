--!nonstrict
-- Identidade por espécie, sem alterar IDs persistidos ou regras econômicas.
local Designs={
 fenix={crest="solar",body="bird",pattern=5},
 cinzelo={crest="embers",body="round",pattern=1},magmarau={crest="horns",body="long",pattern=2},
 fenixfuligem={crest="plume",body="bird",pattern=3},vulcanodrago={crest="horns",body="dragon",pattern=4},
 bolhinho={crest="bubbles",body="round",pattern=2},marilisco={crest="fins",body="serpent",pattern=3},
 carangueperola={crest="claws",body="insect",pattern=4},abissauro={crest="fins",body="dragon",pattern=1},
 brotinho={crest="leaves",body="round",pattern=3},folhuco={crest="ears",body="long",pattern=4},
 aracnoflora={crest="leaves",body="insect",pattern=1},ancestravore={crest="antlers",body="long",pattern=2},
 graozinho={crest="crystals",body="round",pattern=4},escorpiodra={crest="stinger",body="insect",pattern=1},
 esfingeolito={crest="crown",body="long",pattern=2},colossodune={crest="obelisk",body="golem",pattern=3},
 penugem={crest="plume",body="bird",pattern=1},ventanil={crest="fins",body="bird",pattern=2},
 trovoraptor={crest="crystals",body="dragon",pattern=3},aeronimbo={crest="bubbles",body="serpent",pattern=4},
 lodinho={crest="mist",body="round",pattern=2},caudalume={crest="lantern",body="serpent",pattern=4},
 vagalumorte={crest="lantern",body="insect",pattern=3},reinevoento={crest="crown",body="spirit",pattern=1},
 vaporino={crest="mist",body="serpent",pattern=3},magmaterra={crest="crystals",body="long",pattern=1},
 tempestalia={crest="crystals",body="bird",pattern=4},nevoamusgo={crest="antlers",body="spirit",pattern=2},
 cinzavento={crest="plume",body="dragon",pattern=2},
}

-- Proporções desenhadas por espécie: corpo, cabeça, focinho, motivo e temperamento.
local Anatomy={
 cinzelo={.95,.8,.9,1.15,"coal"},magmarau={1.2,.9,1.15,.9,"tusk"},fenixfuligem={.8,1.1,1,.8,"feathers"},vulcanodrago={1.25,1.1,1.25,.9,"magma"},
 bolhinho={1.1,.8,1.1,1.2,"gills"},marilisco={.8,.8,1.3,.85,"sail"},carangueperola={1.35,.65,1.15,.7,"pearl"},abissauro={1.1,.85,1.5,.85,"angler"},
 brotinho={.8,1.1,.85,1.2,"sprout"},folhuco={.85,1,1.2,1,"leafears"},aracnoflora={1.1,.65,1.2,.75,"flower"},ancestravore={1.35,1.2,1.25,.9,"tree"},
 graozinho={1.05,.75,.9,1.1,"geode"},escorpiodra={.85,.6,1.4,.75,"carapace"},esfingeolito={1,1,1.4,1,"headdress"},colossodune={1.2,1.3,1.1,.7,"runes"},
 penugem={.85,.9,.85,1.25,"tuft"},ventanil={.75,1.15,1.2,.85,"ribbons"},trovoraptor={.85,1.1,1.2,.8,"lightning"},aeronimbo={1.1,.9,1.2,1,"cloud"},
 lodinho={1.2,.65,1.15,1.2,"moss"},caudalume={.7,.85,1.5,.75,"lantern"},vagalumorte={.9,.6,1.1,.8,"firefly"},reinevoento={1.1,1.4,1,.9,"mantle"},
 vaporino={1.15,.85,1.1,1.1,"steam"},magmaterra={1.3,.85,1.2,.85,"plates"},tempestalia={.9,1.2,1.1,.8,"storm"},nevoamusgo={.9,1.1,1.2,1.1,"lichen"},cinzavento={.9,1.15,1.4,.8,"ashwings"},fenix={1.05,1.2,1.15,.8,"solar"},
}
for id,a in Anatomy do
 local d=Designs[id];d.width=a[1];d.height=a[2];d.length=a[3];d.head=a[4];d.motif=a[5]
end
return Designs
