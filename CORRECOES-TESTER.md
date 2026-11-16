# Correções da integração

Base: 31c94bec76ce9680004a96aa4263c4d938def82c.

- 90 linhas duplicadas removidas; inserção duplicada agora causa erro explícito.
- Evolução ativa por nível preservada. Remotes possuem respostas, ownership, validação de UID e rate limit. Não há consumo de itens futuros nem concessão de estágio 4.
- Factory aceita ImportedRigs e registro de IDs reais, rejeita scripts internos, aplica física segura e usa cache/fallback quando assets faltam.
- Expressões padrão e fichas de catálogo adicionadas à expansão; galeria não sobrepõe a Fênix com índice fixo.
- IDs de migração, chaves de saves e restrições da Fênix preservados.
- Testes estruturais contam o catálogo real e mantêm os requisitos visuais das 30 espécies anteriores. A expansão toda é construída nos três estágios e validada nos mesmos orçamentos.
- Os novos visuais reutilizam receitas: isso é registrado como limitação, não uma aprovação estética automática.
- Compilação, execução de suites e arquivos gerados são publicados pelo workflow Validate Roblox build. Resultado final registrado junto da build.

Roblox Studio, renderização, física multiplayer e FPS não foram executados neste ambiente. Importar/publicar os OBJ/FBX é uma etapa necessária para os visuais Blender exatos; a build headless contém as receitas locais e a integração pronta.
