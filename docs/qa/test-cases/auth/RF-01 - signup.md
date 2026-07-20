## RF-01 — Cadastro de usuário

### TC-AUTH-001 — Cadastro com dados válidos cria conta

| Campo              | Valor               |
| ------------------ | ------------------- |
| **RF relacionado** | RF-01               |
| **Tipo**           | Funcional — sucesso |
| **Nível**          | Integration         |
| **Prioridade**     | Alta                |

**Pré-condições:**

- Nenhum usuário previamente cadastrado com o e-mail usado no teste.
- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.costa@example.com",
  "password": "senha1234",
  "phone": "86999999999",
  "role": "customer"
}
```

**Passos:**

1. Enviar requisição `POST /auth/register` com os dados de entrada acima.
2. Consultar a resposta retornada pela API.
3. (Se aplicável) Consultar diretamente o banco de dados para confirmar a persistência do registro.

**Resultado esperado:**

- Status HTTP: `201 Created`
- Corpo da resposta contém: `id`, `name`, `email`, `role` — todos correspondendo aos dados enviados.
- Corpo da resposta **não** contém `password` nem `password_hash`.
- No banco de dados, a senha armazenada é um hash (bcrypt) e não o valor em texto puro.
- Um segundo cadastro com o mesmo e-mail deve subsequentemente falhar (ver TC-AUTH-002), um segundo cadastro com o mesmo telefone deve subsequentemente falhar (ver TC-003).

**Resultado atual:**

- Aguardando

- ✅ Conforme esperado

**Observações:**

- Este é o caso de teste base do módulo: praticamente todo outro teste do sistema (login, atualização de perfil, e futuramente carrinho/pedido) depende de um cadastro bem-sucedido para existir.
- Repetir este teste variando o campo `role` para `"partner"`, garantindo que ambos os tipos de usuário válidos sejam cobertos (ver também TC-AUTH-004 para o caso de `role` inválido).

---

### TC-002 — E-mail já cadastrado retorna erro de duplicidade

| Campo              | Valor                  |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-01                  |
| **Tipo**           | Negativo — duplicidade |
| **Nível**          | Integration            |
| **Prioridade**     | Alta                   |

**Pré-condições:**

- Já existe um usuário cadastrado com o e-mail `ana.costa@example.com` (ex: executar o fluxo de TC-001 antes deste teste, ou usar fixture equivalente).

**Dados de entrada:**

```json
{
  "name": "Outra Pessoa",
  "email": "ana.costa@example.com",
  "phone": "86988888888",
  "password": "outrasenha123",
  "role": "customer"
}
```

**Passos:**

1. Garantir que o e-mail `ana.costa@example.com` já está cadastrado.
2. Enviar requisição `POST /auth/register` com os dados de entrada acima (mesmo e-mail, dados diferentes de nome/senha/role).
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que **nenhum segundo registro** foi criado.

**Resultado esperado:**

- Status HTTP: `409 Conflict`
- Corpo da resposta contém mensagem de erro indicando duplicidade de e-mail, sem expor detalhes internos.
- O banco de dados continua com apenas **um** registro para esse e-mail.
- O usuário original continua conseguindo fazer login normalmente após essa tentativa falha (a tentativa de duplicidade não deve ter corrompido o registro existente).

**Observações:**

- Testar também a variação onde nome e role são idênticos ao original, apenas para confirmar que a validação é feita puramente pelo e-mail, não por uma combinação de campos.
- Este teste é a base para TC-013 (duplicidade case-insensitive) — uma vez que a decisão sobre case-sensitivity for confirmada, TC-013 reutiliza essa mesma estrutura, variando apenas o case do e-mail de entrada.

---

### TC-003 — Telefone já cadastrado retorna erro de duplicidade

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-01                  |
| **Tipo**           | Negativo — duplicidade |
| **Nível**          | Integration            |
| **Prioridade**     | Alta                   |

**Pré-condições:**

- Já existe um usuário cadastrado com o telefone `86999999999` (ex: executar o fluxo de TC-001 antes deste teste).

**Dados de entrada:**

```json
{
  "name": "Outra Pessoa",
  "email": "outra.pessoa@example.com",
  "phone": "86999999999",
  "password": "outrasenha123",
  "role": "customer"
}
```

**Passos:**

1. Garantir que o telefone `86999999999` já está cadastrado.
2. Enviar requisição `POST /auth/register` com os dados acima (e-mail diferente, mesmo telefone).
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que **nenhum segundo registro** foi criado.

**Resultado esperado:**

- Status HTTP: `409 Conflict`
- Corpo da resposta contém mensagem de erro indicando duplicidade de telefone.
- O banco de dados continua com apenas **um** registro para esse telefone.

**Observações:**

- Espelha a estrutura de TC-002, mas para o campo `phone` — mesma classe de bug possível (checagem de duplicidade ausente ou mal implementada).

---

### TC-004 — Campo `phone` ausente retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.semtelefone@example.com",
  "password": "senha1234",
  "role": "customer"
}
```

_(campo `phone` deliberadamente omitido do corpo da requisição)_

**Passos:**

1. Enviar requisição `POST /auth/register` com os dados acima, sem o campo `phone`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `phone` é obrigatório (mensagem de erro de validação do schema, não um erro genérico de servidor).
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `500 Internal Server Error` — na versão anterior do projeto (Node.js), campos obrigatórios ausentes causavam erro não tratado pelo middleware (ver TC-AUTH-007/008/009/010 da versão Node, documentados como BUG-005). Este teste existe justamente para garantir que esse tipo de regressão não se repita na versão Python: a ausência de um campo obrigatório deve sempre resultar em erro de validação (422) tratado pelo framework, nunca em uma exceção não capturada.

**Observações:**

- Este é um bom exemplo de teste "aprendido" com um bug de uma versão anterior — sua existência documenta uma lição de arquitetura, não só um requisito isolado.
- Repetir a mesma estrutura de teste para os demais campos obrigatórios ausentes (TC-008, TC-009, TC-010, TC-011), já que todos compartilham esse mesmo risco de regressão.

---

### TC-005 — Telefone em formato inválido retorna erro de validação

| Campo              | Detalhe                         |
| ------------------ | ------------------------------- |
| **RF relacionado** | RF-01                           |
| **Tipo**           | Negativo — validação de formato |
| **Nível**          | Integration                     |
| **Prioridade**     | Alta                            |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada (variações a testar):**

```json
{ "phone": "abc123456789" }
```

```json
{ "phone": "8699999" }
```

```json
{ "phone": "869999999999999" }
```

_(demais campos com **valores válidos** em todas as variações)_

**Passos:**

1. Para cada variação de `phone` acima, enviar requisição `POST /auth/register` com os demais campos válidos.
2. Consultar a resposta retornada pela API em cada caso.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado em nenhuma das tentativas.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity` para todas as variações.
- Corpo da resposta indica claramente que o formato do telefone é inválido.
- Nenhum registro é persistido no banco de dados.

**Observações:**

- Tratado como um único caso de teste "guarda-chuva", mas na implementação deve virar múltiplos casos parametrizados (letras, tamanho curto, tamanho longo) — cada variação é um assert independente, não apenas um exemplo ilustrativo.
- Complementa TC-004 (ausência do campo) cobrindo o eixo "presente, mas inválido".

---

### TC-006 — Senha com menos de 8 caracteres retorna erro de validação

| Campo              | Detalhe                         |
| ------------------ | ------------------------------- |
| **RF relacionado** | RF-01                           |
| **Tipo**           | Negativo — validação de formato |
| **Nível**          | Unit                            |
| **Prioridade**     | Crítica                         |

**Pré-condições:**

- Nenhuma dependência de banco de dados ou API — este teste valida a regra diretamente na camada de schema/validação (ex: `UserCreate` no Pydantic), sem passar por uma requisição HTTP completa.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.senhacurta@example.com",
  "phone": "86999999999",
  "password": "1234567",
  "role": "customer"
}
```

_(senha com **7 caracteres**, um a menos que o mínimo)_

**Passos:**

1. Instanciar/validar o schema de entrada (`UserCreate`) diretamente com os dados acima.
2. Capturar a exceção de validação levantada.

**Resultado esperado:**

- A validação levanta um erro (ex: `ValidationError` do Pydantic), sem exigir acesso ao banco de dados.
- A mensagem de erro referencia o campo `password` e a violação da regra de tamanho mínimo.

**Observações:**

- Por ser puramente uma regra de schema (sem depender de estado do banco), este teste roda mais rápido e de forma mais isolada como Unit — não precisa da sobrecarga de subir um cliente de teste HTTP completo.
- Ver também TC-014 (limite mínimo exato, 8 caracteres — caso positivo/boundary) e TC-016 (limite máximo excedido, 73 caracteres), que juntos cobrem os dois extremos da regra de tamanho de senha.

---

### TC-007 — Tipo de usuário inválido retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Negativo — validação de enum |
| **Nível**          | Integration                  |
| **Prioridade**     | Média                        |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.roleinvalida@example.com",
  "phone": "86999999999",
  "password": "senha1234",
  "role": "admin"
}
```

_(`role` fora dos valores permitidos: nem `"customer"` nem `"partner"`)_

**Passos:**

1. Enviar requisição `POST /auth/register` com `role: "admin"`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o valor de `role` não é um dos valores aceitos pelo enum.
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `500 Internal Server Error` — na versão anterior do projeto (Node.js), um valor de enum inválido para o tipo de usuário causava erro não tratado (ver TC-AUTH-013 da versão Node, documentado como BUG-005). Este teste garante que a validação de enum é tratada como erro de entrada (422), não como falha interna do servidor.

**Observações:**

- Mesma classe de regressão do TC-004 — reforça que toda validação de schema (campo ausente, tipo errado, enum inválido) deve resultar em 422 tratado, nunca em exceção não capturada.

---

### TC-008 — Campo `name` ausente retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "email": "ana.semnome@example.com",
  "phone": "86999999998",
  "password": "senha1234",
  "role": "customer"
}
```

_(campo `name` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/register` sem o campo `name`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `name` é obrigatório.
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `500 Internal Server Error` — mesma classe de regressão documentada em TC-004 (ver BUG-005 da versão Node).

---

### TC-009 — Campo `email` ausente retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.
  **Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "phone": "86999999997",
  "password": "senha1234",
  "role": "customer"
}
```

_(campo `email` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/register` sem o campo `email`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `email` é obrigatório.
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `500 Internal Server Error` — mesma classe de regressão documentada em TC-004 (ver BUG-005 da versão Node).

---

### TC-010 — Campo `password` ausente retorna erro de validação

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Negativo — campo obrigatório |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.semsenha@example.com",
  "phone": "86999999996",
  "role": "customer"
}
```

_(campo `password` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/register` sem o campo `password`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity`
- Corpo da resposta indica claramente que o campo `password` é obrigatório.
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `500 Internal Server Error` — mesma classe de regressão documentada em TC-004 (ver BUG-005 da versão Node).

**Observações:**

- Este é o caso mais sensível de todos os "campo ausente": se por algum motivo uma implementação futura tratar `password` ausente como `None`/`null` sem validação de schema, existe risco de a aplicação tentar gerar um hash de senha vazio, ou pior, permitir login sem senha. O teste deve garantir que isso é impossível na camada de validação de entrada, antes mesmo de qualquer lógica de negócio ser executada.

---

### TC-011 — Campo `role` ausente assume `Customer` como padrão

| Campo              | Detalhe                      |
| ------------------ | ---------------------------- |
| **RF relacionado** | RF-01                        |
| **Tipo**           | Funcional — regra de negócio |
| **Nível**          | Integration                  |
| **Prioridade**     | Alta                         |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

  **Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.semrole@example.com",
  "phone": "86999999995",
  "password": "senha1234"
}
```

_(campo `role` deliberadamente omitido)_

**Passos:**

1. Enviar requisição `POST /auth/register` sem o campo `role`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados para confirmar o valor de `role` persistido.

**Resultado esperado:**

- Status HTTP: `201 Created`
- Corpo da resposta contém `role: "customer"`, mesmo sem o campo ter sido informado na requisição.
- O registro persistido no banco de dados reflete `role = customer`.

**Observações:**

- Decisão de PO (revisada): diferente da primeira definição deste RF, `role` passou a ser **opcional**, com `Customer` como padrão — alinhado ao comportamento da versão anterior do projeto (Node.js, que tinha o mesmo padrão para `typeUser`, ver TC-AUTH-003 daquela versão). Ver `02-requisitos-rangos.md`, RF-01, para o registro formal da decisão.
- TC-007 (role inválido, ex: `"admin"`) continua válido e necessário — a regra é "ausente vira padrão", não "qualquer coisa é aceita". Um valor de `role` explicitamente informado e fora do enum ainda deve ser rejeitado com 422.

---

### TC-012 — Formato de e-mail inválido retorna erro de validação

| Campo              | Detalhe                         |
| ------------------ | ------------------------------- |
| **RF relacionado** | RF-01                           |
| **Tipo**           | Negativo — validação de formato |
| **Nível**          | Integration                     |
| **Prioridade**     | Alta                            |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.
  **Dados de entrada (variações a testar):**

```json
{ "email": "ana@" }
```

```json
{ "email": "não-é-email" }
```

```json
{ "email": "ana@example" }
```

_(demais campos com **valores válidos** em todas as variações)_

**Passos:**

1. Para cada variação de `email` acima, enviar requisição `POST /auth/register` com os demais campos válidos.
2. Consultar a resposta retornada pela API em cada caso.
3. Consultar o banco de dados para confirmar que **nenhum registro** foi criado em nenhuma das tentativas.

**Resultado esperado:**

- Status HTTP: `422 Unprocessable Entity` para todas as variações.
- Corpo da resposta indica claramente que o formato do e-mail é inválido.
- Nenhum registro é persistido no banco de dados.

**Resultado que NÃO deve ocorrer (referência ao histórico do projeto):**

- Status `201 Created` — na versão anterior do projeto (Node.js), e-mails em formato inválido eram aceitos sem qualquer validação de formato (ver TC-AUTH-011 da versão Node, documentado como BUG-001). Este é o bug de maior risco de toda a comparação com a versão anterior: aceitar e-mails inválidos compromete recuperação de senha, notificações e comunicação com o usuário — e só seria percebido tarde, quando o usuário tentasse recuperar acesso à conta.
  **Observações:**
- Assim como TC-005, tratado como caso "guarda-chuva" com múltiplas variações — cada uma deve virar um assert parametrizado independente na implementação, não apenas um exemplo ilustrativo.
- Este é o teste que caso passasse despercebido, teria o maior impacto negativo real de todo o módulo — priorizar sua implementação cedo.

---

### TC-013 — E-mail duplicado com case diferente é tratado como duplicidade

| Campo              | Detalhe                |
| ------------------ | ---------------------- |
| **RF relacionado** | RF-01                  |
| **Tipo**           | Negativo — duplicidade |
| **Nível**          | Integration            |
| **Prioridade**     | Alta                   |

**Pré-condições:**

- Já existe um usuário cadastrado com o e-mail `ana.costa@example.com` (minúsculo).

**Dados de entrada:**

```json
{
  "name": "Outra Pessoa",
  "email": "Ana.Costa@Example.com",
  "phone": "86977777777",
  "password": "outrasenha123",
  "role": "customer"
}
```

_(**mesmo e-mail** do usuário já cadastrado, porém com capitalização diferente)_

**Passos:**

1. Garantir que `ana.costa@example.com` já está cadastrado (minúsculo).
2. Enviar requisição `POST /auth/register` com o e-mail `Ana.Costa@Example.com` (capitalização diferente).
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que **nenhum segundo registro** foi criado.

**Resultado esperado:**

- Status HTTP: `409 Conflict` — mesmo comportamento de TC-002, mesmo com capitalização diferente.
- Corpo da resposta contém mensagem de erro indicando duplicidade de e-mail.
- No banco de dados, o e-mail permanece armazenado normalizado (minúsculo) — validar que a comparação usa normalização, não uma regra especial de case-insensitive na query.

**Observações:**

- Decisão de PO confirmada: deduplicação de e-mail é case-insensitive (e-mail normalizado para minúsculas antes de salvar e comparar). Ver `02-requisitos-rangos.md`, RF-01.
- Este teste é o complemento direto de TC-002: mesma regra de negócio, variação apenas na capitalização da entrada.
- Base para TC-025 (login com case diferente) — uma vez que o cadastro normaliza corretamente, o login deve reconhecer o mesmo e-mail independentemente da capitalização usada.

---

### TC-014 — Senha com exatamente 8 caracteres (limite mínimo) é aceita

| Campo              | Detalhe              |
| ------------------ | -------------------- |
| **RF relacionado** | RF-01                |
| **Tipo**           | Funcional — boundary |
| **Nível**          | Unit                 |
| **Prioridade**     | Alta                 |

**Pré-condições:**

- Nenhuma — teste de schema puro, sem banco de dados.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.senha8@example.com",
  "phone": "86999999994",
  "password": "12345678",
  "role": "customer"
}
```

_(**senha com exatamente 8 caracteres** — o limite mínimo permitido)_

**Passos:**

1. Instanciar/validar o schema de entrada (`UserCreate`) diretamente com os dados acima.

**Resultado esperado:**

- Nenhuma exceção de validação é levantada — o schema aceita a senha normalmente.

**Observações:**

- Caso "espelho" de TC-006 (7 caracteres, deve falhar): juntos, os dois testes definem exatamente onde está a fronteira da regra (7 falha, 8 passa).
- Testes de boundary como este são os que mais frequentemente pegam erros de operador (`<` vs `<=`) na implementação da validação.

---

### TC-015 — Senha com exatamente 72 caracteres (limite máximo) é aceita

| Campo              | Detalhe              |
| ------------------ | -------------------- |
| **RF relacionado** | RF-01                |
| **Tipo**           | Funcional — boundary |
| **Nível**          | Unit                 |
| **Prioridade**     | Alta                 |

**Pré-condições:**

- Nenhuma — teste de schema puro, sem banco de dados.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.senha72@example.com",
  "phone": "86999999993",
  "password": "<string de exatamente 72 caracteres>",
  "role": "customer"
}
```

**Passos:**

1. Gerar uma string de exatamente 72 caracteres para o campo `password`.
2. Instanciar/validar o schema de entrada (`UserCreate`) diretamente com os dados acima.
3. (Complementar) Simular o cadastro completo e confirmar que o hash bcrypt gerado corresponde à senha completa de 72 caracteres, não a uma versão truncada.

**Resultado esperado:**

- Nenhuma exceção de validação é levantada.
- O hash bcrypt resultante reflete os 72 caracteres completos (validado indiretamente: login subsequente com a senha completa de 72 caracteres deve funcionar).

**Observações:**

- Este teste é o que efetivamente prova que a decisão de limitar em 72 caracteres está correta e alinhada ao limite técnico do bcrypt (ver `02-requisitos-rangos.md`, RF-01) — sem ele, seria só uma afirmação não verificada.
- Repetir o passo 3 (login com a senha completa) é o que diferencia este teste de um teste raso que só verifica ausência de erro de validação.

---

### TC-016 — Senha com 73 caracteres retorna erro de validação

| Campo              | Detalhe                         |
| ------------------ | ------------------------------- |
| **RF relacionado** | RF-01                           |
| **Tipo**           | Negativo — validação de formato |
| **Nível**          | Unit                            |
| **Prioridade**     | Alta                            |

**Pré-condições:**

- Nenhuma — teste de schema puro, sem banco de dados.

**Dados de entrada:**

```json
{
  "name": "Ana Costa",
  "email": "ana.senha73@example.com",
  "phone": "86999999992",
  "password": "<string de exatamente 73 caracteres>",
  "role": "customer"
}
```

**Passos:**

1. Gerar uma string de exatamente 73 caracteres para o campo `password`.
2. Instanciar/validar o schema de entrada (`UserCreate`) diretamente com os dados acima.

**Resultado esperado:**

- A validação levanta um erro (ex: `ValidationError` do Pydantic), rejeitando a senha antes de qualquer tentativa de hashing.
- A mensagem de erro referencia o campo `password` e a violação do limite máximo.

**Observações:**

- Caso "espelho" de TC-015 (72 caracteres, deve passar): juntos, definem a fronteira exata do limite máximo.
- Este teste é o que garante que o comportamento perigoso descrito na justificativa da regra (truncamento silencioso do bcrypt) nunca chega a acontecer — a rejeição acontece na validação de entrada, antes mesmo do bcrypt processar qualquer coisa.

---

### TC-017 — Nome com acentuação/caracteres especiais é aceito e persistido corretamente

| Campo              | Detalhe               |
| ------------------ | --------------------- |
| **RF relacionado** | RF-01                 |
| **Tipo**           | Funcional — edge case |
| **Nível**          | Integration           |
| **Prioridade**     | Média                 |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "José da Conceição Araújo",
  "email": "jose.acentuado@example.com",
  "phone": "86999999991",
  "password": "senha1234",
  "role": "customer"
}
```

**Passos:**

1. Enviar requisição `POST /auth/register` com nome contendo acentuação (á, ã, ç, é).
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados diretamente e comparar o valor de `name` armazenado, byte a byte, com o valor enviado.

**Resultado esperado:**

- Status HTTP: `201 Created`
- Corpo da resposta contém `name` idêntico ao enviado, sem substituição, remoção ou escaping incorreto dos caracteres acentuados.
- O valor persistido no banco corresponde exatamente ao valor enviado (sem problemas de encoding, ex: `Jos\u00e9` corrompido para `Jos?` ou similar).

**Observações:**

- Especialmente relevante no contexto brasileiro do Rangos — nomes com acentuação são a norma, não a exceção, e um bug de encoding aqui afetaria a maioria dos usuários reais.
- Vale testar também com o encoding de resposta HTTP (`Content-Type: application/json; charset=utf-8`) explicitamente verificado, não só o conteúdo textual.

---

### TC-018 — Tentativa de SQL injection no campo `name` não compromete o banco

| Campo              | Detalhe     |
| ------------------ | ----------- |
| **RF relacionado** | RF-01       |
| **Tipo**           | Segurança   |
| **Nível**          | Integration |
| **Prioridade**     | Crítica     |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado, contendo ao menos um outro usuário previamente cadastrado (para detectar se a tabela foi corrompida/apagada).

**Dados de entrada:**

```json
{
  "name": "Robert'); DROP TABLE users;--",
  "email": "sqlinjection@example.com",
  "phone": "86999999990",
  "password": "senha1234",
  "role": "customer"
}
```

**Passos:**

1. Garantir que existe ao menos um usuário previamente cadastrado no banco.
2. Enviar requisição `POST /auth/register` com o payload de SQL injection no campo `name`.
3. Consultar a resposta retornada pela API.
4. Consultar o banco de dados para confirmar que a tabela `users` **ainda existe** e que o usuário previamente cadastrado **ainda está lá**.
5. Consultar o registro recém-criado e confirmar que o campo `name` foi salvo como texto literal (a string completa da tentativa de injection), não interpretado como comando SQL.

**Resultado esperado:**

- Status HTTP: `201 Created` (o cadastro é aceito — o payload é uma string válida do ponto de vista de schema, só perigosa se mal tratada na camada de banco).
- A tabela `users` permanece intacta, com todos os registros anteriores preservados.
- O campo `name` do novo registro contém a string literal `"Robert'); DROP TABLE users;--"`, sem execução de comando SQL.

**Observações:**

- Este teste só tem valor real se o acesso ao banco usar ORM/queries parametrizadas (o que já é o padrão ao usar SQLAlchemy, conforme `03-architecture.md`) — ele existe para **provar** essa proteção, não para descobrir uma vulnerabilidade nova em uma stack já protegida por padrão.
- Testar múltiplas variações do payload de injection (ex: `' OR '1'='1`, `'; DELETE FROM users WHERE '1'='1`) fortalece a cobertura, mas o objetivo central é sempre o mesmo: nenhuma delas deve afetar o banco além do registro do próprio teste.

---

### TC-019 — Tentativa de XSS no campo `name` é armazenada como texto literal, sem execução

| Campo              | Detalhe     |
| ------------------ | ----------- |
| **RF relacionado** | RF-01       |
| **Tipo**           | Segurança   |
| **Nível**          | Integration |
| **Prioridade**     | Alta        |

**Pré-condições:**

- API disponível e banco de dados de teste limpo/isolado.

**Dados de entrada:**

```json
{
  "name": "<script>alert('XSS')</script>",
  "email": "xsstest@example.com",
  "phone": "86999999989",
  "password": "senha1234",
  "role": "customer"
}
```

**Passos:**

1. Enviar requisição `POST /auth/register` com o payload de XSS no campo `name`.
2. Consultar a resposta retornada pela API.
3. Consultar o banco de dados e confirmar que o campo `name` foi salvo como texto literal (a tag `<script>` completa), sem sanitização que a remova silenciosamente nem escaping que a corrompa.

**Resultado esperado:**

- Status HTTP: `201 Created`
- O campo `name` retornado e persistido contém a string literal `"<script>alert('XSS')</script>"`.
- A responsabilidade de escapar esse conteúdo ao exibir em HTML é do consumidor da API (frontend), não da API em si — este teste garante apenas que a API não corrompe nem executa o conteúdo, apenas armazena e retorna fielmente.

**Observações:**

- Diferente de TC-018 (onde a preocupação é a integridade do banco), aqui a preocupação é que o dado retornado pela API, se renderizado sem escaping por um frontend mal implementado, poderia executar o script. Este teste cobre a responsabilidade da API (armazenar/retornar fielmente); um teste equivalente do lado do frontend (fora do escopo deste documento) deveria cobrir a responsabilidade de escapar esse conteúdo antes de renderizar.
- Vale documentar essa divisão de responsabilidade explicitamente no código do teste (comentário), para que não pareça que a API "deveria" sanitizar e o teste esteja com expectativa errada.
