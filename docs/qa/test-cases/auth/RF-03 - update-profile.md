## RF-03 — Atualização de perfil

### TC-028 — Atualização de nome autenticado reflete imediatamente

| Campo              | Detalhe             |
| ------------------ | ------------------- |
| **RF relacionado** | RF-03               |
| **Tipo**           | Funcional — sucesso |
| **Nível**          | Integration         |
| **Prioridade**     | Alta                |

**Pré-condições:**

- Usuário cadastrado e autenticado (token JWT válido obtido via login).
  **Dados de entrada:**

```json
{
  "name": "Ana Souza"
}
```

**Passos:**

1. Cadastrar e logar um usuário, obtendo o token.
2. Enviar requisição `PUT /auth/me` com o token no header `Authorization: Bearer <token>` e o novo nome.
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar a persistência da alteração.
   **Resultado esperado:**

- Status HTTP: `200 OK`
- Corpo da resposta contém `name: "Ana Souza"`.
- O registro no banco reflete o novo nome.
  **Observações:**
- Caso de teste base do RF-03 — confirma o fluxo positivo antes dos negativos.

---

### TC-029 — Atualização para e-mail já usado por outra conta retorna erro de duplicidade

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-03                  |
| **Tipo**           | Negativo — duplicidade |
| **Nível**          | Integration            |
| **Prioridade**     | Alta                   |

**Pré-condições:**

- Dois usuários cadastrados: A (`a@example.com`) e B (`b@example.com`). Token de autenticação do usuário B disponível.
  **Dados de entrada:**

```json
{
  "email": "a@example.com"
}
```

**Passos:**

1. Cadastrar os usuários A e B.
2. Logar como usuário B, obtendo o token.
3. Enviar requisição `PUT /auth/me` autenticado como B, tentando alterar o e-mail para o de A.
4. Consultar a resposta retornada pela API.
5. Consultar o banco de dados para confirmar que o e-mail de B **não foi alterado**.
   **Resultado esperado:**

- Status HTTP: `409 Conflict`
- O e-mail do usuário B permanece `b@example.com` no banco de dados.
  **Observações:**
- Mesma classe de teste de TC-002/TC-003, mas aplicada ao contexto de atualização em vez de cadastro.

---

### TC-030 — Acesso à atualização sem token retorna 401

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-03                  |
| **Tipo**           | Negativo — autorização |
| **Nível**          | Integration            |
| **Prioridade**     | Crítica                |

**Pré-condições:**

- Nenhuma — o teste é justamente a ausência de autenticação.
  **Dados de entrada:**

```json
{
  "name": "Tentativa Sem Token"
}
```

**Passos:**

1. Enviar requisição `PUT /auth/me` sem o header `Authorization`.
2. Consultar a resposta retornada pela API.
   **Resultado esperado:**

- Status HTTP: `401 Unauthorized` (não `403` — ver decisão técnica registrada em `05-development.md`, que ajusta o `HTTPBearer` para retornar 401 mesmo sem token presente).
- Nenhuma alteração é feita em nenhum usuário.
  **Observações:**
- Este teste valida meta-comportamento de infraestrutura (a dependência `get_current_user`), não regra de negócio específica de perfil — mas é essencial porque toda rota protegida futura (carrinho, pedido, restaurante) depende do mesmo mecanismo.

---

### TC-031 — Atualização de senha é aceita; senha antiga deixa de funcionar, nova passa a funcionar

| Campo              | Detalhe             |
| ------------------ | ------------------- |
| **RF relacionado** | RF-03               |
| **Tipo**           | Funcional — sucesso |
| **Nível**          | Integration         |
| **Prioridade**     | Crítica             |

**Pré-condições:**

- Usuário cadastrado com senha `senha1234` e autenticado (token obtido via login).
  **Dados de entrada:**

```json
{
  "password": "novasenha5678"
}
```

**Passos:**

1. Cadastrar e logar o usuário com a senha original, obtendo o token.
2. Enviar requisição `PUT /auth/me` com a nova senha.
3. Consultar a resposta retornada pela API.
4. Tentar `POST /auth/login` com a senha **antiga** (`senha1234`).
5. Tentar `POST /auth/login` com a senha **nova** (`novasenha5678`).
   **Resultado esperado:**

- Passo 3: Status `200 OK`, sem exposição de senha no corpo.
- Passo 4 (login com senha antiga): Status `401 Unauthorized` — a senha antiga não deve mais funcionar.
- Passo 5 (login com senha nova): Status `200 OK` com token válido.
  **Observações:**
- Este é o teste mais importante de todo o RF-03 — sem ele, seria possível ter um bug onde a senha "muda" no banco mas o hash não é recalculado corretamente (ex: apenas o campo `password_hash` sendo sobrescrito com a senha em texto puro por engano), e ninguém perceberia até um usuário real ficar preso.
- Cobre a lacuna identificada originalmente na matriz de rastreabilidade antes deste RF ser formalizado com critério de aceite explícito.

---

### TC-032 — Atualização de senha fora do intervalo de 8 a 72 caracteres retorna erro de validação

| Campo              | Detalhe                         |
| ------------------ | ------------------------------- |
| **RF relacionado** | RF-03                           |
| **Tipo**           | Negativo — validação de formato |
| **Nível**          | Unit                            |
| **Prioridade**     | Alta                            |

**Pré-condições:**

- Nenhuma — teste de schema puro (`UserUpdate`), sem banco de dados.
  **Dados de entrada (variações a testar):**

```json
{ "password": "1234567" }
```

```json
{ "password": "<string de 73 caracteres>" }
```

**Passos:**

1. Para cada variação acima, instanciar/validar o schema `UserUpdate` diretamente.
   **Resultado esperado:**

- Ambas as variações levantam erro de validação (`ValidationError`), pelos mesmos motivos de TC-006 e TC-016 aplicados ao contexto de atualização.
  **Observações:**
- Reaproveita a mesma regra de tamanho de senha do cadastro (RF-01) — o teste existe para confirmar que a regra foi aplicada de forma consistente no schema de atualização também, não só no de cadastro (um erro comum é duplicar a regra em dois schemas e esquecer de manter os dois sincronizados).

---

### TC-033 — Token malformado retorna 401

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-03                  |
| **Tipo**           | Negativo — autorização |
| **Nível**          | Integration            |
| **Prioridade**     | Alta                   |

**Pré-condições:**

- Nenhuma — usa uma string arbitrária como token, não um token real gerado pelo sistema.
  **Dados de entrada:**
- Header: `Authorization: Bearer isso-nao-e-um-jwt-valido`
  **Passos:**

1. Enviar requisição `PUT /auth/me` com um token malformado (não decodificável) no header.
2. Consultar a resposta retornada pela API.
   **Resultado esperado:**

- Status HTTP: `401 Unauthorized`
- Corpo da resposta contém mensagem de erro apropriada (ex: `"Token inválido ou expirado"`), sem expor detalhes internos da falha de decodificação.
  **Observações:**
- Diferente de TC-030 (ausência total de token), este testa a presença de um token que existe mas é inválido — caminho de código diferente dentro da mesma dependência `get_current_user`.

---

### TC-034 — Token expirado retorna 401

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-03                  |
| **Tipo**           | Negativo — autorização |
| **Nível**          | Unit                   |
| **Prioridade**     | Média                  |

**Pré-condições:**

- Nenhuma dependência de API completa — o teste gera um token com tempo de expiração mockado para o passado.
  **Dados de entrada:**
- Token gerado com `exp` no passado (ex: mockando o relógio no momento da geração, ou construindo o payload manualmente com `exp` já vencido).
  **Passos:**

1. Gerar um token cujo claim `exp` já esteja no passado.
2. Chamar a função de decodificação/validação de token diretamente (`decode_access_token`).
   **Resultado esperado:**

- A função retorna `None` (ou levanta a exceção equivalente), indicando token inválido por expiração.
  **Observações:**
- Testado no nível Unit para evitar a necessidade de esperar 7 dias reais (o tempo de expiração configurado) — o mock de tempo é essencial aqui.
- Complementa TC-033: juntos, cobrem os dois motivos possíveis de um token ser rejeitado (malformado vs. expirado), que compartilham o mesmo status HTTP mas têm causas internas diferentes.

---

### TC-035 — Corpo de atualização vazio retorna sucesso sem alterar dados

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-03                        |
| **Tipo**           | Funcional — regra de negócio |
| **Nível**          | Integration                  |
| **Prioridade**     | Baixa                        |

**Pré-condições:**

- Usuário cadastrado e autenticado.
  **Dados de entrada:**

```json
{}
```

**Passos:**

1. Cadastrar e logar o usuário, obtendo o token.
2. Enviar requisição `PUT /auth/me` com corpo vazio.
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que nenhum campo foi alterado.
   **Resultado esperado:**

- Status HTTP: `200 OK`
- Corpo da resposta reflete o perfil atual, sem nenhuma alteração.
- Nenhum campo no banco de dados foi modificado.
  **Observações:**
- Decisão de PO confirmada: corpo vazio é tratado como no-op de sucesso, não como erro. Ver `02-requisitos-rangos.md`, RF-03.

---

### TC-036 — Atualização de múltiplos campos simultaneamente aplica todas as mudanças

| Campo              | Detalhe             |
| ------------------ | ------------------- |
| **RF relacionado** | RF-03               |
| **Tipo**           | Funcional — sucesso |
| **Nível**          | Integration         |
| **Prioridade**     | Média               |

**Pré-condições:**

- Usuário cadastrado e autenticado.
  **Dados de entrada:**

```json
{
  "name": "Ana Souza Silva",
  "email": "ana.nova@example.com",
  "password": "outranovasenha99"
}
```

**Passos:**

1. Cadastrar e logar o usuário, obtendo o token.
2. Enviar requisição `PUT /auth/me` com os três campos simultaneamente.
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que **todos** os três campos foram alterados corretamente.
5. Tentar login com o e-mail e senha novos.
   **Resultado esperado:**

- Status HTTP: `200 OK`
- Corpo da resposta reflete `name` e `email` atualizados.
- Login subsequente com o e-mail novo e a senha nova funciona (passo 5).
  **Observações:**
- Este teste garante que a atualização de múltiplos campos não sofre de efeitos colaterais parciais (ex: nome e e-mail atualizarem, mas senha silenciosamente ignorada, ou vice-versa) — um risco real quando a lógica de atualização trata cada campo com um `if` independente.
