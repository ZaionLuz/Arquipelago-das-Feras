# Auditoria do ZIP original

Todos os 16 arquivos de código/configuração e README foram lidos antes das alterações.

## Sistemas presentes
29 IDs de espécies e seis ilhas; catálogo, regras elementais e cruzamentos funcionais em código. Alimentação, produção, ovos, missões, diária e batalha PvE implementados no servidor. Cliente reproduz logs de combate. ModelFactory cria seis famílias com variantes por estágio. Áudio vazio e produtos/passes com ID zero: dependem de configuração, não estão prontos comercialmente.

## Problemas observados
- GetAsync + UpdateAsync sem testar propriedade: duas sessões sobrescrevem progresso.
- nextId aceito sem comparar IDs existentes: Hatch pode substituir criatura.
- snapshot altera o perfil persistente incluindo campos transitórios e expõe recibos.
- Remotes rejeitavam tabelas, mas aceitavam tipos incorretos, infinito e strings ilimitadas; chamadas podiam se sobrepor durante yields.
- Duelos não consensuais; rival usado diretamente como oponente.
- Cenários: mesma plataforma e 16 formas neon aleatórias por ilha; sem direção de bioma.
- Respiração percorre todos os modelos por frame e usa o mesmo movimento.
- Client InvokeServer sem proteção de erro.
- DataStore: reparos por campo existentes, mas sem migração explícita de versão nem proteção contra formato futuro.

## Limitações ainda abertas
Habitat é lista por ilha compartilhada, não construção ou ilha pessoal. Todos os donos podem ter modelos sobrepostos no mesmo centro. Sem UI de convite dedicada, bestiário visual, combate 3v3, habilidades ou novas animações de alimentação/eclosão. HUD original permanece. Catálogo visual ainda necessita modelos por espécie. Não foi feita certificação de compras; IDs continuam desativados. O código de recibos precisa de testes de falha/reentrada antes de habilitar produtos; não ativar monetização nesta entrega.
