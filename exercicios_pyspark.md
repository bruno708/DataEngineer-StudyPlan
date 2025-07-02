# Exercícios PySpark - Níveis Básico, Intermediário e Avançado

## Preparação do Ambiente

Antes de começar os exercícios, certifique-se de ter o PySpark instalado e execute o código de inicialização:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark.sql.window import Window

# Inicializar Spark Session
spark = SparkSession.builder \
    .appName("ExerciciosPySpark") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()

# Configurar para mostrar todas as colunas
spark.conf.set("spark.sql.repl.eagerEval.showToString", "true")
```

---

## EXERCÍCIOS BÁSICOS

### Exercício Básico 1: Análise Simples de Vendas

**Comando para carregar os dados:**
```python
# Carregar dados de vendas
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_vendas.show(5)
df_vendas.printSchema()
```

**Tarefas:**
1. Mostre as primeiras 10 linhas do DataFrame de vendas
2. Conte quantas vendas foram realizadas no total
3. Calcule o valor total de vendas (preço × quantidade)
4. Encontre o preço médio dos produtos vendidos
5. Liste todas as categorias únicas de produtos
6. Filtre apenas as vendas da região "Sul"
7. Ordene as vendas por data de venda (mais recente primeiro)

---

### Exercício Básico 2: Manipulação de Dados de Funcionários

**Comando para carregar os dados:**
```python
# Carregar dados de funcionários
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")
df_funcionarios.show()
df_funcionarios.printSchema()
```

**Tarefas:**
1. Selecione apenas as colunas: nome, cargo e salário
2. Filtre funcionários com salário maior que R$ 4.000
3. Conte quantos funcionários existem por departamento
4. Encontre o funcionário com maior salário
5. Calcule a idade média dos funcionários
6. Crie uma nova coluna chamada "faixa_salarial" com as categorias:
   - "Baixo": salário < 4000
   - "Médio": salário entre 4000 e 6000
   - "Alto": salário > 6000
7. Ordene os funcionários por salário (maior para menor)

---

## EXERCÍCIOS INTERMEDIÁRIOS

### Exercício Intermediário 1: Análise de Vendas por Período e Região

**Comando para carregar os dados:**
```python
# Carregar dados necessários
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")

# Mostrar esquemas
df_vendas.printSchema()
df_funcionarios.printSchema()
```

**Tarefas:**
1. Faça um JOIN entre vendas e funcionários para obter o nome do vendedor em cada venda
2. Calcule o total de vendas (preço × quantidade) por mês
3. Encontre o top 3 vendedores por valor total vendido
4. Calcule a média de vendas por região
5. Crie uma coluna com o mês da venda (extraído da data_venda)
6. Identifique qual categoria de produto teve maior faturamento
7. Calcule o crescimento percentual de vendas entre janeiro e fevereiro de 2024
8. Use window functions para rankear os vendedores por performance em cada região

---

### Exercício Intermediário 2: Análise de Produtos e Estoque

**Comando para carregar os dados:**
```python
# Carregar dados de produtos
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")
df_produtos.show()
df_produtos.printSchema()
```

**Tarefas:**
1. Calcule a margem de lucro de cada produto (preço_venda - preço_custo)
2. Calcule o percentual de margem de lucro ((preço_venda - preço_custo) / preço_custo * 100)
3. Identifique produtos com estoque baixo (menos de 20 unidades)
4. Agrupe produtos por categoria e calcule:
   - Preço médio de venda
   - Estoque total
   - Margem média de lucro
5. Use window functions para rankear produtos por margem de lucro dentro de cada categoria
6. Crie uma coluna "status_estoque" com as categorias:
   - "Crítico": estoque < 15
   - "Baixo": estoque entre 15 e 30
   - "Normal": estoque > 30
7. Calcule o valor total do estoque (estoque × preço_custo) por fornecedor
8. Identifique o produto mais caro e mais barato de cada subcategoria

---

## EXERCÍCIOS AVANÇADOS

### Exercício Avançado 1: Análise Completa de Performance de Vendas

**Comando para carregar os dados:**
```python
# Carregar todos os datasets
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")
df_clientes = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/clientes.csv")

# Verificar os dados carregados
print("Vendas:", df_vendas.count())
print("Funcionários:", df_funcionarios.count())
print("Produtos:", df_produtos.count())
print("Clientes:", df_clientes.count())
```

**Tarefas:**
1. Crie um DataFrame consolidado juntando vendas, funcionários e produtos
2. Implemente window functions para calcular:
   - Vendas acumuladas por vendedor ao longo do tempo
   - Média móvel de 3 períodos das vendas por região
   - Ranking de produtos mais vendidos por mês
3. Calcule métricas avançadas:
   - Taxa de crescimento mês a mês por vendedor
   - Participação percentual de cada região no total de vendas
   - Coeficiente de variação das vendas por vendedor (desvio padrão / média)
4. Identifique padrões sazonais:
   - Dia da semana com maior volume de vendas
   - Produtos com maior variação de preço entre vendas
5. Crie um sistema de scoring de vendedores baseado em:
   - Volume total vendido (peso 40%)
   - Consistência (baixa variação) (peso 30%)
   - Diversidade de produtos vendidos (peso 30%)
6. Use operações de pivot para criar uma tabela cruzada: vendedor × categoria × total_vendas
7. Implemente detecção de outliers usando percentis (vendas muito acima ou abaixo da média)
8. Salve os resultados em formato Parquet particionado por região

---

### Exercício Avançado 2: Sistema de Recomendação e Análise Preditiva

**Comando para carregar os dados:**
```python
# Carregar e preparar dados para análise avançada
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")

# Criar dados sintéticos adicionais para análise mais complexa
from pyspark.sql.functions import rand, when, col

# Simular dados de interações de clientes
df_interacoes = df_vendas.select("id", "produto", "categoria", "quantidade") \
    .withColumn("cliente_id", (rand() * 10 + 1).cast("int")) \
    .withColumn("rating", when(rand() > 0.8, 5)
                         .when(rand() > 0.6, 4)
                         .when(rand() > 0.4, 3)
                         .when(rand() > 0.2, 2)
                         .otherwise(1))

df_interacoes.show(10)
```

**Tarefas:**
1. **Análise de Cesta de Compras:**
   - Identifique produtos frequentemente comprados juntos
   - Calcule a correlação entre categorias de produtos
   - Implemente regras de associação simples (se compra A, também compra B)

2. **Segmentação de Clientes usando RFM:**
   - Recency: dias desde a última compra
   - Frequency: número de compras
   - Monetary: valor total gasto
   - Crie scores RFM e segmente clientes em grupos

3. **Análise de Séries Temporais:**
   - Decomponha as vendas em tendência, sazonalidade e ruído
   - Calcule médias móveis exponenciais
   - Identifique pontos de mudança nas vendas

4. **Sistema de Recomendação Colaborativo:**
   - Calcule similaridade entre produtos baseada em co-ocorrência
   - Implemente recomendação baseada em produtos similares
   - Crie matriz produto-produto com scores de similaridade

5. **Análise de Performance Avançada:**
   - Implemente algoritmo de clustering para agrupar vendedores similares
   - Calcule lifetime value dos clientes
   - Identifique clientes em risco de churn (sem compras recentes)

6. **Otimização e Performance:**
   - Use broadcast joins para otimizar junções
   - Implemente cache estratégico para DataFrames reutilizados
   - Particione dados por critérios relevantes
   - Monitore e otimize o plano de execução

7. **Machine Learning Pipeline:**
   - Prepare features para predição de vendas
   - Implemente encoding de variáveis categóricas
   - Crie pipeline de transformação de dados
   - Divida dados em treino/teste

8. **Relatório Executivo:**
   - Crie dashboard com KPIs principais
   - Gere insights acionáveis para o negócio
   - Salve resultados em múltiplos formatos (Parquet, Delta, JSON)
   - Implemente versionamento de dados

---

## Finalização

```python
# Sempre lembre de parar a sessão Spark ao final
spark.stop()
```

## Dicas Importantes

1. **Performance**: Use `.cache()` em DataFrames que serão reutilizados
2. **Debugging**: Use `.explain()` para entender o plano de execução
3. **Memória**: Configure adequadamente `spark.sql.adaptive.enabled`
4. **Particionamento**: Considere particionar dados grandes por colunas relevantes
5. **Tipos de Dados**: Sempre verifique e ajuste tipos de dados quando necessário
6. **Window Functions**: São poderosas para análises temporais e rankings
7. **Broadcast Joins**: Use para tabelas pequenas que são joinadas com tabelas grandes
8. **Lazy Evaluation**: Lembre-se que transformações são lazy, apenas actions executam o código