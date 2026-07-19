# Roadmap — Rangos

**Versão:** 1.0
**Data:** 12+1/07/2026
**Autor:** Dienay Lima
**Base:** Planejamento (01-planejamento-rangos.md), Requisitos (02-requisitos-rangos.md)

---

## 1. Introdução

Este documento organiza tudo que ficou fora do escopo do MVP (seção 5 de `01-planejamento-rangos.md`) em possíveis versões futuras, além de melhorias técnicas e de processo já identificadas ao longo das fases anteriores. Não é um compromisso de prazo — é um mapa de prioridades para orientar o que vem depois do MVP.

---

## 2. Princípio de Priorização

Cada item futuro é avaliado por dois critérios:

- **Valor de portfólio** — o quanto a funcionalidade demonstra uma habilidade técnica ou de QA relevante para o objetivo de transição de carreira.
- **Esforço relativo** — quão isolado ou quão acoplado ao restante do sistema o item é.

Itens de alto valor de portfólio e esforço razoável têm prioridade sobre itens de alto esforço e baixo valor demonstrativo, mesmo que estes últimos pareçam "mais completos" para um produto real.

---

## 3. Versão 1.1 — Refinamento do MVP

Itens que fortalecem o que já existe, sem expandir escopo funcional:

- [ ] Tradução completa da documentação para inglês (Planejamento, Requisitos, Arquitetura, Estratégia de Testes, Desenvolvimento, Implantação) — a ser feita quando os documentos estiverem estáveis, evitando retrabalho por mudanças de regra de negócio.
- [ ] Implementação dos níveis de teste ainda pendentes na Estratégia de Testes: contract, e2e, performance e security (ver `04-testing.md`, seção 4).
- [ ] Revisão do tempo de expiração do JWT (atualmente 7 dias, definido propositalmente para conveniência de desenvolvimento).
- [ ] Matriz de rastreabilidade completa (`docs/matriz-de-rastreabilidade.md`), cobrindo os 17 RFs.

---

## 4. Versão 1.2 — Experiência do Usuário

Funcionalidades que melhoram a experiência sem alterar a arquitetura core:

- [ ] Avaliação de restaurantes (nota e comentário por pedido concluído)
- [ ] Favoritos (restaurantes e produtos)
- [ ] Cupons de desconto

---

## 5. Versão 2.0 — Expansão de Canal

Funcionalidades que exigem novo front-end ou mudança significativa de infraestrutura:

- [ ] Aplicativo Mobile
- [ ] Painel Administrativo completo (hoje o MVP cobre apenas cadastro básico de restaurante/produto pelo próprio Partner)
- [ ] Notificações Push

---

## 6. Versão 3.0 — Funcionalidades Avançadas

Itens de maior complexidade técnica e/ou dependência de serviços externos:

- [ ] Pagamento real (integração com gateway de pagamento)
- [ ] Geolocalização
- [ ] Rastreamento do entregador em tempo real
- [ ] Chat entre cliente e restaurante/entregador

---

## 7. Explorações Técnicas (fora de qualquer versão fixa)

Itens que não são funcionalidades de produto, mas explorações de arquitetura/infraestrutura que podem valer a pena como estudo:

- [ ] Migração de SQLite para PostgreSQL (mais realista para um ambiente "quase produção")
- [ ] Separação em microsserviços (avaliado e descartado no planejamento original por complexidade desnecessária no MVP — mas pode valer como exercício isolado de arquitetura)
- [ ] Orquestração com Kubernetes (mesmo racional do item anterior)
- [ ] Publicação de imagem Docker em registro público (GitHub Container Registry), permitindo rodar o projeto sem precisar buildar localmente

---

## 8. Itens Explicitamente Não Planejados

Para deixar claro o que não está no radar, mesmo a longo prazo, e por quê:

| Item                                                                 | Motivo                                                                                |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Hospedagem contínua em nuvem                                         | Decisão de custo/risco já registrada em `06-deployment.md`                            |
| Suporte multi-idioma na aplicação (além da tradução da documentação) | Fora do objetivo de portfólio; não agrega valor demonstrativo proporcional ao esforço |

---

## 9. Como Este Roadmap Deve Ser Usado

- Revisar este documento ao final de cada versão entregue, promovendo itens da versão seguinte ou reordenando por aprendizado adquirido.
- Cada item, ao ser priorizado para desenvolvimento, deve passar pelo mesmo ciclo SDLC completo (Planejamento → Requisitos → Arquitetura → Testes → Desenvolvimento), ainda que de forma mais enxuta que a primeira iteração.
- Itens da seção 8 não devem ser reconsiderados sem uma mudança explícita de objetivo do projeto.
