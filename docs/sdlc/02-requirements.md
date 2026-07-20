# Análise de Requisitos

**Versão:** 1.0
**Data:** 10/07/2026
**Autor:** Dienay Lima
**Fase do SDLC:** Análise de Requisitos
**Base:** [Planejamento](01-planning.md)

---

## 1. Introdução

Este documento detalha os requisitos funcionais e não-funcionais do MVP do Rangos, a partir do escopo definido na fase de Planejamento. Cada requisito funcional possui critérios de aceite no formato **Dado/Quando/Então**, servindo de base direta para a criação de casos de teste na fase de QA.

**Legenda de prioridade (MoSCoW):**

- **Must have** — essencial para o MVP funcionar
- **Should have** — importante, mas o MVP sobrevive sem
- **Could have** — desejável, se sobrar tempo
- **Won't have** — fora do MVP (já coberto na seção "Fora do Escopo" do planejamento)

---

## 2. Requisitos Funcionais

### 2.1 Autenticação

#### RF-01 — Cadastro de usuário

**Prioridade:** Must have

**Descrição:** O sistema deve permitir que um novo usuário crie uma conta informando nome, e-mail e senha.

**Regras de negócio:**

- E-mail deve ser único no sistema. Duplicidade é verificada de forma case-insensitive (e-mail normalizado para minúsculas antes de salvar e antes de comparar).
- Telefone é obrigatório e deve ser único no sistema.
- Telefone deve conter apenas dígitos (com DDD), entre 10 e 11 caracteres (padrão brasileiro: fixo ou celular).
- Senha deve ter no mínimo 8 caracteres e no máximo 72 caracteres (limite técnico do algoritmo bcrypt; acima disso, bytes excedentes seriam truncados silenciosamente, criando uma falsa sensação de segurança).
- Senha deve ser armazenada com hash (bcrypt), nunca em texto puro.
- No cadastro, o usuário deve informar seu tipo: **Customer** (cliente que realiza pedidos) ou **Partner** (dono de estabelecimento). Se o campo `role` não for informado, o padrão assumido é **Customer**.
- Um usuário Partner não realiza pedidos como Customer nesta versão do MVP (papéis não se acumulam).

**Critérios de aceite:**

- Dado que informo dados válidos, únicos e um tipo de usuário válido (Customer ou Partner), quando envio o cadastro, então a conta é criada e recebo confirmação de sucesso.
- Dado que informo um e-mail já cadastrado, quando envio o cadastro, então recebo mensagem de erro informando duplicidade.
- Dado que informo um telefone já cadastrado, quando envio o cadastro, então recebo mensagem de erro informando duplicidade.
- Dado que não informo um telefone, quando envio o cadastro, então recebo mensagem de erro de validação.
- Dado que informo um telefone em formato inválido (letras, tamanho incorreto), quando envio o cadastro, então recebo mensagem de erro de validação.
- Dado que informo uma senha com menos de 8 caracteres, quando envio o cadastro, então recebo mensagem de erro de validação.
- Dado que informo uma senha com mais de 72 caracteres, quando envio o cadastro, então recebo mensagem de erro de validação.
- Dado que não informo um tipo de usuário válido, quando envio o cadastro, então recebo mensagem de erro de validação.
- Dado que não informo o campo `role`, quando envio o cadastro, então a conta é criada com o tipo `Customer` como padrão.

#### RF-02 — Login

**Prioridade:** Must have

**Descrição:** O sistema deve permitir que um usuário cadastrado acesse a conta com e-mail e senha.

**Regras de negócio:**

- Comparação de e-mail no login é case-insensitive, consistente com a normalização aplicada no cadastro (RF-01).

**Critérios de aceite:**

- Dado que informo credenciais válidas, quando faço login, então recebo um token JWT válido.
- Dado que informo senha incorreta, quando faço login, então recebo erro de autenticação sem indicar se o e-mail existe (evitar user enumeration).
- Dado que informo e-mail não cadastrado, quando faço login, então recebo a mesma mensagem de erro genérica do caso anterior.
- Dado que informo meu e-mail com capitalização diferente da usada no cadastro, quando faço login, então a autenticação funciona normalmente.

#### RF-03 — Atualização de perfil

**Prioridade:** Should have

**Descrição:** O sistema deve permitir que o usuário autenticado atualize nome, e-mail e senha.

**Regras de negócio:**

- Nova senha segue as mesmas regras do cadastro (RF-01): mínimo 8 e máximo 72 caracteres.
- Requisição sem nenhum campo preenchido é tratada como no-op: retorna sucesso com o perfil atual, sem alterar nada.

**Critérios de aceite:**

- Dado que estou autenticado, quando atualizo meu nome, então a alteração é refletida imediatamente.
- Dado que tento alterar meu e-mail para um já usado por outra conta, quando envio a atualização, então recebo erro de duplicidade.
- Dado que não estou autenticado, quando tento acessar a atualização de perfil, então recebo erro de autorização (401).
- Dado que atualizo minha senha com um valor entre 8 e 72 caracteres, quando envio a atualização, então a senha antiga deixa de funcionar para login e a nova passa a funcionar.
- Dado que tento atualizar minha senha para um valor fora do intervalo de 8 a 72 caracteres, quando envio a atualização, então recebo mensagem de erro de validação.
- Dado que envio a atualização sem nenhum campo preenchido, quando a requisição é processada, então recebo status 200 com meu perfil atual inalterado.

---

### 2.2 Restaurantes

#### RF-04 — Listagem de restaurantes

**Prioridade:** Must have

**Descrição:** O sistema deve exibir a lista de restaurantes disponíveis.

**Critérios de aceite:**

- Dado que acesso a listagem, quando não há restaurantes cadastrados, então vejo uma mensagem de lista vazia (não um erro).
- Dado que existem restaurantes cadastrados, quando acesso a listagem, então vejo nome e informações básicas de cada um.

#### RF-05 — Detalhes do restaurante

**Prioridade:** Must have

**Descrição:** O sistema deve exibir informações detalhadas de um restaurante específico.

**Critérios de aceite:**

- Dado um restaurante existente, quando acesso seus detalhes, então vejo nome, descrição e cardápio associado.
- Dado um ID de restaurante inexistente, quando tento acessar seus detalhes, então recebo erro 404.

---

### 2.3 Produtos

#### RF-06 — Listagem do cardápio

**Prioridade:** Must have

**Descrição:** O sistema deve exibir os produtos disponíveis de um restaurante.

**Critérios de aceite:**

- Dado um restaurante com produtos cadastrados, quando acesso o cardápio, então vejo nome, preço e descrição de cada produto.

#### RF-07 — Detalhes do produto

**Prioridade:** Should have

**Descrição:** O sistema deve exibir informações detalhadas de um produto.

**Critérios de aceite:**

- Dado um produto existente, quando acesso seus detalhes, então vejo nome, descrição, preço e restaurante associado.

---

### 2.4 Carrinho

#### RF-08 — Adicionar produto ao carrinho

**Prioridade:** Must have

**Descrição:** O sistema deve permitir adicionar um produto ao carrinho do usuário autenticado.

**Regras de negócio:**

- O carrinho é restrito a um único restaurante por vez.

**Critérios de aceite:**

- Dado um produto de um restaurante, quando adiciono ao carrinho vazio, então o item aparece no carrinho com quantidade 1.
- Dado um carrinho com item de um restaurante A, quando tento adicionar produto do restaurante B, então recebo aviso de que o carrinho será substituído pelo novo item (esvaziando o restaurante A).

#### RF-09 — Remover produto do carrinho

**Prioridade:** Must have

**Critérios de aceite:**

- Dado um item no carrinho, quando removo esse item, então ele deixa de aparecer na listagem do carrinho.

#### RF-10 — Alterar quantidade

**Prioridade:** Must have

**Critérios de aceite:**

- Dado um item no carrinho, quando altero a quantidade para um valor válido (≥1), então o subtotal é recalculado.
- Dado um item no carrinho, quando tento definir quantidade 0 ou negativa, então recebo erro de validação.

#### RF-11 — Visualizar carrinho

**Prioridade:** Must have

**Critérios de aceite:**

- Dado um carrinho com itens, quando o visualizo, então vejo cada item, quantidade, subtotal e valor total.

---

### 2.5 Pedido

#### RF-12 — Criar pedido

**Prioridade:** Must have

**Descrição:** O sistema deve permitir converter o conteúdo do carrinho em um pedido.

**Critérios de aceite:**

- Dado um carrinho com ao menos um item, quando finalizo o pedido, então um pedido é criado com status inicial (ex: "Recebido") e o carrinho é esvaziado.
- Dado um carrinho vazio, quando tento finalizar o pedido, então recebo erro informando que não há itens.

#### RF-13 — Listar pedidos do usuário

**Prioridade:** Must have

**Critérios de aceite:**

- Dado que possuo pedidos anteriores, quando acesso meu histórico, então vejo todos os meus pedidos ordenados por data (mais recente primeiro).

#### RF-14 — Detalhes do pedido

**Prioridade:** Must have

**Critérios de aceite:**

- Dado um pedido meu, quando acesso seus detalhes, então vejo itens, valores, status e data.
- Dado um pedido de outro usuário, quando tento acessar seus detalhes, então recebo erro de autorização (403).

#### RF-15 — Alterar status do pedido (simulado)

**Prioridade:** Should have

**Descrição:** O sistema deve permitir simular a progressão do status de um pedido (ex: Recebido → Em preparo → Saiu para entrega → Entregue).

**Regras de negócio:**

- A transição de status é sequencial obrigatória (Recebido → Em preparo → Saiu para entrega → Entregue). Não é permitido pular etapas nem retroceder.
- Somente o Partner dono do restaurante associado ao pedido pode alterar seu status.

**Critérios de aceite:**

- Dado um pedido em um status válido, quando o Partner dono do restaurante altera o status para o próximo da sequência, então a mudança é refletida no detalhe do pedido.
- Dado um pedido, quando se tenta pular etapas da sequência (ex: Recebido → Entregue diretamente), então recebo erro de transição inválida.
- Dado um pedido, quando se tenta retroceder o status (ex: Em preparo → Recebido), então recebo erro de transição inválida.
- Dado um pedido de um restaurante que não pertence ao Partner autenticado, quando ele tenta alterar o status, então recebo erro de autorização (403).

---

### 2.6 Administração (básica)

#### RF-16 — Cadastro de restaurante

**Prioridade:** Must have

**Regras de negócio:**

- Somente usuários do tipo Partner podem cadastrar restaurantes.
- O restaurante criado é automaticamente vinculado ao Partner autenticado como dono.

**Critérios de aceite:**

- Dado um Partner autenticado e dados válidos de um restaurante, quando envio o cadastro, então o restaurante é criado, vinculado a mim como dono, e passa a aparecer na listagem pública.
- Dado um usuário do tipo Customer autenticado, quando tento cadastrar um restaurante, então recebo erro de autorização (403).

#### RF-17 — Cadastro de produto

**Prioridade:** Must have

**Regras de negócio:**

- Somente o Partner dono do restaurante pode cadastrar produtos vinculados a ele.

**Critérios de aceite:**

- Dado dados válidos de um produto vinculado a um restaurante do qual sou dono, quando envio o cadastro, então o produto passa a aparecer no cardápio daquele restaurante.
- Dado um restaurante inexistente, quando tento cadastrar um produto vinculado a ele, então recebo erro de referência inválida.
- Dado um restaurante que não me pertence, quando tento cadastrar um produto vinculado a ele, então recebo erro de autorização (403).

---

## 3. Requisitos Não-Funcionais

| ID     | Requisito                    | Métrica/Critério                                                          |
| ------ | ---------------------------- | ------------------------------------------------------------------------- |
| RNF-01 | Segurança — hashing de senha | Senhas armazenadas exclusivamente via bcrypt                              |
| RNF-02 | Segurança — autenticação     | Rotas protegidas exigem JWT válido; token expira em 7 dias                |
| RNF-03 | Desempenho                   | Endpoints de leitura respondem em até [ex: 500ms] em ambiente local       |
| RNF-04 | Portabilidade                | Aplicação sobe integralmente via `docker-compose up`, sem passos manuais  |
| RNF-05 | Confiabilidade               | Pipeline de CI bloqueia merge se algum teste falhar                       |
| RNF-06 | Usabilidade                  | Interface Web funcional em resoluções desktop (≥1280px) e mobile (≥375px) |
| RNF-07 | Testabilidade                | Cobertura mínima de testes automatizados nos fluxos críticos: 80%+        |

---

## 4. Decisões do Product Owner

| Item                                         | Decisão                                                                                                                                                 | Justificativa                                                                                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF-08 — escopo do carrinho                   | Restrito a um único restaurante por vez                                                                                                                 | Alinhado ao padrão de mercado (iFood, Uber Eats); evita complexidade de frete/tempo de preparo misto                                                       |
| RF-15 — transição de status                  | Sequencial obrigatória, sem retrocesso                                                                                                                  | Reflete fluxo real de delivery; gera regras de negócio claras e testáveis (casos positivos e negativos)                                                    |
| RNF-02 — expiração do JWT                    | 7 dias                                                                                                                                                  | Valor definido para o período de desenvolvimento, priorizando conveniência nos testes manuais. **Revisar antes de qualquer deploy próximo de produção.**   |
| RNF-07 — cobertura de testes                 | 90%+                                                                                                                                                    | Meta alta para demonstrar rigor de QA como diferencial de portfólio                                                                                        |
| Tipos de usuário e posse de restaurante      | Papéis **Customer** e **Partner**; Partner é dono do(s) próprio(s) restaurante(s) e gerencia produtos e status dos pedidos apenas dos seus restaurantes | Reflete fluxo real de delivery (multi-vendor); gera casos de teste de autorização ricos (403 quando Partner tenta agir sobre restaurante de outro Partner) |
| RF-01 — tamanho máximo de senha              | 72 caracteres                                                                                                                                           | Limite técnico do bcrypt; acima disso, bytes excedentes seriam truncados silenciosamente                                                                   |
| RF-01 — campo telefone                       | Obrigatório e único                                                                                                                                     | Dado real de contato, importante para delivery; evita duplicidade de conta pelo mesmo contato                                                              |
| RF-01/RF-02 — deduplicação de e-mail         | Case-insensitive (normalizado para lowercase)                                                                                                           | Padrão de mercado; nenhum provedor de e-mail real trata capitalização como endereços distintos                                                             |
| RF-03 — corpo vazio em atualização de perfil | No-op de sucesso (200, sem alteração)                                                                                                                   | Mais tolerante a chamadas de API sem campos preenchidos, sem gerar erro desnecessário                                                                      |
| RF-01 — campo `role`                         | Opcional, com `Customer` como padrão se ausente                                                                                                         | Alinhado ao comportamento da versão anterior do projeto (Node.js); reduz fricção no cadastro para o caso mais comum (cliente)                              |
