-- Script para criar as tabelas dos exercícios SQL
-- Execute este script antes de fazer os exercícios

-- Tabela de Funcionários
CREATE TABLE funcionarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    data_contratacao DATE NOT NULL,
    idade INT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Tabela de Vendas
CREATE TABLE vendas (
    id INT PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade INT NOT NULL,
    data_venda DATE NOT NULL,
    vendedor_id INT NOT NULL,
    regiao VARCHAR(50) NOT NULL,
    FOREIGN KEY (vendedor_id) REFERENCES funcionarios(id)
);

-- Tabela de Clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    data_cadastro DATE NOT NULL,
    tipo_cliente VARCHAR(20) NOT NULL CHECK (tipo_cliente IN ('Individual', 'Corporativo'))
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    subcategoria VARCHAR(50),
    preco_custo DECIMAL(10,2) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    fornecedor VARCHAR(100),
    data_cadastro DATE NOT NULL,
    ativo BOOLEAN DEFAULT true
);

-- Inserir dados de exemplo
INSERT INTO funcionarios VALUES
(101, 'João Silva', 'Vendedor', 3500.00, 'Vendas', '2023-01-15', 28, 'joao.silva@empresa.com'),
(102, 'Maria Santos', 'Vendedor', 3800.00, 'Vendas', '2023-02-20', 32, 'maria.santos@empresa.com'),
(103, 'Pedro Costa', 'Vendedor Senior', 4500.00, 'Vendas', '2022-03-10', 35, 'pedro.costa@empresa.com'),
(104, 'Ana Oliveira', 'Gerente de Vendas', 6500.00, 'Vendas', '2021-05-12', 40, 'ana.oliveira@empresa.com'),
(105, 'Carlos Lima', 'Vendedor', 3600.00, 'Vendas', '2023-06-08', 29, 'carlos.lima@empresa.com'),
(106, 'Lucia Ferreira', 'Analista de TI', 5000.00, 'TI', '2022-01-20', 31, 'lucia.ferreira@empresa.com'),
(107, 'Roberto Alves', 'Desenvolvedor', 5500.00, 'TI', '2021-08-15', 33, 'roberto.alves@empresa.com'),
(108, 'Fernanda Rocha', 'Gerente de TI', 7500.00, 'TI', '2020-04-10', 38, 'fernanda.rocha@empresa.com'),
(109, 'Marcos Pereira', 'Analista Financeiro', 4800.00, 'Financeiro', '2022-09-05', 30, 'marcos.pereira@empresa.com'),
(110, 'Juliana Souza', 'Contadora', 5200.00, 'Financeiro', '2021-11-22', 34, 'juliana.souza@empresa.com');

INSERT INTO vendas VALUES
(1, 'Notebook', 'Eletrônicos', 2500.00, 2, '2024-01-15', 101, 'Sul'),
(2, 'Mouse', 'Eletrônicos', 50.00, 5, '2024-01-16', 102, 'Norte'),
(3, 'Teclado', 'Eletrônicos', 150.00, 3, '2024-01-17', 101, 'Sul'),
(4, 'Monitor', 'Eletrônicos', 800.00, 1, '2024-01-18', 103, 'Sudeste'),
(5, 'Cadeira', 'Móveis', 400.00, 2, '2024-01-19', 104, 'Centro-Oeste'),
(6, 'Mesa', 'Móveis', 600.00, 1, '2024-01-20', 102, 'Norte'),
(7, 'Smartphone', 'Eletrônicos', 1200.00, 3, '2024-01-21', 105, 'Nordeste'),
(8, 'Tablet', 'Eletrônicos', 800.00, 2, '2024-01-22', 101, 'Sul'),
(9, 'Impressora', 'Eletrônicos', 300.00, 1, '2024-01-23', 103, 'Sudeste'),
(10, 'Sofá', 'Móveis', 1500.00, 1, '2024-01-24', 104, 'Centro-Oeste'),
(11, 'Notebook', 'Eletrônicos', 2800.00, 1, '2024-02-01', 102, 'Norte'),
(12, 'Mouse', 'Eletrônicos', 45.00, 8, '2024-02-02', 105, 'Nordeste'),
(13, 'Teclado', 'Eletrônicos', 180.00, 2, '2024-02-03', 101, 'Sul'),
(14, 'Monitor', 'Eletrônicos', 900.00, 2, '2024-02-04', 103, 'Sudeste'),
(15, 'Cadeira', 'Móveis', 450.00, 3, '2024-02-05', 104, 'Centro-Oeste'),
(16, 'Mesa', 'Móveis', 700.00, 1, '2024-02-06', 102, 'Norte'),
(17, 'Smartphone', 'Eletrônicos', 1100.00, 4, '2024-02-07', 105, 'Nordeste'),
(18, 'Tablet', 'Eletrônicos', 750.00, 2, '2024-02-08', 101, 'Sul'),
(19, 'Impressora', 'Eletrônicos', 350.00, 1, '2024-02-09', 103, 'Sudeste'),
(20, 'Sofá', 'Móveis', 1600.00, 1, '2024-02-10', 104, 'Centro-Oeste');

INSERT INTO clientes VALUES
(1, 'Empresa ABC Ltda', 'contato@empresaabc.com', '11999887766', 'São Paulo', 'SP', '2023-01-10', 'Corporativo'),
(2, 'João da Silva', 'joao@email.com', '21987654321', 'Rio de Janeiro', 'RJ', '2023-02-15', 'Individual'),
(3, 'Tech Solutions', 'vendas@techsolutions.com', '31876543210', 'Belo Horizonte', 'MG', '2023-03-20', 'Corporativo'),
(4, 'Maria Oliveira', 'maria@email.com', '47765432109', 'Florianópolis', 'SC', '2023-04-25', 'Individual'),
(5, 'Inovação Digital', 'contato@inovacao.com', '85654321098', 'Fortaleza', 'CE', '2023-05-30', 'Corporativo'),
(6, 'Pedro Santos', 'pedro@email.com', '62543210987', 'Goiânia', 'GO', '2023-06-05', 'Individual'),
(7, 'Mega Corp', 'compras@megacorp.com', '11432109876', 'São Paulo', 'SP', '2023-07-10', 'Corporativo'),
(8, 'Ana Costa', 'ana@email.com', '84321098765', 'Natal', 'RN', '2023-08-15', 'Individual'),
(9, 'StartUp Xyz', 'hello@startupxyz.com', '51210987654', 'Porto Alegre', 'RS', '2023-09-20', 'Corporativo'),
(10, 'Carlos Lima', 'carlos@email.com', '67109876543', 'Campo Grande', 'MS', '2023-10-25', 'Individual');

INSERT INTO produtos VALUES
(1, 'Notebook Dell Inspiron', 'Eletrônicos', 'Computadores', 2000.00, 2500.00, 15, 'Dell Inc', '2023-01-01', true),
(2, 'Mouse Logitech', 'Eletrônicos', 'Periféricos', 25.00, 50.00, 100, 'Logitech', '2023-01-01', true),
(3, 'Teclado Mecânico', 'Eletrônicos', 'Periféricos', 80.00, 150.00, 50, 'Corsair', '2023-01-01', true),
(4, 'Monitor LG 24', 'Eletrônicos', 'Monitores', 500.00, 800.00, 25, 'LG Electronics', '2023-01-01', true),
(5, 'Cadeira Ergonômica', 'Móveis', 'Escritório', 250.00, 400.00, 30, 'Herman Miller', '2023-01-01', true),
(6, 'Mesa de Escritório', 'Móveis', 'Escritório', 350.00, 600.00, 20, 'IKEA', '2023-01-01', true),
(7, 'iPhone 15', 'Eletrônicos', 'Smartphones', 800.00, 1200.00, 40, 'Apple Inc', '2023-01-01', true),
(8, 'iPad Air', 'Eletrônicos', 'Tablets', 500.00, 800.00, 35, 'Apple Inc', '2023-01-01', true),
(9, 'Impressora HP', 'Eletrônicos', 'Impressoras', 200.00, 300.00, 15, 'HP Inc', '2023-01-01', true),
(10, 'Sofá 3 Lugares', 'Móveis', 'Sala', 1000.00, 1500.00, 10, 'Tok&Stok', '2023-01-01', true);

-- Criar índices para melhor performance
CREATE INDEX idx_vendas_data ON vendas(data_venda);
CREATE INDEX idx_vendas_vendedor ON vendas(vendedor_id);
CREATE INDEX idx_funcionarios_departamento ON funcionarios(departamento);
CREATE INDEX idx_clientes_tipo ON clientes(tipo_cliente);
CREATE INDEX idx_produtos_categoria ON produtos(categoria);