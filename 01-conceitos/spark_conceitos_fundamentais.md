# Spark - Conceitos Fundamentais e Performance

## 1. Arquitetura do Spark

### Componentes Principais

**Driver Program**
- Contém a função `main()` da aplicação
- Cria o SparkContext/SparkSession
- Converte código em DAG (Directed Acyclic Graph)
- Coordena a execução dos jobs

**Cluster Manager**
- Gerencia recursos do cluster
- Tipos: Standalone, YARN, Mesos, Kubernetes
- Aloca executors para a aplicação

**Executors**
- Processos JVM que executam tarefas
- Armazenam dados em cache
- Reportam status para o driver
- Cada executor tem múltiplas cores/threads

```
Driver Program
    ↓
Cluster Manager
    ↓
Executor 1    Executor 2    Executor N
[Task][Task]  [Task][Task]  [Task][Task]
```

## 2. RDD, DataFrame e Dataset

### RDD (Resilient Distributed Dataset)
- **Imutável**: Não pode ser modificado após criação
- **Distribuído**: Particionado através do cluster
- **Resiliente**: Pode ser reconstruído em caso de falha
- **Lazy Evaluation**: Transformações só executam com ações

### DataFrame
- RDD com schema estruturado
- Otimizações do Catalyst Optimizer
- API mais amigável (SQL-like)
- Melhor performance que RDD

### Dataset
- Type-safe (apenas Scala/Java)
- Combina benefícios de RDD e DataFrame
- Compile-time type checking

## 3. Lazy Evaluation e DAG

### Conceito
- **Transformações**: Lazy (map, filter, join)
- **Ações**: Eager (collect, count, save)
- **DAG**: Grafo de dependências entre RDDs

### Benefícios
```python
# Exemplo de otimização
df.filter(col("age") > 25) \
  .select("name", "salary") \
  .filter(col("salary") > 50000) \
  .count()  # Só aqui executa tudo

# Spark otimiza: aplica ambos filtros antes da seleção
```

### Stages e Tasks
- **Job**: Ação que dispara execução
- **Stage**: Conjunto de transformações sem shuffle
- **Task**: Menor unidade de trabalho (1 por partição)

## 4. Particionamento

### Conceitos Básicos
- **Partição**: Divisão lógica dos dados
- **Paralelismo**: 1 task por partição
- **Regra geral**: 2-4 partições por core

### Tipos de Particionamento

**Hash Partitioning (padrão)**
```python
# Controlar número de partições
df.repartition(8)  # Força redistribuição
df.coalesce(4)     # Reduz partições (sem shuffle)

# Ver partições atuais
print(f"Partições: {df.rdd.getNumPartitions()}")
```

**Range Partitioning**
```python
# Particionar por range de valores
df.repartitionByRange(4, "idade")
```

**Custom Partitioning**
```python
# Particionar por coluna específica
df.repartition("estado")  # Dados do mesmo estado na mesma partição
```

### Boas Práticas
- Evitar partições muito pequenas (<128MB) ou muito grandes (>1GB)
- Usar `coalesce()` para reduzir partições
- Usar `repartition()` para aumentar ou redistribuir

## 5. Shuffling - O Vilão da Performance

### O que é Shuffle
- Redistribuição de dados entre partições
- Operação custosa (rede + disco)
- Quebra o pipeline de execução

### Operações que Causam Shuffle
```python
# Operações com shuffle
df.groupBy("categoria").count()        # GroupBy
df1.join(df2, "id")                   # Join
df.orderBy("valor")                   # OrderBy
df.repartition(10)                    # Repartition
df.distinct()                         # Distinct

# Operações sem shuffle
df.filter(col("idade") > 25)          # Filter
df.select("nome", "idade")            # Select
df.withColumn("novo", col("a") + 1)   # WithColumn
```

### Minimizando Shuffle

**1. Filtrar Antes de Agrupar**
```python
# ❌ Ruim
df.groupBy("categoria").count().filter(col("count") > 100)

# ✅ Melhor
df.filter(col("ativo") == True).groupBy("categoria").count()
```

**2. Broadcast Joins**
```python
from pyspark.sql.functions import broadcast

# Para tabelas pequenas (<200MB)
df_grande.join(broadcast(df_pequeno), "id")
```

**3. Bucketing**
```python
# Pré-particionar dados por join key
df.write.bucketBy(10, "user_id").saveAsTable("users_bucketed")
```

## 6. Catalyst Optimizer

### Fases de Otimização

1. **Logical Plan**: Análise sintática
2. **Optimized Logical Plan**: Aplicação de regras
3. **Physical Plans**: Estratégias de execução
4. **Code Generation**: Geração de código Java

### Otimizações Principais

**Predicate Pushdown**
```python
# Spark empurra filtros para a fonte
df.filter(col("ano") == 2023)  # Filtro aplicado na leitura
```

**Projection Pushdown**
```python
# Só lê colunas necessárias
df.select("nome", "idade")  # Outras colunas ignoradas
```

**Constant Folding**
```python
# Spark calcula constantes em compile-time
df.filter(col("valor") > 10 + 5)  # Vira col("valor") > 15
```

## 7. Spark UI - Monitoramento

### Acessando a UI
- **URL padrão**: http://localhost:4040
- **History Server**: Para aplicações finalizadas

### Abas Principais

**Jobs Tab**
- Lista de jobs executados
- Duração e status
- Número de stages e tasks

**Stages Tab**
- Detalhes de cada stage
- Tempo de execução por task
- Shuffle read/write
- Identificação de bottlenecks

**Storage Tab**
- RDDs/DataFrames em cache
- Uso de memória
- Nível de persistência

**Executors Tab**
- Status dos executors
- Uso de CPU e memória
- Garbage collection
- Tasks ativas/completas

**SQL Tab**
- Queries SQL executadas
- Planos de execução
- Métricas de performance

### Métricas Importantes
```
Stage Metrics:
- Duration: Tempo total do stage
- Shuffle Read: Dados lidos de outros stages
- Shuffle Write: Dados escritos para próximos stages
- GC Time: Tempo gasto em garbage collection

Task Metrics:
- Task Time: Tempo de execução individual
- Scheduler Delay: Tempo esperando para executar
- Data Locality: LOCAL_PROCESS > NODE_LOCAL > RACK_LOCAL > ANY
```

## 8. Configurações de Performance

### Configurações de Memória

```python
spark = SparkSession.builder \
    .appName("OptimizedApp") \
    .config("spark.executor.memory", "4g") \
    .config("spark.executor.cores", "4") \
    .config("spark.sql.adaptive.enabled", "true") \
    .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
    .getOrCreate()
```

### Configurações Importantes

**Adaptive Query Execution (AQE)**
```python
# Otimizações dinâmicas durante execução
"spark.sql.adaptive.enabled": "true"
"spark.sql.adaptive.coalescePartitions.enabled": "true"
"spark.sql.adaptive.skewJoin.enabled": "true"
```

**Broadcast Threshold**
```python
# Tamanho máximo para broadcast joins (padrão: 10MB)
"spark.sql.autoBroadcastJoinThreshold": "200MB"
```

**Serialização**
```python
# Usar Kryo para melhor performance
"spark.serializer": "org.apache.spark.serializer.KryoSerializer"
```

## 9. Cache e Persistência

### Níveis de Storage

```python
from pyspark import StorageLevel

# Opções de cache
df.cache()                                    # MEMORY_AND_DISK
df.persist(StorageLevel.MEMORY_ONLY)         # Só memória
df.persist(StorageLevel.DISK_ONLY)           # Só disco
df.persist(StorageLevel.MEMORY_AND_DISK_SER) # Serializado
```

### Quando Usar Cache

```python
# ✅ Bom uso de cache
df_filtrado = df.filter(col("ativo") == True).cache()
resultado1 = df_filtrado.groupBy("categoria").count()
resultado2 = df_filtrado.groupBy("regiao").avg("valor")

# ❌ Cache desnecessário
df.cache().count()  # Usado apenas uma vez
```

### Gerenciamento de Cache

```python
# Verificar o que está em cache
spark.catalog.cacheTable("minha_tabela")
spark.catalog.isCached("minha_tabela")

# Limpar cache
df.unpersist()
spark.catalog.clearCache()
```

## 10. Debugging e Troubleshooting

### Problemas Comuns

**OutOfMemoryError**
- Aumentar `spark.executor.memory`
- Reduzir `spark.sql.shuffle.partitions`
- Usar `persist()` com `DISK_ONLY`

**Slow Performance**
- Verificar data skew na Spark UI
- Otimizar particionamento
- Usar broadcast joins
- Habilitar AQE

**Too Many Small Files**
- Usar `coalesce()` antes de salvar
- Configurar `spark.sql.files.maxPartitionBytes`

### Logs e Debugging

```python
# Configurar nível de log
spark.sparkContext.setLogLevel("WARN")

# Ver plano de execução
df.explain(True)  # Mostra todos os planos

# Coletar métricas
df.count()  # Força execução para ver métricas na UI
```

## 11. Boas Práticas Resumidas

### Performance
1. **Filtrar cedo**: Aplique filtros o mais cedo possível
2. **Evitar shuffle**: Use broadcast joins para tabelas pequenas
3. **Particionar adequadamente**: 2-4 partições por core
4. **Cache inteligente**: Só para dados reutilizados
5. **Usar AQE**: Habilite otimizações adaptativas

### Desenvolvimento
1. **Monitorar Spark UI**: Sempre verifique métricas
2. **Testar com dados pequenos**: Valide lógica antes de escalar
3. **Usar explain()**: Entenda o plano de execução
4. **Configurar adequadamente**: Ajuste memória e cores
5. **Limpar recursos**: Sempre feche sessões

### Produção
1. **Monitoramento contínuo**: Use ferramentas de observabilidade
2. **Configurações específicas**: Ajuste para workload
3. **Gestão de recursos**: Implemente resource quotas
4. **Backup e recovery**: Estratégias de falha
5. **Versionamento**: Controle de versões do código

## 12. Formatos de Arquivo Modernos

### Parquet - O Padrão para Analytics

**Características**
- Formato colunar binário
- Compressão eficiente (Snappy, GZIP, LZ4)
- Schema evolution suportado
- Predicate pushdown nativo
- Ideal para workloads analíticos

**Vantagens**
```python
# Leitura eficiente - só lê colunas necessárias
df = spark.read.parquet("dados.parquet")
df.select("nome", "idade").show()  # Só lê essas colunas

# Filtros aplicados no arquivo
df.filter(col("ano") == 2023).count()  # Filtro pushdown

# Compressão automática
df.write.option("compression", "snappy").parquet("output")
```

**Particionamento com Parquet**
```python
# Particionar por colunas para melhor performance
df.write.partitionBy("ano", "mes").parquet("dados_particionados")

# Leitura eficiente de partições específicas
df_2023 = spark.read.parquet("dados_particionados/ano=2023")
```

### ORC (Optimized Row Columnar)

**Características**
- Formato colunar otimizado para Hive
- Compressão superior ao Parquet
- Índices integrados (bloom filters, min/max)
- ACID transactions (com Hive)
- Melhor para workloads Hadoop/Hive

**Uso com Spark**
```python
# Leitura e escrita ORC
df = spark.read.orc("dados.orc")
df.write.orc("output.orc")

# Configurações específicas
df.write.option("compression", "zlib").orc("compressed_output")
```

**Comparação Parquet vs ORC**
```
Parquet:
✅ Melhor ecosistema (Python, R, etc.)
✅ Schema evolution mais flexível
✅ Melhor para Spark/cloud

ORC:
✅ Compressão superior
✅ Índices mais avançados
✅ Melhor para Hive/Hadoop
```

### Apache Iceberg - Table Format Moderno

**Conceitos Fundamentais**
- **Table Format**: Camada sobre Parquet/ORC
- **ACID Transactions**: Operações atômicas
- **Time Travel**: Acesso a versões históricas
- **Schema Evolution**: Mudanças seguras de schema
- **Hidden Partitioning**: Particionamento transparente

**Configuração Iceberg**
```python
# Configurar Spark para Iceberg
spark = SparkSession.builder \
    .appName("IcebergApp") \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
    .config("spark.sql.catalog.spark_catalog.type", "hive") \
    .getOrCreate()
```

**Operações Iceberg**
```python
# Criar tabela Iceberg
spark.sql("""
    CREATE TABLE vendas_iceberg (
        id BIGINT,
        produto STRING,
        valor DECIMAL(10,2),
        data_venda DATE
    ) USING ICEBERG
    PARTITIONED BY (data_venda)
""")

# Insert/Update/Delete (ACID)
spark.sql("INSERT INTO vendas_iceberg VALUES (1, 'Produto A', 100.50, '2023-01-01')")
spark.sql("UPDATE vendas_iceberg SET valor = 120.00 WHERE id = 1")
spark.sql("DELETE FROM vendas_iceberg WHERE id = 1")

# Time Travel
spark.sql("SELECT * FROM vendas_iceberg TIMESTAMP AS OF '2023-01-01 10:00:00'")
spark.sql("SELECT * FROM vendas_iceberg VERSION AS OF 1")

# Schema Evolution
spark.sql("ALTER TABLE vendas_iceberg ADD COLUMN categoria STRING")
```

**Vantagens do Iceberg**
```python
# Hidden Partitioning - sem partition pruning manual
df.write.writeTo("vendas_iceberg").append()  # Particionamento automático

# Compaction automático
spark.sql("CALL spark_catalog.system.rewrite_data_files('vendas_iceberg')")

# Snapshot management
spark.sql("CALL spark_catalog.system.expire_snapshots('vendas_iceberg', TIMESTAMP '2023-01-01')")
```

### Delta Lake - Lakehouse Platform

**Características**
- **ACID Transactions**: Garantias de consistência
- **Unified Batch/Streaming**: Mesmo formato para ambos
- **Time Travel**: Versioning automático
- **Schema Enforcement**: Validação de schema
- **DML Operations**: UPDATE, DELETE, MERGE

**Configuração Delta**
```python
# Instalar: pip install delta-spark
from delta import configure_spark_with_delta_pip

spark = configure_spark_with_delta_pip(SparkSession.builder \
    .appName("DeltaApp") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")) \
    .getOrCreate()
```

**Operações Delta**
```python
from delta.tables import DeltaTable

# Criar tabela Delta
df.write.format("delta").save("/path/to/delta-table")

# Ler tabela Delta
df_delta = spark.read.format("delta").load("/path/to/delta-table")

# Operações DML
delta_table = DeltaTable.forPath(spark, "/path/to/delta-table")

# UPDATE
delta_table.update(
    condition = col("id") == 1,
    set = {"valor": col("valor") * 1.1}
)

# DELETE
delta_table.delete(col("ativo") == False)

# MERGE (Upsert)
delta_table.alias("target").merge(
    df_updates.alias("source"),
    "target.id = source.id"
).whenMatchedUpdate(set = {
    "valor": "source.valor",
    "updated_at": "current_timestamp()"
}).whenNotMatchedInsert(values = {
    "id": "source.id",
    "valor": "source.valor",
    "created_at": "current_timestamp()"
}).execute()
```

**Time Travel Delta**
```python
# Por versão
df_v1 = spark.read.format("delta").option("versionAsOf", 1).load("/path/to/delta-table")

# Por timestamp
df_yesterday = spark.read.format("delta") \
    .option("timestampAsOf", "2023-01-01") \
    .load("/path/to/delta-table")

# Histórico de versões
delta_table.history().show()
```

**Streaming com Delta**
```python
# Streaming write
df_stream.writeStream \
    .format("delta") \
    .outputMode("append") \
    .option("checkpointLocation", "/path/to/checkpoint") \
    .start("/path/to/delta-table")

# Streaming read
df_stream = spark.readStream \
    .format("delta") \
    .load("/path/to/delta-table")
```

### Comparação dos Formatos

| Característica | Parquet | ORC | Iceberg | Delta |
|----------------|---------|-----|---------|-------|
| **Tipo** | File Format | File Format | Table Format | Table Format |
| **ACID** | ❌ | ❌ | ✅ | ✅ |
| **Time Travel** | ❌ | ❌ | ✅ | ✅ |
| **Schema Evolution** | Limitado | Limitado | ✅ | ✅ |
| **DML Operations** | ❌ | ❌ | ✅ | ✅ |
| **Streaming** | ❌ | ❌ | ✅ | ✅ |
| **Ecosistema** | Amplo | Hadoop | Crescendo | Databricks |
| **Performance** | Excelente | Excelente | Muito Boa | Muito Boa |

### Quando Usar Cada Formato

**Parquet**
- Workloads analíticos tradicionais
- Dados imutáveis
- Máxima compatibilidade
- Data warehousing clássico

**ORC**
- Ambientes Hive/Hadoop
- Necessidade de máxima compressão
- Workloads com muitos filtros

**Iceberg**
- Necessidade de ACID transactions
- Schema evolution frequente
- Workloads com updates/deletes
- Multi-engine access (Spark, Flink, etc.)

**Delta Lake**
- Lakehouse architecture
- Streaming + batch unificado
- Necessidade de DML operations
- Ecossistema Databricks

### Migração entre Formatos

```python
# Parquet para Delta
df_parquet = spark.read.parquet("dados.parquet")
df_parquet.write.format("delta").save("dados_delta")

# Delta para Iceberg
df_delta = spark.read.format("delta").load("dados_delta")
df_delta.writeTo("iceberg_catalog.db.tabela").create()

# Parquet para Iceberg com particionamento
df_parquet.writeTo("iceberg_catalog.db.tabela") \
    .partitionedBy("ano", "mes") \
    .create()
```

### Boas Práticas para Formatos Modernos

**Iceberg**
```python
# Configurar compaction automático
spark.conf.set("spark.sql.iceberg.planning.preserve-data-grouping", "true")

# Otimizar queries com Z-ordering
spark.sql("CALL spark_catalog.system.rewrite_data_files('table', strategy => 'sort', sort_order => 'id,timestamp')")
```

**Delta Lake**
```python
# Otimizar tabela
spark.sql("OPTIMIZE delta_table ZORDER BY (id, timestamp)")

# Vacuum para limpar arquivos antigos
spark.sql("VACUUM delta_table RETAIN 168 HOURS")  # 7 dias

# Auto-optimize
spark.conf.set("spark.databricks.delta.autoOptimize.optimizeWrite", "true")
```

---

*Este guia cobre os conceitos fundamentais para entender e otimizar aplicações Spark. Para aprofundamento, consulte a documentação oficial e pratique com datasets reais.*