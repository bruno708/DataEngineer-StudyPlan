# 🗄️ Exercícios de Modelagem de Dados e Formas Normais

## 📚 Índice

1. [Exercícios de Modelo ER](#exercícios-de-modelo-er)
2. [Exercícios de Normalização](#exercícios-de-normalização)
3. [Exercícios de Modelagem Dimensional](#exercícios-de-modelagem-dimensional)
4. [Exercícios de NoSQL](#exercícios-de-nosql)
5. [Projetos Práticos](#projetos-práticos)
6. [Estudos de Caso](#estudos-de-caso)

---

## 🟢 Exercícios de Modelo ER

### Exercício 1: Sistema de Biblioteca

**Objetivo**: Criar um modelo ER básico.

**Cenário**: Uma biblioteca precisa controlar seus livros, autores, clientes e empréstimos.

**Requisitos**:
- Um livro pode ter múltiplos autores
- Um autor pode escrever múltiplos livros
- Um cliente pode fazer múltiplos empréstimos
- Um empréstimo é de um livro para um cliente em uma data específica
- Livros têm: ISBN, título, ano de publicação, editora
- Autores têm: nome, nacionalidade, data de nascimento
- Clientes têm: CPF, nome, endereço, telefone
- Empréstimos têm: data de empréstimo, data de devolução prevista, data de devolução real

**Tarefas**:
1. Desenhe o diagrama ER
2. Identifique as entidades, atributos e relacionamentos
3. Defina as cardinalidades
4. Identifique as chaves primárias e estrangeiras
5. Converta para o modelo relacional

**Solução Esperada**:
```sql
-- Sua solução aqui
-- Entidades identificadas:
-- LIVRO, AUTOR, CLIENTE, EMPRESTIMO
-- Relacionamentos:
-- LIVRO_AUTOR (N:M), EMPRESTIMO (1:N com LIVRO e CLIENTE)

CREATE TABLE AUTOR (
    id_autor INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nacionalidade VARCHAR(50),
    data_nascimento DATE
);

-- Continue com as outras tabelas...
```

### Exercício 2: Sistema de E-commerce

**Objetivo**: Modelar um sistema mais complexo com múltiplos relacionamentos.

**Cenário**: Uma loja online vende produtos organizados em categorias, com clientes fazendo pedidos.

**Requisitos**:
- Produtos pertencem a categorias (hierárquicas)
- Clientes fazem pedidos contendo múltiplos itens
- Cada item do pedido tem quantidade e preço específico
- Produtos têm variações (cor, tamanho)
- Sistema de avaliações de produtos
- Endereços de entrega múltiplos por cliente
- Histórico de preços dos produtos

**Tarefas**:
1. Identifique todas as entidades
2. Modele a hierarquia de categorias
3. Trate as variações de produtos
4. Modele o relacionamento pedido-produto
5. Implemente o histórico de preços

### Exercício 3: Sistema Hospitalar

**Objetivo**: Modelar um domínio complexo com múltiplas especializações.

**Cenário**: Um hospital precisa controlar pacientes, médicos, consultas, internações e tratamentos.

**Requisitos**:
- Médicos têm especialidades
- Pacientes podem ter múltiplas consultas
- Consultas podem gerar prescrições
- Internações têm quartos e leitos
- Tratamentos podem ser ambulatoriais ou de internação
- Funcionários (médicos, enfermeiros, administrativos)
- Equipamentos médicos e sua manutenção

---

## 🟡 Exercícios de Normalização

### Exercício 4: Normalização Passo a Passo

**Objetivo**: Aplicar as formas normais progressivamente.

**Tabela Inicial (0FN)**:
```
PEDIDOS
+--------+-------------+----------------+----------+----------+----------+----------+
| PedidoID | Cliente     | Produtos       | Qtd      | Precos   | Total    | Data     |
+--------+-------------+----------------+----------+----------+----------+----------+
| 001    | João Silva  | Notebook,Mouse | 1,2      | 2000,50  | 2100     | 15/03/23 |
| 002    | Maria Costa | Teclado        | 1        | 150      | 150      | 16/03/23 |
| 003    | João Silva  | Monitor,Mouse  | 1,1      | 800,50   | 850      | 17/03/23 |
+--------+-------------+----------------+----------+----------+----------+----------+
```

**Tarefas**:
1. **1FN**: Elimine grupos repetitivos
2. **2FN**: Elimine dependências parciais
3. **3FN**: Elimine dependências transitivas
4. **BCNF**: Verifique se há dependências funcionais problemáticas
5. Compare as vantagens e desvantagens de cada forma

**Solução 1FN**:
```sql
-- Sua solução aqui
CREATE TABLE PEDIDOS_1FN (
    PedidoID VARCHAR(10),
    Cliente VARCHAR(100),
    Produto VARCHAR(50),
    Quantidade INT,
    Preco DECIMAL(10,2),
    Data DATE
);

-- Continue normalizando...
```

### Exercício 5: Identificação de Dependências Funcionais

**Objetivo**: Identificar e documentar dependências funcionais.

**Tabela FUNCIONARIOS**:
```
+------+----------+-------------+--------+----------+----------+----------+
| CPF  | Nome     | Departamento| Projeto| Salario  | Gerente  | Orcamento|
+------+----------+-------------+--------+----------+----------+----------+
| 123  | Ana      | TI          | Alpha  | 5000     | Carlos   | 100000   |
| 456  | Bruno    | TI          | Beta   | 4500     | Carlos   | 80000    |
| 789  | Carlos   | TI          | Alpha  | 8000     | Carlos   | 100000   |
| 321  | Diana    | RH          | Gamma  | 4000     | Elena    | 50000    |
+------+----------+-------------+--------+----------+----------+----------+
```

**Tarefas**:
1. Identifique todas as dependências funcionais
2. Determine as chaves candidatas
3. Classifique as dependências (total, parcial, transitiva)
4. Normalize até BCNF
5. Justifique cada passo da normalização

### Exercício 6: Desnormalização Estratégica

**Objetivo**: Entender quando e como desnormalizar.

**Cenário**: Um sistema de relatórios precisa de consultas muito rápidas, mas as tabelas normalizadas estão causando lentidão.

**Tabelas Normalizadas**:
```sql
CREATE TABLE VENDAS (
    id_venda INT PRIMARY KEY,
    id_cliente INT,
    id_produto INT,
    quantidade INT,
    data_venda DATE,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id),
    FOREIGN KEY (id_produto) REFERENCES PRODUTOS(id)
);

CREATE TABLE CLIENTES (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(50),
    estado VARCHAR(2)
);

CREATE TABLE PRODUTOS (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10,2)
);
```

**Tarefas**:
1. Identifique consultas que seriam beneficiadas pela desnormalização
2. Crie uma tabela desnormalizada para relatórios
3. Implemente triggers para manter a consistência
4. Compare performance antes e depois
5. Documente os trade-offs

---

## 🔴 Exercícios de Modelagem Dimensional

### Exercício 7: Data Warehouse de Vendas

**Objetivo**: Criar um modelo dimensional completo.

**Cenário**: Uma rede de lojas precisa de um DW para análise de vendas.

**Requisitos**:
- Análise por tempo (dia, mês, trimestre, ano)
- Análise por produto (categoria, subcategoria, marca)
- Análise por loja (região, cidade, tipo de loja)
- Análise por cliente (faixa etária, gênero, segmento)
- Métricas: quantidade vendida, valor total, margem de lucro

**Tarefas**:
1. Identifique os fatos e dimensões
2. Desenhe o esquema estrela
3. Defina as hierarquias nas dimensões
4. Implemente SCDs (Slowly Changing Dimensions)
5. Crie agregações pré-calculadas

**Solução Esperada**:
```sql
-- Tabela Fato
CREATE TABLE FATO_VENDAS (
    id_tempo INT,
    id_produto INT,
    id_loja INT,
    id_cliente INT,
    quantidade_vendida INT,
    valor_total DECIMAL(12,2),
    custo_total DECIMAL(12,2),
    margem_lucro DECIMAL(12,2),
    FOREIGN KEY (id_tempo) REFERENCES DIM_TEMPO(id),
    FOREIGN KEY (id_produto) REFERENCES DIM_PRODUTO(id),
    FOREIGN KEY (id_loja) REFERENCES DIM_LOJA(id),
    FOREIGN KEY (id_cliente) REFERENCES DIM_CLIENTE(id)
);

-- Dimensão Tempo
CREATE TABLE DIM_TEMPO (
    id INT PRIMARY KEY,
    data_completa DATE,
    dia INT,
    mes INT,
    trimestre INT,
    ano INT,
    dia_semana VARCHAR(20),
    nome_mes VARCHAR(20),
    eh_feriado BOOLEAN,
    eh_fim_semana BOOLEAN
);

-- Continue com as outras dimensões...
```

### Exercício 8: SCD (Slowly Changing Dimensions)

**Objetivo**: Implementar diferentes tipos de SCD.

**Cenário**: A dimensão CLIENTE precisa rastrear mudanças ao longo do tempo.

**Tipos de Mudança**:
- **Tipo 1**: Sobrescrever (endereço)
- **Tipo 2**: Histórico completo (salário, estado civil)
- **Tipo 3**: Valor anterior (nome)

**Tarefas**:
1. Implemente SCD Tipo 1 para endereço
2. Implemente SCD Tipo 2 para salário
3. Implemente SCD Tipo 3 para nome
4. Crie procedures para atualização
5. Teste com dados de exemplo

**Estrutura SCD Tipo 2**:
```sql
CREATE TABLE DIM_CLIENTE_SCD2 (
    id_cliente_sk INT PRIMARY KEY, -- Surrogate Key
    id_cliente_nk INT,             -- Natural Key
    nome VARCHAR(100),
    salario DECIMAL(10,2),
    estado_civil VARCHAR(20),
    data_inicio DATE,
    data_fim DATE,
    versao_atual BOOLEAN
);

-- Procedure para atualização SCD Tipo 2
DELIMITER //
CREATE PROCEDURE AtualizarClienteSCD2(
    IN p_id_cliente INT,
    IN p_novo_salario DECIMAL(10,2),
    IN p_novo_estado_civil VARCHAR(20)
)
BEGIN
    -- Sua implementação aqui
END //
DELIMITER ;
```

### Exercício 9: Modelagem de Eventos

**Objetivo**: Modelar fatos sem medidas numéricas.

**Cenário**: Rastreamento de eventos em um site de e-commerce.

**Eventos**:
- Login/Logout de usuários
- Visualização de produtos
- Adição ao carrinho
- Início/Abandono de checkout
- Compras realizadas

**Tarefas**:
1. Modele uma tabela de fatos de eventos
2. Crie dimensões apropriadas
3. Implemente métricas derivadas
4. Crie consultas para análise de funil
5. Calcule taxas de conversão

---

## 🟣 Exercícios de NoSQL

### Exercício 10: Modelagem de Documentos (MongoDB)

**Objetivo**: Modelar dados para banco de documentos.

**Cenário**: Sistema de blog com posts, comentários e usuários.

**Requisitos**:
- Posts têm título, conteúdo, autor, tags, data
- Comentários pertencem a posts e podem ter respostas
- Usuários têm perfil, preferências, histórico
- Sistema de curtidas e compartilhamentos

**Tarefas**:
1. Decida entre embedding vs. referencing
2. Modele a estrutura de documentos
3. Implemente consultas comuns
4. Otimize para padrões de acesso
5. Trate a desnormalização

**Estrutura de Documento**:
```javascript
// Documento POST
{
  "_id": ObjectId("..."),
  "titulo": "Introdução ao NoSQL",
  "conteudo": "...",
  "autor": {
    "id": ObjectId("..."),
    "nome": "João Silva",
    "avatar": "url_avatar"
  },
  "tags": ["nosql", "mongodb", "database"],
  "data_criacao": ISODate("..."),
  "data_atualizacao": ISODate("..."),
  "estatisticas": {
    "visualizacoes": 150,
    "curtidas": 25,
    "compartilhamentos": 5
  },
  "comentarios": [
    {
      "id": ObjectId("..."),
      "autor": {
        "id": ObjectId("..."),
        "nome": "Maria Costa"
      },
      "texto": "Excelente post!",
      "data": ISODate("..."),
      "respostas": [
        {
          "autor": {
            "id": ObjectId("..."),
            "nome": "João Silva"
          },
          "texto": "Obrigado!",
          "data": ISODate("...")
        }
      ]
    }
  ]
}

// Suas consultas aqui
// 1. Buscar posts por tag
// 2. Listar comentários de um post
// 3. Contar curtidas por autor
// 4. Posts mais populares do mês
```

### Exercício 11: Modelagem de Grafos (Neo4j)

**Objetivo**: Modelar relacionamentos complexos em grafo.

**Cenário**: Rede social com usuários, posts, grupos e interações.

**Entidades e Relacionamentos**:
- USUARIO -[:SEGUE]-> USUARIO
- USUARIO -[:MEMBRO_DE]-> GRUPO
- USUARIO -[:CRIOU]-> POST
- USUARIO -[:CURTIU]-> POST
- USUARIO -[:COMENTOU]-> POST
- POST -[:PERTENCE_A]-> GRUPO

**Tarefas**:
1. Modele o grafo completo
2. Implemente consultas Cypher
3. Encontre influenciadores (PageRank)
4. Detecte comunidades
5. Recomende amigos e conteúdo

**Consultas Cypher**:
```cypher
// Criar nós e relacionamentos
CREATE (u1:Usuario {nome: "João", idade: 30})
CREATE (u2:Usuario {nome: "Maria", idade: 25})
CREATE (u1)-[:SEGUE]->(u2)

// Suas consultas aqui:
// 1. Amigos em comum
// 2. Caminho mais curto entre usuários
// 3. Posts mais curtidos por amigos
// 4. Sugestão de grupos
// 5. Análise de influência
```

### Exercício 12: Modelagem Colunar (Cassandra)

**Objetivo**: Modelar para alta performance em leitura.

**Cenário**: Sistema de IoT coletando dados de sensores.

**Requisitos**:
- Milhões de sensores enviando dados por minuto
- Consultas por sensor, por período, por tipo
- Agregações em tempo real
- Retenção de dados por período

**Tarefas**:
1. Defina a partition key e clustering columns
2. Modele para diferentes padrões de consulta
3. Implemente TTL para retenção
4. Otimize para compactação
5. Teste performance com dados simulados

**Estrutura CQL**:
```sql
-- Tabela para consultas por sensor e tempo
CREATE TABLE sensor_data_by_sensor (
    sensor_id UUID,
    timestamp TIMESTAMP,
    temperature DOUBLE,
    humidity DOUBLE,
    pressure DOUBLE,
    PRIMARY KEY (sensor_id, timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Tabela para consultas por localização
CREATE TABLE sensor_data_by_location (
    location TEXT,
    timestamp TIMESTAMP,
    sensor_id UUID,
    temperature DOUBLE,
    humidity DOUBLE,
    pressure DOUBLE,
    PRIMARY KEY (location, timestamp, sensor_id)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Suas consultas aqui
-- 1. Dados de um sensor nas últimas 24h
-- 2. Média de temperatura por localização
-- 3. Sensores com anomalias
-- 4. Agregações por hora/dia
```

---

## 🚀 Projetos Práticos

### Projeto 1: Sistema Bancário Completo

**Objetivo**: Modelar um sistema bancário real com todos os aspectos.

**Requisitos Funcionais**:
1. **Clientes e Contas**:
   - Pessoas físicas e jurídicas
   - Múltiplos tipos de conta (corrente, poupança, investimento)
   - Relacionamentos entre contas (conta conjunta)

2. **Transações**:
   - Transferências, depósitos, saques
   - Histórico completo de transações
   - Conciliação bancária
   - Estornos e cancelamentos

3. **Produtos Financeiros**:
   - Empréstimos e financiamentos
   - Cartões de crédito
   - Investimentos
   - Seguros

4. **Compliance e Auditoria**:
   - Rastreamento de todas as operações
   - Relatórios regulatórios
   - Detecção de fraudes
   - Controle de limites

**Entregáveis**:
1. Modelo ER completo
2. Modelo físico normalizado
3. Modelo dimensional para BI
4. Scripts de criação
5. Procedures para operações críticas
6. Plano de backup e recovery

### Projeto 2: Plataforma de Streaming

**Objetivo**: Modelar uma plataforma como Netflix/Spotify.

**Requisitos**:
1. **Catálogo de Conteúdo**:
   - Filmes, séries, episódios
   - Metadados ricos (gênero, elenco, diretor)
   - Múltiplas versões (qualidade, idioma, legendas)

2. **Usuários e Perfis**:
   - Contas familiares com múltiplos perfis
   - Preferências e histórico
   - Sistema de recomendação

3. **Reprodução e Analytics**:
   - Controle de reprodução (pause, resume)
   - Métricas de engajamento
   - Análise de abandono

4. **Monetização**:
   - Diferentes planos de assinatura
   - Publicidade direcionada
   - Compras dentro do app

**Desafios Técnicos**:
- Escala global (milhões de usuários)
- Baixa latência para recomendações
- Análise em tempo real
- Armazenamento de mídia

### Projeto 3: Marketplace Multi-tenant

**Objetivo**: Modelar um marketplace como Amazon/MercadoLivre.

**Requisitos**:
1. **Multi-tenancy**:
   - Múltiplos vendedores independentes
   - Isolamento de dados
   - Configurações personalizadas

2. **Catálogo Unificado**:
   - Produtos de múltiplos vendedores
   - Variações e combinações
   - Sistema de busca avançado

3. **Transações Complexas**:
   - Carrinho com produtos de múltiplos vendedores
   - Split de pagamentos
   - Logística integrada

4. **Avaliações e Reputação**:
   - Sistema de reviews
   - Reputação de vendedores
   - Detecção de reviews falsas

---

## 📊 Estudos de Caso

### Caso 1: Migração de Legacy para Microserviços

**Situação**: Uma empresa tem um sistema monolítico com banco de dados único e precisa migrar para microserviços.

**Desafios**:
- Identificar bounded contexts
- Quebrar o banco monolítico
- Manter consistência entre serviços
- Migração gradual sem downtime

**Tarefas**:
1. Analise o modelo atual
2. Identifique os domínios
3. Proponha a decomposição
4. Defina estratégia de migração
5. Implemente padrões como Saga, CQRS

### Caso 2: Otimização de Performance

**Situação**: Um e-commerce está com problemas de performance nas consultas de relatórios.

**Problemas Identificados**:
- Consultas complexas com múltiplos JOINs
- Falta de índices apropriados
- Tabelas muito grandes sem particionamento
- Consultas em tempo real no banco transacional

**Tarefas**:
1. Analise as consultas problemáticas
2. Proponha otimizações de índices
3. Implemente particionamento
4. Crie um data warehouse separado
5. Implemente cache estratégico

### Caso 3: Compliance LGPD/GDPR

**Situação**: Uma empresa precisa adequar seu modelo de dados para compliance com LGPD.

**Requisitos**:
- Direito ao esquecimento
- Portabilidade de dados
- Consentimento granular
- Auditoria de acesso
- Pseudonimização

**Tarefas**:
1. Identifique dados pessoais
2. Implemente controle de consentimento
3. Crie mecanismo de anonimização
4. Implemente auditoria
5. Crie processo de exportação/exclusão

---

## 📝 Critérios de Avaliação

### Para Modelagem ER:
- ✅ Identificação correta de entidades
- ✅ Relacionamentos e cardinalidades apropriados
- ✅ Atributos bem definidos
- ✅ Chaves primárias e estrangeiras corretas
- ✅ Normalização adequada

### Para Normalização:
- ✅ Identificação de dependências funcionais
- ✅ Aplicação correta das formas normais
- ✅ Justificativa para desnormalização
- ✅ Preservação da integridade dos dados
- ✅ Considerações de performance

### Para Modelagem Dimensional:
- ✅ Identificação correta de fatos e dimensões
- ✅ Granularidade apropriada
- ✅ Hierarquias bem definidas
- ✅ Tratamento adequado de SCDs
- ✅ Otimização para consultas analíticas

### Para NoSQL:
- ✅ Escolha adequada do tipo de banco
- ✅ Modelagem otimizada para padrões de acesso
- ✅ Considerações de consistência
- ✅ Estratégias de sharding/particionamento
- ✅ Performance e escalabilidade

---

## 🎯 Dicas para Sucesso

### Antes de Começar:
1. 📖 **Entenda o domínio** completamente
2. 🎯 **Identifique os casos de uso** principais
3. 📊 **Analise os padrões de acesso** aos dados
4. ⚡ **Considere requisitos não-funcionais** (performance, escala)

### Durante a Modelagem:
1. 🔄 **Itere e refine** o modelo
2. 🧪 **Valide com dados reais** quando possível
3. 📚 **Documente decisões** de design
4. 🤝 **Colabore com stakeholders**

### Após a Modelagem:
1. 🧪 **Teste com cenários reais**
2. 📈 **Monitore performance**
3. 🔄 **Refatore quando necessário**
4. 📖 **Mantenha documentação atualizada**

---

**🎉 Parabéns!** Você tem agora um conjunto abrangente de exercícios para dominar modelagem de dados e formas normais. Comece pelos exercícios básicos e vá progredindo para os mais complexos. A prática constante é a chave para o sucesso!