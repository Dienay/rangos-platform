# Planejamento

**Versão:** 1.0
**Data:** 09/07/2026
**Autor:** Dienay Lima
**Fase do SDLC:** Planejamento

---

## 1. Visão Geral

O Rangos é uma plataforma de delivery desenvolvida como projeto de estudo para demonstrar a aplicação de boas práticas de Engenharia de Software e Quality Assurance ao longo de todo o ciclo de vida de desenvolvimento de software (SDLC).

O projeto será desenvolvido de forma incremental, iniciando com um Produto Mínimo Viável (MVP) e evoluindo por versões. Cada etapa seguirá um processo estruturado, incluindo planejamento, levantamento de requisitos, arquitetura, desenvolvimento, testes, documentação e implantação.

O objetivo não é apenas entregar uma aplicação funcional, mas demonstrar um processo de desenvolvimento próximo ao utilizado em equipes profissionais.

---

## 2. Objetivo

### Objetivo Principal

Desenvolver uma plataforma de delivery moderna, aplicando boas práticas de desenvolvimento de software e garantindo qualidade através de testes automatizados.

### Objetivos Secundários

- Desenvolver uma API REST utilizando FastAPI.
- Construir uma aplicação Web para os clientes.
- Aplicar princípios de arquitetura limpa e organização em camadas.
- Automatizar testes da aplicação.
- Utilizar Docker para facilitar a execução do projeto.
- Automatizar processos utilizando GitHub Actions.
- Documentar todas as etapas do desenvolvimento.

---

## 3. Papéis e Responsabilidades

| Papel            | Responsável | Responsabilidades principais                                                        |
| ---------------- | ----------- | ----------------------------------------------------------------------------------- |
| Product Owner    | Dienay Lima | Definir escopo, prioridades e critérios de aceite                                   |
| Desenvolvedor(a) | Dienay Lima | Implementar API, Web app e infraestrutura (Docker, CI/CD)                           |
| QA / Testador(a) | Dienay Lima | Planejar e executar testes automatizados e manuais, garantir qualidade das entregas |

---

## 4. Escopo do MVP (Versão 1.0)

O objetivo do MVP é permitir que um cliente consiga navegar pelos restaurantes, montar um pedido e finalizar a compra de forma simulada.

### Funcionalidades

#### Autenticação

- Cadastro de usuário
- Login
- Atualização de perfil

#### Restaurantes

- Listagem de restaurantes
- Visualização dos detalhes de um restaurante

#### Produtos

- Listagem do cardápio
- Visualização dos detalhes de um produto

#### Carrinho

- Adicionar produto
- Remover produto
- Alterar quantidade
- Visualizar carrinho

#### Pedido

- Criar pedido
- Listar pedidos do usuário
- Visualizar detalhes do pedido
- Alterar status do pedido (simulado)

#### Administração (básica)

- Cadastro de restaurantes
- Cadastro de produtos

---

## 5. Fora do Escopo do MVP

As funcionalidades abaixo serão implementadas em versões futuras.

- Aplicativo Mobile
- Painel Administrativo completo
- Pagamento real
- Cupons de desconto
- Avaliação de restaurantes
- Favoritos
- Chat
- Notificações Push
- Geolocalização
- Rastreamento do entregador
- Microsserviços
- Kubernetes

---

## 6. Requisitos Não-Funcionais (visão macro)

> Seção sugerida — detalhamento completo (métricas específicas, ferramentas de medição) fica para a fase de Análise de Requisitos.

1. **Segurança:** senhas devem ser armazenadas com hashing (ex: bcrypt); autenticação via token (ex: JWT).
2. **Desempenho:** endpoints da API devem responder em tempo aceitável para uso interativo (definir SLA na próxima fase, ex: < 500ms para operações de leitura).
3. **Portabilidade:** aplicação deve subir integralmente via Docker/Docker Compose, sem dependências manuais de ambiente.
4. **Manutenibilidade:** código organizado em camadas (ex: rotas, serviços, repositórios), facilitando testes e evolução.
5. **Confiabilidade:** pipeline de CI/CD deve bloquear merge/deploy em caso de falha nos testes automatizados.
6. **Usabilidade:** interface Web responsiva para uso em desktop e mobile.

---

## 7. Riscos Identificados

> Seção sugerida — revisar e ajustar probabilidade/impacto conforme sua realidade.

| Risco                                                                            | Probabilidade | Impacto | Mitigação                                                                                 |
| -------------------------------------------------------------------------------- | ------------- | ------- | ----------------------------------------------------------------------------------------- |
| Tempo limitado para manutenção (projeto solo, sem equipe)                        | Alta          | Alto    | Priorizar rigorosamente o escopo do MVP; adiar tudo que estiver na lista "fora do escopo" |
| Acúmulo de papéis (Dev/QA/PO) gerar viés na definição de aceite                  | Média         | Médio   | Definir critérios de aceite objetivos por funcionalidade antes de implementar             |
| Complexidade de configurar CI/CD e Docker consumir tempo do desenvolvimento core | Média         | Médio   | Validar pipeline básico cedo, antes de acumular muitas funcionalidades                    |
| Escopo aumentar durante o desenvolvimento ("scope creep")                        | Alta          | Alto    | Congelar escopo do MVP; novas ideias vão para o backlog de versões futuras                |
| Cobertura de testes insuficiente por pressão de tempo                            | Média         | Alto    | Definir meta mínima de cobertura antes de iniciar o desenvolvimento                       |

---

## 8. Entregas do MVP

Ao final da versão 1.0 o projeto deverá possuir:

- API REST funcional
- Interface Web funcional
- Banco de dados estruturado
- Autenticação
- CRUD dos principais recursos
- Testes automatizados
- Documentação da API
- Containerização com Docker
- Pipeline de CI/CD
- Deploy da aplicação

---

## 9. Cronograma e Marcos (Alto Nível)

> Seção sugerida — ajustar datas conforme sua disponibilidade real.

| Etapa                                     | Entregável                                                             | Prazo estimado |
| ----------------------------------------- | ---------------------------------------------------------------------- | -------------- |
| Planejamento                              | Este documento validado                                                | [data]         |
| Análise de Requisitos                     | Requisitos funcionais e não-funcionais detalhados, critérios de aceite | [data]         |
| Design/Arquitetura                        | Modelagem de dados, arquitetura da API, definição de endpoints         | [data]         |
| Desenvolvimento — Autenticação            | Cadastro, login, atualização de perfil                                 | [data]         |
| Desenvolvimento — Restaurantes e Produtos | Listagem e detalhes                                                    | [data]         |
| Desenvolvimento — Carrinho e Pedido       | Fluxo completo de compra simulada                                      | [data]         |
| Testes                                    | Suíte de testes automatizados cobrindo fluxos críticos                 | [data]         |
| Implantação                               | Deploy via Docker/CI-CD                                                | [data]         |

---

## 10. Critérios de sucesso

O MVP será considerado concluído quando:

- Todas as funcionalidades previstas para a versão 1.0 estiverem implementadas.
- Os testes automatizados estiverem passando.
- A aplicação puder ser executada utilizando Docker.
- A API estiver documentada.
- O pipeline de CI/CD estiver funcionando corretamente.
- O projeto estiver disponível para demonstração.
