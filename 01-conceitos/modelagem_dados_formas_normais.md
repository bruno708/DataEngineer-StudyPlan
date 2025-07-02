# Modelagem de Dados e Formas Normais - Conceitos Fundamentais

## 📚 Índice

1. [Introdução à Modelagem de Dados](#introdução-à-modelagem-de-dados)
2. [Modelo Entidade-Relacionamento (ER)](#modelo-entidade-relacionamento-er)
3. [Modelo Relacional](#modelo-relacional)
4. [Dependências Funcionais](#dependências-funcionais)
5. [Formas Normais](#formas-normais)
6. [Desnormalização](#desnormalização)
7. [Modelagem Dimensional](#modelagem-dimensional)
8. [NoSQL e Modelagem Não-Relacional](#nosql-e-modelagem-não-relacional)
9. [Ferramentas de Modelagem](#ferramentas-de-modelagem)
10. [Boas Práticas](#boas-práticas)

---

## 🎯 Introdução à Modelagem de Dados

### O que é Modelagem de Dados?

A **modelagem de dados** é o processo de criar uma representação abstrata e conceitual de como os dados são organizados, armazenados e relacionados em um sistema de informação.

### Objetivos da Modelagem

- ✅ **Organizar dados** de forma lógica e eficiente
- ✅ **Eliminar redundâncias** desnecessárias
- ✅ **Garantir integridade** dos dados
- ✅ **Facilitar consultas** e manutenção
- ✅ **Documentar** a estrutura do sistema

### Níveis de Modelagem

1. **Modelo Conceitual**: Visão de alto nível, independente de tecnologia
2. **Modelo Lógico**: Estrutura detalhada, ainda independente de SGBD
3. **Modelo Físico**: Implementação específica do SGBD

### Tipos de Modelos

- **Hierárquico**: Estrutura em árvore
- **Rede**: Grafos com múltiplas conexões
- **Relacional**: Tabelas com relacionamentos
- **Orientado a Objetos**: Classes e objetos
- **NoSQL**: Documentos, grafos, chave-valor

---

## 🔗 Modelo Entidade-Relacionamento (ER)

### Componentes Básicos

#### Entidades
```
┌─────────────┐
│   CLIENTE   │  ← Entidade
└─────────────┘

┌─────────────┐
│   PRODUTO   │  ← Entidade
└─────────────┘
```

#### Atributos
```
CLIENTE
├── id_cliente (PK)
├── nome
├── email
├── telefone
└── data_nascimento

PRODUTO
├── id_produto (PK)
├── nome
├── preco
├── categoria
└── estoque
```

#### Relacionamentos
```
CLIENTE ──[compra]── PRODUTO
   1                    N

CLIENTE ──[possui]── PEDIDO ──[contém]── PRODUTO
   1                   N         N           N
```

### Cardinalidades

#### Um para Um (1:1)
```
PESSOA ──[possui]── CPF
  1                  1
```

#### Um para Muitos (1:N)
```
CATEGORIA ──[contém]── PRODUTO
    1                     N
```

#### Muitos para Muitos (N:N)
```
ESTUDANTE ──[cursa]── DISCIPLINA
    N                     N

# Resolução com tabela associativa:
ESTUDANTE ──[matricula]── MATRICULA ──[disciplina]── DISCIPLINA
    1                         N              N              1
```

### Exemplo Completo - Sistema de E-commerce

```sql
-- Modelo ER para E-commerce

Entidades:
- CLIENTE (id_cliente, nome, email, telefone, endereco)
- CATEGORIA (id_categoria, nome, descricao)
- PRODUTO (id_produto, nome, preco, estoque, id_categoria)
- PEDIDO (id_pedido, data_pedido, status, id_cliente)
- ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario)

Relacionamentos:
- CLIENTE [1] ──[faz]── [N] PEDIDO
- CATEGORIA [1] ──[possui]── [N] PRODUTO
- PEDIDO [1] ──[contém]── [N] ITEM_PEDIDO
- PRODUTO [1] ──[está_em]── [N] ITEM_PEDIDO
```

---

## 📊 Modelo Relacional

### Conceitos Fundamentais

#### Relação (Tabela)
```
CLIENTE
┌────────────┬─────────────┬──────────────────┬─────────────┐
│ id_cliente │    nome     │      email       │   telefone  │
├────────────┼─────────────┼──────────────────┼─────────────┤
│     1      │ João Silva  │ joao@email.com   │ 11999999999 │
│     2      │ Maria Santos│ maria@email.com  │ 11888888888 │
│     3      │ Pedro Costa │ pedro@email.com  │ 11777777777 │
└────────────┴─────────────┴──────────────────┴─────────────┘
```

#### Tupla (Linha/Registro)
```
│     1      │ João Silva  │ joao@email.com   │ 11999999999 │ ← Tupla
```

#### Atributo (Coluna)
```
│    nome     │ ← Atributo
├─────────────┤
│ João Silva  │
│ Maria Santos│
│ Pedro Costa │
```

#### Domínio
```
Atributo: idade
Domínio: {0, 1, 2, ..., 150} (números inteiros não negativos)

Atributo: status
Domínio: {'Ativo', 'Inativo', 'Suspenso'}
```

### Chaves

#### Chave Primária (Primary Key)
```sql
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY,  -- Chave primária
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);
```

#### Chave Estrangeira (Foreign Key)
```sql
CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY,
    data_pedido DATE,
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);
```

#### Chave Candidata
```sql
-- Múltiplas chaves candidatas
CREATE TABLE funcionario (
    id_funcionario INT PRIMARY KEY,  -- Chave primária escolhida
    cpf VARCHAR(11) UNIQUE,          -- Chave candidata
    email VARCHAR(100) UNIQUE,       -- Chave candidata
    matricula VARCHAR(10) UNIQUE     -- Chave candidata
);
```

#### Chave Composta
```sql
CREATE TABLE item_pedido (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    PRIMARY KEY (id_pedido, id_produto),  -- Chave composta
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);
```

---

## 🔍 Dependências Funcionais

### Definição

Uma **dependência funcional** X → Y significa que para cada valor de X, existe exatamente um valor de Y.

### Exemplos

```
Tabela: FUNCIONARIO
Atributos: {CPF, Nome, Departamento, Salario, Gerente}

Dependências Funcionais:
CPF → Nome, Departamento, Salario    (CPF determina funcionalmente outros atributos)
Departamento → Gerente               (Cada departamento tem um gerente)
```

### Tipos de Dependências

#### Dependência Funcional Total
```
Tabela: ITEM_PEDIDO
Chave: {id_pedido, id_produto}

{id_pedido, id_produto} → quantidade
{id_pedido, id_produto} → preco_unitario

# Dependência total: precisa da chave completa
```

#### Dependência Funcional Parcial
```
Tabela: ITEM_PEDIDO (problemática)
Chave: {id_pedido, id_produto}

id_pedido → data_pedido     # Dependência parcial (só parte da chave)
id_produto → nome_produto   # Dependência parcial (só parte da chave)
```

#### Dependência Transitiva
```
Tabela: FUNCIONARIO

CPF → Departamento → Gerente

# CPF determina Departamento, e Departamento determina Gerente
# Logo, CPF determina Gerente transitivamente
```

### Axiomas de Armstrong

```
Reflexividade: Se Y ⊆ X, então X → Y
Aumento: Se X → Y, então XZ → YZ
Transitividade: Se X → Y e Y → Z, então X → Z
```

---

## 📐 Formas Normais

### Primeira Forma Normal (1FN)

**Regra**: Eliminar grupos repetitivos e garantir atomicidade dos atributos.

#### ❌ Não está em 1FN
```
CLIENTE
┌────────────┬─────────────┬──────────────────────────┐
│ id_cliente │    nome     │        telefones         │
├────────────┼─────────────┼──────────────────────────┤
│     1      │ João Silva  │ 11999999999, 1188888888 │
│     2      │ Maria Santos│ 11777777777             │
└────────────┴─────────────┴──────────────────────────┘
```

#### ✅ Em 1FN
```
CLIENTE
┌────────────┬─────────────┐
│ id_cliente │    nome     │
├────────────┼─────────────┤
│     1      │ João Silva  │
│     2      │ Maria Santos│
└────────────┴─────────────┘

TELEFONE
┌────────────┬─────────────┬──────────────┐
│ id_cliente │   telefone  │     tipo     │
├────────────┼─────────────┼──────────────┤
│     1      │ 11999999999 │   celular    │
│     1      │ 11888888888 │ residencial  │
│     2      │ 11777777777 │   celular    │
└────────────┴─────────────┴──────────────┘
```

### Segunda Forma Normal (2FN)

**Regra**: Estar em 1FN + eliminar dependências funcionais parciais.

#### ❌ Não está em 2FN
```
ITEM_PEDIDO
┌───────────┬────────────┬────────────┬──────────────┬─────────────┐
│ id_pedido │ id_produto │ quantidade │ nome_produto │ data_pedido │
├───────────┼────────────┼────────────┼──────────────┼─────────────┤
│    1      │     10     │     2      │   Notebook   │ 2024-01-15  │
│    1      │     20     │     1      │    Mouse     │ 2024-01-15  │
│    2      │     10     │     1      │   Notebook   │ 2024-01-16  │
└───────────┴────────────┴────────────┴──────────────┴─────────────┘

Problemas:
- id_produto → nome_produto (dependência parcial)
- id_pedido → data_pedido (dependência parcial)
```

#### ✅ Em 2FN
```
PEDIDO
┌───────────┬─────────────┐
│ id_pedido │ data_pedido │
├───────────┼─────────────┤
│    1      │ 2024-01-15  │
│    2      │ 2024-01-16  │
└───────────┴─────────────┘

PRODUTO
┌────────────┬──────────────┐
│ id_produto │ nome_produto │
├────────────┼──────────────┤
│     10     │   Notebook   │
│     20     │    Mouse     │
└────────────┴──────────────┘

ITEM_PEDIDO
┌───────────┬────────────┬────────────┐
│ id_pedido │ id_produto │ quantidade │
├───────────┼────────────┼────────────┤
│    1      │     10     │     2      │
│    1      │     20     │     1      │
│    2      │     10     │     1      │
└───────────┴────────────┴────────────┘
```

### Terceira Forma Normal (3FN)

**Regra**: Estar em 2FN + eliminar dependências transitivas.

#### ❌ Não está em 3FN
```
FUNCIONARIO
┌─────┬──────────┬──────────────┬─────────────┬─────────────┐
│ CPF │   Nome   │ Departamento │   Gerente   │   Salario   │
├─────┼──────────┼──────────────┼─────────────┼─────────────┤
│ 123 │   João   │      TI      │   Carlos    │    5000     │
│ 456 │  Maria   │      RH      │    Ana      │    4500     │
│ 789 │  Pedro   │      TI      │   Carlos    │    5200     │
└─────┴──────────┴──────────────┴─────────────┴─────────────┘

Problema:
CPF → Departamento → Gerente (dependência transitiva)
```

#### ✅ Em 3FN
```
FUNCIONARIO
┌─────┬──────────┬──────────────┬─────────────┐
│ CPF │   Nome   │ Departamento │   Salario   │
├─────┼──────────┼──────────────┼─────────────┤
│ 123 │   João   │      TI      │    5000     │
│ 456 │  Maria   │      RH      │    4500     │
│ 789 │  Pedro   │      TI      │    5200     │
└─────┴──────────┴──────────────┴─────────────┘

DEPARTAMENTO
┌──────────────┬─────────────┐
│ Departamento │   Gerente   │
├──────────────┼─────────────┤
│      TI      │   Carlos    │
│      RH      │    Ana      │
└──────────────┴─────────────┘
```

### Forma Normal de Boyce-Codd (BCNF)

**Regra**: Estar em 3FN + para toda dependência funcional X → Y, X deve ser superchave.

#### ❌ Não está em BCNF
```
AULA
┌───────────┬───────────┬─────────────┬──────────┐
│ Estudante │ Professor │ Disciplina  │   Sala   │
├───────────┼───────────┼─────────────┼──────────┤
│   João    │  Dr. Ana  │ Matemática  │   101    │
│   Maria   │  Dr. Ana  │ Matemática  │   101    │
│   Pedro   │ Dr. Carlos│   Física    │   102    │
└───────────┴───────────┴─────────────┴──────────┘

Chave: {Estudante, Disciplina}
Dependência problemática: Professor → Disciplina
(Professor não é superchave)
```

#### ✅ Em BCNF
```
MATRICULA
┌───────────┬─────────────┐
│ Estudante │ Disciplina  │
├───────────┼─────────────┤
│   João    │ Matemática  │
│   Maria   │ Matemática  │
│   Pedro   │   Física    │
└───────────┴─────────────┘

DISCIPLINA_PROFESSOR
┌─────────────┬───────────┬──────────┐
│ Disciplina  │ Professor │   Sala   │
├─────────────┼───────────┼──────────┤
│ Matemática  │  Dr. Ana  │   101    │
│   Física    │ Dr. Carlos│   102    │
└─────────────┴───────────┴──────────┘
```

### Quarta Forma Normal (4FN)

**Regra**: Estar em BCNF + eliminar dependências multivaloradas.

#### ❌ Não está em 4FN
```
FUNCIONARIO_HABILIDADES_IDIOMAS
┌─────────────┬─────────────┬─────────┐
│ Funcionario │ Habilidade  │ Idioma  │
├─────────────┼─────────────┼─────────┤
│    João     │    Java     │ Inglês  │
│    João     │    Java     │ Francês │
│    João     │   Python    │ Inglês  │
│    João     │   Python    │ Francês │
└─────────────┴─────────────┴─────────┘

Problema: Habilidades e Idiomas são independentes
```

#### ✅ Em 4FN
```
FUNCIONARIO_HABILIDADES
┌─────────────┬─────────────┐
│ Funcionario │ Habilidade  │
├─────────────┼─────────────┤
│    João     │    Java     │
│    João     │   Python    │
└─────────────┴─────────────┘

FUNCIONARIO_IDIOMAS
┌─────────────┬─────────┐
│ Funcionario │ Idioma  │
├─────────────┼─────────┤
│    João     │ Inglês  │
│    João     │ Francês │
└─────────────┴─────────┘
```

### Quinta Forma Normal (5FN)

**Regra**: Estar em 4FN + eliminar dependências de junção.

#### Exemplo Complexo
```
# Cenário: Fornecedores, Produtos e Projetos
# Um fornecedor pode fornecer um produto para um projeto
# apenas se ele fornece o produto E participa do projeto

FORNECEDOR_PRODUTO_PROJETO
┌─────────────┬─────────┬─────────┐
│ Fornecedor  │ Produto │ Projeto │
├─────────────┼─────────┼─────────┤
│   Acme      │  Parafuso│   A     │
│   Acme      │  Porca   │   A     │
│   Beta      │  Parafuso│   B     │
└─────────────┴─────────┴─────────┘

# Se pode ser decomposta sem perda em:
FORNECEDOR_PRODUTO + FORNECEDOR_PROJETO + PRODUTO_PROJETO
# Então não está em 5FN
```

---

## 📈 Desnormalização

### Quando Desnormalizar?

1. **Performance crítica** em consultas frequentes
2. **Relatórios complexos** com muitas junções
3. **Data warehouses** e sistemas analíticos
4. **Aplicações read-heavy**

### Técnicas de Desnormalização

#### Duplicação de Dados
```sql
-- Normalizado (3FN)
CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY,
    data_pedido DATE,
    id_cliente INT
);

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100)
);

-- Desnormalizado (para performance)
CREATE TABLE pedido_desnormalizado (
    id_pedido INT PRIMARY KEY,
    data_pedido DATE,
    id_cliente INT,
    nome_cliente VARCHAR(100),  -- Duplicado
    email_cliente VARCHAR(100)  -- Duplicado
);
```

#### Campos Calculados
```sql
-- Normalizado
CREATE TABLE item_pedido (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2)
);

-- Desnormalizado com campo calculado
CREATE TABLE item_pedido_desnormalizado (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2)  -- quantidade * preco_unitario
);
```

#### Agregações Pré-calculadas
```sql
-- Tabela de resumo para relatórios
CREATE TABLE vendas_mensais (
    ano INT,
    mes INT,
    total_vendas DECIMAL(15,2),
    quantidade_pedidos INT,
    ticket_medio DECIMAL(10,2),
    PRIMARY KEY (ano, mes)
);
```

### Consequências da Desnormalização

#### Vantagens
- ✅ **Melhor performance** em consultas
- ✅ **Menos junções** necessárias
- ✅ **Consultas mais simples**
- ✅ **Melhor para relatórios**

#### Desvantagens
- ❌ **Redundância de dados**
- ❌ **Maior complexidade** de manutenção
- ❌ **Risco de inconsistência**
- ❌ **Maior uso de espaço**

---

## 🎯 Modelagem Dimensional

### Conceitos Básicos

#### Fatos e Dimensões
```
FATO: Vendas (métricas/medidas)
├── quantidade_vendida
├── valor_venda
├── custo_produto
└── lucro

DIMENSÕES: (contexto)
├── Tempo (ano, mês, dia)
├── Produto (categoria, marca, modelo)
├── Cliente (região, segmento, idade)
└── Loja (cidade, estado, região)
```

### Esquema Estrela (Star Schema)

```
                    DIM_TEMPO
                   ┌─────────────┐
                   │ id_tempo    │
                   │ data        │
                   │ ano         │
                   │ mes         │
                   │ trimestre   │
                   │ dia_semana  │
                   └─────────────┘
                          │
                          │
DIM_PRODUTO        FATO_VENDAS         DIM_CLIENTE
┌─────────────┐   ┌─────────────┐    ┌─────────────┐
│ id_produto  │───│ id_produto  │    │ id_cliente  │
│ nome        │   │ id_cliente  │────│ nome        │
│ categoria   │   │ id_tempo    │    │ cidade      │
│ marca       │   │ id_loja     │    │ segmento    │
│ preco       │   │ quantidade  │    │ idade       │
└─────────────┘   │ valor_venda │    └─────────────┘
                  │ custo       │
                  │ lucro       │
                  └─────────────┘
                          │
                          │
                    DIM_LOJA
                   ┌─────────────┐
                   │ id_loja     │
                   │ nome_loja   │
                   │ cidade      │
                   │ estado      │
                   │ regiao      │
                   └─────────────┘
```

### Esquema Floco de Neve (Snowflake Schema)

```
DIM_CATEGORIA          DIM_PRODUTO
┌─────────────┐       ┌─────────────┐
│ id_categoria│───────│ id_produto  │
│ nome        │       │ nome        │
│ descricao   │       │ id_categoria│
└─────────────┘       │ id_marca    │
                      └─────────────┘
                             │
                             │
                      DIM_MARCA
                     ┌─────────────┐
                     │ id_marca    │
                     │ nome        │
                     │ pais_origem │
                     └─────────────┘
```

### Slowly Changing Dimensions (SCD)

#### Tipo 1: Sobrescrever
```sql
-- Cliente muda de cidade
UPDATE dim_cliente 
SET cidade = 'São Paulo' 
WHERE id_cliente = 123;

-- Histórico é perdido
```

#### Tipo 2: Versionar
```sql
DIM_CLIENTE
┌────────────┬─────────────┬─────────┬────────────┬────────────┬────────┐
│ id_cliente │ id_negocio  │  nome   │   cidade   │ data_inicio│data_fim│
├────────────┼─────────────┼─────────┼────────────┼────────────┼────────┤
│     1      │    C001     │  João   │ Rio de Jan │ 2023-01-01 │2024-06-│
│     2      │    C001     │  João   │ São Paulo  │ 2024-06-01 │9999-12-│
└────────────┴─────────────┴─────────┴────────────┴────────────┴────────┘
```

#### Tipo 3: Adicionar Coluna
```sql
DIM_CLIENTE
┌────────────┬─────────┬──────────────┬──────────────┐
│ id_cliente │  nome   │ cidade_atual │cidade_anterior│
├────────────┼─────────┼──────────────┼──────────────┤
│     1      │  João   │  São Paulo   │ Rio de Janeiro│
└────────────┴─────────┴──────────────┴──────────────┘
```

---

## 🗄️ NoSQL e Modelagem Não-Relacional

### Tipos de Bancos NoSQL

#### Documento (MongoDB, CouchDB)
```json
// Coleção: usuarios
{
  "_id": "507f1f77bcf86cd799439011",
  "nome": "João Silva",
  "email": "joao@email.com",
  "enderecos": [
    {
      "tipo": "residencial",
      "rua": "Rua das Flores, 123",
      "cidade": "São Paulo",
      "cep": "01234-567"
    },
    {
      "tipo": "comercial",
      "rua": "Av. Paulista, 1000",
      "cidade": "São Paulo",
      "cep": "01310-100"
    }
  ],
  "pedidos": [
    {
      "id_pedido": "P001",
      "data": "2024-01-15",
      "total": 299.99,
      "itens": [
        {"produto": "Notebook", "quantidade": 1, "preco": 299.99}
      ]
    }
  ]
}
```

#### Chave-Valor (Redis, DynamoDB)
```
Chave: "usuario:123"
Valor: {
  "nome": "João Silva",
  "email": "joao@email.com",
  "ultimo_login": "2024-01-15T10:30:00Z"
}

Chave: "sessao:abc123"
Valor: {
  "usuario_id": 123,
  "expira_em": "2024-01-15T12:00:00Z"
}
```

#### Coluna (Cassandra, HBase)
```
Tabela: usuarios
Partition Key: id_usuario
Clustering Key: timestamp

id_usuario | timestamp           | nome        | email           | acao
-----------+--------------------+-------------+-----------------+--------
123        | 2024-01-15 10:00:00| João Silva  | joao@email.com  | login
123        | 2024-01-15 10:30:00| João Silva  | joao@email.com  | compra
123        | 2024-01-15 11:00:00| João Silva  | joao@email.com  | logout
```

#### Grafo (Neo4j, Amazon Neptune)
```cypher
// Nós
(joao:Usuario {nome: "João Silva", email: "joao@email.com"})
(maria:Usuario {nome: "Maria Santos", email: "maria@email.com"})
(produto1:Produto {nome: "Notebook", preco: 2500.00})
(categoria1:Categoria {nome: "Eletrônicos"})

// Relacionamentos
(joao)-[:AMIGO_DE {desde: "2020-01-01"}]->(maria)
(joao)-[:COMPROU {data: "2024-01-15", quantidade: 1}]->(produto1)
(produto1)-[:PERTENCE_A]->(categoria1)
(maria)-[:VISUALIZOU {data: "2024-01-16"}]->(produto1)
```

### Padrões de Modelagem NoSQL

#### Embedding vs Referencing
```javascript
// Embedding (dados relacionados no mesmo documento)
{
  "_id": "pedido_001",
  "cliente": {
    "nome": "João Silva",
    "email": "joao@email.com"
  },
  "itens": [
    {"produto": "Notebook", "preco": 2500.00},
    {"produto": "Mouse", "preco": 50.00}
  ]
}

// Referencing (referências para outros documentos)
{
  "_id": "pedido_001",
  "cliente_id": "cliente_123",
  "item_ids": ["item_001", "item_002"]
}
```

#### Desnormalização Estratégica
```javascript
// Produto com informações desnormalizadas para performance
{
  "_id": "produto_001",
  "nome": "Notebook Dell",
  "preco": 2500.00,
  "categoria": {
    "id": "cat_001",
    "nome": "Eletrônicos",  // Desnormalizado
    "descricao": "Produtos eletrônicos"  // Desnormalizado
  },
  "estatisticas": {
    "total_vendas": 150,  // Calculado
    "avaliacao_media": 4.5,  // Calculado
    "ultima_venda": "2024-01-15"  // Desnormalizado
  }
}
```

---

## 🛠️ Ferramentas de Modelagem

### Ferramentas Visuais

#### MySQL Workbench
```sql
-- Geração automática de DDL
CREATE TABLE cliente (
  id_cliente INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NULL,
  PRIMARY KEY (id_cliente),
  UNIQUE INDEX email_UNIQUE (email ASC)
);
```

#### ERwin Data Modeler
- Modelagem conceitual, lógica e física
- Engenharia reversa de bancos existentes
- Geração de documentação automática

#### Lucidchart / Draw.io
- Diagramas ER online
- Colaboração em tempo real
- Templates prontos

### Ferramentas de Código

#### SQLAlchemy (Python)
```python
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Cliente(Base):
    __tablename__ = 'cliente'
    
    id_cliente = Column(Integer, primary_key=True)
    nome = Column(String(100), nullable=False)
    email = Column(String(100), unique=True)
    
    # Relacionamento
    pedidos = relationship("Pedido", back_populates="cliente")

class Pedido(Base):
    __tablename__ = 'pedido'
    
    id_pedido = Column(Integer, primary_key=True)
    data_pedido = Column(DateTime)
    id_cliente = Column(Integer, ForeignKey('cliente.id_cliente'))
    
    # Relacionamento
    cliente = relationship("Cliente", back_populates="pedidos")
```

#### Prisma (Node.js)
```prisma
model Cliente {
  id_cliente Int      @id @default(autoincrement())
  nome       String   @db.VarChar(100)
  email      String?  @unique @db.VarChar(100)
  pedidos    Pedido[]
  
  @@map("cliente")
}

model Pedido {
  id_pedido   Int      @id @default(autoincrement())
  data_pedido DateTime @default(now())
  id_cliente  Int
  cliente     Cliente  @relation(fields: [id_cliente], references: [id_cliente])
  
  @@map("pedido")
}
```

### Documentação de Modelos

#### Dicionário de Dados
```markdown
## Tabela: CLIENTE

| Campo      | Tipo         | Nulo | Chave | Descrição                    |
|------------|--------------|------|-------|------------------------------|
| id_cliente | INT          | Não  | PK    | Identificador único          |
| nome       | VARCHAR(100) | Não  | -     | Nome completo do cliente     |
| email      | VARCHAR(100) | Sim  | UK    | Email para contato           |
| telefone   | VARCHAR(15)  | Sim  | -     | Telefone principal           |
| data_nasc  | DATE         | Sim  | -     | Data de nascimento           |

### Regras de Negócio:
- Email deve ser único quando informado
- Nome é obrigatório
- Data de nascimento não pode ser futura
```

---

## ✅ Boas Práticas

### Nomenclatura

#### Convenções de Nomes
```sql
-- ✅ Boas práticas
CREATE TABLE cliente (          -- Singular, minúsculo
    id_cliente INT,             -- Prefixo com nome da tabela
    nome_completo VARCHAR(100), -- Snake_case
    data_nascimento DATE,       -- Nomes descritivos
    status_ativo BOOLEAN        -- Booleanos com is_ ou status_
);

-- ❌ Evitar
CREATE TABLE Clientes (         -- Plural, CamelCase
    ID INT,                     -- Muito genérico
    Name VARCHAR(100),          -- Inglês misturado
    dt_nasc DATE,               -- Abreviações
    ativo CHAR(1)               -- Char para boolean
);
```

#### Padrões de Chaves
```sql
-- Chaves primárias
id_cliente, id_produto, id_pedido

-- Chaves estrangeiras
id_cliente_fk, cliente_id

-- Chaves compostas
PRIMARY KEY (id_pedido, id_produto)
```

### Performance

#### Índices Estratégicos
```sql
-- Índices em chaves estrangeiras
CREATE INDEX idx_pedido_cliente ON pedido(id_cliente);

-- Índices em campos de busca frequente
CREATE INDEX idx_cliente_email ON cliente(email);
CREATE INDEX idx_produto_categoria ON produto(categoria);

-- Índices compostos para consultas específicas
CREATE INDEX idx_pedido_data_status ON pedido(data_pedido, status);
```

#### Particionamento
```sql
-- Particionamento por data
CREATE TABLE vendas (
    id_venda INT,
    data_venda DATE,
    valor DECIMAL(10,2)
) PARTITION BY RANGE (YEAR(data_venda)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);
```

### Integridade

#### Constraints
```sql
CREATE TABLE produto (
    id_produto INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) CHECK (preco > 0),
    categoria VARCHAR(50) NOT NULL,
    estoque INT DEFAULT 0 CHECK (estoque >= 0),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_produto_nome UNIQUE (nome),
    CONSTRAINT chk_categoria CHECK (categoria IN ('Eletrônicos', 'Roupas', 'Livros'))
);
```

#### Triggers para Auditoria
```sql
CREATE TABLE auditoria_produto (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT,
    operacao ENUM('INSERT', 'UPDATE', 'DELETE'),
    dados_antigos JSON,
    dados_novos JSON,
    usuario VARCHAR(100),
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER tr_produto_auditoria
AFTER UPDATE ON produto
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_produto (
        id_produto, operacao, dados_antigos, dados_novos, usuario
    ) VALUES (
        NEW.id_produto, 'UPDATE',
        JSON_OBJECT('nome', OLD.nome, 'preco', OLD.preco),
        JSON_OBJECT('nome', NEW.nome, 'preco', NEW.preco),
        USER()
    );
END//
DELIMITER ;
```

### Versionamento

#### Migrations
```sql
-- Migration 001: Criar tabela cliente
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Migration 002: Adicionar telefone
ALTER TABLE cliente ADD COLUMN telefone VARCHAR(15);

-- Migration 003: Criar índice em email
CREATE INDEX idx_cliente_email ON cliente(email);
```

---

## 🎓 Resumo dos Conceitos

### Modelagem de Dados
1. **Conceitual**: Entidades, atributos, relacionamentos
2. **Lógico**: Tabelas, colunas, chaves, constraints
3. **Físico**: Implementação específica do SGBD

### Formas Normais
1. **1FN**: Atomicidade dos atributos
2. **2FN**: Eliminar dependências parciais
3. **3FN**: Eliminar dependências transitivas
4. **BCNF**: Determinantes devem ser superchaves
5. **4FN**: Eliminar dependências multivaloradas
6. **5FN**: Eliminar dependências de junção

### Estratégias
- **Normalização**: Reduzir redundância e inconsistência
- **Desnormalização**: Melhorar performance de consultas
- **Modelagem Dimensional**: Star/Snowflake para analytics
- **NoSQL**: Flexibilidade para dados não-estruturados

### Boas Práticas
- Nomenclatura consistente e descritiva
- Documentação completa do modelo
- Índices estratégicos para performance
- Constraints para integridade
- Versionamento com migrations

---

## 📚 Próximos Passos

1. **Pratique** modelagem com casos reais
2. **Estude** padrões específicos do seu domínio
3. **Experimente** diferentes SGBDs
4. **Aprenda** sobre Data Warehousing
5. **Explore** bancos NoSQL para casos específicos

**Lembre-se**: A modelagem perfeita não existe. O objetivo é encontrar o equilíbrio entre normalização, performance e simplicidade para o seu contexto específico!