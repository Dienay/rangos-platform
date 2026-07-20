# 🍔 Rangos Platform

> Projeto de estudo desenvolvido para demonstrar a aplicação de práticas de **Engenharia de Software** e **Quality Assurance** ao longo de todo o ciclo de vida de desenvolvimento de software (SDLC), utilizando uma plataforma de delivery como domínio de negócio.

O objetivo do Rangos vai além de entregar uma API REST funcional. O projeto busca reproduzir um processo de desenvolvimento próximo ao utilizado em equipes profissionais, abrangendo planejamento, levantamento de requisitos, arquitetura, estratégia de testes, desenvolvimento, integração contínua (CI/CD) e implantação.

Cada etapa é documentada e rastreável, permitindo acompanhar a evolução do projeto desde a definição dos requisitos até a validação por testes automatizados.

---

## 💡 Por que este projeto é relevante para QA?

O Rangos utiliza uma plataforma de delivery como domínio de negócio para demonstrar a aplicação prática de processos de Engenharia de Software e Quality Assurance. Mais do que implementar funcionalidades, o projeto evidencia como requisitos, arquitetura, testes e desenvolvimento podem ser conduzidos de forma estruturada e rastreável ao longo de todo o SDLC.

---

## 🎯 Objetivos

O projeto foi concebido para servir como um portfólio técnico, demonstrando não apenas habilidades de desenvolvimento, mas também competências relacionadas à qualidade de software, documentação e processos de engenharia.

- Aplicar o ciclo completo de desenvolvimento de software (SDLC)
- Desenvolver uma API REST utilizando FastAPI
- Aplicar boas práticas de arquitetura em camadas
- Escrever testes automatizados desde o início do desenvolvimento (TDD)
- Definir requisitos e critérios de aceite utilizando conceitos de BDD
- Garantir rastreabilidade entre requisitos, testes e implementação
- Automatizar validações por meio de CI/CD
- Produzir documentação técnica como parte integrante do projeto

---

## 🔄 Ciclo de Desenvolvimento (SDLC)

O desenvolvimento do Rangos segue uma abordagem estruturada baseada no **Software Development Life Cycle (SDLC)**. Cada etapa produz artefatos que orientam a próxima fase, garantindo rastreabilidade entre requisitos, arquitetura, testes e implementação.

**Práticas adotadas durante o desenvolvimento:**

- Critérios de aceite definidos utilizando conceitos de BDD
- Estratégia de testes planejada antes da implementação (Shift Left)
- Desenvolvimento orientado por testes (TDD)
- Documentação contínua das decisões técnicas
- Integração contínua (CI/CD)

---

## 📚 Documentação

Toda a documentação do projeto foi organizada para refletir as fases do ciclo de vida de desenvolvimento de software (SDLC), mantendo a rastreabilidade entre requisitos, arquitetura, implementação e testes.

### Documentação do SDLC

| Documento                                          | Objetivo                                                                           |
| -------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [01-planning.md](docs/sdlc/01-planning.md)         | Define visão, escopo e planejamento do projeto.                                    |
| [02-requirements.md](docs/sdlc/02-requirements.md) | Especifica requisitos funcionais, não funcionais e critérios de aceite.            |
| [03-architecture.md](docs/sdlc/03-architecture.md) | Documenta a arquitetura da aplicação, modelo de dados e decisões técnicas.         |
| [04-testing.md](docs/sdlc/04-testing.md)           | Define a estratégia de testes, níveis de teste, métricas e critérios de qualidade. |
| [05-development.md](docs/sdlc/05-development.md)   | Registra a implementação dos módulos, decisões técnicas e evolução do projeto.     |
| [06-deployment.md](docs/sdlc/06-deployment.md)     | Descreve a estratégia de empacotamento, CI/CD e implantação.                       |
| [07-roadmap.md](docs/sdlc/07-roadmap.md)           | Apresenta a evolução planejada para versões futuras.                               |

### Documentação de QA

Além dos documentos do SDLC, o projeto mantém uma área dedicada aos artefatos de Engenharia de Qualidade.

```text
docs/
└── qa/
    ├── test-cases/
    ├── bugs/
    ├── bug-backlog.md
    └── traceability-matrix.md
```

Essa estrutura concentra:

- Casos de teste
- Matriz de rastreabilidade
- Relatórios de bugs
- Evidências de validação

---

## ⚙️ Stack Tecnológica

### Backend

- Python
- FastAPI
- SQLAlchemy
- PostgreSQL
- Pydantic
- Alembic
- Uvicorn

### QA

- Pytest
- pytest-cov
- httpx

### DevOps

- Docker
- Docker Compose
- GitHub Actions

---

## 🏛️ Arquitetura

O projeto utiliza uma arquitetura em camadas para favorecer manutenção, testabilidade e separação de responsabilidades.

```text
Cliente
   │
   ▼
FastAPI
   │
Routes
   │
Services
   │
Repositories
   │
PostgreSQL
```

O projeto adota uma arquitetura em camadas (Layered Architecture), separando responsabilidades entre apresentação, regras de negócio e persistência de dados, facilitando manutenção e testes.

---

## 🏗️ Estrutura do Projeto

```dir
rangos-platform/
├── apps/
│   ├── backend/      # API FastAPI
│   ├── frontend/     # Interface Web (MVP)
│   └── mobile/       # Futuras versões
├── docs/
│   ├── sdlc/         # Documentação do processo
│   ├── qa/           # Artefatos de qualidade
│   └── api/          # Documentação da API
├── tests/            # Testes automatizados
└── docker-compose.yml
```

---

## 📖 API

A API segue princípios REST e utiliza códigos HTTP padronizados para representar o resultado das operações.
As rotas, contratos, modelos de dados e exemplos de requisição estão documentados em:

- Swagger/OpenAPI (`/docs`)
---

## 🚀 Instalação & Execução

### Pré-requisitos

- Git
- Docker e Docker Compose

### Clone o repositório

```bash
git clone https://github.com/seu-user/rangos-platform.git
cd rangos-platform
```

### Configurar variáveis
```bash
cp .env.example .env
```

### Docker

```bash
# Permissão de execução
chmod +x run
```

```bash
# Comandos disponíveis
./run up              # Inicia os containers
./run build           # Build dos containers
./run rebuild         # Build + start
./run rebuild:force   # Rebuild forçado
./run down            # Remove containers
./run stop            # Para containers
./run restart         # Reinicia containers
./run logs            # Logs em tempo real
./run ps              # Lista containers
```

---

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).
