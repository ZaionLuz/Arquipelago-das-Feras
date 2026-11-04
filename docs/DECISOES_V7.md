# Decisões V7

- Manter os 30 IDs, nível máximo 100 e evolução 7/15. Fênix Fuligem continua espécie geral e a Fênix especial é adulta, sem estágio 4 disponível.
- Access/LevelBands são puros e configuráveis; região e transporte ficam na sessão do servidor. Direitos legados são preservados com marca explícita; perfis novos só abrem Alvorecer.
- Santuário Solar integrado às Dunas, sem oitava ilha. Glyphs também usam Picos. No estado 0, o payload do diário é apenas `{stage=0}`. A regra de sigilo se refere ao payload especial: o catálogo compartilhado e a Fênix Fuligem pública já existem na base e não constituem proteção contra mineração do cliente.
- Criaturas especiais novas só aceitam phoenix_sanctuary. Um ovo especial já persistido antes da V7 precisa de permissão de migração vinculada ao nonce para eclosão legada: exceção estritamente limitada a esse item, não fonte nova. Isso concilia preservação do legado com exclusividade de novas obtenções; testes sem essa permissão devem recusar legacy_egg. O campo não é aceito de remotes.
- Modelos serão primitives/meshes internos, sem assets externos; Motor6D/WeldConstraint substituem CFrame por peça. Métricas automáticas não equivalem a aprovação estética.
- Raridade numérica legada e IDs de missões persistem. Não retirar ilhas de perfis antigos nem alterar nível/XP na migração. Campos ainda desconhecidos devem ser conservados no envelope bruto; entrada corrompida/futura não será salva como padrão.
- Flags de rollback em Config.V7. Desligar enforcement não rebaixa dados ou remove criatura; rollback binário para esquema antigo exige backup porque o leitor antigo rejeita versão futura.
