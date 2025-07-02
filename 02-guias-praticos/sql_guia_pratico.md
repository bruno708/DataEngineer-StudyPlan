# SQL - Guia Prático com Exemplos

## 1. Estrutura Básica e Sintaxe

### SELECT - Consulta Básica
```sql
-- Selecionar todas as colunas
SELECT * FROM usuarios;

-- Selecionar colunas específicas
SELECT nome, email, idade FROM usuarios;

-- Usar alias para colunas
SELECT 
    nome AS nome_completo,
    email AS endereco_email,
    idade AS anos
FROM usuarios;
```

### WHERE - Filtros
```sql
-- Filtros básicos
SELECT * FROM usuarios WHERE idade > 25;
SELECT * FROM usuarios WHERE nome = 'João';
SELECT * FROM usuarios WHERE email LIKE '%@gmail.com';

-- Múltiplas condições
SELECT * FROM usuarios 
WHERE idade BETWEEN 25 AND 35 
  AND cidade = 'São Paulo';

-- Operadores lógicos
SELECT * FROM usuarios 
WHERE (idade > 30 OR salario > 5000) 
  AND ativo = true;

-- IN e NOT IN
SELECT * FROM usuarios 
WHERE cidade IN ('São Paulo', 'Rio de Janeiro', 'Belo Horizonte');

SELECT * FROM usuarios 
WHERE departamento NOT IN ('TI', 'RH');
```

## 2. Ordenação e Limitação

### ORDER BY
```sql
-- Ordenação crescente
SELECT * FROM usuarios ORDER BY idade;
SELECT * FROM usuarios ORDER BY nome ASC;

-- Ordenação decrescente
SELECT * FROM usuarios ORDER BY salario DESC;

-- Múltiplas colunas
SELECT * FROM usuarios 
ORDER BY departamento ASC, salario DESC;
```

### LIMIT e OFFSET
```sql
-- Limitar resultados
SELECT * FROM usuarios LIMIT 10;

-- Paginação
SELECT * FROM usuarios 
ORDER BY id 
LIMIT 10 OFFSET 20;  -- Página 3 (20 registros pulados)

-- Top N
SELECT * FROM usuarios 
ORDER BY salario DESC 
LIMIT 5;  -- 5 maiores salários
```

## 3. Funções de Agregação

### Funções Básicas
```sql
-- Contagem
SELECT COUNT(*) FROM usuarios;
SELECT COUNT(DISTINCT departamento) FROM usuarios;

-- Soma, média, min, max
SELECT 
    SUM(salario) AS total_folha,
    AVG(salario) AS salario_medio,
    MIN(salario) AS menor_salario,
    MAX(salario) AS maior_salario
FROM usuarios;

-- Estatísticas por grupo
SELECT 
    departamento,
    COUNT(*) AS total_funcionarios,
    AVG(salario) AS salario_medio,
    MAX(idade) AS idade_maxima
FROM usuarios
GROUP BY departamento;
```

### GROUP BY e HAVING
```sql
-- Agrupamento básico
SELECT departamento, COUNT(*) as total
FROM usuarios
GROUP BY departamento;

-- Filtrar grupos com HAVING
SELECT departamento, AVG(salario) as salario_medio
FROM usuarios
GROUP BY departamento
HAVING AVG(salario) > 5000;

-- Múltiplas colunas no GROUP BY
SELECT 
    departamento, 
    cidade,
    COUNT(*) as total,
    AVG(idade) as idade_media
FROM usuarios
GROUP BY departamento, cidade
ORDER BY departamento, cidade;
```

## 4. JOINs - Relacionamentos

### Dados de Exemplo
```sql
-- Tabela usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT,
    salario DECIMAL(10,2)
);

-- Tabela departamentos
CREATE TABLE departamentos (
    id INT PRIMARY KEY,
    nome VARCHAR(50),
    orcamento DECIMAL(12,2)
);
```

### INNER JOIN
```sql
-- Buscar usuários com seus departamentos
SELECT 
    u.nome,
    u.salario,
    d.nome AS departamento
FROM usuarios u
INNER JOIN departamentos d ON u.departamento_id = d.id;

-- JOIN com múltiplas tabelas
SELECT 
    u.nome,
    d.nome AS departamento,
    p.titulo AS projeto
FROM usuarios u
INNER JOIN departamentos d ON u.departamento_id = d.id
INNER JOIN projetos p ON u.id = p.responsavel_id;
```

### LEFT JOIN
```sql
-- Todos os usuários, mesmo sem departamento
SELECT 
    u.nome,
    COALESCE(d.nome, 'Sem Departamento') AS departamento
FROM usuarios u
LEFT JOIN departamentos d ON u.departamento_id = d.id;
```

### RIGHT JOIN e FULL OUTER JOIN
```sql
-- Todos os departamentos, mesmo sem usuários
SELECT 
    d.nome AS departamento,
    COUNT(u.id) AS total_usuarios
FROM usuarios u
RIGHT JOIN departamentos d ON u.departamento_id = d.id
GROUP BY d.id, d.nome;

-- Todos os registros de ambas as tabelas
SELECT 
    u.nome,
    d.nome AS departamento
FROM usuarios u
FULL OUTER JOIN departamentos d ON u.departamento_id = d.id;
```

## 5. Subconsultas (Subqueries)

### Subconsulta no WHERE
```sql
-- Usuários com salário acima da média
SELECT nome, salario
FROM usuarios
WHERE salario > (SELECT AVG(salario) FROM usuarios);

-- Usuários do departamento com maior orçamento
SELECT nome, salario
FROM usuarios
WHERE departamento_id = (
    SELECT id FROM departamentos 
    ORDER BY orcamento DESC 
    LIMIT 1
);
```

### Subconsulta no SELECT
```sql
-- Comparar salário individual com média do departamento
SELECT 
    nome,
    salario,
    (SELECT AVG(salario) 
     FROM usuarios u2 
     WHERE u2.departamento_id = u1.departamento_id) AS media_dept
FROM usuarios u1;
```

### EXISTS e NOT EXISTS
```sql
-- Departamentos que têm usuários
SELECT nome
FROM departamentos d
WHERE EXISTS (
    SELECT 1 FROM usuarios u 
    WHERE u.departamento_id = d.id
);

-- Departamentos sem usuários
SELECT nome
FROM departamentos d
WHERE NOT EXISTS (
    SELECT 1 FROM usuarios u 
    WHERE u.departamento_id = d.id
);
```

## 6. Window Functions (Funções de Janela)

### ROW_NUMBER, RANK, DENSE_RANK
```sql
-- Ranking de salários
SELECT 
    nome,
    salario,
    ROW_NUMBER() OVER (ORDER BY salario DESC) as posicao,
    RANK() OVER (ORDER BY salario DESC) as rank_salario,
    DENSE_RANK() OVER (ORDER BY salario DESC) as dense_rank
FROM usuarios;

-- Ranking por departamento
SELECT 
    nome,
    departamento_id,
    salario,
    ROW_NUMBER() OVER (PARTITION BY departamento_id ORDER BY salario DESC) as rank_dept
FROM usuarios;
```

### LAG e LEAD
```sql
-- Comparar com salário anterior/posterior
SELECT 
    nome,
    salario,
    LAG(salario, 1) OVER (ORDER BY salario) as salario_anterior,
    LEAD(salario, 1) OVER (ORDER BY salario) as salario_posterior,
    salario - LAG(salario, 1) OVER (ORDER BY salario) as diferenca
FROM usuarios
ORDER BY salario;
```

### Agregações com Window Functions
```sql
-- Soma cumulativa
SELECT 
    nome,
    salario,
    SUM(salario) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) as soma_cumulativa,
    AVG(salario) OVER (ORDER BY id ROWS 2 PRECEDING) as media_movel_3
FROM usuarios
ORDER BY id;

-- Percentis
SELECT 
    nome,
    salario,
    PERCENT_RANK() OVER (ORDER BY salario) as percentil,
    NTILE(4) OVER (ORDER BY salario) as quartil
FROM usuarios;
```

## 7. Common Table Expressions (CTEs)

### CTE Básico
```sql
-- CTE simples
WITH usuarios_senior AS (
    SELECT * FROM usuarios WHERE idade > 40
)
SELECT 
    departamento_id,
    COUNT(*) as total_seniors,
    AVG(salario) as salario_medio
FROM usuarios_senior
GROUP BY departamento_id;
```

### CTE Recursivo
```sql
-- Hierarquia organizacional
WITH RECURSIVE hierarquia AS (
    -- Caso base: gerentes sem chefe
    SELECT id, nome, chefe_id, 1 as nivel
    FROM funcionarios
    WHERE chefe_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo: subordinados
    SELECT f.id, f.nome, f.chefe_id, h.nivel + 1
    FROM funcionarios f
    INNER JOIN hierarquia h ON f.chefe_id = h.id
)
SELECT * FROM hierarquia ORDER BY nivel, nome;
```

### Múltiplos CTEs
```sql
WITH 
vendas_mes AS (
    SELECT 
        EXTRACT(MONTH FROM data_venda) as mes,
        SUM(valor) as total_vendas
    FROM vendas
    WHERE EXTRACT(YEAR FROM data_venda) = 2023
    GROUP BY EXTRACT(MONTH FROM data_venda)
),
media_anual AS (
    SELECT AVG(total_vendas) as media FROM vendas_mes
)
SELECT 
    v.mes,
    v.total_vendas,
    m.media,
    CASE 
        WHEN v.total_vendas > m.media THEN 'Acima da Média'
        ELSE 'Abaixo da Média'
    END as performance
FROM vendas_mes v
CROSS JOIN media_anual m
ORDER BY v.mes;
```

## 8. Manipulação de Dados (DML)

### INSERT
```sql
-- Insert simples
INSERT INTO usuarios (nome, email, idade, departamento_id)
VALUES ('João Silva', 'joao@email.com', 30, 1);

-- Insert múltiplos registros
INSERT INTO usuarios (nome, email, idade, departamento_id) VALUES
    ('Maria Santos', 'maria@email.com', 28, 2),
    ('Pedro Costa', 'pedro@email.com', 35, 1),
    ('Ana Oliveira', 'ana@email.com', 32, 3);

-- Insert com SELECT
INSERT INTO usuarios_backup
SELECT * FROM usuarios WHERE ativo = false;
```

### UPDATE
```sql
-- Update simples
UPDATE usuarios 
SET salario = salario * 1.1 
WHERE departamento_id = 1;

-- Update com JOIN
UPDATE usuarios u
SET salario = u.salario * 1.05
FROM departamentos d
WHERE u.departamento_id = d.id 
  AND d.nome = 'Vendas';

-- Update condicional
UPDATE usuarios
SET categoria = CASE
    WHEN salario < 3000 THEN 'Junior'
    WHEN salario < 6000 THEN 'Pleno'
    ELSE 'Senior'
END;
```

### DELETE
```sql
-- Delete simples
DELETE FROM usuarios WHERE ativo = false;

-- Delete com subconsulta
DELETE FROM usuarios
WHERE departamento_id IN (
    SELECT id FROM departamentos WHERE orcamento = 0
);

-- Delete com JOIN
DELETE u FROM usuarios u
INNER JOIN departamentos d ON u.departamento_id = d.id
WHERE d.nome = 'Departamento Extinto';
```

## 9. Funções de String

```sql
-- Manipulação de texto
SELECT 
    nome,
    UPPER(nome) as nome_maiusculo,
    LOWER(email) as email_minusculo,
    LENGTH(nome) as tamanho_nome,
    SUBSTRING(nome, 1, 3) as iniciais,
    CONCAT(nome, ' - ', email) as nome_email
FROM usuarios;

-- Busca e substituição
SELECT 
    nome,
    REPLACE(email, '@gmail.com', '@empresa.com') as email_corporativo,
    TRIM(nome) as nome_limpo,
    LEFT(nome, 10) as nome_abreviado
FROM usuarios
WHERE email LIKE '%gmail%';
```

## 10. Funções de Data

```sql
-- Manipulação de datas
SELECT 
    nome,
    data_nascimento,
    EXTRACT(YEAR FROM data_nascimento) as ano_nascimento,
    DATE_PART('month', data_nascimento) as mes_nascimento,
    AGE(data_nascimento) as idade_exata,
    CURRENT_DATE - data_nascimento as dias_vividos
FROM usuarios;

-- Cálculos com datas
SELECT 
    nome,
    data_contratacao,
    data_contratacao + INTERVAL '90 days' as fim_experiencia,
    EXTRACT(YEAR FROM AGE(data_contratacao)) as anos_empresa
FROM usuarios
WHERE data_contratacao > CURRENT_DATE - INTERVAL '1 year';
```

## 11. CASE WHEN - Lógica Condicional

```sql
-- CASE simples
SELECT 
    nome,
    salario,
    CASE 
        WHEN salario < 3000 THEN 'Baixo'
        WHEN salario < 6000 THEN 'Médio'
        WHEN salario < 10000 THEN 'Alto'
        ELSE 'Muito Alto'
    END as faixa_salarial
FROM usuarios;

-- CASE com múltiplas condições
SELECT 
    nome,
    idade,
    departamento_id,
    CASE 
        WHEN idade < 25 AND departamento_id = 1 THEN 'Trainee TI'
        WHEN idade < 30 AND salario > 5000 THEN 'Jovem Talento'
        WHEN idade > 50 THEN 'Experiente'
        ELSE 'Padrão'
    END as categoria
FROM usuarios;
```

## 12. Índices e Performance

### Criação de Índices
```sql
-- Índice simples
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- Índice composto
CREATE INDEX idx_usuarios_dept_salario ON usuarios(departamento_id, salario);

-- Índice único
CREATE UNIQUE INDEX idx_usuarios_email_unique ON usuarios(email);

-- Índice parcial
CREATE INDEX idx_usuarios_ativos ON usuarios(departamento_id) 
WHERE ativo = true;
```

### Análise de Performance
```sql
-- Explicar plano de execução
EXPLAIN ANALYZE
SELECT u.nome, d.nome
FROM usuarios u
INNER JOIN departamentos d ON u.departamento_id = d.id
WHERE u.salario > 5000;

-- Estatísticas da tabela
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes
FROM pg_stat_user_tables
WHERE tablename = 'usuarios';
```

## 13. Transações

```sql
-- Transação básica
BEGIN;
    UPDATE usuarios SET salario = salario * 1.1 WHERE departamento_id = 1;
    INSERT INTO log_alteracoes (tabela, acao, data) 
    VALUES ('usuarios', 'aumento_salarial', CURRENT_TIMESTAMP);
COMMIT;

-- Transação com rollback
BEGIN;
    DELETE FROM usuarios WHERE id = 100;
    -- Se algo der errado:
    ROLLBACK;
    -- Ou se tudo estiver ok:
    -- COMMIT;

-- Savepoint
BEGIN;
    UPDATE usuarios SET salario = salario * 1.1;
    SAVEPOINT sp1;
    DELETE FROM usuarios WHERE ativo = false;
    -- Se quiser desfazer só o DELETE:
    ROLLBACK TO sp1;
COMMIT;
```

## 14. Exemplo Prático Completo

```sql
-- Relatório completo de análise de RH
WITH 
statisticas_dept AS (
    SELECT 
        d.nome as departamento,
        COUNT(u.id) as total_funcionarios,
        AVG(u.salario) as salario_medio,
        MIN(u.salario) as menor_salario,
        MAX(u.salario) as maior_salario,
        SUM(u.salario) as folha_total
    FROM departamentos d
    LEFT JOIN usuarios u ON d.id = u.departamento_id
    WHERE u.ativo = true
    GROUP BY d.id, d.nome
),
ranking_salarios AS (
    SELECT 
        u.nome,
        u.salario,
        d.nome as departamento,
        ROW_NUMBER() OVER (PARTITION BY d.nome ORDER BY u.salario DESC) as rank_dept,
        PERCENT_RANK() OVER (ORDER BY u.salario) as percentil_geral
    FROM usuarios u
    INNER JOIN departamentos d ON u.departamento_id = d.id
    WHERE u.ativo = true
)
SELECT 
    s.departamento,
    s.total_funcionarios,
    ROUND(s.salario_medio, 2) as salario_medio,
    s.menor_salario,
    s.maior_salario,
    s.folha_total,
    r.nome as funcionario_mais_bem_pago,
    r.salario as maior_salario_dept
FROM statisticas_dept s
LEFT JOIN ranking_salarios r ON s.departamento = r.departamento AND r.rank_dept = 1
ORDER BY s.folha_total DESC;
```

## Dicas de Boas Práticas

1. **Use índices apropriados** para colunas frequentemente filtradas
2. **Evite SELECT *** em produção, especifique colunas necessárias
3. **Use LIMIT** para evitar resultados muito grandes
4. **Prefira JOINs a subconsultas** quando possível
5. **Use EXPLAIN** para analisar performance de queries complexas
6. **Normalize dados** adequadamente para evitar redundância
7. **Use transações** para operações que modificam múltiplas tabelas
8. **Documente queries complexas** com comentários
9. **Teste queries** com dados pequenos antes de executar em produção
10. **Use CTEs** para melhorar legibilidade de queries complexas

---

*Este guia cobre as principais operações SQL com exemplos práticos. Para aprofundamento, pratique com datasets reais e consulte a documentação específica do seu SGBD.*