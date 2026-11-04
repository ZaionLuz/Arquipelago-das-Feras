> V7 atual: consulte [docs/MUNDO.md](docs/MUNDO.md). O conteúdo abaixo registra as versões anteriores.

# Mundo: estado implementado e direção final

## Regiões presentes

| ID persistente | Região | Nível mínimo para novo desbloqueio | Estado real |
|---|---|---:|---|
| Alvorecer | Ilha do Alvorecer | 1 | Nova região inicial, vegetação, acampamento, fonte decorativa, Maia, marco de coleta, fauna e guardião. |
| Brasa | Ilha das Brasas | 1 | Vulcão estilizado, basalto, cristais, fauna de fogo e guardião. Mantida acessível a jogadores legados. |
| Recife | Recife Cristalino | 10 | Corais, cristais e cachoeira estilizada; fauna aquática e guardião. Perfis novos recebem acesso para acomodar o companheiro aquático inicial. |
| Floresta | Floresta Murmurante | 18 | Árvores, flora luminosa, marco, fauna e guardião. |
| Dunas | Dunas Quebradas | 26 | Ruínas e arenito; fauna e guardião. Seu papel futuro de ilha ancestral final ainda precisa de reformulação. |
| Picos | Picos Celestes | 34 | Nuvens e cristais; fauna aérea e guardião. |
| Pantano | Pântano Umbral | 42 | Árvores sombrias e portal decorativo, fauna e guardião. |

Regiões preservam IDs e desbloqueios existentes. O nível só é exigido para novos desbloqueios; não retiramos permissões já conquistadas. Custos de ouro foram reduzidos para evitar a barreira antiga de 22 mil moedas. O botão Viajar leva a uma superfície segura de qualquer ilha desbloqueada; o portal pessoal retorna ao Alvorecer. Pontes existentes continuam transitáveis. As ilhas ainda têm superfícies simples: não há rede completa de cavernas, relevo navegável complexo ou desafios de plataforma homologados.

## Direção de dez regiões

Alvorecer, Brasas, Marés/Recife, Ventos/Picos, Inverno, Raízes/Floresta, Trovão, Profundezas/Pantano, Celestial e Ancestral/Dunas formam o alvo de dez regiões. **Inverno, Trovão e Celestial não foram construídas.** As outras sete não devem ser tratadas como mapas de qualidade final antes de revisão de arte e playtest. Sons de bioma continuam pendentes de assets autorizados; nenhum ID fictício foi acrescentado.

## Exploração e aventura presentes

Maia apresenta os capítulos iniciais, que verificam captura, alimentação, coleta, eclosão, vitória, melhoria de habitat e guardião. O resgate é explícito em Missões e não se repete. Cada marco concede uma essência a cada 120s; a primeira descoberta também dá 30 ouro e 60 XP. Temporizadores e descobertas são persistidos. Perfil e distância são validados no servidor.

Cada ilha tem um guardião representado por uma espécie existente, em nível recomendado da ilha +7. O desafio usa a batalha por turnos e não permite captura. A conclusão é individual, com bônus único de 100 ouro/200 XP, além da recompensa do combate. Ainda não existe elenco de treinadores com história individual, raids ou chefes com rig próprio.

## Santuários pessoais

Terrenos flutuantes de 144×144 studs, fora das ilhas de exploração, distribuídos por sessão com 190 studs entre centros. A origem física pode mudar na reconexão; as posições relativas das estruturas são salvas. Cada jogador tem nove posições com 36 studs de separação. Visitantes podem atravessar o espaço público do servidor, mas todas as ações de construção e manejo usam exclusivamente o perfil do proprietário.

Habitats possuem elemento, nível 1–3 e capacidade; melhora acrescenta duas vagas por nível. O santuário mostra até dois representantes por habitat, no máximo 12 por proprietário; as demais criaturas acomodadas continuam produzindo e aparecem na coleção. Modelos grandes são reduzidos apenas para exibição no habitat, sem alterar atributos. A incubação/reprodução continua acessível pelas mesmas telas, com a base pessoal como destino da coleção.
