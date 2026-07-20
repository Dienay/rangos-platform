# Matriz de Rastreabilidade

**Versão:** 1.0
**Data:** 12+1/07/2026
**Autor:** Dienay Lima
**Base:** [Requisitos](../sdlc/02-requirements.md), [Estratégia de Testes](../sdlc/04-testing.md)

---

## 1. Como usar este documento

Cada linha conecta um **critério de aceite** de um RF a um **caso de teste** que o comprova. É um artefato vivo — atualizado a cada módulo desenvolvido (ver `docs/sdlc/05-development.md`, seção 3.X.5).

**Legenda de Status:**

- **Pendente** — teste ainda não escrito
- **Implementado** — teste escrito e passando
- **Falhando** — teste escrito, mas quebrando (bug real ou teste desatualizado)
- **Bloqueado** — depende de outro módulo ainda não implementado

**Legenda de Origem:**

- **RF** — decorre diretamente de um critério de aceite documentado em `docs/sdlc/02-requirements.md`
- **Implícito** — regra de robustez/segurança não explicitada no RF original, mas necessária (premissa assumida, sinalizada onde relevante)

---

## 2. Autenticação (RF-01, RF-02, RF-03)

### RF-01 — Cadastro de usuário

| TC     | Critério de Aceite                                                                                   | Origem                | Prioridade | Nível       | Status   |
| ------ | ---------------------------------------------------------------------------------------------------- | --------------------- | ---------- | ----------- | -------- |
| TC-001 | Cadastro com dados válidos (nome, e-mail, telefone, senha, tipo) cria conta                          | RF                    | Crítica    | Integration | Pendente |
| TC-002 | E-mail já cadastrado retorna erro de duplicidade                                                     | RF                    | Crítica    | Integration | Pendente |
| TC-003 | Telefone já cadastrado retorna erro de duplicidade                                                   | RF                    | Alta       | Integration | Pendente |
| TC-004 | Campo `phone` ausente retorna erro de validação                                                      | RF                    | Alta       | Integration | Pendente |
| TC-005 | Telefone em formato inválido (letras, tamanho fora de 10-11 dígitos) retorna erro de validação       | RF                    | Alta       | Integration | Pendente |
| TC-006 | Senha com menos de 8 caracteres retorna erro de validação                                            | RF                    | Crítica    | Unit        | Pendente |
| TC-007 | Tipo de usuário inválido (nem Customer nem Partner) retorna erro de validação                        | RF                    | Média      | Integration | Pendente |
| TC-008 | Campo `name` ausente na requisição retorna erro de validação (422)                                   | Implícito             | Alta       | Integration | Pendente |
| TC-009 | Campo `email` ausente na requisição retorna erro de validação (422)                                  | Implícito             | Alta       | Integration | Pendente |
| TC-010 | Campo `password` ausente na requisição retorna erro de validação (422)                               | Implícito             | Alta       | Integration | Pendente |
| TC-011 | Campo `role` ausente na requisição assume `Customer` como padrão                                     | RF                    | Alta       | Integration | Pendente |
| TC-012 | Formato de e-mail inválido (ex: `"ana@"`) retorna erro de validação                                  | Implícito             | Alta       | Integration | Pendente |
| TC-013 | E-mail duplicado com case diferente (`Ana@x.com` vs `ana@x.com`) é tratado como duplicidade          | RF                    | Alta       | Integration | Pendente |
| TC-014 | Senha com exatamente 8 caracteres (limite mínimo) é aceita                                           | Implícito (boundary)  | Alta       | Unit        | Pendente |
| TC-015 | Senha com exatamente 72 caracteres (limite máximo) é aceita                                          | RF (boundary)         | Alta       | Unit        | Pendente |
| TC-016 | Senha com 73 caracteres (acima do limite máximo) retorna erro de validação                           | RF                    | Alta       | Unit        | Pendente |
| TC-017 | Nome com acentuação/caracteres especiais (ex: "José") é aceito e persistido corretamente             | Implícito             | Média      | Integration | Pendente |
| TC-018 | Tentativa de SQL injection no campo `name` não compromete o banco; dado é tratado como texto literal | Implícito — segurança | Crítica    | Integration | Pendente |
| TC-019 | Tentativa de XSS no campo `name` (ex: `<script>`) é armazenada como texto literal, sem execução      | Implícito — segurança | Alta       | Integration | Pendente |

### RF-02 — Login

| TC     | Critério de Aceite                                                                             | Origem                 | Prioridade | Nível       | Status   |
| ------ | ---------------------------------------------------------------------------------------------- | ---------------------- | ---------- | ----------- | -------- |
| TC-020 | Login com credenciais válidas retorna JWT válido                                               | RF                     | Crítica    | Integration | Pendente |
| TC-021 | Senha incorreta retorna erro genérico (401)                                                    | RF                     | Crítica    | Integration | Pendente |
| TC-022 | E-mail não cadastrado retorna a mesma mensagem genérica de erro                                | RF                     | Crítica    | Integration | Pendente |
| TC-023 | Campo `email` ausente na requisição de login retorna erro de validação (422)                   | Implícito              | Alta       | Integration | Pendente |
| TC-024 | Campo `password` ausente na requisição de login retorna erro de validação (422)                | Implícito              | Alta       | Integration | Pendente |
| TC-025 | Login com e-mail em case diferente do cadastrado é aceito                                      | RF — depende de TC-013 | Média      | Integration | Pendente |
| TC-026 | Token JWT gerado contém claims corretos (`sub` = id do usuário, `role` = papel correto)        | Implícito              | Alta       | Unit        | Pendente |
| TC-027 | Tentativa de SQL injection nos campos de login não compromete o banco nem burla a autenticação | Implícito — segurança  | Crítica    | Integration | Pendente |

### RF-03 — Atualização de perfil

| TC     | Critério de Aceite                                                                                         | Origem    | Prioridade | Nível       | Status   |
| ------ | ---------------------------------------------------------------------------------------------------------- | --------- | ---------- | ----------- | -------- |
| TC-028 | Atualização de nome autenticado reflete imediatamente                                                      | RF        | Alta       | Integration | Pendente |
| TC-029 | Atualização para e-mail já usado por outra conta retorna erro de duplicidade (409)                         | RF        | Alta       | Integration | Pendente |
| TC-030 | Acesso à atualização sem token retorna 401                                                                 | RF        | Crítica    | Integration | Pendente |
| TC-031 | Atualização de senha (8 a 72 caracteres) é aceita; senha antiga deixa de funcionar, nova passa a funcionar | RF        | Crítica    | Integration | Pendente |
| TC-032 | Atualização de senha fora do intervalo de 8 a 72 caracteres retorna erro de validação                      | RF        | Alta       | Unit        | Pendente |
| TC-033 | Token malformado (string inválida, não decodificável) retorna 401                                          | Implícito | Alta       | Integration | Pendente |
| TC-034 | Token expirado retorna 401 (nível unit, com tempo mockado)                                                 | Implícito | Média      | Unit        | Pendente |
| TC-035 | Corpo de atualização vazio (nenhum campo enviado) retorna sucesso sem alterar dados (no-op)                | RF        | Baixa      | Integration | Pendente |
| TC-036 | Atualização de múltiplos campos simultaneamente (nome + e-mail + senha) aplica todas as mudanças           | Implícito | Média      | Integration | Pendente |

---

## 3. Restaurantes (RF-04, RF-05, RF-16)

| TC     | Critério de Aceite                                                     | Origem | Prioridade | Nível       | Status   |
| ------ | ---------------------------------------------------------------------- | ------ | ---------- | ----------- | -------- |
| TC-037 | Listagem vazia exibe mensagem de lista vazia, não erro                 | RF     | Média      | Integration | Pendente |
| TC-038 | Listagem com restaurantes cadastrados exibe nome e informações básicas | RF     | Média      | Integration | Pendente |
| TC-039 | Detalhes de restaurante existente exibem nome, descrição e cardápio    | RF     | Média      | Integration | Pendente |
| TC-040 | ID de restaurante inexistente retorna 404                              | RF     | Média      | Integration | Pendente |
| TC-041 | Partner autenticado cadastra restaurante, vinculado a ele como dono    | RF     | Crítica    | Integration | Pendente |
| TC-042 | Customer autenticado tentando cadastrar restaurante retorna 403        | RF     | Crítica    | Integration | Pendente |

---

## 4. Produtos (RF-06, RF-07, RF-17)

| TC     | Critério de Aceite                                                                 | Origem | Prioridade | Nível       | Status   |
| ------ | ---------------------------------------------------------------------------------- | ------ | ---------- | ----------- | -------- |
| TC-043 | Cardápio de restaurante com produtos exibe nome, preço e descrição                 | RF     | Média      | Integration | Pendente |
| TC-044 | Detalhes de produto existente exibem nome, descrição, preço e restaurante          | RF     | Média      | Integration | Pendente |
| TC-045 | Cadastro de produto vinculado a restaurante próprio é aceito                       | RF     | Crítica    | Integration | Pendente |
| TC-046 | Cadastro de produto vinculado a restaurante inexistente retorna erro de referência | RF     | Alta       | Integration | Pendente |
| TC-047 | Cadastro de produto vinculado a restaurante de outro Partner retorna 403           | RF     | Crítica    | Integration | Pendente |

---

## 5. Carrinho (RF-08 a RF-11)

| TC     | Critério de Aceite                                                               | Origem | Prioridade | Nível       | Status   |
| ------ | -------------------------------------------------------------------------------- | ------ | ---------- | ----------- | -------- |
| TC-048 | Adicionar produto a carrinho vazio cria item com quantidade 1                    | RF     | Alta       | Integration | Pendente |
| TC-049 | Adicionar produto de outro restaurante substitui o carrinho (esvazia o anterior) | RF     | Alta       | Integration | Pendente |
| TC-050 | Remover item do carrinho faz com que ele deixe de aparecer na listagem           | RF     | Média      | Integration | Pendente |
| TC-051 | Alterar quantidade para valor válido (≥1) recalcula o subtotal                   | RF     | Média      | Unit        | Pendente |
| TC-052 | Definir quantidade 0 ou negativa retorna erro de validação                       | RF     | Média      | Unit        | Pendente |
| TC-053 | Visualizar carrinho exibe itens, quantidade, subtotal e total                    | RF     | Média      | Integration | Pendente |

---

## 6. Pedido (RF-12 a RF-15)

| TC     | Critério de Aceite                                                                     | Origem | Prioridade | Nível       | Status   |
| ------ | -------------------------------------------------------------------------------------- | ------ | ---------- | ----------- | -------- |
| TC-054 | Finalizar pedido com carrinho não-vazio cria pedido e esvazia o carrinho               | RF     | Crítica    | Integration | Pendente |
| TC-055 | Finalizar pedido com carrinho vazio retorna erro                                       | RF     | Alta       | Integration | Pendente |
| TC-056 | Histórico de pedidos exibe todos ordenados por data (mais recente primeiro)            | RF     | Média      | Integration | Pendente |
| TC-057 | Detalhes de pedido próprio exibem itens, valores, status e data                        | RF     | Alta       | Integration | Pendente |
| TC-058 | Acessar detalhes de pedido de outro usuário retorna 403                                | RF     | Crítica    | Integration | Pendente |
| TC-059 | Avançar status para o próximo da sequência é refletido no pedido                       | RF     | Alta       | Unit        | Pendente |
| TC-060 | Pular etapas da sequência (ex: Recebido → Entregue) retorna erro de transição inválida | RF     | Crítica    | Unit        | Pendente |
| TC-061 | Retroceder status (ex: Em preparo → Recebido) retorna erro de transição inválida       | RF     | Crítica    | Unit        | Pendente |
| TC-062 | Partner alterando status de pedido de restaurante que não é seu retorna 403            | RF     | Crítica    | Integration | Pendente |

---

## 7. Resumo de Cobertura

| Módulo       | Total de Casos | Implementados | Pendentes | % Concluído |
| ------------ | -------------- | ------------- | --------- | ----------- |
| Autenticação | 36             | 0             | 36        | 0%          |
| Restaurantes | 6              | 0             | 6         | 0%          |
| Produtos     | 5              | 0             | 5         | 0%          |
| Carrinho     | 6              | 0             | 6         | 0%          |
| Pedido       | 9              | 0             | 9         | 0%          |
| **Total**    | **62**         | **0**         | **62**    | **0%**      |

> Atualizar esta tabela junto com o status de cada linha, conforme os módulos forem desenvolvidos.

---

## 8. Casos Ainda Não Incorporados (em discussão)

Identificados por comparação com uma versão anterior do projeto (Node.js), aguardando decisão do PO antes de virarem RF/TC formais:

- **Tamanho máximo do campo `name`** — a versão anterior tinha um bug real de nome aceito sem limite de caracteres.
- **Nome contendo apenas espaços em branco** — a versão anterior tinha um bug real de nome "vazio" (só espaços) sendo aceito.

---

## 9. Próximos Passos

1. Decidir sobre os itens da seção 8 e incorporá-los como RF/TC formais, se aprovados.
2. Atualizar o status de cada linha conforme os testes forem escritos durante a fase de Desenvolvimento.
3. Ao final de cada módulo, sincronizar esta matriz com a seção correspondente em `docs/sdlc/05-development.md`.
