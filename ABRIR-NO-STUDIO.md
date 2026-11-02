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
