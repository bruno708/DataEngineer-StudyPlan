# Gabarito - Exercícios PySpark

## Preparação do Ambiente

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark.sql.window import Window
import pyspark.sql.functions as F

# Inicializar Spark Session
spark = SparkSession.builder \
    .appName("GabaritoPySpark") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()

spark.conf.set("spark.sql.repl.eagerEval.showToString", "true")
```

---

## GABARITO - EXERCÍCIOS BÁSICOS

### Exercício Básico 1: Análise Simples de Vendas

```python
# Carregar dados
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")

# 1. Mostrar primeiras 10 linhas
df_vendas.show(10)

# 2. Contar total de vendas
total_vendas = df_vendas.count()
print(f"Total de vendas: {total_vendas}")

# 3. Calcular valor total de vendas
df_valor_total = df_vendas.withColumn("valor_total", col("preco") * col("quantidade"))
valor_total_geral = df_valor_total.agg(sum("valor_total")).collect()[0][0]
print(f"Valor total de vendas: R$ {valor_total_geral:,.2f}")

# 4. Preço médio dos produtos
preco_medio = df_vendas.agg(avg("preco")).collect()[0][0]
print(f"Preço médio: R$ {preco_medio:.2f}")

# 5. Categorias únicas
categorias = df_vendas.select("categoria").distinct().collect()
print("Categorias:", [row.categoria for row in categorias])

# 6. Filtrar vendas da região Sul
vendas_sul = df_vendas.filter(col("regiao") == "Sul")
vendas_sul.show()

# 7. Ordenar por data (mais recente primeiro)
vendas_ordenadas = df_vendas.orderBy(col("data_venda").desc())
vendas_ordenadas.show()
```

### Exercício Básico 2: Manipulação de Dados de Funcionários

```python
# Carregar dados
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")

# 1. Selecionar colunas específicas
df_selecionado = df_funcionarios.select("nome", "cargo", "salario")
df_selecionado.show()

# 2. Filtrar salário > 4000
func_alto_salario = df_funcionarios.filter(col("salario") > 4000)
func_alto_salario.show()

# 3. Contar funcionários por departamento
func_por_depto = df_funcionarios.groupBy("departamento").count()
func_por_depto.show()

# 4. Funcionário com maior salário
maior_salario = df_funcionarios.orderBy(col("salario").desc()).first()
print(f"Maior salário: {maior_salario.nome} - R$ {maior_salario.salario}")

# 5. Idade média
idade_media = df_funcionarios.agg(avg("idade")).collect()[0][0]
print(f"Idade média: {idade_media:.1f} anos")

# 6. Criar faixa salarial
df_com_faixa = df_funcionarios.withColumn(
    "faixa_salarial",
    when(col("salario") < 4000, "Baixo")
    .when((col("salario") >= 4000) & (col("salario") <= 6000), "Médio")
    .otherwise("Alto")
)
df_com_faixa.select("nome", "salario", "faixa_salarial").show()

# 7. Ordenar por salário (maior para menor)
func_ordenados = df_funcionarios.orderBy(col("salario").desc())
func_ordenados.show()
```

---

## GABARITO - EXERCÍCIOS INTERMEDIÁRIOS

### Exercício Intermediário 1: Análise de Vendas por Período e Região

```python
# Carregar dados
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")

# 1. JOIN entre vendas e funcionários
df_vendas_func = df_vendas.join(df_funcionarios, df_vendas.vendedor_id == df_funcionarios.id, "inner") \
    .select(df_vendas["*"], df_funcionarios.nome.alias("vendedor_nome"))
df_vendas_func.show()

# 2. Total de vendas por mês
df_vendas_mes = df_vendas.withColumn("mes", month("data_venda")) \
    .withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("mes") \
    .agg(sum("valor_total").alias("total_vendas")) \
    .orderBy("mes")
df_vendas_mes.show()

# 3. Top 3 vendedores por valor total
top_vendedores = df_vendas_func.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("vendedor_id", "vendedor_nome") \
    .agg(sum("valor_total").alias("total_vendido")) \
    .orderBy(col("total_vendido").desc()) \
    .limit(3)
top_vendedores.show()

# 4. Média de vendas por região
media_regiao = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("regiao") \
    .agg(avg("valor_total").alias("media_vendas"))
media_regiao.show()

# 5. Criar coluna com mês da venda
df_com_mes = df_vendas.withColumn("mes_venda", month("data_venda"))
df_com_mes.select("id", "data_venda", "mes_venda").show()

# 6. Categoria com maior faturamento
faturamento_categoria = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("categoria") \
    .agg(sum("valor_total").alias("faturamento_total")) \
    .orderBy(col("faturamento_total").desc())
faturamento_categoria.show()

# 7. Crescimento percentual janeiro vs fevereiro
vendas_jan = df_vendas.filter(month("data_venda") == 1) \
    .withColumn("valor_total", col("preco") * col("quantidade")) \
    .agg(sum("valor_total")).collect()[0][0]

vendas_fev = df_vendas.filter(month("data_venda") == 2) \
    .withColumn("valor_total", col("preco") * col("quantidade")) \
    .agg(sum("valor_total")).collect()[0][0]

crescimento = ((vendas_fev - vendas_jan) / vendas_jan) * 100
print(f"Crescimento Jan->Fev: {crescimento:.2f}%")

# 8. Ranking de vendedores por região usando window functions
window_regiao = Window.partitionBy("regiao").orderBy(col("total_vendido").desc())

ranking_vendedores = df_vendas_func.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("regiao", "vendedor_id", "vendedor_nome") \
    .agg(sum("valor_total").alias("total_vendido")) \
    .withColumn("ranking", row_number().over(window_regiao))

ranking_vendedores.orderBy("regiao", "ranking").show()
```

### Exercício Intermediário 2: Análise de Produtos e Estoque

```python
# Carregar dados
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")

# 1. Calcular margem de lucro
df_com_margem = df_produtos.withColumn("margem_lucro", col("preco_venda") - col("preco_custo"))
df_com_margem.select("nome", "preco_custo", "preco_venda", "margem_lucro").show()

# 2. Percentual de margem de lucro
df_com_percentual = df_com_margem.withColumn(
    "percentual_margem", 
    ((col("preco_venda") - col("preco_custo")) / col("preco_custo") * 100)
)
df_com_percentual.select("nome", "percentual_margem").show()

# 3. Produtos com estoque baixo
estoque_baixo = df_produtos.filter(col("estoque") < 20)
estoque_baixo.select("nome", "estoque").show()

# 4. Agregações por categoria
agg_categoria = df_produtos.groupBy("categoria").agg(
    avg("preco_venda").alias("preco_medio"),
    sum("estoque").alias("estoque_total"),
    avg((col("preco_venda") - col("preco_custo"))).alias("margem_media")
)
agg_categoria.show()

# 5. Ranking por margem dentro de cada categoria
window_categoria = Window.partitionBy("categoria").orderBy((col("preco_venda") - col("preco_custo")).desc())

ranking_margem = df_produtos.withColumn(
    "ranking_margem", 
    row_number().over(window_categoria)
)
ranking_margem.select("categoria", "nome", "preco_venda", "preco_custo", "ranking_margem").show()

# 6. Status do estoque
df_status_estoque = df_produtos.withColumn(
    "status_estoque",
    when(col("estoque") < 15, "Crítico")
    .when((col("estoque") >= 15) & (col("estoque") <= 30), "Baixo")
    .otherwise("Normal")
)
df_status_estoque.select("nome", "estoque", "status_estoque").show()

# 7. Valor total do estoque por fornecedor
valor_estoque_fornecedor = df_produtos.withColumn(
    "valor_estoque", col("estoque") * col("preco_custo")
).groupBy("fornecedor").agg(
    sum("valor_estoque").alias("valor_total_estoque")
).orderBy(col("valor_total_estoque").desc())
valor_estoque_fornecedor.show()

# 8. Produto mais caro e mais barato por subcategoria
window_max = Window.partitionBy("subcategoria").orderBy(col("preco_venda").desc())
window_min = Window.partitionBy("subcategoria").orderBy(col("preco_venda").asc())

produtos_extremos = df_produtos.withColumn("rank_max", row_number().over(window_max)) \
    .withColumn("rank_min", row_number().over(window_min)) \
    .filter((col("rank_max") == 1) | (col("rank_min") == 1)) \
    .select("subcategoria", "nome", "preco_venda", "rank_max", "rank_min")

produtos_extremos.show()
```

---

## GABARITO - EXERCÍCIOS AVANÇADOS

### Exercício Avançado 1: Análise Completa de Performance de Vendas

```python
# Carregar todos os datasets
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")
df_clientes = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/clientes.csv")

# 1. DataFrame consolidado
df_consolidado = df_vendas.join(df_funcionarios, df_vendas.vendedor_id == df_funcionarios.id, "inner") \
    .select(
        df_vendas["*"],
        df_funcionarios.nome.alias("vendedor_nome"),
        df_funcionarios.cargo,
        df_funcionarios.departamento,
        df_funcionarios.salario
    ).withColumn("valor_total", col("preco") * col("quantidade"))

df_consolidado.cache()  # Cache para reutilização
df_consolidado.show(5)

# 2. Window Functions avançadas

# Vendas acumuladas por vendedor
window_vendedor_tempo = Window.partitionBy("vendedor_id").orderBy("data_venda")
df_acumulado = df_consolidado.withColumn(
    "vendas_acumuladas",
    sum("valor_total").over(window_vendedor_tempo)
)

# Média móvel de 3 períodos por região
window_regiao_tempo = Window.partitionBy("regiao").orderBy("data_venda").rowsBetween(-2, 0)
df_media_movel = df_consolidado.withColumn(
    "media_movel_3",
    avg("valor_total").over(window_regiao_tempo)
)

# Ranking de produtos por mês
df_com_mes = df_consolidado.withColumn("mes", month("data_venda"))
window_produto_mes = Window.partitionBy("mes", "produto").orderBy(col("valor_total").desc())
df_ranking_produto = df_com_mes.withColumn(
    "ranking_produto_mes",
    row_number().over(window_produto_mes)
)

# 3. Métricas avançadas

# Taxa de crescimento por vendedor
df_vendedor_mes = df_consolidado.withColumn("mes", month("data_venda")) \
    .groupBy("vendedor_id", "vendedor_nome", "mes") \
    .agg(sum("valor_total").alias("total_mes"))

window_crescimento = Window.partitionBy("vendedor_id").orderBy("mes")
df_crescimento = df_vendedor_mes.withColumn(
    "mes_anterior",
    lag("total_mes").over(window_crescimento)
).withColumn(
    "taxa_crescimento",
    ((col("total_mes") - col("mes_anterior")) / col("mes_anterior") * 100)
)

# Participação percentual por região
total_geral = df_consolidado.agg(sum("valor_total")).collect()[0][0]
df_participacao = df_consolidado.groupBy("regiao") \
    .agg(sum("valor_total").alias("total_regiao")) \
    .withColumn("participacao_pct", (col("total_regiao") / total_geral * 100))

# Coeficiente de variação por vendedor
df_cv = df_consolidado.groupBy("vendedor_id", "vendedor_nome") \
    .agg(
        avg("valor_total").alias("media"),
        stddev("valor_total").alias("desvio_padrao")
    ).withColumn(
        "coef_variacao",
        col("desvio_padrao") / col("media")
    )

# 4. Padrões sazonais

# Dia da semana com maior volume
df_dia_semana = df_consolidado.withColumn("dia_semana", dayofweek("data_venda")) \
    .groupBy("dia_semana") \
    .agg(sum("valor_total").alias("total_dia")) \
    .orderBy(col("total_dia").desc())

# Produtos com maior variação de preço
df_variacao_preco = df_consolidado.groupBy("produto") \
    .agg(
        max("preco").alias("preco_max"),
        min("preco").alias("preco_min")
    ).withColumn(
        "variacao_preco",
        col("preco_max") - col("preco_min")
    ).orderBy(col("variacao_preco").desc())

# 5. Sistema de scoring de vendedores

# Calcular métricas base
df_metricas_vendedor = df_consolidado.groupBy("vendedor_id", "vendedor_nome") \
    .agg(
        sum("valor_total").alias("volume_total"),
        stddev("valor_total").alias("desvio_padrao"),
        countDistinct("produto").alias("diversidade_produtos")
    )

# Normalizar métricas (0-100)
max_volume = df_metricas_vendedor.agg(max("volume_total")).collect()[0][0]
min_desvio = df_metricas_vendedor.agg(min("desvio_padrao")).collect()[0][0]
max_desvio = df_metricas_vendedor.agg(max("desvio_padrao")).collect()[0][0]
max_diversidade = df_metricas_vendedor.agg(max("diversidade_produtos")).collect()[0][0]

df_scoring = df_metricas_vendedor.withColumn(
    "score_volume", (col("volume_total") / max_volume * 100)
).withColumn(
    "score_consistencia", ((max_desvio - col("desvio_padrao")) / (max_desvio - min_desvio) * 100)
).withColumn(
    "score_diversidade", (col("diversidade_produtos") / max_diversidade * 100)
).withColumn(
    "score_final",
    col("score_volume") * 0.4 + col("score_consistencia") * 0.3 + col("score_diversidade") * 0.3
).orderBy(col("score_final").desc())

df_scoring.show()

# 6. Operação de pivot
df_pivot = df_consolidado.groupBy("vendedor_nome") \
    .pivot("categoria") \
    .agg(sum("valor_total")) \
    .fillna(0)

df_pivot.show()

# 7. Detecção de outliers
percentis = df_consolidado.approxQuantile("valor_total", [0.25, 0.75], 0.01)
q1, q3 = percentis[0], percentis[1]
iqr = q3 - q1
limite_inferior = q1 - 1.5 * iqr
limite_superior = q3 + 1.5 * iqr

df_outliers = df_consolidado.filter(
    (col("valor_total") < limite_inferior) | (col("valor_total") > limite_superior)
)

print(f"Outliers detectados: {df_outliers.count()}")
df_outliers.show()

# 8. Salvar em Parquet particionado
df_consolidado.write \
    .mode("overwrite") \
    .partitionBy("regiao") \
    .parquet("output/vendas_consolidadas")

print("Dados salvos em formato Parquet particionado por região")
```

### Exercício Avançado 2: Sistema de Recomendação e Análise Preditiva

```python
# Carregar e preparar dados
df_vendas = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/vendas.csv")
df_funcionarios = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/funcionarios.csv")
df_produtos = spark.read.option("header", "true").option("inferSchema", "true").csv("dados/produtos.csv")

# Criar dados sintéticos de interações
df_interacoes = df_vendas.select("id", "produto", "categoria", "quantidade") \
    .withColumn("cliente_id", (rand() * 10 + 1).cast("int")) \
    .withColumn("rating", when(rand() > 0.8, 5)
                         .when(rand() > 0.6, 4)
                         .when(rand() > 0.4, 3)
                         .when(rand() > 0.2, 2)
                         .otherwise(1))

# 1. Análise de Cesta de Compras

# Produtos frequentemente comprados juntos
df_cestas = df_vendas.groupBy("vendedor_id", "data_venda") \
    .agg(collect_list("produto").alias("produtos_comprados"))

# Criar pares de produtos
from pyspark.sql.functions import explode, col

def criar_pares_produtos(produtos):
    pares = []
    for i in range(len(produtos)):
        for j in range(i+1, len(produtos)):
            pares.append((produtos[i], produtos[j]))
    return pares

# UDF para criar pares
criar_pares_udf = udf(criar_pares_produtos, ArrayType(StructType([
    StructField("produto1", StringType()),
    StructField("produto2", StringType())
])))

df_pares = df_cestas.withColumn("pares", criar_pares_udf("produtos_comprados")) \
    .select(explode("pares").alias("par")) \
    .select("par.produto1", "par.produto2")

# Contar co-ocorrências
df_coocorrencia = df_pares.groupBy("produto1", "produto2").count() \
    .orderBy(col("count").desc())

print("Produtos frequentemente comprados juntos:")
df_coocorrencia.show(10)

# 2. Segmentação RFM

# Simular dados de clientes com múltiplas compras
df_vendas_cliente = df_vendas.withColumn("cliente_id", (rand() * 50 + 1).cast("int")) \
    .withColumn("valor_total", col("preco") * col("quantidade"))

# Calcular métricas RFM
data_referencia = df_vendas_cliente.agg(max("data_venda")).collect()[0][0]

df_rfm = df_vendas_cliente.groupBy("cliente_id") \
    .agg(
        datediff(lit(data_referencia), max("data_venda")).alias("recency"),
        count("*").alias("frequency"),
        sum("valor_total").alias("monetary")
    )

# Criar scores RFM (1-5)
percentis_r = df_rfm.approxQuantile("recency", [0.2, 0.4, 0.6, 0.8], 0.01)
percentis_f = df_rfm.approxQuantile("frequency", [0.2, 0.4, 0.6, 0.8], 0.01)
percentis_m = df_rfm.approxQuantile("monetary", [0.2, 0.4, 0.6, 0.8], 0.01)

df_rfm_scores = df_rfm.withColumn(
    "r_score",
    when(col("recency") <= percentis_r[0], 5)
    .when(col("recency") <= percentis_r[1], 4)
    .when(col("recency") <= percentis_r[2], 3)
    .when(col("recency") <= percentis_r[3], 2)
    .otherwise(1)
).withColumn(
    "f_score",
    when(col("frequency") >= percentis_f[3], 5)
    .when(col("frequency") >= percentis_f[2], 4)
    .when(col("frequency") >= percentis_f[1], 3)
    .when(col("frequency") >= percentis_f[0], 2)
    .otherwise(1)
).withColumn(
    "m_score",
    when(col("monetary") >= percentis_m[3], 5)
    .when(col("monetary") >= percentis_m[2], 4)
    .when(col("monetary") >= percentis_m[1], 3)
    .when(col("monetary") >= percentis_m[0], 2)
    .otherwise(1)
).withColumn(
    "rfm_score",
    concat(col("r_score"), col("f_score"), col("m_score"))
)

# Segmentar clientes
df_segmentos = df_rfm_scores.withColumn(
    "segmento",
    when(col("rfm_score").isin(["555", "554", "544", "545", "454", "455", "445"]), "Champions")
    .when(col("rfm_score").isin(["543", "444", "435", "355", "354", "345", "344", "335"]), "Loyal Customers")
    .when(col("rfm_score").isin(["512", "511", "422", "421", "412", "411", "311"]), "New Customers")
    .when(col("rfm_score").isin(["155", "154", "144", "214", "215", "115", "114"]), "At Risk")
    .otherwise("Others")
)

print("Segmentação de clientes:")
df_segmentos.groupBy("segmento").count().show()

# 3. Análise de Séries Temporais

# Vendas diárias
df_vendas_diarias = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("data_venda") \
    .agg(sum("valor_total").alias("vendas_dia")) \
    .orderBy("data_venda")

# Média móvel
window_ma = Window.orderBy("data_venda").rowsBetween(-6, 0)
df_ma = df_vendas_diarias.withColumn(
    "media_movel_7d",
    avg("vendas_dia").over(window_ma)
)

# Crescimento diário
window_growth = Window.orderBy("data_venda")
df_growth = df_ma.withColumn(
    "vendas_dia_anterior",
    lag("vendas_dia").over(window_growth)
).withColumn(
    "crescimento_diario",
    ((col("vendas_dia") - col("vendas_dia_anterior")) / col("vendas_dia_anterior") * 100)
)

print("Análise temporal das vendas:")
df_growth.show()

# 4. Sistema de Recomendação

# Matriz produto-produto baseada em co-ocorrência
df_produto_similarity = df_coocorrencia.withColumnRenamed("count", "similarity_score")

# Normalizar scores de similaridade
max_similarity = df_produto_similarity.agg(max("similarity_score")).collect()[0][0]
df_produto_similarity_norm = df_produto_similarity.withColumn(
    "similarity_normalized",
    col("similarity_score") / max_similarity
)

print("Matriz de similaridade entre produtos:")
df_produto_similarity_norm.show()

# 5. Análise de Performance Avançada

# Clustering de vendedores (usando métricas simples)
df_vendedor_features = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .groupBy("vendedor_id") \
    .agg(
        sum("valor_total").alias("total_vendas"),
        avg("valor_total").alias("ticket_medio"),
        count("*").alias("num_vendas"),
        countDistinct("produto").alias("diversidade")
    )

# Normalizar features para clustering
from pyspark.ml.feature import StandardScaler, VectorAssembler
from pyspark.ml.clustering import KMeans

# Preparar features
assembler = VectorAssembler(
    inputCols=["total_vendas", "ticket_medio", "num_vendas", "diversidade"],
    outputCol="features"
)

df_features = assembler.transform(df_vendedor_features)

# Escalar features
scaler = StandardScaler(inputCol="features", outputCol="scaledFeatures")
scaler_model = scaler.fit(df_features)
df_scaled = scaler_model.transform(df_features)

# Aplicar K-means
kmeans = KMeans(k=3, featuresCol="scaledFeatures", predictionCol="cluster")
kmeans_model = kmeans.fit(df_scaled)
df_clustered = kmeans_model.transform(df_scaled)

print("Clustering de vendedores:")
df_clustered.select("vendedor_id", "total_vendas", "ticket_medio", "cluster").show()

# 6. Otimização e Performance

# Broadcast join para tabelas pequenas
df_funcionarios_broadcast = broadcast(df_funcionarios)
df_vendas_otimizado = df_vendas.join(df_funcionarios_broadcast, "vendedor_id")

# Cache estratégico
df_vendas_otimizado.cache()
df_vendas_otimizado.count()  # Materializar cache

# Reparticionamento
df_vendas_partitioned = df_vendas_otimizado.repartition(4, "regiao")

# 7. Pipeline de ML

from pyspark.ml.feature import StringIndexer, OneHotEncoder
from pyspark.ml import Pipeline
from pyspark.ml.regression import LinearRegression
from pyspark.ml.evaluation import RegressionEvaluator

# Preparar dados para ML
df_ml = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .withColumn("mes", month("data_venda")) \
    .withColumn("dia_semana", dayofweek("data_venda"))

# Indexar variáveis categóricas
categoria_indexer = StringIndexer(inputCol="categoria", outputCol="categoria_index")
regiao_indexer = StringIndexer(inputCol="regiao", outputCol="regiao_index")

# One-hot encoding
categoria_encoder = OneHotEncoder(inputCol="categoria_index", outputCol="categoria_vec")
regiao_encoder = OneHotEncoder(inputCol="regiao_index", outputCol="regiao_vec")

# Assembler final
feature_assembler = VectorAssembler(
    inputCols=["quantidade", "mes", "dia_semana", "categoria_vec", "regiao_vec"],
    outputCol="features"
)

# Modelo de regressão
lr = LinearRegression(featuresCol="features", labelCol="preco")

# Pipeline
pipeline = Pipeline(stages=[
    categoria_indexer, regiao_indexer,
    categoria_encoder, regiao_encoder,
    feature_assembler, lr
])

# Dividir dados
train_data, test_data = df_ml.randomSplit([0.8, 0.2], seed=42)

# Treinar modelo
model = pipeline.fit(train_data)
predictions = model.transform(test_data)

# Avaliar modelo
evaluator = RegressionEvaluator(labelCol="preco", predictionCol="prediction", metricName="rmse")
rmse = evaluator.evaluate(predictions)
print(f"RMSE: {rmse:.2f}")

# 8. Relatório Executivo

# KPIs principais
total_vendas = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .agg(sum("valor_total")).collect()[0][0]

num_vendedores = df_vendas.select("vendedor_id").distinct().count()
ticket_medio = df_vendas.withColumn("valor_total", col("preco") * col("quantidade")) \
    .agg(avg("valor_total")).collect()[0][0]

print("\n=== RELATÓRIO EXECUTIVO ===")
print(f"Total de Vendas: R$ {total_vendas:,.2f}")
print(f"Número de Vendedores: {num_vendedores}")
print(f"Ticket Médio: R$ {ticket_medio:.2f}")
print(f"RMSE do Modelo: {rmse:.2f}")

# Salvar resultados
df_vendas_otimizado.write.mode("overwrite").parquet("output/vendas_ml")
df_segmentos.write.mode("overwrite").json("output/segmentos_clientes")
df_produto_similarity_norm.write.mode("overwrite").delta("output/produto_similarity")

print("\nResultados salvos em múltiplos formatos!")
```

## Finalização

```python
# Limpar cache
spark.catalog.clearCache()

# Parar sessão Spark
spark.stop()
```

## Observações Importantes

1. **Performance**: Os exemplos incluem otimizações como cache, broadcast joins e reparticionamento
2. **Escalabilidade**: As soluções são projetadas para funcionar com datasets maiores
3. **Boas Práticas**: Uso adequado de window functions, UDFs e pipelines de ML
4. **Formatos Modernos**: Exemplos de salvamento em Parquet, Delta e JSON
5. **Monitoramento**: Use `spark.sparkContext.statusTracker()` para monitorar jobs
6. **Debugging**: Use `.explain()` e Spark UI para otimizar queries
7. **Memória**: Configure adequadamente `spark.executor.memory` e `spark.driver.memory`
8. **Particionamento**: Considere o particionamento baseado em colunas de alta cardinalidade