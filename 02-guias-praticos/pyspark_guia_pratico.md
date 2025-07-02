# Guia Prático PySpark - Operações Essenciais

## 1. Inicializando a Sessão Spark

```python
from pyspark.sql import SparkSession

# Criar sessão Spark
spark = SparkSession.builder \
    .appName("MeuApp") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()

# Verificar se funcionou
print(spark.version)
```

## 2. Criando DataFrames

### A partir de lista
```python
# Dados simples
dados = [("João", 25, "SP"), ("Maria", 30, "RJ"), ("Pedro", 35, "MG")]
colunas = ["nome", "idade", "estado"]

df = spark.createDataFrame(dados, colunas)
df.show()
```

### A partir de arquivo CSV
```python
# Ler CSV
df = spark.read.option("header", "true") \
    .option("inferSchema", "true") \
    .csv("caminho/arquivo.csv")

df.show(5)  # Mostra 5 linhas
```

## 3. Operações Básicas de Visualização

```python
# Ver estrutura
df.printSchema()

# Contar linhas
print(f"Total de linhas: {df.count()}")

# Ver colunas
print(f"Colunas: {df.columns}")

# Estatísticas básicas
df.describe().show()

# Primeiras linhas
df.head(3)  # Retorna lista
df.show(3)  # Mostra formatado
```

## 4. Seleção e Filtros

```python
# Selecionar colunas
df.select("nome", "idade").show()

# Filtrar dados
df.filter(df.idade > 25).show()
df.where(df.estado == "SP").show()

# Múltiplas condições
df.filter((df.idade > 25) & (df.estado == "SP")).show()
```

## 5. Transformações Comuns

```python
from pyspark.sql.functions import col, when, upper, lower

# Adicionar nova coluna
df_novo = df.withColumn("categoria", 
    when(col("idade") < 30, "Jovem")
    .when(col("idade") < 40, "Adulto")
    .otherwise("Sênior")
)

# Renomear coluna
df_renomeado = df.withColumnRenamed("nome", "nome_completo")

# Transformar texto
df.withColumn("nome_upper", upper(col("nome"))).show()
```

## 6. Agrupamentos e Agregações

```python
from pyspark.sql.functions import count, avg, max, min, sum

# Agrupar por estado
df.groupBy("estado").count().show()

# Múltiplas agregações
df.groupBy("estado").agg(
    count("nome").alias("total_pessoas"),
    avg("idade").alias("idade_media"),
    max("idade").alias("idade_maxima")
).show()
```

## 7. Ordenação

```python
from pyspark.sql.functions import desc

# Ordenar crescente
df.orderBy("idade").show()

# Ordenar decrescente
df.orderBy(desc("idade")).show()

# Múltiplas colunas
df.orderBy("estado", desc("idade")).show()
```

## 8. Joins

```python
# Criar segundo DataFrame
dados2 = [("SP", "São Paulo"), ("RJ", "Rio de Janeiro"), ("MG", "Minas Gerais")]
df_estados = spark.createDataFrame(dados2, ["sigla", "nome_estado"])

# Inner join
resultado = df.join(df_estados, df.estado == df_estados.sigla, "inner")
resultado.show()

# Left join
resultado_left = df.join(df_estados, df.estado == df_estados.sigla, "left")
```

## 9. Salvando Dados

```python
# Salvar como CSV
df.write.mode("overwrite") \
    .option("header", "true") \
    .csv("caminho/saida")

# Salvar como Parquet (recomendado)
df.write.mode("overwrite").parquet("caminho/saida.parquet")

# Salvar como JSON
df.write.mode("overwrite").json("caminho/saida.json")
```

## 10. SQL Queries

```python
# Registrar DataFrame como tabela temporária
df.createOrReplaceTempView("pessoas")

# Executar SQL
resultado_sql = spark.sql("""
    SELECT estado, COUNT(*) as total, AVG(idade) as idade_media
    FROM pessoas 
    WHERE idade > 25
    GROUP BY estado
    ORDER BY total DESC
""")

resultado_sql.show()
```

## 11. Cache e Persist

```python
# Cache para reutilizar DataFrame
df_cache = df.filter(df.idade > 25).cache()
df_cache.count()  # Primeira execução carrega no cache
df_cache.show()   # Segunda execução usa cache

# Remover do cache
df_cache.unpersist()
```

## 12. Window Functions (Funções de Janela)

### Conceito Básico
Window Functions permitem cálculos sobre um conjunto de linhas relacionadas à linha atual.

```python
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number, rank, dense_rank, lag, lead, sum, avg, max, min

# Dados de exemplo - vendas por vendedor
vendas = [
    ("João", "2023-01", 1000), ("João", "2023-02", 1500), ("João", "2023-03", 1200),
    ("Maria", "2023-01", 1100), ("Maria", "2023-02", 1300), ("Maria", "2023-03", 1400),
    ("Pedro", "2023-01", 900), ("Pedro", "2023-02", 1600), ("Pedro", "2023-03", 1100)
]
df_vendas = spark.createDataFrame(vendas, ["vendedor", "mes", "valor"])
```

### Ranking Functions

```python
# Definir janela para ranking por valor total
window_rank = Window.orderBy(col("valor").desc())

df_ranking = df_vendas.withColumn("row_number", row_number().over(window_rank)) \
    .withColumn("rank", rank().over(window_rank)) \
    .withColumn("dense_rank", dense_rank().over(window_rank))

df_ranking.show()
```

### Particionamento por Vendedor

```python
# Ranking dentro de cada vendedor
window_vendedor = Window.partitionBy("vendedor").orderBy("mes")

df_vendedor_rank = df_vendas.withColumn("rank_vendedor", 
    row_number().over(window_vendedor))

df_vendedor_rank.show()
```

### Lag e Lead (Valores Anteriores/Posteriores)

```python
# Comparar com mês anterior e posterior
window_temporal = Window.partitionBy("vendedor").orderBy("mes")

df_temporal = df_vendas.withColumn("valor_anterior", lag("valor", 1).over(window_temporal)) \
    .withColumn("valor_posterior", lead("valor", 1).over(window_temporal)) \
    .withColumn("diferenca_anterior", 
        col("valor") - lag("valor", 1).over(window_temporal))

df_temporal.show()
```

### Agregações Móveis (Rolling)

```python
# Janela móvel de 2 meses
window_rolling = Window.partitionBy("vendedor") \
    .orderBy("mes") \
    .rowsBetween(-1, 0)  # Linha anterior até atual

df_rolling = df_vendas.withColumn("media_movel_2m", 
    avg("valor").over(window_rolling)) \
    .withColumn("soma_movel_2m", 
        sum("valor").over(window_rolling))

df_rolling.show()
```

### Agregações Cumulativas

```python
# Soma cumulativa
window_cumulative = Window.partitionBy("vendedor") \
    .orderBy("mes") \
    .rowsBetween(Window.unboundedPreceding, Window.currentRow)

df_cumulative = df_vendas.withColumn("soma_cumulativa", 
    sum("valor").over(window_cumulative)) \
    .withColumn("media_cumulativa", 
        avg("valor").over(window_cumulative))

df_cumulative.show()
```

### Percentis e Quartis

```python
from pyspark.sql.functions import percent_rank, ntile

# Percentil e quartis
window_percentil = Window.orderBy("valor")

df_percentil = df_vendas.withColumn("percentil", 
    percent_rank().over(window_percentil)) \
    .withColumn("quartil", 
        ntile(4).over(window_percentil))

df_percentil.show()
```

### Exemplo Complexo - Análise de Performance

```python
# Análise completa de performance de vendas
window_geral = Window.orderBy(col("valor").desc())
window_vendedor = Window.partitionBy("vendedor").orderBy("mes")
window_mes = Window.partitionBy("mes").orderBy(col("valor").desc())

df_analise = df_vendas \
    .withColumn("rank_geral", rank().over(window_geral)) \
    .withColumn("rank_no_mes", rank().over(window_mes)) \
    .withColumn("crescimento", 
        ((col("valor") - lag("valor", 1).over(window_vendedor)) / 
         lag("valor", 1).over(window_vendedor) * 100)) \
    .withColumn("melhor_mes", 
        when(col("valor") == max("valor").over(
            Window.partitionBy("vendedor")), "SIM").otherwise("NÃO")) \
    .withColumn("acumulado_vendedor", 
        sum("valor").over(
            Window.partitionBy("vendedor")
            .orderBy("mes")
            .rowsBetween(Window.unboundedPreceding, Window.currentRow)))

df_analise.show()
```

### Dicas para Window Functions

- **Performance**: Use particionamento adequado para evitar shuffling excessivo
- **Ordenação**: Sempre defina ordenação clara para resultados consistentes
- **Frames**: Entenda a diferença entre `rowsBetween` e `rangeBetween`
- **Null Values**: Window functions lidam bem com valores nulos

## 13. Finalizando a Sessão

```python
# Sempre fechar a sessão ao final
spark.stop()
```

## Dicas Importantes

- **Lazy Evaluation**: Transformações só executam quando há uma ação (show, count, collect)
- **Evite collect()**: Traz todos os dados para o driver, pode causar OutOfMemory
- **Use cache()**: Para DataFrames reutilizados múltiplas vezes
- **Prefira Parquet**: Formato mais eficiente que CSV
- **Particionamento**: Use `.repartition()` ou `.coalesce()` para otimizar performance

## Exemplo Completo

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count

# Inicializar
spark = SparkSession.builder.appName("ExemploCompleto").getOrCreate()

# Criar dados
dados = [("João", 25, "SP", 5000), ("Maria", 30, "RJ", 6000), 
         ("Pedro", 35, "MG", 5500), ("Ana", 28, "SP", 5800)]
df = spark.createDataFrame(dados, ["nome", "idade", "estado", "salario"])

# Processar
resultado = df.filter(col("idade") > 25) \
    .groupBy("estado") \
    .agg(count("nome").alias("total"), 
         avg("salario").alias("salario_medio")) \
    .orderBy("total")

# Mostrar resultado
resultado.show()

# Finalizar
spark.stop()
```