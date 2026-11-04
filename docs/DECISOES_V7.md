# Decisões V7

- Manter os 30 IDs, nível máximo 100 e evolução 7/15. Fênix Fuligem continua espécie geral e a Fênix especial é adulta, sem estágio 4 disponível.
- Access/LevelBands são puros e configuráveis; região e transporte ficam na sessão do servidor. Direitos legados são preservados com marca explícita; perfis novos só abrem Alvorecer.
- Santuário Solar integrado às Dunas, sem oitava ilha. Glyphs também usam Picos. No estado 0, o payload do diário é apenas `{stage=0}`. A regra de sigilo se refere ao payload especial: o catálogo compartilhado e a Fênix Fuligem pública já existem na base e não constituem proteção contra mineração do cliente.
- Criaturas especiais novas só aceitam phoenix_sanctuary. Um ovo especial já persistido antes da V7 precisa de permissão de migração vinculada ao nonce para eclosão legada: exceção estritamente limitada a esse item, não fonte nova. Isso concilia preservação do legado com exclusividade de novas obtenções; testes sem essa permissão devem recusar legacy_egg. O campo não é aceito de remotes.
- Modelos serão primitives/meshes internos, sem assets externos; Motor6D/WeldConstraint substituem CFrame por peça. Métricas automáticas não equivalem a aprovação estética.
- Raridade numérica legada e IDs de missões persistem. Não retirar ilhas de perfis antigos nem alterar nível/XP na migração. Campos ainda desconhecidos devem ser conservados no envelope bruto; entrada corrompida/futura não será salva como padrão.
- Flags de rollback em Config.V7. Desligar enforcement não rebaixa dados ou remove criatura; rollback binário para esquema antigo exige backup porque o leitor antigo rejeita versão futura.

## Balanceamento e compatibilidade

- Simulação usa o núcleo real CombatRules.step e as mesmas opções de construção do EncounterService; treino e duelo também passam por esse núcleo, sem duplicar fórmulas de dano. Metas são medidas na média das faixas amostradas: há variação por nível, espécie, elemento e composição. Os JSON registram cada faixa, inclusive resultados fora da meta individual.
- A antiga XP linear atingia níveis cedo demais no ritmo de 50 vitórias/h. Custos por faixa foram calibrados para 0,75/2/4/7/11/16h, sem retirar nível ou XP de perfis antigos. Missões, capturas e alimentação mudam o tempo real; isto é previsão de ritmo, não medição de jogadores.
- Dano varia de 50–150%, arredondado estocasticamente; treino dá +8% vida e +8,5% ataque. Crescimento de estatística é suave e diferenças acima de sete níveis têm pressão adicional; o aviso de +8 na UI explica o salto de risco. A Fênix usa pressão suave, permitindo que contrajogo elemental importe na faixa 45–55; mantém estatísticas ×1,3. Esses coeficientes ficam em CombatRules para recalibração.
- Guardiões usam ×1,17, dentro de 1,15–1,35. Simulação de guardião usa o topo da faixa e equipe raro/comum/raro; não compara um iniciante da faixa ao chefe final como se fosse a recomendação.
- Ouro de desbloqueio foi alterado após a auditoria: o antigo ficava muito abaixo de uma hora de quatro comuns compatíveis. Os novos custos equivalem a uma hora no nível mínimo da faixa anterior. Renda com raros, eventos, passes e offline é maior. Rever LevelBands para recalibrar.
- Captura especial não usa a fuga aleatória/limite de seis selos de animais comuns: aceita até o limite de turnos ou estoque, mantendo a chance de até 15 tentativas compatível com a simulação. Sem preparo, 4% por selo; preparado, ~20,6%. Limite geral é 1–35%.
- Estoque legado acima de 60 criaturas/3 ovos/capacidade visual é preservado. Novas concessões continuam bloqueadas no limite, evitando confundir sanitização com confisco. Desconhecidos/corrompidos essenciais causam recusa antes de escrever; campos extras do envelope persistem.
- CreatureGallery é opt-in no Studio. O sigilo é do payload de descoberta, não de arquivos replicados. Fênix já possuída ou ovo legado autenticado preserva a descoberta.
- O padrão PhoenixMaxPerAccount é 1; captureCount permite elevar o limite sem ignorar capturas anteriores. A exceção legacy_egg continua limitada ao nonce de item anterior à versão 5.
- As receitas foram feitas primeiro e as fichas textuais consolidadas depois; desvio processual registrado, sem afirmar o contrário. A entrega contém as 30 fichas e métricas por estágio.

- Verificação final ampliada: construções/listas/flags inválidos são recusados antes de UpdateAsync; timestamps e metadados numéricos extras de criaturas, ovos e inventários são mantidos em round-trip. Não se limita preservação aos campos conhecidos pelo cliente atual.
