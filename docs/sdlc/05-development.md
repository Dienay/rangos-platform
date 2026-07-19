# Desenvolvimento — Rangos

**Versão:** 1.0 (documento vivo — atualizado a cada módulo implementado)
**Data de início:** 12+1/07/2026
**Autor:** Dienay Lima
**Fase do SDLC:** Desenvolvimento
**Base:** [Requisitos](02-requirements.md), [Arquitetura](03-architecture.md), [Estratégia de Testes](04-testing.md)

---

## 1. Introdução

Este documento é um **log vivo** da fase de Desenvolvimento: à medida que cada módulo é implementado, uma nova seção é adicionada registrando o que foi feito, decisões técnicas tomadas durante a codificação (que às vezes refinam o que estava previsto na Arquitetura), problemas encontrados e como foram resolvidos, e o estado de cobertura de testes.

A ideia é que os testes descritos em `04-testing.md` sejam escritos junto com o código de cada módulo, não depois — e que qualquer bug real encontrado durante o desenvolvimento seja documentado aqui como artefato de aprendizado, não descartado.

---

## 2. Status Geral

| Módulo       | RFs                 | Status          | Cobertura |
| ------------ | ------------------- | --------------- | --------- |
| Autenticação | RF-01, RF-02, RF-03 | ⏳ Não iniciado | —         |
| Restaurantes | RF-04, RF-05, RF-16 | ⏳ Não iniciado | —         |
| Produtos     | RF-06, RF-07, RF-17 | ⏳ Não iniciado | —         |
| Carrinho     | RF-08 a RF-11       | ⏳ Não iniciado | —         |
| Pedido       | RF-12 a RF-15       | ⏳ Não iniciado | —         |

> Atualizar esta tabela conforme cada módulo avança: ⏳ Não iniciado → 🔄 Em desenvolvimento → ✅ Concluído.

---

## 3. Modelo de Seção por Módulo

Ao iniciar cada módulo, duplicar a estrutura abaixo (substituindo "Autenticação" pelo módulo correspondente).

### 3.X Módulo: [Nome do Módulo] ([RFs envolvidos])

#### 3.X.1 O que foi implementado

- [Resumo do que foi construído: camadas, endpoints, arquivos principais]

#### 3.X.2 Decisões técnicas tomadas durante a implementação

| Decisão   | Contexto                                                                          |
| --------- | --------------------------------------------------------------------------------- |
| [Decisão] | [Por que foi necessária; se refina algo do documento de Arquitetura, referenciar] |

#### 3.X.3 Problemas encontrados e resolvidos

**[Nome curto do problema]**

- **Sintoma:** [o que quebrou/o que foi observado]
- **Causa:** [causa raiz identificada]
- **Resolução:** [como foi corrigido]
- **Valor para QA:** [o que esse bug ensina — vale registrar mesmo bugs simples, pois viram artefato de portfólio]

#### 3.X.4 Testes implementados

| Tipo        | Arquivo   | Quantidade |
| ----------- | --------- | ---------- |
| Unit        | [caminho] | [nº]       |
| Integration | [caminho] | [nº]       |

Cobertura do módulo: **[%]** (meta RNF-07: 80%+).

#### 3.X.5 Atualização da Matriz de Rastreabilidade

Refletir os novos casos de teste em `docs/qa/matriz-de-rastreabilidade.md`, vinculando cada critério de aceite do RF ao teste correspondente.

---

## 4. Ordem Planejada dos Módulos

1. **Autenticação** (RF-01, RF-02, RF-03) — base para autorização de todos os módulos seguintes.
2. **Restaurantes** (RF-04, RF-05, RF-16) — introduz a relação Partner → Restaurant.
3. **Produtos** (RF-06, RF-07, RF-17) — depende da posse de restaurante já validada no módulo anterior.
4. **Carrinho** (RF-08 a RF-11) — depende de Produto e da regra de restrição a um restaurante.
5. **Pedido** (RF-12 a RF-15) — depende de Carrinho; introduz a máquina de estados sequencial de status.

---

## 5. Próximos Passos

1. Iniciar a implementação pelo módulo de Autenticação, escrevendo testes junto com o código.
2. Preencher a seção 3 correspondente assim que o módulo for concluído.
3. Manter este documento atualizado como histórico do processo de desenvolvimento.
