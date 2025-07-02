# Gabarito - Exercícios SQL

## Preparação do Ambiente

```sql
-- Verificar se as tabelas foram criadas corretamente
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('funcionarios', 'vendas', 'clientes', 'produtos')
ORDER BY table_name, ordinal_position;

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

## GABARITO - EXERCÍCIOS BÁSICOS

### Exercício Básico 1: Consultas Simples e Filtros

```sql
-- 1. Listar funcionários ordenados por nome
SELECT * FROM funcionarios 
ORDER BY nome;

-- 2. Funcionários do departamento de Vendas
SELECT * FROM funcionarios 
WHERE departamento = 'Vendas';

-- 3. Funcionários com salário > R$ 4.000
SELECT nome, cargo, salario 
FROM funcionarios 
WHERE salario > 4000
ORDER BY salario DESC;

-- 4. Top 3 funcionários mais bem pagos
SELECT nome, cargo, salario 
FROM funcionarios 
ORDER BY salario DESC 
LIMIT 3;

-- 5. Contar funcionários por departamento
SELECT departamento, COUNT(*) as total_funcionarios
FROM funcionarios 
GROUP BY departamento
ORDER BY total_funcionarios DESC;

-- 6. Idade média dos funcionários
SELECT ROUND(AVG(idade), 1) as idade_media
FROM funcionarios;

-- 7. Funcionários contratados em 2023
SELECT nome, cargo, data_contratacao
FROM funcionarios 
WHERE EXTRACT(YEAR FROM data_contratacao) = 2023
ORDER BY data_contratacao;

-- 8. Maior e menor salário
SELECT 
    MAX(salario) as maior_salario,
    MIN(salario) as menor_salario,
    MAX(salario) - MIN(salario) as diferenca
FROM funcionarios;

-- 9. Funcionários com "Silva" no nome
SELECT nome, cargo, departamento
FROM funcionarios 
WHERE nome ILIKE '%Silva%';

-- 10. Departamentos únicos
SELECT DISTINCT departamento
FROM funcionarios 
ORDER BY departamento;
```

### Exercício Básico 2: Agregações e Agrupamentos

```sql
-- 1. Total de vendas por categoria
SELECT 
    categoria,
    SUM(preco * quantidade) as total_vendas,
    COUNT(*) as num_vendas
FROM vendas 
GROUP BY categoria
ORDER BY total_vendas DESC;

-- 2. Venda com maior valor unitário
SELECT produto, preco, quantidade, (preco * quantidade) as valor_total
FROM vendas 
ORDER BY preco DESC 
LIMIT 1;

-- 3. Média de preços por categoria
SELECT 
    categoria,
    ROUND(AVG(preco), 2) as preco_medio,
    COUNT(*) as total_produtos
FROM vendas 
GROUP BY categoria
ORDER BY preco_medio DESC;

-- 4. Vendas por região
SELECT 
    regiao,
    COUNT(*) as total_vendas,
    SUM(preco * quantidade) as faturamento_total
FROM vendas 
GROUP BY regiao
ORDER BY faturamento_total DESC;

-- 5. Total de produtos vendidos (quantidade)
SELECT SUM(quantidade) as total_produtos_vendidos
FROM vendas;

-- 6. Vendas de janeiro de 2024
SELECT *
FROM vendas 
WHERE data_venda >= '2024-01-01' 
  AND data_venda < '2024-02-01'
ORDER BY data_venda;

-- 7. Valor médio das vendas por vendedor
SELECT 
    vendedor_id,
    COUNT(*) as num_vendas,
    ROUND(AVG(preco * quantidade), 2) as valor_medio
FROM vendas 
GROUP BY vendedor_id
ORDER BY valor_medio DESC;

-- 8. Categoria com maior faturamento
SELECT 
    categoria,
    SUM(preco * quantidade) as faturamento_total
FROM vendas 
GROUP BY categoria
ORDER BY faturamento_total DESC
LIMIT 1;

-- 9. Vendas agrupadas por mês
SELECT 
    EXTRACT(YEAR FROM data_venda) as ano,
    EXTRACT(MONTH FROM data_venda) as mes,
    COUNT(*) as total_vendas,
    SUM(preco * quantidade) as faturamento
FROM vendas 
GROUP BY EXTRACT(YEAR FROM data_venda), EXTRACT(MONTH FROM data_venda)
ORDER BY ano, mes;

-- 10. Região com menor número de vendas
SELECT 
    regiao,
    COUNT(*) as total_vendas
FROM vendas 
GROUP BY regiao
ORDER BY total_vendas ASC
LIMIT 1;
```

---

## GABARITO - EXERCÍCIOS INTERMEDIÁRIOS

### Exercício Intermediário 1: JOINs e Subconsultas

```sql
-- 1. Vendas com nome do vendedor
SELECT 
    v.id,
    v.produto,
    v.categoria,
    v.preco,
    v.quantidade,
    v.data_venda,
    f.nome as vendedor_nome,
    f.cargo
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.data_venda DESC;

-- 2. Total vendido por funcionário
SELECT 
    f.nome,
    f.cargo,
    COUNT(v.id) as num_vendas,
    SUM(v.preco * v.quantidade) as total_vendido
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome, f.cargo
ORDER BY total_vendido DESC;

-- 3. Vendedores que não fizeram vendas
SELECT f.nome, f.cargo, f.departamento
FROM funcionarios f
LEFT JOIN vendas v ON f.id = v.vendedor_id
WHERE v.vendedor_id IS NULL;

-- 4. Funcionários com suas vendas (incluindo quem não vendeu)
SELECT 
    f.nome,
    f.cargo,
    COALESCE(COUNT(v.id), 0) as num_vendas,
    COALESCE(SUM(v.preco * v.quantidade), 0) as total_vendido
FROM funcionarios f
LEFT JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome, f.cargo
ORDER BY total_vendido DESC;

-- 5. Vendedor com maior faturamento
SELECT 
    f.nome,
    SUM(v.preco * v.quantidade) as total_vendido
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome
ORDER BY total_vendido DESC
LIMIT 1;

-- 6. Comissão de 5% sobre vendas
SELECT 
    f.nome,
    f.salario,
    SUM(v.preco * v.quantidade) as total_vendido,
    ROUND(SUM(v.preco * v.quantidade) * 0.05, 2) as comissao
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome, f.salario
ORDER BY comissao DESC;

-- 7. Vendas acima da média geral
WITH media_vendas AS (
    SELECT AVG(preco * quantidade) as media
    FROM vendas
)
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
CROSS JOIN media_vendas m
WHERE (v.preco * v.quantidade) > m.media
ORDER BY valor_venda DESC;

-- 8. Funcionários que venderam eletrônicos
SELECT DISTINCT f.nome, f.cargo
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
WHERE v.categoria = 'Eletrônicos'
ORDER BY f.nome;

-- 9. Ranking top 5 vendedores
SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(v.preco * v.quantidade) DESC) as ranking,
    f.nome,
    SUM(v.preco * v.quantidade) as total_vendido
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome
ORDER BY total_vendido DESC
LIMIT 5;

-- 10. Vendedores que venderam em múltiplas regiões
SELECT 
    f.nome,
    COUNT(DISTINCT v.regiao) as num_regioes,
    STRING_AGG(DISTINCT v.regiao, ', ') as regioes
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome
HAVING COUNT(DISTINCT v.regiao) > 1
ORDER BY num_regioes DESC;
```

### Exercício Intermediário 2: Window Functions e Análises Temporais

```sql
-- 1. Ranking de vendedores por faturamento
SELECT 
    f.nome,
    SUM(v.preco * v.quantidade) as total_vendido,
    RANK() OVER (ORDER BY SUM(v.preco * v.quantidade) DESC) as ranking,
    DENSE_RANK() OVER (ORDER BY SUM(v.preco * v.quantidade) DESC) as dense_ranking
FROM funcionarios f
JOIN vendas v ON f.id = v.vendedor_id
GROUP BY f.id, f.nome
ORDER BY ranking;

-- 2. Numeração sequencial por vendedor
SELECT 
    v.*,
    f.nome as vendedor_nome,
    ROW_NUMBER() OVER (PARTITION BY v.vendedor_id ORDER BY v.data_venda) as seq_vendedor
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 3. Diferença entre venda atual e anterior (LAG)
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_atual,
    LAG(v.preco * v.quantidade) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda
    ) as valor_anterior,
    (v.preco * v.quantidade) - LAG(v.preco * v.quantidade) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda
    ) as diferenca
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 4. Próxima venda de cada vendedor (LEAD)
SELECT 
    v.*,
    f.nome as vendedor_nome,
    LEAD(v.produto) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda
    ) as proximo_produto,
    LEAD(v.data_venda) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda
    ) as proxima_data
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 5. Vendas acumuladas por vendedor
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda,
    SUM(v.preco * v.quantidade) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda 
        ROWS UNBOUNDED PRECEDING
    ) as vendas_acumuladas
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 6. Média móvel de 3 vendas por vendedor
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda,
    ROUND(AVG(v.preco * v.quantidade) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda 
        ROWS 2 PRECEDING
    ), 2) as media_movel_3
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 7. Primeira e última venda de cada vendedor
SELECT 
    v.*,
    f.nome as vendedor_nome,
    FIRST_VALUE(v.produto) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda 
        ROWS UNBOUNDED PRECEDING
    ) as primeiro_produto,
    LAST_VALUE(v.produto) OVER (
        PARTITION BY v.vendedor_id 
        ORDER BY v.data_venda 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as ultimo_produto
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.data_venda;

-- 8. Percentual de cada venda no total do vendedor
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda,
    ROUND(
        (v.preco * v.quantidade) * 100.0 / 
        SUM(v.preco * v.quantidade) OVER (PARTITION BY v.vendedor_id),
        2
    ) as percentual_vendedor
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, percentual_vendedor DESC;

-- 9. Top 25% das vendas por valor (NTILE)
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda,
    NTILE(4) OVER (ORDER BY v.preco * v.quantidade DESC) as quartil
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY valor_venda DESC;

-- 10. Comparar venda com média do vendedor na categoria
SELECT 
    v.*,
    f.nome as vendedor_nome,
    (v.preco * v.quantidade) as valor_venda,
    ROUND(AVG(v.preco * v.quantidade) OVER (
        PARTITION BY v.vendedor_id, v.categoria
    ), 2) as media_vendedor_categoria,
    ROUND(
        (v.preco * v.quantidade) - 
        AVG(v.preco * v.quantidade) OVER (
            PARTITION BY v.vendedor_id, v.categoria
        ), 2
    ) as diferenca_media
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id
ORDER BY v.vendedor_id, v.categoria, v.data_venda;
```

---

## GABARITO - EXERCÍCIOS AVANÇADOS

### Exercício Avançado 1: Análise Complexa de Performance

```sql
-- Criar view consolidada
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
    EXTRACT(DOW FROM v.data_venda) as dia_semana,
    f.data_contratacao,
    EXTRACT(DAYS FROM (CURRENT_DATE - f.data_contratacao)) as dias_empresa
FROM vendas v
JOIN funcionarios f ON v.vendedor_id = f.id;

-- 1. Análise de Crescimento

-- Crescimento mês a mês das vendas
WITH vendas_mensais AS (
    SELECT 
        ano,
        mes,
        SUM(valor_total) as total_mes
    FROM vw_vendas_completa
    GROUP BY ano, mes
    ORDER BY ano, mes
),
crescimento_mensal AS (
    SELECT 
        *,
        LAG(total_mes) OVER (ORDER BY ano, mes) as mes_anterior,
        ROUND(
            ((total_mes - LAG(total_mes) OVER (ORDER BY ano, mes)) / 
             LAG(total_mes) OVER (ORDER BY ano, mes)) * 100, 2
        ) as crescimento_pct
    FROM vendas_mensais
)
SELECT * FROM crescimento_mensal;

-- Vendedores com crescimento consistente
WITH vendedor_mensal AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        ano,
        mes,
        SUM(valor_total) as total_mes
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome, ano, mes
),
crescimento_vendedor AS (
    SELECT 
        *,
        LAG(total_mes) OVER (PARTITION BY vendedor_id ORDER BY ano, mes) as mes_anterior,
        CASE 
            WHEN LAG(total_mes) OVER (PARTITION BY vendedor_id ORDER BY ano, mes) > 0
            THEN ((total_mes - LAG(total_mes) OVER (PARTITION BY vendedor_id ORDER BY ano, mes)) / 
                  LAG(total_mes) OVER (PARTITION BY vendedor_id ORDER BY ano, mes)) * 100
            ELSE NULL
        END as crescimento_pct
    FROM vendedor_mensal
)
SELECT 
    vendedor_nome,
    COUNT(CASE WHEN crescimento_pct > 0 THEN 1 END) as meses_crescimento,
    COUNT(crescimento_pct) as total_meses_comparacao,
    ROUND(AVG(crescimento_pct), 2) as crescimento_medio
FROM crescimento_vendedor
WHERE crescimento_pct IS NOT NULL
GROUP BY vendedor_id, vendedor_nome
HAVING COUNT(crescimento_pct) > 0
ORDER BY crescimento_medio DESC;

-- 2. Segmentação de Vendedores

-- Classificar vendedores em quartis
WITH performance_vendedor AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        SUM(valor_total) as total_vendido,
        COUNT(*) as num_vendas,
        AVG(valor_total) as ticket_medio,
        STDDEV(valor_total) as desvio_padrao
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome
)
SELECT 
    *,
    NTILE(4) OVER (ORDER BY total_vendido) as quartil_volume,
    NTILE(4) OVER (ORDER BY ticket_medio) as quartil_ticket,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_vendido) = 4 
         AND NTILE(4) OVER (ORDER BY ticket_medio) >= 3
        THEN 'Estrela'
        WHEN NTILE(4) OVER (ORDER BY total_vendido) = 4
        THEN 'Alto Volume'
        WHEN NTILE(4) OVER (ORDER BY ticket_medio) = 4
        THEN 'Alto Ticket'
        ELSE 'Padrão'
    END as classificacao
FROM performance_vendedor
ORDER BY total_vendido DESC;

-- Score composto de performance
WITH metricas_vendedor AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        SUM(valor_total) as volume_total,
        COUNT(*) as frequencia_vendas,
        AVG(valor_total) as ticket_medio,
        COUNT(DISTINCT categoria) as diversidade_categoria,
        STDDEV(valor_total) as variabilidade
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome
),
scores_normalizados AS (
    SELECT 
        *,
        -- Normalizar métricas (0-100)
        (volume_total - MIN(volume_total) OVER()) * 100.0 / 
        (MAX(volume_total) OVER() - MIN(volume_total) OVER()) as score_volume,
        
        (frequencia_vendas - MIN(frequencia_vendas) OVER()) * 100.0 / 
        (MAX(frequencia_vendas) OVER() - MIN(frequencia_vendas) OVER()) as score_frequencia,
        
        (ticket_medio - MIN(ticket_medio) OVER()) * 100.0 / 
        (MAX(ticket_medio) OVER() - MIN(ticket_medio) OVER()) as score_ticket,
        
        (diversidade_categoria - MIN(diversidade_categoria) OVER()) * 100.0 / 
        (MAX(diversidade_categoria) OVER() - MIN(diversidade_categoria) OVER()) as score_diversidade,
        
        -- Consistência (menor variabilidade = melhor score)
        (MAX(variabilidade) OVER() - variabilidade) * 100.0 / 
        (MAX(variabilidade) OVER() - MIN(variabilidade) OVER()) as score_consistencia
    FROM metricas_vendedor
)
SELECT 
    vendedor_nome,
    volume_total,
    frequencia_vendas,
    ROUND(ticket_medio, 2) as ticket_medio,
    diversidade_categoria,
    ROUND(score_volume, 1) as score_volume,
    ROUND(score_frequencia, 1) as score_frequencia,
    ROUND(score_ticket, 1) as score_ticket,
    ROUND(score_diversidade, 1) as score_diversidade,
    ROUND(score_consistencia, 1) as score_consistencia,
    ROUND(
        score_volume * 0.3 + 
        score_frequencia * 0.2 + 
        score_ticket * 0.2 + 
        score_diversidade * 0.15 + 
        score_consistencia * 0.15, 1
    ) as score_final
FROM scores_normalizados
ORDER BY score_final DESC;

-- 3. Análise de Sazonalidade

-- Padrões por dia da semana
SELECT 
    dia_semana,
    CASE dia_semana
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda'
        WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta'
        WHEN 4 THEN 'Quinta'
        WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END as nome_dia,
    COUNT(*) as num_vendas,
    SUM(valor_total) as total_vendas,
    ROUND(AVG(valor_total), 2) as ticket_medio
FROM vw_vendas_completa
GROUP BY dia_semana
ORDER BY total_vendas DESC;

-- Variação de vendas por mês
WITH vendas_mes AS (
    SELECT 
        mes,
        SUM(valor_total) as total_mes,
        COUNT(*) as num_vendas
    FROM vw_vendas_completa
    GROUP BY mes
)
SELECT 
    mes,
    total_mes,
    num_vendas,
    ROUND(total_mes / num_vendas, 2) as ticket_medio_mes,
    ROUND(
        (total_mes - AVG(total_mes) OVER()) * 100.0 / AVG(total_mes) OVER(), 2
    ) as variacao_media_pct
FROM vendas_mes
ORDER BY mes;

-- Produtos com maior sazonalidade
WITH produto_mes AS (
    SELECT 
        produto,
        mes,
        SUM(valor_total) as total_produto_mes
    FROM vw_vendas_completa
    GROUP BY produto, mes
),
sazonalidade_produto AS (
    SELECT 
        produto,
        STDDEV(total_produto_mes) as desvio_mensal,
        AVG(total_produto_mes) as media_mensal,
        STDDEV(total_produto_mes) / AVG(total_produto_mes) as coef_variacao
    FROM produto_mes
    GROUP BY produto
    HAVING COUNT(*) > 1  -- Apenas produtos vendidos em múltiplos meses
)
SELECT 
    produto,
    ROUND(media_mensal, 2) as media_mensal,
    ROUND(desvio_mensal, 2) as desvio_mensal,
    ROUND(coef_variacao, 3) as coef_variacao
FROM sazonalidade_produto
ORDER BY coef_variacao DESC;

-- 4. Detecção de Anomalias

-- Vendas outliers
WITH estatisticas AS (
    SELECT 
        AVG(valor_total) as media,
        STDDEV(valor_total) as desvio_padrao,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY valor_total) as q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY valor_total) as q3
    FROM vw_vendas_completa
),
limites AS (
    SELECT 
        *,
        q3 - q1 as iqr,
        q1 - 1.5 * (q3 - q1) as limite_inferior,
        q3 + 1.5 * (q3 - q1) as limite_superior,
        media - 2 * desvio_padrao as limite_inf_2sigma,
        media + 2 * desvio_padrao as limite_sup_2sigma
    FROM estatisticas
)
SELECT 
    v.*,
    'IQR Outlier' as tipo_outlier
FROM vw_vendas_completa v
CROSS JOIN limites l
WHERE v.valor_total < l.limite_inferior OR v.valor_total > l.limite_superior

UNION ALL

SELECT 
    v.*,
    '2-Sigma Outlier' as tipo_outlier
FROM vw_vendas_completa v
CROSS JOIN limites l
WHERE v.valor_total < l.limite_inf_2sigma OR v.valor_total > l.limite_sup_2sigma

ORDER BY valor_total DESC;

-- Vendedores com performance inconsistente
WITH performance_vendedor AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        STDDEV(valor_total) as desvio_vendas,
        AVG(valor_total) as media_vendas,
        COUNT(*) as num_vendas
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome
    HAVING COUNT(*) >= 3  -- Mínimo 3 vendas para análise
)
SELECT 
    vendedor_nome,
    num_vendas,
    ROUND(media_vendas, 2) as media_vendas,
    ROUND(desvio_vendas, 2) as desvio_vendas,
    ROUND(desvio_vendas / media_vendas, 3) as coef_variacao,
    CASE 
        WHEN desvio_vendas / media_vendas > 1.0 THEN 'Muito Inconsistente'
        WHEN desvio_vendas / media_vendas > 0.5 THEN 'Inconsistente'
        WHEN desvio_vendas / media_vendas > 0.3 THEN 'Moderadamente Consistente'
        ELSE 'Consistente'
    END as classificacao_consistencia
FROM performance_vendedor
ORDER BY coef_variacao DESC;

-- 5. Análise de Correlação

-- Correlação salário vs performance
WITH vendedor_performance AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        salario,
        SUM(valor_total) as total_vendido,
        COUNT(*) as num_vendas,
        AVG(valor_total) as ticket_medio
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome, salario
)
SELECT 
    vendedor_nome,
    salario,
    total_vendido,
    num_vendas,
    ROUND(ticket_medio, 2) as ticket_medio,
    ROUND(total_vendido / salario, 2) as roi_vendedor
FROM vendedor_performance
ORDER BY roi_vendedor DESC;

-- Experiência vs vendas
WITH experiencia_performance AS (
    SELECT 
        vendedor_id,
        vendedor_nome,
        dias_empresa,
        CASE 
            WHEN dias_empresa < 365 THEN 'Novato (< 1 ano)'
            WHEN dias_empresa < 730 THEN 'Experiente (1-2 anos)'
            ELSE 'Veterano (> 2 anos)'
        END as faixa_experiencia,
        SUM(valor_total) as total_vendido,
        COUNT(*) as num_vendas
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome, dias_empresa
)
SELECT 
    faixa_experiencia,
    COUNT(*) as num_vendedores,
    ROUND(AVG(total_vendido), 2) as media_vendas,
    ROUND(AVG(num_vendas), 1) as media_num_vendas,
    ROUND(AVG(total_vendido / num_vendas), 2) as ticket_medio
FROM experiencia_performance
GROUP BY faixa_experiencia
ORDER BY 
    CASE faixa_experiencia
        WHEN 'Novato (< 1 ano)' THEN 1
        WHEN 'Experiente (1-2 anos)' THEN 2
        WHEN 'Veterano (> 2 anos)' THEN 3
    END;

-- 6. KPIs Avançados

-- Dashboard executivo
WITH kpis_gerais AS (
    SELECT 
        COUNT(DISTINCT vendedor_id) as num_vendedores_ativos,
        COUNT(*) as total_vendas,
        SUM(valor_total) as faturamento_total,
        AVG(valor_total) as ticket_medio_geral,
        COUNT(DISTINCT produto) as produtos_vendidos,
        COUNT(DISTINCT regiao) as regioes_ativas
    FROM vw_vendas_completa
),
top_performers AS (
    SELECT 
        vendedor_nome,
        SUM(valor_total) as total_vendido
    FROM vw_vendas_completa
    GROUP BY vendedor_id, vendedor_nome
    ORDER BY total_vendido DESC
    LIMIT 3
),
categorias_top AS (
    SELECT 
        categoria,
        SUM(valor_total) as total_categoria
    FROM vw_vendas_completa
    GROUP BY categoria
    ORDER BY total_categoria DESC
    LIMIT 3
)
SELECT 
    'KPIs Gerais' as secao,
    CONCAT('Vendedores Ativos: ', num_vendedores_ativos) as metrica
FROM kpis_gerais
UNION ALL
SELECT 
    'KPIs Gerais',
    CONCAT('Total de Vendas: ', total_vendas)
FROM kpis_gerais
UNION ALL
SELECT 
    'KPIs Gerais',
    CONCAT('Faturamento: R$ ', ROUND(faturamento_total, 2))
FROM kpis_gerais
UNION ALL
SELECT 
    'KPIs Gerais',
    CONCAT('Ticket Médio: R$ ', ROUND(ticket_medio_geral, 2))
FROM kpis_gerais
UNION ALL
SELECT 
    'Top Performers',
    CONCAT(vendedor_nome, ': R$ ', ROUND(total_vendido, 2))
FROM top_performers
UNION ALL
SELECT 
    'Top Categorias',
    CONCAT(categoria, ': R$ ', ROUND(total_categoria, 2))
FROM categorias_top;
```

### Exercício Avançado 2: Data Warehousing e Analytics

```sql
-- 1. Modelagem Dimensional

-- Criar dimensão tempo
CREATE TABLE IF NOT EXISTS dim_tempo AS
WITH RECURSIVE datas AS (
    SELECT DATE '2024-01-01' as data
    UNION ALL
    SELECT data + INTERVAL '1 day'
    FROM datas
    WHERE data < DATE '2024-12-31'
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY data) as tempo_id,
    data,
    EXTRACT(YEAR FROM data) as ano,
    EXTRACT(MONTH FROM data) as mes,
    EXTRACT(DAY FROM data) as dia,
    EXTRACT(DOW FROM data) as dia_semana,
    EXTRACT(QUARTER FROM data) as trimestre,
    EXTRACT(WEEK FROM data) as semana,
    CASE EXTRACT(DOW FROM data)
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda'
        WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta'
        WHEN 4 THEN 'Quinta'
        WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END as nome_dia_semana,
    CASE EXTRACT(MONTH FROM data)
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END as nome_mes,
    CASE 
        WHEN EXTRACT(DOW FROM data) IN (0, 6) THEN 'Fim de Semana'
        ELSE 'Dia Útil'
    END as tipo_dia
FROM datas;

-- Criar dimensão vendedor
CREATE TABLE IF NOT EXISTS dim_vendedor AS
SELECT 
    id as vendedor_id,
    nome,
    cargo,
    departamento,
    salario,
    data_contratacao,
    idade,
    email,
    CASE 
        WHEN salario < 4000 THEN 'Júnior'
        WHEN salario < 6000 THEN 'Pleno'
        ELSE 'Sênior'
    END as nivel_salarial,
    CASE 
        WHEN idade < 30 THEN 'Jovem'
        WHEN idade < 40 THEN 'Adulto'
        ELSE 'Experiente'
    END as faixa_etaria
FROM funcionarios;

-- Criar dimensão produto
CREATE TABLE IF NOT EXISTS dim_produto AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY produto) as produto_id,
    produto as nome_produto,
    categoria,
    CASE categoria
        WHEN 'Eletrônicos' THEN 'Tecnologia'
        WHEN 'Móveis' THEN 'Casa e Decoração'
        ELSE 'Outros'
    END as grupo_categoria
FROM vendas;

-- Criar dimensão geografia
CREATE TABLE IF NOT EXISTS dim_geografia AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY regiao) as geografia_id,
    regiao,
    CASE regiao
        WHEN 'Sul' THEN 'Região Sul'
        WHEN 'Norte' THEN 'Região Norte'
        WHEN 'Sudeste' THEN 'Região Sudeste'
        WHEN 'Nordeste' THEN 'Região Nordeste'
        WHEN 'Centro-Oeste' THEN 'Região Centro-Oeste'
    END as regiao_completa,
    CASE regiao
        WHEN 'Sul' THEN 'S'
        WHEN 'Norte' THEN 'N'
        WHEN 'Sudeste' THEN 'SE'
        WHEN 'Nordeste' THEN 'NE'
        WHEN 'Centro-Oeste' THEN 'CO'
    END as sigla_regiao
FROM vendas;

-- Criar tabela fato de vendas
CREATE TABLE IF NOT EXISTS fato_vendas AS
SELECT 
    v.id as venda_id,
    dt.tempo_id,
    dv.vendedor_id,
    dp.produto_id,
    dg.geografia_id,
    v.preco,
    v.quantidade,
    (v.preco * v.quantidade) as valor_total,
    v.preco as preco_unitario
FROM vendas v
JOIN dim_tempo dt ON v.data_venda = dt.data
JOIN dim_vendedor dv ON v.vendedor_id = dv.vendedor_id
JOIN dim_produto dp ON v.produto = dp.nome_produto
JOIN dim_geografia dg ON v.regiao = dg.regiao;

-- 2. ETL Avançado

-- Procedure para carga incremental
CREATE OR REPLACE FUNCTION proc_carga_incremental()
RETURNS void AS $$
DECLARE
    ultima_carga timestamp;
    registros_processados integer;
BEGIN
    -- Obter timestamp da última carga
    SELECT COALESCE(MAX(data_processamento), '1900-01-01'::timestamp) 
    INTO ultima_carga
    FROM log_carga;
    
    -- Inserir novos registros
    INSERT INTO fato_vendas (
        venda_id, tempo_id, vendedor_id, produto_id, geografia_id,
        preco, quantidade, valor_total, preco_unitario
    )
    SELECT 
        v.id,
        dt.tempo_id,
        dv.vendedor_id,
        dp.produto_id,
        dg.geografia_id,
        v.preco,
        v.quantidade,
        (v.preco * v.quantidade),
        v.preco
    FROM vendas v
    JOIN dim_tempo dt ON v.data_venda = dt.data
    JOIN dim_vendedor dv ON v.vendedor_id = dv.vendedor_id
    JOIN dim_produto dp ON v.produto = dp.nome_produto
    JOIN dim_geografia dg ON v.regiao = dg.regiao
    WHERE v.data_venda > ultima_carga
    AND NOT EXISTS (
        SELECT 1 FROM fato_vendas fv WHERE fv.venda_id = v.id
    );
    
    GET DIAGNOSTICS registros_processados = ROW_COUNT;
    
    -- Log da carga
    INSERT INTO log_carga (data_processamento, registros_processados)
    VALUES (CURRENT_TIMESTAMP, registros_processados);
    
    RAISE NOTICE 'Carga incremental concluída: % registros processados', registros_processados;
END;
$$ LANGUAGE plpgsql;

-- Criar tabela de log
CREATE TABLE IF NOT EXISTS log_carga (
    id SERIAL PRIMARY KEY,
    data_processamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registros_processados INTEGER
);

-- Validação de qualidade de dados
CREATE OR REPLACE FUNCTION validar_qualidade_dados()
RETURNS TABLE(
    tabela VARCHAR,
    validacao VARCHAR,
    status VARCHAR,
    detalhes TEXT
) AS $$
BEGIN
    -- Verificar valores nulos em campos obrigatórios
    RETURN QUERY
    SELECT 
        'fato_vendas'::VARCHAR,
        'Valores Nulos'::VARCHAR,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::VARCHAR,
        CONCAT('Registros com valores nulos: ', COUNT(*))::TEXT
    FROM fato_vendas
    WHERE venda_id IS NULL OR tempo_id IS NULL OR vendedor_id IS NULL;
    
    -- Verificar valores negativos
    RETURN QUERY
    SELECT 
        'fato_vendas'::VARCHAR,
        'Valores Negativos'::VARCHAR,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::VARCHAR,
        CONCAT('Registros com valores negativos: ', COUNT(*))::TEXT
    FROM fato_vendas
    WHERE preco < 0 OR quantidade < 0 OR valor_total < 0;
    
    -- Verificar integridade referencial
    RETURN QUERY
    SELECT 
        'fato_vendas'::VARCHAR,
        'Integridade Referencial'::VARCHAR,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::VARCHAR,
        CONCAT('Registros órfãos: ', COUNT(*))::TEXT
    FROM fato_vendas fv
    LEFT JOIN dim_vendedor dv ON fv.vendedor_id = dv.vendedor_id
    WHERE dv.vendedor_id IS NULL;
    
END;
$$ LANGUAGE plpgsql;

-- 3. OLAP Operations

-- Drill-down: Vendas por Ano -> Mês -> Dia
SELECT 
    dt.ano,
    dt.mes,
    dt.dia,
    COUNT(*) as num_vendas,
    SUM(fv.valor_total) as total_vendas,
    AVG(fv.valor_total) as ticket_medio
FROM fato_vendas fv
JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
GROUP BY ROLLUP(dt.ano, dt.mes, dt.dia)
ORDER BY dt.ano, dt.mes, dt.dia;

-- Roll-up: Vendas por Produto -> Categoria -> Grupo
SELECT 
    dp.grupo_categoria,
    dp.categoria,
    dp.nome_produto,
    SUM(fv.valor_total) as total_vendas,
    COUNT(*) as num_vendas
FROM fato_vendas fv
JOIN dim_produto dp ON fv.produto_id = dp.produto_id
GROUP BY ROLLUP(dp.grupo_categoria, dp.categoria, dp.nome_produto)
ORDER BY dp.grupo_categoria, dp.categoria, dp.nome_produto;

-- Slice and Dice
SELECT 
    dg.regiao,
    dp.categoria,
    dt.trimestre,
    SUM(fv.valor_total) as total_vendas,
    COUNT(*) as num_vendas
FROM fato_vendas fv
JOIN dim_geografia dg ON fv.geografia_id = dg.geografia_id
JOIN dim_produto dp ON fv.produto_id = dp.produto_id
JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
WHERE dt.ano = 2024
GROUP BY CUBE(dg.regiao, dp.categoria, dt.trimestre)
ORDER BY dg.regiao, dp.categoria, dt.trimestre;

-- 4. Análise de Cohort

-- Cohort de vendedores por período de contratação
WITH cohort_vendedores AS (
    SELECT 
        dv.vendedor_id,
        dv.nome,
        DATE_TRUNC('quarter', dv.data_contratacao) as cohort_contratacao,
        DATE_TRUNC('month', dt.data) as periodo_venda,
        SUM(fv.valor_total) as vendas_periodo
    FROM fato_vendas fv
    JOIN dim_vendedor dv ON fv.vendedor_id = dv.vendedor_id
    JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
    GROUP BY dv.vendedor_id, dv.nome, cohort_contratacao, periodo_venda
),
cohort_analysis AS (
    SELECT 
        cohort_contratacao,
        periodo_venda,
        COUNT(DISTINCT vendedor_id) as vendedores_ativos,
        SUM(vendas_periodo) as total_vendas_cohort,
        AVG(vendas_periodo) as media_vendas_vendedor
    FROM cohort_vendedores
    GROUP BY cohort_contratacao, periodo_venda
)
SELECT 
    cohort_contratacao,
    periodo_venda,
    vendedores_ativos,
    ROUND(total_vendas_cohort, 2) as total_vendas,
    ROUND(media_vendas_vendedor, 2) as media_por_vendedor,
    -- Calcular retenção
    ROUND(
        vendedores_ativos * 100.0 / 
        FIRST_VALUE(vendedores_ativos) OVER (
            PARTITION BY cohort_contratacao 
            ORDER BY periodo_venda
        ), 2
    ) as taxa_retencao_pct
FROM cohort_analysis
ORDER BY cohort_contratacao, periodo_venda;

-- 5. Machine Learning em SQL

-- Regressão linear simples para predição de vendas
WITH dados_ml AS (
    SELECT 
        fv.valor_total as y,
        fv.quantidade as x1,
        dt.dia_semana as x2,
        CASE dp.categoria WHEN 'Eletrônicos' THEN 1 ELSE 0 END as x3
    FROM fato_vendas fv
    JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
    JOIN dim_produto dp ON fv.produto_id = dp.produto_id
),
statisticas AS (
    SELECT 
        COUNT(*) as n,
        AVG(y) as y_mean,
        AVG(x1) as x1_mean,
        SUM((x1 - AVG(x1) OVER()) * (y - AVG(y) OVER())) as sum_xy,
        SUM(POWER(x1 - AVG(x1) OVER(), 2)) as sum_x2
    FROM dados_ml
)
SELECT 
    'Regressão Linear: Valor = a + b * Quantidade' as modelo,
    ROUND(y_mean - (sum_xy / sum_x2) * x1_mean, 2) as intercepto_a,
    ROUND(sum_xy / sum_x2, 2) as coeficiente_b,
    ROUND(
        POWER(
            (SELECT CORR(quantidade, valor_total) FROM dados_ml), 2
        ), 3
    ) as r_squared
FROM estatisticas;

-- Clustering simples usando SQL
WITH vendedor_features AS (
    SELECT 
        dv.vendedor_id,
        dv.nome,
        AVG(fv.valor_total) as ticket_medio,
        COUNT(*) as frequencia_vendas,
        SUM(fv.valor_total) as volume_total
    FROM fato_vendas fv
    JOIN dim_vendedor dv ON fv.vendedor_id = dv.vendedor_id
    GROUP BY dv.vendedor_id, dv.nome
),
features_normalizadas AS (
    SELECT 
        *,
        (ticket_medio - AVG(ticket_medio) OVER()) / STDDEV(ticket_medio) OVER() as ticket_norm,
        (frequencia_vendas - AVG(frequencia_vendas) OVER()) / STDDEV(frequencia_vendas) OVER() as freq_norm,
        (volume_total - AVG(volume_total) OVER()) / STDDEV(volume_total) OVER() as volume_norm
    FROM vendedor_features
)
SELECT 
    vendedor_id,
    nome,
    ROUND(ticket_medio, 2) as ticket_medio,
    frequencia_vendas,
    ROUND(volume_total, 2) as volume_total,
    CASE 
        WHEN ticket_norm > 0.5 AND volume_norm > 0.5 THEN 'Alto Valor'
        WHEN freq_norm > 0.5 THEN 'Alta Frequência'
        WHEN volume_norm < -0.5 THEN 'Baixo Volume'
        ELSE 'Padrão'
    END as cluster
FROM features_normalizadas
ORDER BY cluster, volume_total DESC;

-- 6. Otimização Avançada

-- Criar índices otimizados
CREATE INDEX IF NOT EXISTS idx_fato_vendas_tempo ON fato_vendas(tempo_id);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_vendedor ON fato_vendas(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_produto ON fato_vendas(produto_id);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_geografia ON fato_vendas(geografia_id);
CREATE INDEX IF NOT EXISTS idx_fato_vendas_valor ON fato_vendas(valor_total);

-- Índice composto para queries frequentes
CREATE INDEX IF NOT EXISTS idx_fato_vendas_tempo_vendedor 
ON fato_vendas(tempo_id, vendedor_id);

-- Particionamento por tempo (exemplo conceitual)
-- CREATE TABLE fato_vendas_2024_q1 PARTITION OF fato_vendas
-- FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Análise de performance de queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
WHERE query LIKE '%fato_vendas%'
ORDER BY total_time DESC
LIMIT 10;

-- 7. Relatórios Executivos

-- Dashboard principal
WITH kpis_principais AS (
    SELECT 
        COUNT(DISTINCT fv.vendedor_id) as vendedores_ativos,
        COUNT(*) as total_vendas,
        SUM(fv.valor_total) as faturamento_total,
        AVG(fv.valor_total) as ticket_medio,
        MAX(dt.data) as ultima_venda
    FROM fato_vendas fv
    JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
),
top_vendedores AS (
    SELECT 
        dv.nome,
        SUM(fv.valor_total) as total_vendido,
        ROW_NUMBER() OVER (ORDER BY SUM(fv.valor_total) DESC) as ranking
    FROM fato_vendas fv
    JOIN dim_vendedor dv ON fv.vendedor_id = dv.vendedor_id
    GROUP BY dv.vendedor_id, dv.nome
    LIMIT 5
),
top_produtos AS (
    SELECT 
        dp.nome_produto,
        SUM(fv.valor_total) as total_vendido,
        ROW_NUMBER() OVER (ORDER BY SUM(fv.valor_total) DESC) as ranking
    FROM fato_vendas fv
    JOIN dim_produto dp ON fv.produto_id = dp.produto_id
    GROUP BY dp.produto_id, dp.nome_produto
    LIMIT 5
)
SELECT 
    'DASHBOARD EXECUTIVO - ' || TO_CHAR(CURRENT_DATE, 'DD/MM/YYYY') as titulo,
    '' as separador,
    '=== KPIs PRINCIPAIS ===' as secao1,
    CONCAT('Vendedores Ativos: ', vendedores_ativos) as kpi1,
    CONCAT('Total de Vendas: ', total_vendas) as kpi2,
    CONCAT('Faturamento: R$ ', TO_CHAR(faturamento_total, '999,999,999.99')) as kpi3,
    CONCAT('Ticket Médio: R$ ', TO_CHAR(ticket_medio, '999,999.99')) as kpi4,
    CONCAT('Última Venda: ', TO_CHAR(ultima_venda, 'DD/MM/YYYY')) as kpi5
FROM kpis_principais;

-- Alertas automáticos
WITH alertas AS (
    -- Vendedores sem vendas nos últimos 7 dias
    SELECT 
        'ALERTA' as tipo,
        'Vendedor Inativo' as categoria,
        CONCAT(dv.nome, ' - sem vendas há mais de 7 dias') as descricao,
        'ALTA' as prioridade
    FROM dim_vendedor dv
    WHERE NOT EXISTS (
        SELECT 1 FROM fato_vendas fv
        JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
        WHERE fv.vendedor_id = dv.vendedor_id
        AND dt.data >= CURRENT_DATE - INTERVAL '7 days'
    )
    
    UNION ALL
    
    -- Vendas muito abaixo da média
    SELECT 
        'ALERTA',
        'Performance Baixa',
        CONCAT('Vendas 50% abaixo da média nos últimos 7 dias'),
        'MÉDIA'
    FROM (
        SELECT AVG(valor_total) as media_geral
        FROM fato_vendas fv
        JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
        WHERE dt.data >= CURRENT_DATE - INTERVAL '7 days'
    ) mg
    WHERE EXISTS (
        SELECT 1
        FROM fato_vendas fv
        JOIN dim_tempo dt ON fv.tempo_id = dt.tempo_id
        WHERE dt.data >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY fv.vendedor_id
        HAVING AVG(fv.valor_total) < mg.media_geral * 0.5
    )
)
SELECT * FROM alertas
ORDER BY 
    CASE prioridade
        WHEN 'ALTA' THEN 1
        WHEN 'MÉDIA' THEN 2
        WHEN 'BAIXA' THEN 3
    END;

-- 8. Auditoria e Compliance

-- Log de auditoria
CREATE TABLE IF NOT EXISTS auditoria_vendas (
    id SERIAL PRIMARY KEY,
    tabela VARCHAR(50),
    operacao VARCHAR(10),
    usuario VARCHAR(100),
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB
);

-- Trigger para auditoria
CREATE OR REPLACE FUNCTION audit_vendas_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_vendas (tabela, operacao, usuario, dados_novos)
        VALUES (TG_TABLE_NAME, TG_OP, USER, row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_vendas (tabela, operacao, usuario, dados_antigos, dados_novos)
        VALUES (TG_TABLE_NAME, TG_OP, USER, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_vendas (tabela, operacao, usuario, dados_antigos)
        VALUES (TG_TABLE_NAME, TG_OP, USER, row_to_json(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger
CREATE TRIGGER audit_vendas_trigger
    AFTER INSERT OR UPDATE OR DELETE ON vendas
    FOR EACH ROW EXECUTE FUNCTION audit_vendas_trigger();

-- Controle de acesso
CREATE ROLE vendedor_role;
GRANT SELECT ON vendas, funcionarios TO vendedor_role;
GRANT SELECT ON dim_vendedor, dim_produto, dim_tempo, dim_geografia TO vendedor_role;

CREATE ROLE gerente_role;
GRANT ALL ON vendas, funcionarios TO gerente_role;
GRANT ALL ON fato_vendas, dim_vendedor, dim_produto, dim_tempo, dim_geografia TO gerente_role;

-- Monitoramento de alterações
SELECT 
    tabela,
    operacao,
    usuario,
    data_operacao,
    COUNT(*) as num_operacoes
FROM auditoria_vendas
WHERE data_operacao >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY tabela, operacao, usuario, DATE(data_operacao)
ORDER BY data_operacao DESC;
```

## Queries de Verificação e Manutenção

```sql
-- Verificar integridade dos dados
SELECT 
    'Vendas sem vendedor' as problema,
    COUNT(*) as ocorrencias
FROM vendas v
LEFT JOIN funcionarios f ON v.vendedor_id = f.id
WHERE f.id IS NULL

UNION ALL

SELECT 
    'Vendas com valores negativos',
    COUNT(*)
FROM vendas
WHERE preco < 0 OR quantidade < 0

UNION ALL

SELECT 
    'Funcionários sem vendas',
    COUNT(*)
FROM funcionarios f
LEFT JOIN vendas v ON f.id = v.vendedor_id
WHERE v.vendedor_id IS NULL;

-- Estatísticas das tabelas
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserções,
    n_tup_upd as atualizações,
    n_tup_del as exclusões,
    n_live_tup as registros_ativos,
    last_analyze as última_análise
FROM pg_stat_user_tables
WHERE tablename IN ('vendas', 'funcionarios', 'produtos', 'clientes')
ORDER BY tablename;

-- Limpeza e otimização
VACUUM ANALYZE vendas;
VACUUM ANALYZE funcionarios;
VACUUM ANALYZE fato_vendas;
REINDEX TABLE fato_vendas;

-- Backup de segurança
CREATE TABLE backup_vendas_$(date +%Y%m%d) AS
SELECT * FROM vendas;

CREATE TABLE backup_funcionarios_$(date +%Y%m%d) AS
SELECT * FROM funcionarios;
```

## Dicas Importantes para Otimização

1. **Índices**: Sempre crie índices em colunas de junção e filtros frequentes
2. **Particionamento**: Para tabelas grandes, considere particionamento por data
3. **Estatísticas**: Mantenha as estatísticas atualizadas com ANALYZE
4. **EXPLAIN**: Use EXPLAIN ANALYZE para otimizar queries complexas
5. **Window Functions**: São mais eficientes que subconsultas correlacionadas
6. **CTEs**: Melhoram legibilidade e podem ser otimizadas pelo planner
7. **Materialização**: Considere views materializadas para consultas complexas
8. **Monitoramento**: Use pg_stat_statements para identificar queries lentas
9. **Backup**: Sempre faça backup antes de operações de manutenção
10. **Segurança**: Implemente controle de acesso granular e auditoria

## Observações Finais

- **Escalabilidade**: As soluções são projetadas para funcionar com datasets maiores
- **Performance**: Incluem otimizações como índices compostos e particionamento
- **Manutenibilidade**: Código bem documentado e estruturado
- **Segurança**: Implementação de auditoria e controle de acesso
- **Monitoramento**: Ferramentas para acompanhar performance e qualidade
- **Flexibilidade**: Estrutura dimensional permite análises multidimensionais
- **Automação**: Procedures para ETL e validação automática
- **Compliance**: Logs de auditoria para rastreabilidade completa