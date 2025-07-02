# SQL - Conceitos Fundamentais e Teoria

## 1. Fundamentos de Bancos de Dados

### Modelo Relacional

**Conceitos Básicos**
- **Relação (Tabela)**: Conjunto de tuplas com mesmo esquema
- **Tupla (Linha)**: Registro individual com valores para cada atributo
- **Atributo (Coluna)**: Propriedade ou característica dos dados
- **Domínio**: Conjunto de valores válidos para um atributo
- **Esquema**: Estrutura da relação (nome + atributos + tipos)

**Propriedades das Relações**
```
1. Ordem das tuplas é irrelevante
2. Ordem dos atributos é irrelevante
3. Cada tupla é única (sem duplicatas)
4. Valores atômicos (não divisíveis)
5. Valores nulos permitidos (quando apropriado)
```

### Chaves e Integridade

**Tipos de Chaves**
- **Superchave**: Conjunto de atributos que identifica unicamente cada tupla
- **Chave Candidata**: Superchave minimal (sem atributos redundantes)
- **Chave Primária**: Chave candidata escolhida como identificador principal
- **Chave Estrangeira**: Atributo que referencia chave primária de outra relação
- **Chave Alternativa**: Chaves candidatas não escolhidas como primária

**Restrições de Integridade**
```sql
-- Integridade de Entidade
CREATE TABLE usuarios (
    id INT PRIMARY KEY,  -- Não pode ser NULL
    nome VARCHAR(100) NOT NULL
);

-- Integridade Referencial
CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Integridade de Domínio
CREATE TABLE produtos (
    id INT PRIMARY KEY,
    preco DECIMAL(10,2) CHECK (preco > 0),
    categoria VARCHAR(50) CHECK (categoria IN ('A', 'B', 'C'))
);
```

## 2. Álgebra Relacional

### Operações Fundamentais

**Seleção (σ - Sigma)**
```sql
-- σ(condição)(Relação)
-- Equivale a WHERE em SQL
SELECT * FROM usuarios WHERE idade > 25;
```

**Projeção (π - Pi)**
```sql
-- π(atributos)(Relação)
-- Equivale a SELECT específico em SQL
SELECT nome, email FROM usuarios;
```

**União (∪)**
```sql
-- R ∪ S (relações compatíveis)
SELECT nome FROM clientes
UNION
SELECT nome FROM fornecedores;
```

**Interseção (∩)**
```sql
-- R ∩ S
SELECT nome FROM clientes
INTERSECT
SELECT nome FROM fornecedores;
```

**Diferença (-)**
```sql
-- R - S
SELECT nome FROM clientes
EXCEPT
SELECT nome FROM fornecedores;
```

**Produto Cartesiano (×)**
```sql
-- R × S
SELECT * FROM usuarios, departamentos;
-- Gera todas as combinações possíveis
```

### Operações Derivadas

**Junção (⋈)**
```sql
-- Junção Natural
SELECT * FROM usuarios NATURAL JOIN departamentos;

-- Theta-Junção
SELECT * FROM usuarios u, departamentos d 
WHERE u.dept_id = d.id;

-- Equi-Junção
SELECT * FROM usuarios u 
INNER JOIN departamentos d ON u.dept_id = d.id;
```

**Divisão (÷)**
```sql
-- Operação complexa, exemplo: 
-- "Usuários que participaram de TODOS os projetos"
SELECT u.id FROM usuarios u
WHERE NOT EXISTS (
    SELECT p.id FROM projetos p
    WHERE NOT EXISTS (
        SELECT 1 FROM participacoes part
        WHERE part.usuario_id = u.id AND part.projeto_id = p.id
    )
);
```

## 3. Normalização

### Dependências Funcionais

**Conceito**
- X → Y: "X determina funcionalmente Y"
- Se duas tuplas têm mesmo valor para X, devem ter mesmo valor para Y
- Exemplo: CPF → Nome (CPF determina o nome)

**Tipos de Dependências**
```
Trivial: X → Y onde Y ⊆ X
Não-trivial: X → Y onde Y ⊄ X
Completa: X → Y onde nenhum subconjunto próprio de X determina Y
Parcial: X → Y onde existe subconjunto próprio de X que determina Y
Transitiva: X → Y e Y → Z, então X → Z
```

### Formas Normais

**Primeira Forma Normal (1FN)**
- Todos os atributos são atômicos
- Não há grupos repetitivos
- Cada célula contém um único valor

```sql
-- ❌ Não está em 1FN
CREATE TABLE usuarios_ruim (
    id INT,
    nome VARCHAR(100),
    telefones VARCHAR(500)  -- "11999999999,1188888888"
);

-- ✅ Em 1FN
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE telefones (
    id INT PRIMARY KEY,
    usuario_id INT,
    numero VARCHAR(15),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
```

**Segunda Forma Normal (2FN)**
- Está em 1FN
- Não há dependências parciais (atributos não-chave dependem de toda a chave)

```sql
-- ❌ Não está em 2FN
CREATE TABLE pedido_item_ruim (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    produto_nome VARCHAR(100),  -- Depende só de produto_id
    produto_preco DECIMAL(10,2), -- Depende só de produto_id
    PRIMARY KEY (pedido_id, produto_id)
);

-- ✅ Em 2FN
CREATE TABLE produtos (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    preco DECIMAL(10,2)
);

CREATE TABLE pedido_itens (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);
```

**Terceira Forma Normal (3FN)**
- Está em 2FN
- Não há dependências transitivas

```sql
-- ❌ Não está em 3FN
CREATE TABLE funcionarios_ruim (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT,
    departamento_nome VARCHAR(100),  -- Transitiva: id → dept_id → dept_nome
    departamento_orcamento DECIMAL(12,2)
);

-- ✅ Em 3FN
CREATE TABLE departamentos (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    orcamento DECIMAL(12,2)
);

CREATE TABLE funcionarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);
```

**Forma Normal de Boyce-Codd (BCNF)**
- Está em 3FN
- Para toda dependência X → Y, X é superchave

**Quarta Forma Normal (4FN)**
- Está em BCNF
- Não há dependências multivaloradas

**Quinta Forma Normal (5FN)**
- Está em 4FN
- Não há dependências de junção

### Desnormalização

**Quando Desnormalizar**
- Performance crítica em consultas
- Dados históricos (snapshots)
- Data warehousing
- Relatórios frequentes

```sql
-- Exemplo: Tabela desnormalizada para relatórios
CREATE TABLE vendas_resumo (
    data_venda DATE,
    produto_nome VARCHAR(100),
    categoria VARCHAR(50),
    vendedor_nome VARCHAR(100),
    departamento VARCHAR(50),
    quantidade INT,
    valor_total DECIMAL(10,2)
);
```

## 4. Arquitetura de SGBD

### Níveis de Abstração

**Nível Físico**
- Como dados são armazenados fisicamente
- Estruturas de índices
- Organização de arquivos
- Buffers e cache

**Nível Lógico/Conceitual**
- Esquema global do banco
- Relacionamentos entre entidades
- Restrições de integridade
- Independente da implementação física

**Nível de Visão/Externo**
- Views específicas para usuários
- Subconjuntos dos dados
- Segurança e privacidade

```sql
-- Exemplo de separação de níveis
-- Nível Físico: índices, particionamento
CREATE INDEX idx_vendas_data ON vendas(data_venda);

-- Nível Lógico: estrutura das tabelas
CREATE TABLE vendas (
    id INT PRIMARY KEY,
    produto_id INT,
    data_venda DATE,
    valor DECIMAL(10,2)
);

-- Nível de Visão: views para usuários
CREATE VIEW vendas_mes_atual AS
SELECT produto_id, SUM(valor) as total
FROM vendas
WHERE data_venda >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY produto_id;
```

### Componentes do SGBD

**Gerenciador de Transações**
- Controle de concorrência
- Recuperação de falhas
- Propriedades ACID

**Gerenciador de Armazenamento**
- Gerenciamento de buffers
- Organização de arquivos
- Controle de acesso a disco

**Processador de Consultas**
- Parser SQL
- Otimizador de consultas
- Executor de planos

## 5. Processamento de Consultas

### Fases do Processamento

**1. Análise Sintática (Parsing)**
```sql
-- SQL é convertido em árvore sintática
SELECT u.nome, d.nome
FROM usuarios u
JOIN departamentos d ON u.dept_id = d.id
WHERE u.salario > 5000;
```

**2. Análise Semântica**
- Verificação de existência de tabelas/colunas
- Verificação de tipos
- Resolução de ambiguidades

**3. Otimização**
- Transformações algébricas
- Escolha de algoritmos
- Estimativa de custos

**4. Execução**
- Geração de código
- Execução do plano
- Retorno dos resultados

### Otimização de Consultas

**Transformações Algébricas**
```sql
-- Pushdown de seleção
-- ❌ Ineficiente
SELECT * FROM (
    SELECT * FROM usuarios u
    JOIN departamentos d ON u.dept_id = d.id
) WHERE salario > 5000;

-- ✅ Otimizado (filtro aplicado antes do JOIN)
SELECT u.*, d.*
FROM (SELECT * FROM usuarios WHERE salario > 5000) u
JOIN departamentos d ON u.dept_id = d.id;
```

**Estimativa de Custos**
```
Custo = Custo_CPU + Custo_IO

Fatores considerados:
- Cardinalidade das relações
- Seletividade dos predicados
- Disponibilidade de índices
- Estatísticas das tabelas
```

**Algoritmos de Junção**
```
Nested Loop Join: O(n × m)
- Bom para tabelas pequenas
- Eficiente com índices

Sort-Merge Join: O(n log n + m log m)
- Bom para tabelas grandes já ordenadas
- Requer ordenação prévia

Hash Join: O(n + m)
- Melhor para tabelas grandes
- Requer memória suficiente
```

## 6. Índices e Estruturas de Dados

### Tipos de Índices

**Índice Primário**
- Baseado na chave primária
- Dados fisicamente ordenados
- Um por tabela

**Índice Secundário**
- Baseado em atributos não-chave
- Múltiplos por tabela
- Ponteiros para registros

**Índice Denso vs Esparso**
```
Denso: Uma entrada para cada registro
Esparso: Uma entrada para cada bloco/página
```

### Estruturas de Dados

**B+ Tree**
- Estrutura mais comum para índices
- Balanceada automaticamente
- Folhas contêm todos os dados
- Busca: O(log n)

```
Características:
- Nós internos: apenas chaves de navegação
- Folhas: chaves + dados (ou ponteiros)
- Folhas ligadas sequencialmente
- Altura baixa (3-4 níveis para milhões de registros)
```

**Hash**
- Acesso direto O(1)
- Bom para buscas por igualdade
- Não suporta range queries
- Problemas com colisões

**Bitmap**
- Eficiente para baixa cardinalidade
- Operações booleanas rápidas
- Compressão eficiente
- Usado em data warehouses

### Estratégias de Indexação

```sql
-- Índice composto - ordem importa
CREATE INDEX idx_usuario_dept_salario ON usuarios(departamento_id, salario);

-- Eficiente para:
SELECT * FROM usuarios WHERE departamento_id = 1 AND salario > 5000;
SELECT * FROM usuarios WHERE departamento_id = 1;

-- Ineficiente para:
SELECT * FROM usuarios WHERE salario > 5000;  -- Não usa o índice

-- Índice de cobertura
CREATE INDEX idx_covering ON usuarios(departamento_id) INCLUDE (nome, salario);
-- Consulta pode ser respondida apenas com o índice
```

## 7. Transações e Controle de Concorrência

### Propriedades ACID

**Atomicidade**
- Transação é indivisível
- Tudo ou nada
- Rollback em caso de falha

**Consistência**
- Banco permanece em estado válido
- Restrições de integridade mantidas
- Invariantes preservadas

**Isolamento**
- Transações não interferem entre si
- Execução concorrente = execução serial
- Níveis de isolamento

**Durabilidade**
- Mudanças persistem após commit
- Sobrevivem a falhas do sistema
- Write-ahead logging

### Níveis de Isolamento

**Read Uncommitted**
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Permite: Dirty Read, Non-repeatable Read, Phantom Read
-- Mais rápido, menos seguro
```

**Read Committed**
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Permite: Non-repeatable Read, Phantom Read
-- Padrão na maioria dos SGBDs
```

**Repeatable Read**
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Permite: Phantom Read
-- Leituras consistentes durante a transação
```

**Serializable**
```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Mais restritivo, equivale à execução serial
-- Pode causar mais deadlocks
```

### Problemas de Concorrência

**Dirty Read**
```sql
-- T1 modifica mas não commitou
-- T2 lê o valor modificado
-- T1 faz rollback
-- T2 leu dados "sujos"
```

**Non-repeatable Read**
```sql
-- T1 lê um valor
-- T2 modifica e commita
-- T1 lê novamente e obtém valor diferente
```

**Phantom Read**
```sql
-- T1 executa query com WHERE
-- T2 insere registros que satisfazem o WHERE
-- T1 executa a mesma query e vê registros "fantasma"
```

### Controle de Concorrência

**Two-Phase Locking (2PL)**
```
Fase 1 (Growing): Apenas adquire locks
Fase 2 (Shrinking): Apenas libera locks

Tipos de Lock:
- Shared (S): Para leitura
- Exclusive (X): Para escrita
```

**Timestamp Ordering**
```
Cada transação recebe timestamp único
Operações executadas em ordem de timestamp
Detecção de conflitos por comparação de timestamps
```

**Multiversion Concurrency Control (MVCC)**
```
Múltiplas versões dos dados
Leitores não bloqueiam escritores
Escritores não bloqueiam leitores
Usado por PostgreSQL, Oracle, SQL Server
```

## 8. Recuperação e Backup

### Tipos de Falhas

**Falhas de Transação**
- Erro lógico na aplicação
- Deadlock detectado
- Violação de restrições

**Falhas de Sistema**
- Queda de energia
- Falha de hardware
- Erro no SO

**Falhas de Mídia**
- Falha de disco
- Corrupção de dados
- Desastres naturais

### Técnicas de Recuperação

**Write-Ahead Logging (WAL)**
```
1. Log escrito antes dos dados
2. Log contém UNDO e REDO information
3. Checkpoint periódicos
4. Recovery usa log para restaurar estado
```

**Shadow Paging**
```
1. Páginas modificadas copiadas
2. Ponteiros atualizados atomicamente
3. Páginas antigas mantidas até commit
4. Rollback = restaurar ponteiros antigos
```

### Estratégias de Backup

**Backup Completo**
```sql
-- Copia todo o banco de dados
pg_dump -h localhost -U user -d database > backup_completo.sql
```

**Backup Incremental**
```sql
-- Apenas mudanças desde último backup
-- Requer WAL archiving
SELECT pg_start_backup('backup_incremental');
-- Copiar arquivos WAL
SELECT pg_stop_backup();
```

**Backup Diferencial**
```sql
-- Mudanças desde último backup completo
-- Meio termo entre completo e incremental
```

## 9. Segurança em Bancos de Dados

### Controle de Acesso

**Autenticação**
```sql
-- Criação de usuários
CREATE USER analista WITH PASSWORD 'senha_forte';
CREATE ROLE desenvolvedor;

-- Autenticação por certificado, LDAP, etc.
```

**Autorização**
```sql
-- Privilégios em tabelas
GRANT SELECT, INSERT ON usuarios TO analista;
GRANT ALL PRIVILEGES ON vendas TO desenvolvedor;

-- Privilégios em colunas
GRANT SELECT (nome, email) ON usuarios TO suporte;

-- Revogação
REVOKE INSERT ON usuarios FROM analista;
```

**Roles e Hierarquias**
```sql
-- Criação de roles
CREATE ROLE gerente;
CREATE ROLE funcionario;

-- Hierarquia
GRANT funcionario TO gerente;
GRANT gerente TO usuario_admin;

-- Atribuição
GRANT funcionario TO joao;
```

### Segurança de Dados

**Criptografia**
```sql
-- Criptografia de coluna
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    cpf BYTEA  -- Armazenado criptografado
);

-- Inserção com criptografia
INSERT INTO usuarios (nome, cpf) 
VALUES ('João', pgp_sym_encrypt('12345678901', 'chave_secreta'));

-- Consulta com descriptografia
SELECT nome, pgp_sym_decrypt(cpf, 'chave_secreta') as cpf_decrypted
FROM usuarios;
```

**Auditoria**
```sql
-- Tabela de auditoria
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    tabela VARCHAR(50),
    operacao VARCHAR(10),
    usuario VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB
);

-- Trigger de auditoria
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (tabela, operacao, usuario, dados_antigos, dados_novos)
    VALUES (TG_TABLE_NAME, TG_OP, current_user, 
            row_to_json(OLD), row_to_json(NEW));
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

## 10. Data Warehousing e OLAP

### Conceitos Fundamentais

**OLTP vs OLAP**
```
OLTP (Online Transaction Processing):
- Transações frequentes e curtas
- Dados normalizados
- Foco em integridade e consistência
- Queries simples

OLAP (Online Analytical Processing):
- Consultas complexas e longas
- Dados desnormalizados
- Foco em performance de leitura
- Análises multidimensionais
```

**Esquemas Dimensionais**

**Star Schema**
```sql
-- Tabela Fato (centro)
CREATE TABLE fato_vendas (
    data_key INT,
    produto_key INT,
    cliente_key INT,
    vendedor_key INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (data_key) REFERENCES dim_data(data_key),
    FOREIGN KEY (produto_key) REFERENCES dim_produto(produto_key)
);

-- Tabelas Dimensão (pontas da estrela)
CREATE TABLE dim_produto (
    produto_key INT PRIMARY KEY,
    nome VARCHAR(100),
    categoria VARCHAR(50),
    subcategoria VARCHAR(50)
);
```

**Snowflake Schema**
```sql
-- Dimensões normalizadas
CREATE TABLE dim_produto (
    produto_key INT PRIMARY KEY,
    nome VARCHAR(100),
    categoria_key INT,
    FOREIGN KEY (categoria_key) REFERENCES dim_categoria(categoria_key)
);

CREATE TABLE dim_categoria (
    categoria_key INT PRIMARY KEY,
    nome VARCHAR(50),
    departamento_key INT
);
```

### Slowly Changing Dimensions (SCD)

**Tipo 1: Sobrescrever**
```sql
-- Atualiza diretamente, perde histórico
UPDATE dim_cliente 
SET endereco = 'Novo Endereço' 
WHERE cliente_key = 123;
```

**Tipo 2: Versioning**
```sql
-- Mantém histórico com versões
CREATE TABLE dim_cliente (
    cliente_key INT PRIMARY KEY,
    cliente_id INT,  -- ID natural
    nome VARCHAR(100),
    endereco VARCHAR(200),
    data_inicio DATE,
    data_fim DATE,
    versao_atual BOOLEAN
);

-- Inserir nova versão
INSERT INTO dim_cliente (cliente_id, nome, endereco, data_inicio, versao_atual)
VALUES (123, 'João', 'Novo Endereço', CURRENT_DATE, true);

-- Marcar versão anterior como inativa
UPDATE dim_cliente 
SET data_fim = CURRENT_DATE, versao_atual = false
WHERE cliente_id = 123 AND versao_atual = true;
```

**Tipo 3: Atributos Adicionais**
```sql
-- Mantém valor atual e anterior
CREATE TABLE dim_cliente (
    cliente_key INT PRIMARY KEY,
    nome VARCHAR(100),
    endereco_atual VARCHAR(200),
    endereco_anterior VARCHAR(200),
    data_mudanca_endereco DATE
);
```

## 11. Performance e Tuning

### Identificação de Problemas

**Análise de Queries Lentas**
```sql
-- PostgreSQL: log de queries lentas
SET log_min_duration_statement = 1000;  -- Log queries > 1s

-- Análise de plano de execução
EXPLAIN (ANALYZE, BUFFERS) 
SELECT u.nome, COUNT(*) 
FROM usuarios u 
JOIN pedidos p ON u.id = p.usuario_id 
GROUP BY u.nome;
```

**Estatísticas do Sistema**
```sql
-- Tabelas mais acessadas
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
ORDER BY seq_tup_read DESC;

-- Índices não utilizados
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

### Técnicas de Otimização

**Reescrita de Queries**
```sql
-- ❌ Subconsulta correlacionada
SELECT u.nome
FROM usuarios u
WHERE u.salario > (
    SELECT AVG(salario) 
    FROM usuarios u2 
    WHERE u2.departamento_id = u.departamento_id
);

-- ✅ Window function
SELECT nome
FROM (
    SELECT 
        nome,
        salario,
        AVG(salario) OVER (PARTITION BY departamento_id) as avg_dept
    FROM usuarios
) t
WHERE salario > avg_dept;
```

**Particionamento**
```sql
-- Particionamento por range
CREATE TABLE vendas (
    id INT,
    data_venda DATE,
    valor DECIMAL(10,2)
) PARTITION BY RANGE (data_venda);

CREATE TABLE vendas_2023 PARTITION OF vendas
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE vendas_2024 PARTITION OF vendas
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

**Materialização**
```sql
-- View materializada para consultas complexas
CREATE MATERIALIZED VIEW vendas_resumo AS
SELECT 
    DATE_TRUNC('month', data_venda) as mes,
    produto_id,
    SUM(quantidade) as total_quantidade,
    SUM(valor) as total_valor
FROM vendas
GROUP BY DATE_TRUNC('month', data_venda), produto_id;

-- Refresh periódico
REFRESH MATERIALIZED VIEW vendas_resumo;
```

## 12. Tendências e Tecnologias Emergentes

### NewSQL
- Combina ACID com escalabilidade horizontal
- Exemplos: CockroachDB, TiDB, VoltDB
- Mantém interface SQL familiar

### Bancos Distribuídos
- Sharding automático
- Replicação multi-master
- Consistência eventual vs forte

### Cloud-Native Databases
- Separação compute/storage
- Auto-scaling
- Serverless databases

### AI/ML Integration
- Automatic query optimization
- Predictive indexing
- Anomaly detection

---

*Este guia cobre os conceitos fundamentais de SQL e bancos de dados relacionais. Para aprofundamento, estude implementações específicas de SGBDs e pratique com casos reais.*