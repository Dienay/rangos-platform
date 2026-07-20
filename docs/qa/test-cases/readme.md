# Casos de Teste

Este diretório reúne todos os casos de teste do projeto.

Os casos são organizados por requisito funcional (RF) e mantêm rastreabilidade com:

- `docs/sdlc/02-requirements.md`
- `docs/sdlc/04-testing.md`
- `docs/qa/traceability-matrix.md`

---

# Organização

Os casos de teste são agrupados por módulo e requisito funcional.

Exemplo:

```text
test-cases/
├── auth/
│   ├── rf-01-register.md
│   ├── rf-02-login.md
│   └── rf-03-profile.md
├── restaurants/
├── products/
├── cart/
└── orders/
```

Cada arquivo representa um requisito funcional específico.

---

# Convenção de elaboração

Os casos de teste são escritos seguindo a mesma ordem em que normalmente são projetados durante a análise de testes.

1. Caminho feliz (Happy Path)
2. Casos negativos derivados diretamente do requisito
3. Casos de validação
4. Edge cases (limites)
5. Casos implícitos
6. Casos de segurança

Essa organização facilita a revisão dos testes e a rastreabilidade com os critérios de aceite.

---

# Categorias

O campo **Tipo** utiliza as seguintes categorias:

| Categoria                       | Objetivo                       |
| ------------------------------- | ------------------------------ |
| Funcional — sucesso             | Fluxo principal esperado       |
| Negativo — duplicidade          | Recursos já existentes         |
| Negativo — campo obrigatório    | Campos ausentes                |
| Negativo — validação de formato | Formatos inválidos             |
| Negativo — credencial inválida  | Autenticação                   |
| Negativo — autorização          | Controle de acesso             |
| Edge case                       | Valores de limite              |
| Segurança                       | Tentativas de abuso ou ataques |

---

# Estrutura de um caso de teste

Cada caso deve seguir o mesmo formato.

- Identificador (TC-001)
- Requisito (RF)
- Objetivo
- Tipo
- Prioridade
- Pré-condições
- Dados de teste
- Passos
- Resultado esperado
- Status

---

# Identificação

Os identificadores são únicos em todo o projeto.

Exemplo:

```
TC-001
TC-002
TC-003
...
```

A numeração é contínua e não reinicia entre módulos.
