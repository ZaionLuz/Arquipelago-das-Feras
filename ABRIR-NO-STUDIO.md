# Versão atual: mundo aberto

Abra **releases/Feras-Open-World.rbxlx** pelo menu File → Open from File do Roblox Studio e pressione Play. O mapa aparece durante a execução. Não precisa instalar Node ou colar scripts para abrir esse arquivo. Para editar `src/`, reconstrua com Rojo ou sincronize pelo plugin.

Confira [README](README.md) e [validação da fase atual](docs/open_world/STUDIO_QA.md). As instruções abaixo são históricas; o bundle atual usa esquema de save 6 e não deve ser substituído por um bundle antigo em dados já migrados.

---

# V7 — abrir diretamente

Abra `releases/Feras-V7.rbxlx` no Roblox Studio e pressione Play. O arquivo já inclui os scripts. Leia `docs/QA_STUDIO_V7.md` para galeria, mobile e testes privados. As instruções abaixo são histórico de versões anteriores.

# Como abrir a versão 3

Este ZIP contém um projeto **Rojo**, não um lugar .rbxl pronto. Não arraste o ZIP para o Studio.

1. Extraia o ZIP em uma pasta.
2. Instale Rojo CLI e o plugin oficial Rojo para Roblox Studio (rojo.space).
3. Abra o terminal na pasta que contém default.project.json.
4. Execute `rojo build -o Feras-v3.rbxlx`.
5. Abra Feras-v3.rbxlx no Studio e pressione Play.
6. Para testar persistência, publique como experiência privada de testes e habilite acesso às APIs do Studio nela. Sem DataStore disponível, o jogo recusa o carregamento para proteger dados, em vez de iniciar um perfil descartável.
7. Alternativa de edição contínua: `rojo serve` e conectar pelo plugin.

Leia TESTES-STUDIO.md. Não habilite produtos de monetização: estão bloqueados nesta etapa. O DataStore mantém nome e chaves originais; use experiência de teste isolada para não acessar progresso comercial.

## V4
O ZIP do GitHub contém a raiz Rojo. Execute `rojo build -o Feras-v4.rbxlx`. Novos módulos são mapeados automaticamente pelas pastas existentes. Não habilite produtos reais. Os selos são adquiridos com ouro do jogo e as capturas são validadas no servidor. A nova Fênix é adulta (estágio 3) e o estágio 4 está desativado.

## V5
Gere com `rojo build -o Feras-v5.rbxlx`. Verifique StreamingEnabled e os raios 64/256 no Workspace depois de abrir. Aproximar-se da fera selvagem abre encontro com captura direta ou batalha por turnos. Consulte RELEASE-V5.md para as escolhas e TESTES-STUDIO.md para validação. Não é preciso instalar assets pagos.

## V6 — primeira expedição
Execute `rojo build -o Feras-v6.rbxlx`. Abra a experiência privada, Play e procure Maia no Alvorecer. Capture uma fera, selecione Companheiro na coleção e use Menu → Santuário para visitar/construir. Leia MUNDO.md, SISTEMAS.md e PENDENCIAS.md. Os módulos continuam mapeados pelas pastas já existentes; não precisa colar scripts em locais diferentes.

A versão persistente passa de 3 para 4. Faça os testes de migração em experiência isolada antes de usar dados comerciais. Não é uma versão 100% do briefing: 30 espécies estão integradas e 70 permanecem conceitos de direção artística.
