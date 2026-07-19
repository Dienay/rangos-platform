# Implantação

**Versão:** 1.0
**Data:** 12+1/07/2026
**Autor:** Dienay Lima
**Fase do SDLC:** Implantação
**Base:** [Arquitetura](03-architecture.md), [Desenvolvimento](05-development.md)

---

## 1. Introdução

Diferente de um projeto comercial, o Rangos não terá uma instância rodando continuamente em produção. Manter um serviço ativo em nuvem gera custo real e risco de cobrança inesperada caso o uso exceda o tier gratuito de algum provedor — um risco desnecessário para um projeto de portfólio.

A estratégia de implantação adotada é, portanto, **empacotamento reproduzível via Docker**: qualquer pessoa (recrutador, avaliador técnico, o próprio autor no futuro) deve conseguir rodar o projeto completo localmente com o mínimo de comandos possível, sem depender de infraestrutura paga ou de terceiros.

---

## 2. Objetivo da Fase

- Garantir que o projeto rode com **um único comando**, via Docker.
- Garantir que o `README.md` documente esse comando de forma clara, sem exigir conhecimento prévio do projeto.
- Validar, via CI, que a imagem Docker realmente builda e sobe sem erros — simulando "implantação" mesmo sem ambiente de produção real.
- Deixar documentado o caminho para uma implantação real em nuvem, caso isso seja desejado no futuro (ex: para uma demonstração ao vivo pontual).

---

## 3. Estratégia de Empacotamento

### 3.1 Comando único de execução

```bash
docker compose up --build
```

Este comando deve:

- Subir a API backend, com banco de dados já configurado (SQLite em volume Docker, sem necessidade de instalação externa).
- Expor a documentação interativa da API (Swagger/OpenAPI) em uma porta acessível localmente.
- Não exigir nenhuma configuração manual de variáveis de ambiente para o caso de uso básico (valores padrão sensatos para ambiente de demonstração).

### 3.2 Gestão de configuração

| Variável         | Uso                        | Valor padrão (demo)                                                      |
| ---------------- | -------------------------- | ------------------------------------------------------------------------ |
| `DATABASE_URL`   | Conexão com banco de dados | SQLite local, dentro do volume Docker                                    |
| `JWT_SECRET_KEY` | Assinatura dos tokens JWT  | Valor de desenvolvimento fixo, documentado como não-seguro para produção |

Um arquivo `.env.example` deve existir no repositório, documentando todas as variáveis configuráveis, mesmo que os valores padrão já funcionem sem alteração.

---

## 4. Papel do CI/CD nesta Estratégia

Mesmo sem deploy real, o pipeline de CI/CD continua tendo um papel importante: validar que o projeto é de fato "implantável" a qualquer momento.

O workflow do GitHub Actions (`ci.yml`) deve, a cada push/PR:

1. Rodar a suíte de testes automatizados (unit + integration), conforme `04-testing.md`.
2. Buildar a imagem Docker do backend, garantindo que o `Dockerfile` está correto e atualizado.
3. _(Opcional/futuro)_ Publicar a imagem buildada em um registro de imagens (ex: GitHub Container Registry), para que ela possa ser baixada e rodada sem precisar buildar localmente.

Essa validação contínua evita o cenário clássico de "funciona na minha máquina, mas o Dockerfile está desatualizado" — um problema real de portfólio, já que muitas vezes o código é revisado meses depois de escrito.

---

## 5. Checklist Pré-"Release"

Como não há deploy em produção, este checklist substitui a ideia tradicional de "checklist pré-deploy". Ele deve ser seguido antes de qualquer tag de versão/release no GitHub:

- [ ] Todos os testes automatizados passando no CI.
- [ ] Cobertura de testes atendendo a meta definida (RNF-07: 80%+).
- [ ] `docker compose up --build` testado do zero (clone limpo do repositório) e funcionando sem passos manuais extras.
- [ ] `README.md` revisado e atualizado com instruções corretas de execução.
- [ ] Revisão dos itens sinalizados como "ajustar antes de produção" nos documentos anteriores (ex: expiração do JWT de 7 dias, definida propositalmente longa para conveniência de desenvolvimento — ver `02-requisitos-rangos.md`, RNF-02).
- [ ] `.env.example` refletindo todas as variáveis realmente usadas pelo projeto.

---

## 6. Versionamento e Releases

- Uso de tags semânticas no GitHub (ex: `v0.1.0` para o MVP completo).
- Cada release deve ter uma nota curta descrevendo os módulos/RFs cobertos naquela versão, referenciando `05-development.md`.
- Não há necessidade de plano de rollback tradicional (não há serviço rodando), mas o versionamento via Git/tags já cumpre esse papel: qualquer versão anterior pode ser restaurada a qualquer momento via `git checkout`.

---

## 7. Caminho Futuro (opcional, fora do escopo atual)

Caso surja a necessidade pontual de uma demonstração ao vivo (ex: durante um processo seletivo específico), as opções consideradas e descartadas por ora foram:

| Opção                                  | Observação                                                                                                                    |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| PaaS simples (Render, Railway, Fly.io) | Mais rápido de configurar; tier gratuito costuma ser suficiente para demonstrações curtas, mas exige atenção a limites de uso |
| VPS próprio (DigitalOcean, Linode)     | Mais controle, mas exige manutenção manual de infraestrutura                                                                  |
| Cloud provider maior (AWS/GCP/Azure)   | Overkill para o porte do projeto; custo e complexidade desnecessários para um MVP de portfólio                                |

Se essa necessidade surgir, o Dockerfile e docker-compose já existentes tornam qualquer uma dessas opções rápida de configurar — a decisão de não hospedar continuamente é reversível a qualquer momento, sem retrabalho de arquitetura.
