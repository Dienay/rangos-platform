## RF-02 — Login

### TC-020 — Login com credenciais válidas retorna JWT válido

| Campo              | Detalhe             |
| ------------------ | ------------------- |
| **RF relacionado** | RF-02               |
| **Tipo**           | Funcional — sucesso |
| **Nível**          | Integration         |
| **Prioridade**     | Crítica             |

**Pré-condições:**

- Já existe um usuário cadastrado com e-mail `ana.costa@example.com` e senha `senha1234` (ex: via TC-001 ou fixture equivalente).

**Dados de entrada:**

```json
{
  "email": "ana.costa@example.com",
  "password": "senha1234"
}
```

**Passos:**

1. Garantir que o usuário já está cadastrado.
2. Enviar requisição `POST /auth/login` com as credenciais corretas.
3. Consultar a resposta retornada pela API.

**Resultado esperado:**

- Status HTTP: `200 OK`
- Corpo da resposta contém `access_token` (string não vazia) e `token_type: "bearer"`.
- O token retornado, quando usado em uma rota protegida (ex: `PUT /auth/me`), é aceito sem erro de autenticação.

**Observações:**

- Caso de teste base do RF-02 — praticamente todo teste de rota protegida (atualização de perfil, e futuramente carrinho/pedido/restaurante) depende de um login bem-sucedido para gerar o token usado nos testes.

---

### TC-021 — Senha incorreta retorna erro genérico

| Campo              | Detalhe                        |
| ------------------ | ------------------------------ |
| **RF relacionado** | RF-02                          |
| **Tipo**           | Negativo — credencial inválida |
| **Nível**          | Integration                    |
| **Prioridade**     | Crítica                        |

**Pré-condições:**

- Já existe um usuário cadastrado com e-mail `ana.costa@example.com` e senha `senha1234`.

**Dados de entrada:**

```json
{
  "email": "ana.costa@example.com",
  "password": "senha_errada"
}
```

**Passos:**

1. Garantir que o usuário já está cadastrado.
2. Enviar requisição `POST /auth/login` com a senha incorreta.
3. Consultar a resposta retornada pela API.

**Resultado esperado:**

- Status HTTP: `401 Unauthorized`
- Corpo da resposta contém uma mensagem de erro **genérica** (ex: `"Credenciais inválidas"`), que não indica se o problema foi o e-mail ou a senha especificamente.
- Nenhum token é retornado no corpo da resposta.

**Observações:**

- A mensagem genérica é intencional — evita user enumeration (ver TC-022, que deve retornar exatamente a mesma mensagem e o mesmo status, ainda que por um motivo diferente internamente).
- Comparar byte-a-byte a mensagem de erro deste teste com a de TC-022 é uma boa prática — se as mensagens divergirem entre "senha errada" e "e-mail inexistente", a proteção contra user enumeration está quebrada mesmo que ambos retornem 401.

---

### TC-022 — E-mail não cadastrado retorna a mesma mensagem genérica de erro

| Campo              | Detalhe                        |
| ------------------ | ------------------------------ |
| **RF relacionado** | RF-02                          |
| **Tipo**           | Negativo — credencial inválida |
| **Nível**          | Integration                    |
| **Prioridade**     | Crítica                        |

**Pré-condições:**

- Nenhum usuário cadastrado com o e-mail `fantasma@example.com`.

**Dados de entrada:**

```json
{
  "email": "fantasma@example.com",
  "password": "qualquersenha123"
}
```

**Passos:**

1. Garantir que o e-mail `fantasma@example.com` não existe no banco.
2. Enviar requisição `POST /auth/login` com esse e-mail.
3. Consultar a resposta retornada pela API.
4. Comparar a mensagem de erro e o status HTTP com os obtidos em TC-021.

**Resultado esperado:**

- Status HTTP: `401 Unauthorized` — idêntico ao de TC-021.
- Corpo da resposta contém **exatamente a mesma mensagem genérica** de TC-021, palavra por palavra.
- Nenhum token é retornado no corpo da resposta.

**Observações:**

- Este teste só está completo quando comparado diretamente com TC-021 — o objetivo central é provar que um atacante não consegue diferenciar "e-mail existe, senha errada" de "e-mail não existe" observando a resposta da API.
- Vale automatizar essa comparação explicitamente (ex: `assert response_tc021.json() == response_tc022.json()`), em vez de apenas verificar cada resposta isoladamente.

---

### TC-023 — Campo `email` ausente na requisição de login retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-02                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível.

**Dados de entrada:**

```json
{
  "password": "senha1234"
}
```

_(campo `email` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/login` sem o campo `email`.
2. Consultar a resposta retornada pela API.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `email` é obrigatório.
- Nenhum token é retornado.

**Resultado que NÃO deve ocorrer:**

- Status `500 Internal Server Error` — mesma classe de regressão documentada em TC-004/TC-008 a TC-011 para o endpoint de cadastro; aqui aplicada ao endpoint de login.

**Observações:**

- Diferente dos testes de campo ausente no cadastro (TC-008 a TC-011), este não precisa de verificação de banco de dados — login não persiste nada, então a validação de resposta HTTP é suficiente.

---

### TC-024 — Campo `password` ausente na requisição de login retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-02                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível.

**Dados de entrada:**

```json
{
  "email": "ana.costa@example.com"
}
```

_(campo `password` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/login` sem o campo `password`.
2. Consultar a resposta retornada pela API.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `password` é obrigatório.
- Nenhum token é retornado.

**Resultado que NÃO deve ocorrer:**

- Status `500 Internal Server Error` — mesma classe de regressão documentada nos demais testes de campo ausente.

**Observações:**

- Este teste não depende de um usuário previamente cadastrado — a validação de schema deve rejeitar a requisição antes mesmo de qualquer consulta ao banco ser feita, então funciona com qualquer e-mail, cadastrado ou não.

---

### TC-025 — Login com e-mail em case diferente do cadastrado é aceito

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-02                        |
| **Tipo**           | Funcional — regra de negócio |
| **Nível**          | Integration                  |
| **Prioridade**     | Média                        |

**Pré-condições:**

- Já existe um usuário cadastrado com e-mail `ana.costa@example.com` (minúsculo) e senha `senha1234`.

**Dados de entrada:**

```json
{
  "email": "Ana.Costa@Example.com",
  "password": "senha1234"
}
```

_(**mesmo e-mail do cadastro**, porém com capitalização diferente)_

**Passos:**

1. Garantir que o usuário já está cadastrado com e-mail em minúsculo.
2. Enviar requisição `POST /auth/login` usando o e-mail com capitalização diferente.
3. Consultar a resposta retornada pela API.

**Resultado esperado:**

- Status HTTP: `200 OK` — login funciona normalmente, apesar da diferença de capitalização.
- Corpo da resposta contém `access_token` válido, correspondente ao mesmo usuário cadastrado.

**Observações:**

- Depende diretamente de TC-013 (cadastro com normalização case-insensitive) — se o e-mail não for normalizado corretamente no momento do cadastro ou da comparação no login, este teste falha.
- Decisão de PO confirmada: comparação de e-mail no login é case-insensitive. Ver `02-requisitos-rangos.md`, RF-02.

---

**Validação de campos obrigatórios:**

- [ ] TC-023 — Campo `email` ausente retorna 422
- [ ] TC-024 — Campo `password` ausente retorna 422

**Casos implícitos (robustez/segurança):**

- [ ] TC-026 — Token JWT gerado contém claims corretos (`sub`, `role`)
- [ ] TC-027 — Tentativa de SQL injection nos campos de login não compromete o banco nem burla a autenticação

---

## RF-03 — Atualização de perfil (pendente de detalhamento)

**Derivados diretamente do RF:**

- [ ] TC-028 — Atualização de nome autenticado reflete imediatamente
- [ ] TC-029 — Atualização para e-mail duplicado retorna erro (409)
- [ ] TC-030 — Acesso sem token retorna 401
- [ ] TC-031 — Atualização de senha (8 a 72 caracteres) é aceita; senha antiga deixa de funcionar, nova passa a funcionar
- [ ] TC-032 — Atualização de senha fora do intervalo de 8 a 72 caracteres retorna erro de validação
- [ ] TC-035 — Corpo de atualização vazio retorna sucesso sem alterar dados (no-op)

**Casos implícitos (robustez/segurança):**

- [ ] TC-033 — Token malformado retorna 401
- [ ] TC-034 — Token expirado retorna 401 (nível unit, com tempo mockado)
- [ ] TC-036 — Atualização de múltiplos campos simultaneamente aplica todas as mudanças

---

### TC-026 — Token JWT gerado contém claims corretos

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-02                        |
| **Tipo**           | Funcional — regra de negócio |
| **Nível**          | Unit                         |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- Nenhuma dependência de API/banco — este teste chama diretamente a função de geração de token (ex: `create_access_token`), com um `user_id` e `role` conhecidos.
  **Dados de entrada:**

```python
user_id = "abc-123"
role = "partner"
```

**Passos:**

1. Chamar a função de geração de token diretamente com `user_id` e `role` conhecidos.
2. Decodificar o token gerado (sem passar pela rota HTTP).
3. Inspecionar os claims do payload decodificado.
   **Resultado esperado:**

- O claim `sub` (subject) do token corresponde exatamente ao `user_id` informado.
- O claim `role` do token corresponde exatamente ao `role` informado.
- O claim `exp` (expiração) está presente e corresponde a aproximadamente 7 dias a partir do momento da geração (ver RNF-02 em `02-requisitos-rangos.md`).
  **Observações:**
- Este teste é o que efetivamente prova que a decisão de incluir `role` no token (necessária para autorização por posse em módulos futuros, como Restaurantes e Pedido) está implementada corretamente — sem ele, um bug de token sem `role` só apareceria muito mais tarde, ao implementar RF-16/RF-17/RF-15.
- Testar a expiração com uma margem de tolerância (ex: `exp` entre 6 dias 23h e 7 dias 1h a partir de "agora"), não um valor exato, para evitar flakiness por diferença de milissegundos entre geração e verificação.

---

### TC-027 — Tentativa de SQL injection nos campos de login não compromete o banco

| Campo              | Detalhe     |
| ------------------ | ----------- |
| **RF relacionado** | RF-02       |
| **Tipo**           | Segurança   |
| **Nível**          | Integration |
| **Prioridade**     | Crítica     |

**Pré-condições:**

- Já existe um usuário cadastrado (ex: `ana.costa@example.com`), para confirmar que a tentativa de injection não permite login indevido nem corrompe o registro existente.
  **Dados de entrada:**

```json
{
  "email": "' OR '1'='1",
  "password": "' OR '1'='1"
}
```

**Passos:**

1. Garantir que existe ao menos um usuário previamente cadastrado.
2. Enviar requisição `POST /auth/login` com o payload de SQL injection nos campos `email` e `password`.
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que a tabela `users` permanece intacta.
   **Resultado esperado:**

- Status HTTP: `401 Unauthorized` — o payload de injection é tratado como uma credencial inválida comum, não como um comando SQL.
- Nenhum token é retornado — a tentativa de "bypass" via injection não concede acesso a nenhuma conta.
- A tabela `users` permanece intacta, sem alteração nos registros existentes.
  **Observações:**
- Este é o teste de segurança mais crítico do módulo de login: um sistema vulnerável a este payload clássico (`' OR '1'='1`) permitiria login sem credenciais válidas, comprometendo toda a autenticação.
- Assim como TC-018, este teste existe para **provar** a proteção já garantida pelo uso de ORM com queries parametrizadas (SQLAlchemy), não para descobrir uma vulnerabilidade nova.
