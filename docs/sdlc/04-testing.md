# Estratégia de Testes

**Versão:** 1.0
**Data:** 12/07/2026
**Autor:** Dienay Lima
**Fase do SDLC:** Testes (estratégia definida antes/durante o Desenvolvimento — abordagem shift-left)
**Base:** [Requisitos](02-requirements.md) e [Arquitetura](03-architecture.md)

---

## 1. Introdução

Este documento define a estratégia de testes do Rangos: o que será testado, em que nível, com quais ferramentas e sob quais critérios. A estratégia é definida antes da implementação (shift-left), para que os testes sejam escritos junto com o código na fase de Desenvolvimento, e não como uma etapa isolada posterior.

Cada teste planejado é rastreável a um RF ou RNF do documento de requisitos.

---

## 2. Objetivos de Teste

- Garantir que os 17 requisitos funcionais (RF-01 a RF-17) atendam seus critérios de aceite (Dado/Quando/Então).
- Validar as regras de autorização por posse (Customer/Partner) definidas na fase de arquitetura.
- Atingir a meta de cobertura de código definida em RNF-07 (80%+) nos fluxos críticos.
- Detectar regressões antes de qualquer merge, via CI/CD (RNF-05).
- Documentar evidências de qualidade que sirvam como artefato de portfólio.

---

## 3. Escopo de Testes

### 3.1 Dentro do escopo

- Toda a API REST (endpoints listados na seção 4 de `03-architecture.md`)
- Regras de negócio das camadas de serviço (ex: transição sequencial de status, restrição de restaurante único no carrinho)
- Autorização e autenticação (JWT, hashing de senha, autorização por posse)
- Fluxos de ponta a ponta do MVP (cadastro → login → navegação → carrinho → pedido)

### 3.2 Fora do escopo (nesta versão)

- Testes de carga em escala de produção (não há ambiente de produção real)
- Testes de penetração profissionais/certificados (apenas varredura básica de vulnerabilidades comuns)
- Testes de aplicativo mobile (funcionalidade fora do escopo do MVP)

---

## 4. Níveis de Teste

| Nível           | O que valida                                                                                      | Ferramenta sugerida                                                                                               | Pasta                |
| --------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------- |
| **Unit**        | Funções isoladas: regras de serviço (ex: validação de transição de status), utilitários, hashing  | `pytest`                                                                                                          | `tests/unit/`        |
| **Integration** | Integração entre camadas (routes → services → repositories → banco)                               | `pytest` + `httpx`/`TestClient` do FastAPI, banco de teste (ex: SQLite em memória ou container Postgres de teste) | `tests/integration/` |
| **Contract**    | Contratos de resposta da API (schemas, status codes) — útil se o frontend for consumidor separado | `schemathesis` (valida contra o OpenAPI gerado pelo FastAPI)                                                      | `tests/contract/`    |
| **E2E**         | Fluxos completos do ponto de vista do usuário (cadastro → pedido)                                 | `Playwright` ou `Cypress` (dependendo da stack do frontend)                                                       | `tests/e2e/`         |
| **Performance** | Tempo de resposta dos endpoints sob carga (RNF-03)                                                | `Locust`                                                                                                          | `tests/performance/` |
| **Security**    | Vulnerabilidades comuns (injeção, autenticação quebrada, exposição de dados)                      | `OWASP ZAP` (varredura automatizada) + checklist manual baseado no OWASP Top 10                                   | `tests/security/`    |

> **Nota de escopo:** Contract, E2E, Performance e Security exigem ferramentas fora do stack definido no planejamento inicial (FastAPI, Docker, GitHub Actions). Isso é esperado — essas ferramentas serão adicionadas como dependências de desenvolvimento/CI, não alteram o stack de produção.

---

## 5. Priorização Baseada em Risco

Nem todo requisito tem o mesmo risco. Priorização de esforço de teste:

| Prioridade  | Critério                                      | RFs envolvidos                                                                                             |
| ----------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Crítica** | Envolve dinheiro, autenticação ou autorização | RF-01, RF-02, RF-12 (criação de pedido), RF-15 (autorização de status), RF-16/RF-17 (autorização de posse) |
| **Alta**    | Regra de negócio complexa, alta chance de bug | RF-08 (restrição de restaurante no carrinho), transições de status                                         |
| **Média**   | CRUD simples sem regra de negócio complexa    | RF-04, RF-05, RF-06, RF-07                                                                                 |
| **Baixa**   | Funcionalidades de conveniência               | RF-03 (atualização de perfil)                                                                              |

Testes de nível **Crítica** devem ter cobertura de casos positivos e negativos obrigatoriamente. Testes de nível **Baixa** podem ter cobertura apenas do caminho feliz nesta fase.

---

## 6. Responsabilidades

> Como você acumula os papéis de Dev, QA e PO, a separação abaixo é lógica/processual, não organizacional — mas vale manter documentada para simular um fluxo profissional real.

| Atividade                                               | Papel responsável                        |
| ------------------------------------------------------- | ---------------------------------------- |
| Definir critérios de aceite                             | PO (já feito em `02-requirements.md`)    |
| Escrever testes unitários e de integração               | Dev, durante a implementação de cada RF  |
| Revisar cobertura e qualidade dos testes                | QA                                       |
| Definir e executar testes E2E, performance e security   | QA                                       |
| Aprovar merge com base nos critérios de saída (seção 8) | QA (ou PO, na ausência de bugs críticos) |

---

## 7. Ambientes de Teste

| Ambiente            | Propósito                                                      | Observações                       |
| ------------------- | -------------------------------------------------------------- | --------------------------------- |
| Local               | Desenvolvimento e testes unitários/integração durante o código | Via `docker-compose up`           |
| CI (GitHub Actions) | Execução automática de unit + integration a cada push/PR       | Bloqueia merge se falhar (RNF-05) |
| Staging _(futuro)_  | Testes E2E, performance e security antes de qualquer deploy    | A definir na fase de Implantação  |

---

## 8. Critérios de Entrada e Saída

### 8.1 Critérios de entrada (para iniciar testes de uma funcionalidade)

- RF correspondente implementado e mergeado na branch de desenvolvimento.
- Critérios de aceite do RF revisados e sem ambiguidade.

### 8.2 Critérios de saída (para considerar uma funcionalidade testada)

- Todos os critérios de aceite (Dado/Quando/Então) do RF cobertos por pelo menos um teste automatizado.
- Cobertura de código nos arquivos da funcionalidade ≥ 80% (RNF-07).
- Nenhum bug crítico ou de alta severidade em aberto para o RF.
- Pipeline de CI passando (verde).

---

## 9. Gestão de Dados de Teste

- Banco de dados de teste isolado do banco de desenvolvimento (ex: schema separado ou container dedicado no `docker-compose`).
- Dados de teste criados via _fixtures_/_factories_ (ex: `factory_boy` ou fixtures nativas do `pytest`), evitando dependência de dados manuais.
- Nenhum dado real ou sensível utilizado em testes (o projeto não lida com dados reais de terceiros, mas o princípio é registrado como boa prática).

---

## 10. Gestão de Defeitos (Bug Lifecycle)

Fluxo simplificado, adequado a projeto solo, mas documentado para simular processo real:

```flow
Novo → Em análise → Em correção → Em validação → Fechado
                                 ↘ Reaberto (se validação falhar)
```

| Severidade | Critério                                                      | SLA sugerido                          |
| ---------- | ------------------------------------------------------------- | ------------------------------------- |
| Crítica    | Bloqueia fluxo principal (ex: não consegue logar)             | Corrigir antes de qualquer novo merge |
| Alta       | Afeta regra de negócio importante, mas há workaround          | Corrigir na mesma sprint/ciclo        |
| Média      | Comportamento incorreto sem impacto direto no fluxo principal | Corrigir no próximo ciclo             |
| Baixa      | Cosmético ou edge case raro                                   | Backlog                               |

---

## 11. Matriz de Rastreabilidade (estrutura)

A matriz completa será mantida em `docs/qa/matriz-de-rastreabilidade.md`, atualizada conforme os testes forem escritos. Estrutura proposta:

| RF    | Critério de Aceite            | Caso de Teste (ID) | Nível       | Status   |
| ----- | ----------------------------- | ------------------ | ----------- | -------- |
| RF-01 | Cadastro com dados válidos    | TC-001             | Integration | Pendente |
| RF-01 | E-mail duplicado retorna erro | TC-002             | Integration | Pendente |
| RF-01 | Senha curta retorna erro      | TC-003             | Unit        | Pendente |
| ...   | ...                           | ...                | ...         | ...      |

> Esta tabela será expandida para os 17 RFs conforme os testes forem implementados na fase de Desenvolvimento.

---

## 12. Métricas de Qualidade

| Métrica                                        | Meta                               | Ferramenta                          |
| ---------------------------------------------- | ---------------------------------- | ----------------------------------- |
| Cobertura de código                            | ≥ 80% nos fluxos críticos (RNF-07) | `pytest-cov`                        |
| Taxa de sucesso do pipeline CI                 | 100% na branch principal           | GitHub Actions                      |
| Bugs críticos em aberto                        | 0 antes de qualquer deploy         | Registro manual (ex: GitHub Issues) |
| Tempo de resposta médio (endpoints de leitura) | < 500ms (RNF-03)                   | `Locust`                            |

---

## 13. Integração com CI/CD

O pipeline de GitHub Actions (`ci.yml`) deve, a cada push/PR:

1. Instalar dependências.
2. Rodar linter (ex: `ruff` ou `flake8`).
3. Rodar testes unitários e de integração (`pytest --cov`).
4. Falhar o pipeline se a cobertura ficar abaixo da meta ou se algum teste quebrar.
5. _(Futuro)_ Rodar testes de contrato/E2E em ambiente de staging antes de deploy.
