# AWS para Engenharia de Dados - Conceitos Fundamentais ☁️

Guia completo dos principais serviços AWS para Engenheiros de Dados, cobrindo armazenamento, processamento, segurança e orquestração de dados.

## 📋 Índice

1. [Visão Geral da AWS para Dados](#visão-geral)
2. [Amazon S3 - Simple Storage Service](#amazon-s3)
3. [AWS KMS - Key Management Service](#aws-kms)
4. [Serviços de Processamento](#serviços-de-processamento)
5. [Serviços de Analytics](#serviços-de-analytics)
6. [Orquestração e Workflow](#orquestração-e-workflow)
7. [Monitoramento e Logging](#monitoramento-e-logging)
8. [Segurança e Compliance](#segurança-e-compliance)
9. [Arquiteturas de Referência](#arquiteturas-de-referência)
10. [Boas Práticas](#boas-práticas)

---

## 🌐 Visão Geral da AWS para Dados {#visão-geral}

### Pilares da Engenharia de Dados na AWS

1. **Ingestão**: Kinesis, DMS, DataSync
2. **Armazenamento**: S3, EFS, EBS
3. **Processamento**: EMR, Glue, Lambda, Batch
4. **Analytics**: Redshift, Athena, QuickSight
5. **Orquestração**: Step Functions, Airflow (MWAA)
6. **Segurança**: IAM, KMS, VPC
7. **Monitoramento**: CloudWatch, CloudTrail

### Modelo de Responsabilidade Compartilhada

**AWS Responsável por:**
- Infraestrutura física
- Segurança da nuvem
- Patches do sistema operacional
- Configuração de rede

**Cliente Responsável por:**
- Dados e criptografia
- Configuração de segurança
- Gerenciamento de identidade
- Configuração de aplicações

---

## 🪣 Amazon S3 - Simple Storage Service {#amazon-s3}

### Conceitos Fundamentais

**S3** é um serviço de armazenamento de objetos altamente escalável, durável e disponível.

#### Hierarquia S3
```
Bucket (Contêiner global único)
├── Prefix/Folder (Organização lógica)
│   ├── Object (Arquivo + Metadata)
│   │   ├── Key (Nome único)
│   │   ├── Version ID
│   │   └── Metadata
```

### Classes de Armazenamento S3

#### 1. **S3 Standard**
- **Uso**: Dados acessados frequentemente
- **Durabilidade**: 99.999999999% (11 9's)
- **Disponibilidade**: 99.99%
- **Latência**: Milissegundos
- **Custo**: Mais alto para armazenamento, menor para acesso

#### 2. **S3 Intelligent-Tiering**
- **Uso**: Padrões de acesso desconhecidos ou variáveis
- **Funcionalidade**: Move automaticamente entre tiers
- **Tiers**:
  - Frequent Access
  - Infrequent Access
  - Archive Instant Access
  - Archive Access
  - Deep Archive Access

#### 3. **S3 Standard-IA (Infrequent Access)**
- **Uso**: Dados acessados menos frequentemente
- **Disponibilidade**: 99.9%
- **Custo**: Menor armazenamento, maior acesso
- **Tempo mínimo**: 30 dias

#### 4. **S3 One Zone-IA**
- **Uso**: Dados não críticos, acessados raramente
- **Disponibilidade**: 99.5% (uma AZ)
- **Custo**: 20% menor que Standard-IA
- **Risco**: Perda se AZ falhar

#### 5. **S3 Glacier Instant Retrieval**
- **Uso**: Arquivamento com acesso instantâneo
- **Retrieval**: Milissegundos
- **Tempo mínimo**: 90 dias
- **Custo**: Muito baixo para armazenamento

#### 6. **S3 Glacier Flexible Retrieval**
- **Uso**: Backup e arquivamento
- **Retrieval**: 1-12 horas
- **Tempo mínimo**: 90 dias
- **Opções**: Expedited (1-5 min), Standard (3-5h), Bulk (5-12h)

#### 7. **S3 Glacier Deep Archive**
- **Uso**: Arquivamento de longo prazo
- **Retrieval**: 12-48 horas
- **Tempo mínimo**: 180 dias
- **Custo**: Mais baixo da AWS

### Lifecycle Policies

```json
{
  "Rules": [
    {
      "ID": "DataLakeLifecycle",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "data/"
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        },
        {
          "Days": 365,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ]
    }
  ]
}
```

### Recursos Avançados do S3

#### Versionamento
- Mantém múltiplas versões do mesmo objeto
- Proteção contra exclusão acidental
- Integração com MFA Delete

#### Cross-Region Replication (CRR)
- Replicação automática entre regiões
- Compliance e disaster recovery
- Redução de latência

#### Transfer Acceleration
- Usa CloudFront edge locations
- Acelera uploads para S3
- Ideal para uploads globais

#### Multipart Upload
- Upload de arquivos grandes (>100MB)
- Paralelização e resumo
- Melhora performance e confiabilidade

### S3 para Data Lakes

#### Estrutura Recomendada
```
data-lake-bucket/
├── raw/                    # Dados brutos
│   ├── year=2024/
│   ├── month=01/
│   └── day=15/
├── processed/              # Dados processados
│   ├── bronze/            # Limpeza básica
│   ├── silver/            # Transformações
│   └── gold/              # Dados analíticos
├── archive/               # Dados arquivados
└── temp/                  # Dados temporários
```

#### Particionamento
```
# Por data (Hive-style)
s3://bucket/table/year=2024/month=01/day=15/

# Por região
s3://bucket/sales/region=us-east/year=2024/

# Múltiplas dimensões
s3://bucket/events/year=2024/month=01/day=15/hour=14/
```

---

## 🔐 AWS KMS - Key Management Service {#aws-kms}

### Conceitos Fundamentais

**KMS** é um serviço gerenciado para criação e controle de chaves de criptografia.

#### Tipos de Chaves

1. **AWS Managed Keys**
   - Criadas e gerenciadas pela AWS
   - Rotação automática anual
   - Sem custo adicional
   - Formato: `aws/service-name`

2. **Customer Managed Keys (CMK)**
   - Criadas e gerenciadas pelo cliente
   - Controle total sobre políticas
   - Rotação opcional
   - Custo: $1/mês por chave

3. **AWS Owned Keys**
   - Propriedade da AWS
   - Usadas internamente
   - Não visíveis ao cliente

#### Tipos de Chaves por Material

1. **KMS Keys (HSM)**
   - Material gerado no HSM da AWS
   - FIPS 140-2 Level 2
   - Mais comum e econômico

2. **CloudHSM Keys**
   - Material gerado no CloudHSM
   - FIPS 140-2 Level 3
   - Controle exclusivo do HSM

3. **External Keys (BYOK)**
   - Material importado pelo cliente
   - Controle total sobre o material
   - Responsabilidade de backup

### Criptografia no S3 com KMS

#### Server-Side Encryption (SSE)

1. **SSE-S3**
   - Chaves gerenciadas pelo S3
   - AES-256
   - Transparente para o usuário

2. **SSE-KMS**
   - Chaves gerenciadas pelo KMS
   - Auditoria via CloudTrail
   - Controle granular de acesso

3. **SSE-C**
   - Chaves fornecidas pelo cliente
   - Cliente gerencia chaves
   - AWS não armazena chaves

#### Exemplo de Política KMS
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDataEngineers",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/DataEngineerRole"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```

### Envelope Encryption

```
1. KMS gera Data Encryption Key (DEK)
2. DEK criptografa os dados
3. KMS criptografa DEK com CMK
4. Armazena DEK criptografada com dados
5. Para descriptografar:
   - KMS descriptografa DEK
   - DEK descriptografa dados
```

---

## ⚙️ Serviços de Processamento {#serviços-de-processamento}

### AWS Glue

#### Componentes Principais

1. **Data Catalog**
   - Metastore centralizado
   - Schema discovery automático
   - Integração com Athena, EMR, Redshift

2. **ETL Jobs**
   - Spark-based transformations
   - Python ou Scala
   - Serverless execution

3. **Crawlers**
   - Descoberta automática de schema
   - Suporte para múltiplos formatos
   - Agendamento automático

4. **DataBrew**
   - Visual data preparation
   - No-code transformations
   - Profile e quality rules

#### Exemplo Glue Job
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="sales_db",
    table_name="raw_sales"
)

# Transform data
transformed = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("customer_id", "string", "customer_id", "string"),
        ("amount", "double", "amount", "double"),
        ("date", "string", "sale_date", "timestamp")
    ]
)

# Write to S3
glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={
        "path": "s3://processed-data/sales/",
        "partitionKeys": ["year", "month"]
    },
    format="parquet"
)

job.commit()
```

### Amazon EMR

#### Componentes
- **Master Node**: Coordena cluster
- **Core Nodes**: HDFS e processamento
- **Task Nodes**: Apenas processamento

#### Configurações

1. **EMR on EC2**
   - Controle total sobre instâncias
   - Customização completa
   - Gerenciamento manual

2. **EMR on EKS**
   - Kubernetes-based
   - Melhor isolamento
   - Integração com EKS

3. **EMR Serverless**
   - Sem gerenciamento de infraestrutura
   - Auto-scaling automático
   - Pay-per-use

#### Exemplo EMR Step
```json
{
  "Name": "Spark ETL Job",
  "ActionOnFailure": "TERMINATE_CLUSTER",
  "HadoopJarStep": {
    "Jar": "command-runner.jar",
    "Args": [
      "spark-submit",
      "--deploy-mode", "cluster",
      "--class", "com.company.DataProcessor",
      "s3://my-bucket/jars/data-processor.jar",
      "s3://input-bucket/data/",
      "s3://output-bucket/processed/"
    ]
  }
}
```

### AWS Lambda

#### Casos de Uso para Dados
- Triggers para S3 events
- Processamento de streaming
- APIs para dados
- Orquestração simples

#### Exemplo Lambda para S3
```python
import json
import boto3
import pandas as pd
from io import StringIO

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    # Get S3 event details
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Read CSV from S3
    obj = s3.get_object(Bucket=bucket, Key=key)
    df = pd.read_csv(StringIO(obj['Body'].read().decode('utf-8')))
    
    # Simple transformation
    df['processed_date'] = pd.Timestamp.now()
    df['amount_usd'] = df['amount'] * df['exchange_rate']
    
    # Write back to S3
    csv_buffer = StringIO()
    df.to_csv(csv_buffer, index=False)
    
    s3.put_object(
        Bucket='processed-bucket',
        Key=f'processed/{key}',
        Body=csv_buffer.getvalue()
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {len(df)} records')
    }
```

---

## 📊 Serviços de Analytics {#serviços-de-analytics}

### Amazon Athena

#### Características
- **Serverless**: Sem infraestrutura para gerenciar
- **SQL Standard**: ANSI SQL compatível
- **Pay-per-query**: Cobra por dados escaneados
- **Integração**: S3, Glue Data Catalog

#### Otimizações

1. **Particionamento**
```sql
-- Criar tabela particionada
CREATE TABLE sales_partitioned (
  customer_id string,
  amount double,
  product_id string
)
PARTITIONED BY (
  year int,
  month int,
  day int
)
STORED AS PARQUET
LOCATION 's3://my-bucket/sales/'

-- Query otimizada
SELECT customer_id, SUM(amount)
FROM sales_partitioned
WHERE year = 2024 AND month = 1
GROUP BY customer_id
```

2. **Columnar Formats**
```sql
-- Converter para Parquet
CREATE TABLE sales_parquet
WITH (
  format = 'PARQUET',
  external_location = 's3://my-bucket/sales-parquet/'
)
AS SELECT * FROM sales_csv
```

3. **Compression**
```sql
-- Usar compressão
CREATE TABLE sales_compressed
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY'
)
AS SELECT * FROM sales
```

### Amazon Redshift

#### Arquitetura
- **Leader Node**: Query planning e coordination
- **Compute Nodes**: Data storage e processing
- **Node Slices**: Parallel processing units

#### Tipos de Cluster

1. **Provisioned**
   - Instâncias dedicadas
   - Controle sobre configuração
   - Previsibilidade de custos

2. **Serverless**
   - Auto-scaling automático
   - Pay-per-use
   - Ideal para workloads variáveis

#### Distribution Styles

```sql
-- EVEN distribution
CREATE TABLE sales (
  sale_id INT,
  customer_id INT,
  amount DECIMAL(10,2)
)
DISTSTYLE EVEN;

-- KEY distribution
CREATE TABLE customers (
  customer_id INT,
  name VARCHAR(100)
)
DISTSTYLE KEY
DISTKEY (customer_id);

-- ALL distribution
CREATE TABLE products (
  product_id INT,
  name VARCHAR(100),
  category VARCHAR(50)
)
DISTSTYLE ALL;
```

#### Sort Keys

```sql
-- Compound sort key
CREATE TABLE events (
  event_id BIGINT,
  user_id INT,
  event_time TIMESTAMP,
  event_type VARCHAR(50)
)
COMPOUND SORTKEY (event_time, user_id);

-- Interleaved sort key
CREATE TABLE logs (
  log_id BIGINT,
  timestamp TIMESTAMP,
  level VARCHAR(10),
  message TEXT
)
INTERLEAVED SORTKEY (timestamp, level);
```

### Amazon QuickSight

#### Características
- **Serverless BI**: Sem infraestrutura
- **ML Insights**: Anomaly detection, forecasting
- **Embedded Analytics**: Integração em aplicações
- **Pay-per-session**: Modelo de preços flexível

#### Data Sources
- S3, Athena, Redshift
- RDS, Aurora
- SaaS applications
- On-premises databases

---

## 🔄 Orquestração e Workflow {#orquestração-e-workflow}

### AWS Step Functions

#### State Types

1. **Task**: Executa trabalho
2. **Choice**: Decisões condicionais
3. **Parallel**: Execução paralela
4. **Map**: Iteração sobre arrays
5. **Wait**: Delay temporal
6. **Pass**: Transformação de dados
7. **Fail/Succeed**: Estados terminais

#### Exemplo ETL Workflow
```json
{
  "Comment": "ETL Pipeline",
  "StartAt": "ValidateInput",
  "States": {
    "ValidateInput": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ValidateData",
      "Next": "ProcessData",
      "Catch": [{
        "ErrorEquals": ["ValidationError"],
        "Next": "HandleError"
      }]
    },
    "ProcessData": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "TransformCustomers",
          "States": {
            "TransformCustomers": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "customer-etl"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "TransformOrders",
          "States": {
            "TransformOrders": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "orders-etl"
              },
              "End": true
            }
          }
        }
      ],
      "Next": "LoadToWarehouse"
    },
    "LoadToWarehouse": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:LoadToRedshift",
      "End": true
    },
    "HandleError": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:SendAlert",
      "End": true
    }
  }
}
```

### Amazon MWAA (Managed Apache Airflow)

#### Características
- **Managed Airflow**: Sem gerenciamento de infraestrutura
- **Auto-scaling**: Workers automáticos
- **Security**: VPC, IAM integration
- **Monitoring**: CloudWatch integration

#### Exemplo DAG
```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.operators.s3 import S3KeySensor
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'daily_etl_pipeline',
    default_args=default_args,
    description='Daily ETL Pipeline',
    schedule_interval='0 2 * * *',  # 2 AM daily
    catchup=False
)

# Wait for input file
wait_for_file = S3KeySensor(
    task_id='wait_for_input_file',
    bucket_name='input-bucket',
    bucket_key='data/{{ ds }}/sales.csv',
    timeout=3600,
    poke_interval=300,
    dag=dag
)

# Validate data
validate_data = LambdaInvokeFunctionOperator(
    task_id='validate_data',
    function_name='validate-sales-data',
    payload='{"date": "{{ ds }}"}',
    dag=dag
)

# Transform data
transform_data = GlueJobOperator(
    task_id='transform_sales_data',
    job_name='sales-etl-job',
    script_args={
        '--input_path': 's3://input-bucket/data/{{ ds }}/',
        '--output_path': 's3://processed-bucket/sales/{{ ds }}/',
        '--date': '{{ ds }}'
    },
    dag=dag
)

# Load to warehouse
load_to_warehouse = LambdaInvokeFunctionOperator(
    task_id='load_to_redshift',
    function_name='load-sales-to-redshift',
    payload='{"date": "{{ ds }}"}',
    dag=dag
)

# Set dependencies
wait_for_file >> validate_data >> transform_data >> load_to_warehouse
```

---

## 📈 Monitoramento e Logging {#monitoramento-e-logging}

### Amazon CloudWatch

#### Métricas Importantes

1. **S3 Metrics**
   - BucketSizeBytes
   - NumberOfObjects
   - AllRequests
   - GetRequests
   - PutRequests

2. **Glue Metrics**
   - glue.driver.aggregate.numCompletedTasks
   - glue.driver.aggregate.numFailedTasks
   - glue.driver.BlockManager.disk.diskSpaceUsed_MB

3. **EMR Metrics**
   - IsIdle
   - CoreNodesRunning
   - AppsCompleted
   - AppsFailed

#### Custom Metrics
```python
import boto3
from datetime import datetime

cloudwatch = boto3.client('cloudwatch')

# Send custom metric
cloudwatch.put_metric_data(
    Namespace='DataPipeline/ETL',
    MetricData=[
        {
            'MetricName': 'RecordsProcessed',
            'Value': 1000000,
            'Unit': 'Count',
            'Timestamp': datetime.utcnow(),
            'Dimensions': [
                {
                    'Name': 'Pipeline',
                    'Value': 'sales-etl'
                },
                {
                    'Name': 'Environment',
                    'Value': 'production'
                }
            ]
        }
    ]
)
```

#### CloudWatch Alarms
```json
{
  "AlarmName": "ETL-Job-Failure",
  "AlarmDescription": "Alert when ETL job fails",
  "MetricName": "Errors",
  "Namespace": "AWS/Glue",
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 1,
  "Threshold": 1,
  "ComparisonOperator": "GreaterThanOrEqualToThreshold",
  "Dimensions": [
    {
      "Name": "JobName",
      "Value": "sales-etl-job"
    }
  ],
  "AlarmActions": [
    "arn:aws:sns:us-east-1:123456789012:data-alerts"
  ]
}
```

### AWS CloudTrail

#### Eventos Importantes
- API calls para S3, Glue, EMR
- Mudanças em políticas IAM
- Acesso a dados sensíveis
- Modificações em recursos

#### Exemplo Query CloudTrail
```sql
-- Athena query para CloudTrail logs
SELECT 
    eventtime,
    eventname,
    sourceipaddress,
    useragent,
    errorcode,
    errormessage
FROM cloudtrail_logs
WHERE 
    eventtime >= '2024-01-01'
    AND eventname LIKE '%S3%'
    AND errorcode IS NOT NULL
ORDER BY eventtime DESC
```

---

## 🔒 Segurança e Compliance {#segurança-e-compliance}

### AWS IAM (Identity and Access Management)

#### Princípios de Segurança

1. **Least Privilege**: Mínimas permissões necessárias
2. **Defense in Depth**: Múltiplas camadas de segurança
3. **Zero Trust**: Verificar sempre, nunca confiar
4. **Separation of Duties**: Dividir responsabilidades

#### Exemplo Política IAM para Data Engineer
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3DataAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::data-lake-bucket/*",
        "arn:aws:s3:::data-lake-bucket"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "GlueJobAccess",
      "Effect": "Allow",
      "Action": [
        "glue:StartJobRun",
        "glue:GetJobRun",
        "glue:GetJobRuns",
        "glue:BatchStopJobRun"
      ],
      "Resource": "arn:aws:glue:*:*:job/data-*"
    },
    {
      "Sid": "KMSAccess",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "arn:aws:kms:*:*:key/12345678-1234-1234-1234-123456789012",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": [
            "s3.us-east-1.amazonaws.com",
            "glue.us-east-1.amazonaws.com"
          ]
        }
      }
    }
  ]
}
```

### Data Classification

#### Níveis de Classificação

1. **Public**: Dados públicos
2. **Internal**: Uso interno da empresa
3. **Confidential**: Dados sensíveis
4. **Restricted**: Dados altamente sensíveis

#### Implementação com Tags
```json
{
  "TagSet": [
    {
      "Key": "DataClassification",
      "Value": "Confidential"
    },
    {
      "Key": "DataOwner",
      "Value": "finance-team"
    },
    {
      "Key": "RetentionPeriod",
      "Value": "7years"
    },
    {
      "Key": "ComplianceRequirement",
      "Value": "SOX"
    }
  ]
}
```

### AWS Macie

#### Funcionalidades
- **Data Discovery**: Encontra dados sensíveis
- **Classification**: Classifica automaticamente
- **Monitoring**: Monitora acesso a dados
- **Alerting**: Alertas de segurança

#### Tipos de Dados Detectados
- PII (Personally Identifiable Information)
- PHI (Protected Health Information)
- Financial data
- Credentials e tokens

---

## 🏗️ Arquiteturas de Referência {#arquiteturas-de-referência}

### Data Lake Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   Ingestion     │    │   Storage       │
│                 │    │                 │    │                 │
│ • Databases     │───▶│ • Kinesis       │───▶│ • S3 Raw        │
│ • APIs          │    │ • DMS           │    │ • S3 Processed  │
│ • Files         │    │ • Lambda        │    │ • S3 Curated    │
│ • Streaming     │    │ • Glue          │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Consumption   │    │   Analytics     │    │   Processing    │
│                 │    │                 │    │                 │
│ • QuickSight    │◀───│ • Athena        │◀───│ • Glue ETL      │
│ • Tableau       │    │ • Redshift      │    │ • EMR           │
│ • Applications  │    │ • SageMaker     │    │ • Lambda        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Modern Data Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     Governance Layer                        │
│  • IAM • KMS • CloudTrail • Macie • Lake Formation         │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────┐    ┌─────────▼─────────┐    ┌─────────────────┐
│   Streaming     │    │   Batch Processing │    │   Real-time     │
│                 │    │                    │    │                 │
│ • Kinesis       │    │ • Glue             │    │ • Lambda        │
│ • MSK           │    │ • EMR              │    │ • Kinesis       │
│ • Kinesis       │    │ • Step Functions   │    │ • Analytics     │
│   Analytics     │    │ • MWAA             │    │                 │
└─────────────────┘    └────────────────────┘    └─────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │     Data Lake (S3)    │
                    │                       │
                    │ • Bronze (Raw)        │
                    │ • Silver (Cleaned)    │
                    │ • Gold (Curated)      │
                    └───────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   Analytics Layer     │
                    │                       │
                    │ • Athena              │
                    │ • Redshift            │
                    │ • QuickSight          │
                    │ • SageMaker           │
                    └───────────────────────┘
```

### Lambda Architecture

```
┌─────────────────┐
│  Data Sources   │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Speed Layer    │    │  Batch Layer    │    │  Serving Layer  │
│                 │    │                 │    │                 │
│ • Kinesis       │    │ • S3            │    │ • DynamoDB      │
│ • Lambda        │    │ • Glue          │    │ • ElastiCache   │
│ • Real-time     │    │ • EMR           │    │ • API Gateway   │
│   Processing    │    │ • Historical    │    │ • Applications  │
│                 │    │   Processing    │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────▲───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Batch Views         │
                    │   (Precomputed)         │
                    └─────────────────────────┘
```

---

## ✅ Boas Práticas {#boas-práticas}

### Segurança

1. **Encryption Everywhere**
   - Dados em trânsito (TLS/SSL)
   - Dados em repouso (KMS)
   - Chaves rotacionadas regularmente

2. **Access Control**
   - Princípio do menor privilégio
   - MFA para acesso administrativo
   - Auditoria de acessos

3. **Network Security**
   - VPC endpoints para serviços AWS
   - Security groups restritivos
   - NACLs quando necessário

### Performance

1. **S3 Optimization**
   - Usar formatos colunares (Parquet, ORC)
   - Implementar particionamento
   - Configurar lifecycle policies
   - Usar Transfer Acceleration

2. **Query Optimization**
   - Particionar dados por colunas de filtro
   - Usar compressão adequada
   - Limitar escaneamento de dados
   - Implementar caching

3. **Cost Optimization**
   - Monitorar custos regularmente
   - Usar Spot instances para EMR
   - Implementar auto-scaling
   - Arquivar dados antigos

### Governança

1. **Data Catalog**
   - Documentar todos os datasets
   - Manter metadados atualizados
   - Implementar data lineage
   - Definir data owners

2. **Quality Assurance**
   - Validação de dados na ingestão
   - Monitoramento de qualidade
   - Alertas para anomalias
   - Testes automatizados

3. **Compliance**
   - Classificar dados por sensibilidade
   - Implementar retenção de dados
   - Auditoria de acessos
   - Documentar processos

### Monitoramento

1. **Observability**
   - Logs estruturados
   - Métricas customizadas
   - Distributed tracing
   - Alertas proativos

2. **Performance Monitoring**
   - Latência de queries
   - Throughput de pipelines
   - Utilização de recursos
   - Custos por workload

### Disaster Recovery

1. **Backup Strategy**
   - Cross-region replication
   - Point-in-time recovery
   - Backup automatizado
   - Testes de restore

2. **High Availability**
   - Multi-AZ deployments
   - Auto-scaling groups
   - Health checks
   - Failover automático

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [AWS Data Analytics](https://aws.amazon.com/big-data/datalakes-and-analytics/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Security Best Practices](https://aws.amazon.com/security/)

### Certificações Relevantes
- **AWS Certified Data Engineer - Associate**
- **AWS Certified Solutions Architect**
- **AWS Certified Security - Specialty**
- **AWS Certified Machine Learning - Specialty**

### Ferramentas de Terceiros
- **dbt**: Transformações SQL
- **Apache Airflow**: Orquestração
- **Terraform**: Infrastructure as Code
- **DataDog**: Monitoramento

---

## 🎯 Conclusão

A AWS oferece um ecossistema completo para Engenharia de Dados, desde ingestão até visualização. O sucesso depende de:

1. **Arquitetura bem planejada**
2. **Segurança desde o design**
3. **Otimização contínua**
4. **Monitoramento proativo**
5. **Governança de dados**

Com esses conceitos e práticas, você estará preparado para construir soluções robustas e escaláveis de dados na AWS! 🚀

---

**Happy Data Engineering! ☁️📊**