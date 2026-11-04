# Revisão no Roblox Studio — V7

Legenda: ✔ executado headless; ◐ implementado, exige Studio; ✘ pendente.
Todos os passos desta página estão ◐ até um humano registrar resultado.

1. Abra `releases/Feras-V7.rbxlx` como experiência privada e pressione Play. Para validar persistência, use um universo de teste com API Services habilitado; não altere a chave do código para testar em produção.
2. No Command Bar do **servidor**, execute:
   ```lua
   require(game.ServerScriptService.Server.CreatureGallery).build()
   ```
   A galeria só aceita `RunService:IsStudio()`. Teleporte o personagem para `Vector3.new(0,120,0)` e percorra as 91 plataformas. Cada uma tem rótulo e prompt para alternar estágio. Ela não é construída automaticamente no jogo publicado.
3. Revise olhos, inserção do rosto, alinhamento de pés/cauda, interseção de penas, materiais e proporções. Compare a mesma espécie nos níveis 6/7 e 14/15; cabeça do filhote deve parecer maior. Confira Fênix Fuligem e Fênix Solar separadamente. Marque cada ficha em docs/CRIATURAS.md como aprovada ou liste ajustes.
4. Teste idle, andar, serpentear, voo, ataque, dano, desmaio, vitória e a Fênix: mergulho, onda, hover e ascensão. Verifique os Motor6D em WorldModel e Workspace; Lune não simula joints nem renderiza.
5. Com perfil novo, tente atravessar a ponte para Brasa, voar até Pântano, usar prompt remoto e morrer fora de área. O guard deve retornar ao Alvorecer. Abra a ilha via progressão e use Entrar/Viajar; confirme RespawnLocation. Faça o mesmo com perfil legado abaixo do nível mínimo.
6. Com perfil de teste nível 45+ e Dunas/Picos abertos, descubra os três vestígios. Antes do primeiro, não há trilha no diário. O segundo dá a pista e o terceiro revela o altar. Confira saltos dos glifos e colisão das paredes. Não há comando de grant ou moeda incluído para produção.
7. Inicie o altar com duas contas observando. Só o participante vê a introdução. Confirme câmera restaurada ao fechar, perder personagem ou provocar erro na UI. Capture, duplo clique, desconecte durante save, reconecte e valide inventário e cooldown persistido. Repita em servidor real privado: o teste cooperativo headless não substitui a rede Roblox.
8. Device Emulator: 360×640, 390×844, tablet, desktop e gamepad. Confira alvos de 44 px, gaveta, rolagem das ações/ilhas, barra de XP, cores de dificuldade e texto do nível. Abra/feche Bestiário 30 vezes: não deve acumular Viewports, conexões ou modelos.
9. MicroProfiler e memória com 40 feras, mais de um santuário e qualidade Baixo/Médio/Alto. Perto <70: até 30 Hz; médio <150: 15 Hz; longe congelado; >300 oculto. Limites 8/16/24 animados. Confira custo total incluindo mapa e outros jogadores; contagem de peças headless não demonstra FPS em celular.
10. Salve, saia, reentre e confira criaturas, ovos legados, habitats lotados, missões, descobertas, ouro/XP e cooldown. Teste falha de DataStore e lease ocupado: deve recusar entrada, sem reset.

Áudio permanece vazio em Sounds e Config.Assets. A apresentação visual funciona em silêncio; adicionar áudios licenciados é configuração opcional. A homologação visual e multiplayer ainda não foi executada neste ambiente.
