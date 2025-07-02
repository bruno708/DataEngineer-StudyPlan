# Exercícios SQL - Níveis Básico, Intermediário e Avançado

## Preparação do Ambiente

Antes de começar os exercícios, execute o script de criação das tabelas:

```sql
-- Execute o arquivo criar_tabelas.sql
-- Ou copie e execute o conteúdo do arquivo dados/criar_tabelas.sql
```

**Comando para verificar se as tabelas foram criadas:**
```sql
-- Verificar tabelas criadas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Verificar dados carregados
SELECT 'funcionarios' as tabela, COUNT(*) as registros FROM funcionarios
UNION ALL
SELECT 'vendas', COUNT(*) FROM vendas
UNION ALL
SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL
SELECT 'produtos', COUNT(*) FROM produtos;
```

---

## EXERCÍCIOS BÁSICOS

### Exercício Básico 1: Consultas Simples e Filtros

**Comando para verificar os dados:**
```sql
-- Visualizar estrutura das tabelas
DESC funcionarios;
SELECT * FROM funcionarios LIMIT 5;

DESC vendas;
SELECT * FROM vendas LIMIT 5;
```

**Tarefas:**
1. Liste todos os funcionários ordenados por nome
2. Encontre todos os funcionários do departamento de "Vendas"
3. Mostre funcionários com salário maior que R$ 4.000
4. Liste os 3 funcionários mais bem pagos
5. Conte quantos funcionários existem por departamento
6. Encontre a idade média dos funcionários
7. Liste funcionários contratados em 2023
8. Mostre o maior e menor salário da empresa
9. Encontre funcionários cujo nome contém "Silva"
10. Liste departamentos únicos da empresa

---

### Exercício Básico 2: Agregações e Agrupamentos

**Comando para verificar os dados:**
```sql
-- Visualizar dados de vendas
SELECT * FROM vendas LIMIT 10;
SELECT DISTINCT categoria FROM vendas;
SELECT DISTINCT regiao FROM vendas;
```

**Tarefas:**
1. Calcule o total de vendas (preço × quantidade) por categoria
2. Encontre a venda com maior valor unitário
3. Calcule a média de preços por categoria
4. Conte quantas vendas foram feitas por região
5. Encontre o total de produtos vendidos (soma das quantidades)
6. Liste as vendas do mês de janeiro de 2024
7. Calcule o valor médio das vendas por vendedor
8. Encontre a categoria com maior faturamento total
9. Mostre vendas agrupadas por mês
10. Identifique a região com menor número de vendas

---

## EXERCÍCIOS INTERMEDIÁRIOS

### Exercício Intermediário 1: JOINs e Subconsultas

**Comando para verificar relacionamentos:**
```sql
-- Verificar chaves estrangeiras
SELECT v.id, v.produto, v.vendedor_id, f.nome as vendedor
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
LIMIT 5;
```

**Tarefas:**
1. Liste todas as vendas com o nome do vendedor responsável
2. Encontre o total vendido por cada funcionário (nome e valor)
3. Mostre vendedores que não fizeram nenhuma venda
4. Liste funcionários com suas respectivas vendas (incluindo quem não vendeu)
5. Encontre o vendedor com maior faturamento total
6. Calcule a comissão de 5% sobre vendas para cada vendedor
7. Liste vendas com valor acima da média geral
8. Encontre funcionários que venderam produtos da categoria "Eletrônicos"
9. Mostre o ranking dos top 5 vendedores por valor total
10. Identifique vendedores que venderam em mais de uma região

---

### Exercício Intermediário 2: Window Functions e Análises Temporais

**Comando para preparar dados temporais:**
```sql
-- Verificar distribuição temporal das vendas
SELECT 
    DATE_TRUNC('month', data_venda) as mes,
    COUNT(*) as total_vendas,
    SUM(preco * quantidade) as faturamento
FROM vendas 
GROUP BY DATE_TRUNC('month', data_venda)
ORDER BY mes;
```

**Tarefas:**
1. Calcule o ranking de vendedores por faturamento usando RANK()
2. Mostre vendas com numeração sequencial por vendedor (ROW_NUMBER)
3. Calcule a diferença entre cada venda e a anterior do mesmo vendedor (LAG)
4. Encontre a próxima venda de cada vendedor (LEAD)
5. Calcule vendas acumuladas por vendedor ao longo do tempo
6. Mostre a média móvel de 3 vendas por vendedor
7. Identifique a primeira e última venda de cada vendedor
8. Calcule o percentual de cada venda no total do vendedor
9. Encontre vendas que estão no top 25% por valor (NTILE)
10. Compare cada venda com a média do vendedor na mesma categoria

---

## EXERCÍCIOS AVANÇADOS

### Exercício Avançado 1: Análise Complexa de Performance

**Comando para preparar análise avançada:**
```sql
-- Criar view consolidada para análises
CREATE OR REPLACE VIEW vw_vendas_completa AS
SELECT 
    v.*,
    f.nome as vendedor_nome,
    f.cargo,
    f.departamento,
    f.salario,
    (v.preco * v.quantidade) as valor_total,
    EXTRACT(MONTH FROM v.data_venda) as mes,
    EXTRACT(YEAR FROM v.data_venda) as ano,
    EXTRACT(DOW FROM v.data_venda) as dia_semana
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id;

SELECT * FROM vw_vendas_completa LIMIT 5;
```

**Tarefas:**
1. **Análise de Crescimento:**
   - Calcule o crescimento mês a mês das vendas
   - Identifique vendedores com crescimento consistente
   - Compare performance atual vs período anterior

2. **Segmentação de Vendedores:**
   - Classifique vendedores em quartis por performance
   - Identifique vendedores "estrela" (alto volume + alta margem)
   - Crie score composto de performance

3. **Análise de Sazonalidade:**
   - Identifique padrões por dia da semana
   - Analise variação de vendas por mês
   - Encontre produtos com maior sazonalidade

4. **Detecção de Anomalias:**
   - Identifique vendas outliers (muito acima/abaixo da média)
   - Encontre vendedores com performance inconsistente
   - Detecte mudanças bruscas no padrão de vendas

5. **Análise de Correlação:**
   - Correlacione salário do vendedor com performance
   - Analise relação entre experiência (tempo na empresa) e vendas
   - Identifique fatores que influenciam vendas

6. **KPIs Avançados:**
   - Calcule lifetime value por vendedor
   - Implemente balanced scorecard de vendas
   - Crie dashboard executivo com métricas principais

---

### Exercício Avançado 2: Data Warehousing e Analytics

**Comando para criar estrutura dimensional:**
```sql
-- Criar tabelas dimensionais
CREATE TABLE dim_tempo AS
SELECT DISTINCT
    data_venda as data,
    EXTRACT(YEAR FROM data_venda) as ano,
    EXTRACT(MONTH FROM data_venda) as mes,
    EXTRACT(DAY FROM data_venda) as dia,
    EXTRACT(DOW FROM data_venda) as dia_semana,
    EXTRACT(QUARTER FROM data_venda) as trimestre,
    CASE EXTRACT(DOW FROM data_venda)
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda'
        WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta'
        WHEN 4 THEN 'Quinta'
        WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END as nome_dia_semana
FROM vendas;

SELECT * FROM dim_tempo LIMIT 5;
```

**Tarefas:**
1. **Modelagem Dimensional:**
   - Crie tabela fato de vendas
   - Implemente dimensões: tempo, produto, vendedor, geografia
   - Estabeleça relacionamentos entre fato e dimensões

2. **ETL Avançado:**
   - Implemente processo de carga incremental
   - Crie procedures para atualização automática
   - Implemente validação de qualidade de dados

3. **OLAP Operations:**
   - Implemente operações de drill-down e roll-up
   - Crie cubos de dados multidimensionais
   - Implemente slice and dice nas vendas

4. **Análise de Cohort:**
   - Analise retenção de vendedores ao longo do tempo
   - Implemente análise de cohort por período de contratação
   - Calcule métricas de engajamento

5. **Machine Learning em SQL:**
   - Implemente regressão linear simples para predição
   - Crie algoritmo de clustering usando SQL
   - Implemente sistema de recomendação

6. **Otimização Avançada:**
   - Crie índices compostos otimizados
   - Implemente particionamento de tabelas
   - Otimize queries complexas
   - Monitore performance e planos de execução

7. **Relatórios Executivos:**
   - Crie dashboard de vendas em tempo real
   - Implemente alertas automáticos
   - Gere relatórios de exceção

8. **Auditoria e Compliance:**
   - Implemente log de auditoria
   - Crie controles de acesso granular
   - Monitore alterações nos dados

---

## Queries de Apoio e Utilitários

```sql
-- Verificar performance das queries
EXPLAIN ANALYZE SELECT * FROM vw_vendas_completa;

-- Estatísticas das tabelas
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE tablename IN ('vendas', 'funcionarios', 'produtos', 'clientes');

-- Limpeza e manutenção
VACUUM ANALYZE vendas;
VACUUM ANALYZE funcionarios;

-- Backup de resultados
CREATE TABLE backup_resultados AS
SELECT * FROM vw_vendas_completa;
```

## Dicas Importantes

1. **Performance**: Use EXPLAIN ANALYZE para otimizar queries
2. **Índices**: Crie índices em colunas frequentemente filtradas
3. **Window Functions**: Poderosas para análises analíticas
4. **CTEs**: Use para queries complexas e legibilidade
5. **Particionamento**: Considere para tabelas grandes
6. **Estatísticas**: Mantenha estatísticas atualizadas
7. **Backup**: Sempre faça backup antes de modificações
8. **Documentação**: Documente queries complexas
9. **Segurança**: Use princípio do menor privilégio
10. **Monitoramento**: Monitore performance continuamente