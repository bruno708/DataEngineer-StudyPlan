# Data Engineer Study Plan 📊

Um plano de estudos completo para Engenharia de Dados, focado em Apache Spark, PySpark e SQL.

## 📁 Estrutura do Projeto

```
DataEngineer-StudyPlan/
├── 01-conceitos/              # Fundamentos teóricos
│   ├── spark_conceitos_fundamentais.md
│   └── sql_conceitos_fundamentais.md
├── 02-guias-praticos/         # Guias práticos com exemplos
│   ├── pyspark_guia_pratico.md
│   └── sql_guia_pratico.md
├── 03-exercicios/             # Exercícios práticos e gabaritos
│   ├── exercicios_pyspark.md
│   ├── exercicios_sql.md
│   ├── gabarito_pyspark.md
│   └── gabarito_sql.md
├── 04-dados/                  # Datasets para exercícios
│   ├── vendas.csv
│   ├── funcionarios.csv
│   ├── clientes.csv
│   ├── produtos.csv
│   └── criar_tabelas.sql
└── README.md
```

## 🎯 Objetivos do Plano de Estudos

Este repositório foi criado para fornecer um caminho estruturado de aprendizado em Engenharia de Dados, cobrindo:

- **Fundamentos teóricos** sólidos em Spark e SQL
- **Exemplos práticos** executáveis
- **Exercícios progressivos** (básico → intermediário → avançado)
- **Datasets reais** para prática
- **Gabaritos detalhados** com explicações

## 📚 Conteúdo Detalhado

### 01 - Conceitos Fundamentais

#### 🔥 Spark Conceitos Fundamentais
- Arquitetura do Spark (Driver, Executors, Cluster Manager)
- RDDs, DataFrames e Datasets
- Lazy Evaluation e DAG
- Particionamento e Shuffling
- Catalyst Optimizer
- Spark UI e Monitoramento
- Cache e Persistência
- Formatos de arquivo (Parquet, ORC, Delta, Iceberg)

#### 🗃️ SQL Conceitos Fundamentais
- Modelo Relacional e Normalização
- Álgebra Relacional
- Arquitetura de SGBD
- Processamento e Otimização de Consultas
- Índices e Performance
- Transações ACID
- Data Warehousing e OLAP
- Segurança e Auditoria

### 02 - Guias Práticos

#### ⚡ PySpark Guia Prático
- Configuração do ambiente
- Operações básicas com DataFrames
- Transformações e Ações
- Window Functions
- Joins e Agregações
- UDFs (User Defined Functions)
- Streaming e Machine Learning
- Otimização de Performance

#### 📊 SQL Guia Prático
- Consultas básicas e avançadas
- JOINs e Subconsultas
- Window Functions e CTEs
- Funções de agregação
- Manipulação de strings e datas
- Índices e otimização
- Transações e controle de concorrência

### 03 - Exercícios Práticos

#### Níveis de Dificuldade:

**🟢 Básico**
- Operações fundamentais
- Filtros e agregações simples
- JOINs básicos

**🟡 Intermediário**
- Window Functions
- Análises temporais
- Transformações complexas
- Otimização de queries

**🔴 Avançado**
- Machine Learning
- Sistemas de recomendação
- Data Warehousing
- ETL complexo
- Análise preditiva

### 04 - Dados para Prática

**Datasets incluídos:**
- `vendas.csv` - Dados de vendas (20 registros)
- `funcionarios.csv` - Dados de funcionários (10 registros)
- `clientes.csv` - Dados de clientes (15 registros)
- `produtos.csv` - Dados de produtos (12 registros)
- `criar_tabelas.sql` - Script para criar tabelas SQL

## 🚀 Como Usar Este Repositório

### 1. **Estude os Conceitos**
```bash
# Comece pelos fundamentos
cat 01-conceitos/spark_conceitos_fundamentais.md
cat 01-conceitos/sql_conceitos_fundamentais.md
```

### 2. **Pratique com os Guias**
```bash
# Execute os exemplos práticos
cat 02-guias-praticos/pyspark_guia_pratico.md
cat 02-guias-praticos/sql_guia_pratico.md
```

### 3. **Resolva os Exercícios**
```bash
# Tente resolver antes de ver o gabarito
cat 03-exercicios/exercicios_pyspark.md
cat 03-exercicios/exercicios_sql.md
```

### 4. **Configure o Ambiente**

#### Para PySpark:
```bash
# Instalar dependências
pip install pyspark pandas numpy matplotlib seaborn

# Iniciar PySpark
pyspark
```

#### Para SQL:
```bash
# Executar script de criação das tabelas
psql -d seu_banco -f 04-dados/criar_tabelas.sql
```

## 🛠️ Pré-requisitos

- **Python 3.7+**
- **Apache Spark 3.0+**
- **PostgreSQL** (para exercícios SQL)
- **Jupyter Notebook** (recomendado)

### Instalação Rápida:
```bash
# Instalar PySpark
pip install pyspark

# Instalar PostgreSQL (macOS)
brew install postgresql

# Instalar Jupyter
pip install jupyter
```

## 📈 Progressão Sugerida

1. **Semana 1-2**: Conceitos fundamentais do Spark
2. **Semana 3-4**: Conceitos fundamentais de SQL
3. **Semana 5-6**: Guias práticos (PySpark + SQL)
4. **Semana 7-8**: Exercícios básicos
5. **Semana 9-10**: Exercícios intermediários
6. **Semana 11-12**: Exercícios avançados

## 🎯 Objetivos de Aprendizado

Ao completar este plano de estudos, você será capaz de:

- ✅ Compreender a arquitetura do Apache Spark
- ✅ Desenvolver aplicações PySpark eficientes
- ✅ Escrever queries SQL complexas e otimizadas
- ✅ Implementar pipelines de ETL
- ✅ Otimizar performance de aplicações de dados
- ✅ Trabalhar com diferentes formatos de arquivo
- ✅ Implementar soluções de Machine Learning
- ✅ Projetar Data Warehouses dimensionais

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:

- Reportar bugs ou erros
- Sugerir melhorias
- Adicionar novos exercícios
- Melhorar a documentação

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 📞 Contato

Para dúvidas ou sugestões:
- GitHub: [@bruno708](https://github.com/bruno708)
- Email: [seu-email@exemplo.com]

---

**Happy Learning! 🚀📊**

> "A jornada de mil milhas começa com um único passo" - Lao Tzu

Comece sua jornada em Engenharia de Dados hoje mesmo! 💪