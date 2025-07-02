# 🐍 Exercícios de Orientação a Objetos com Python

## 📚 Índice

1. [Exercícios Básicos](#exercícios-básicos)
2. [Exercícios Intermediários](#exercícios-intermediários)
3. [Exercícios Avançados](#exercícios-avançados)
4. [Projetos Práticos](#projetos-práticos)
5. [Desafios](#desafios)

---

## 🟢 Exercícios Básicos

### Exercício 1: Classe Pessoa

**Objetivo**: Criar uma classe básica com atributos e métodos.

**Enunciado**:
Crie uma classe `Pessoa` com os seguintes requisitos:
- Atributos: nome, idade, email
- Método `apresentar()` que retorna uma string de apresentação
- Método `fazer_aniversario()` que incrementa a idade
- Propriedade `eh_maior_idade` que retorna True se idade >= 18

```python
# Sua implementação aqui
class Pessoa:
    pass

# Teste
pessoa = Pessoa("João", 25, "joao@email.com")
print(pessoa.apresentar())  # "Olá, eu sou João, tenho 25 anos"
print(pessoa.eh_maior_idade)  # True
pessoa.fazer_aniversario()
print(pessoa.idade)  # 26
```

### Exercício 2: Classe ContaBancaria

**Objetivo**: Implementar encapsulamento e validações.

**Enunciado**:
Crie uma classe `ContaBancaria` com:
- Atributos privados: número da conta, titular, saldo
- Métodos: depositar, sacar, consultar_saldo
- Validações: não permitir saque maior que o saldo
- Propriedade para acessar o saldo (somente leitura)

```python
# Sua implementação aqui
class ContaBancaria:
    pass

# Teste
conta = ContaBancaria("12345", "Maria Silva", 1000.0)
conta.depositar(500.0)
print(conta.saldo)  # 1500.0
conta.sacar(200.0)
print(conta.saldo)  # 1300.0
# conta.sacar(2000.0)  # Deve gerar erro
```

### Exercício 3: Herança Simples

**Objetivo**: Implementar herança básica.

**Enunciado**:
Crie uma hierarquia de classes:
- Classe base `Veiculo` com atributos: marca, modelo, ano
- Classe `Carro` que herda de `Veiculo` e adiciona: número_portas
- Classe `Moto` que herda de `Veiculo` e adiciona: cilindrada
- Método `info()` em cada classe que retorna informações específicas

```python
# Sua implementação aqui
class Veiculo:
    pass

class Carro(Veiculo):
    pass

class Moto(Veiculo):
    pass

# Teste
carro = Carro("Toyota", "Corolla", 2020, 4)
moto = Moto("Honda", "CB600", 2019, 600)
print(carro.info())
print(moto.info())
```

---

## 🟡 Exercícios Intermediários

### Exercício 4: Sistema de Funcionários

**Objetivo**: Polimorfismo e métodos abstratos.

**Enunciado**:
Crie um sistema de funcionários com:
- Classe abstrata `Funcionario` com método abstrato `calcular_salario()`
- Classes `FuncionarioCLT`, `Freelancer`, `Estagiario`
- Cada tipo calcula salário de forma diferente
- Método `gerar_folha_pagamento()` que aceita lista de funcionários

```python
from abc import ABC, abstractmethod

# Sua implementação aqui
class Funcionario(ABC):
    pass

class FuncionarioCLT(Funcionario):
    pass

class Freelancer(Funcionario):
    pass

class Estagiario(Funcionario):
    pass

def gerar_folha_pagamento(funcionarios):
    pass

# Teste
funcionarios = [
    FuncionarioCLT("Ana", 5000.0),
    Freelancer("Bruno", 80.0, 160),  # valor_hora, horas_trabalhadas
    Estagiario("Carlos", 1200.0)
]

folha = gerar_folha_pagamento(funcionarios)
print(folha)
```

### Exercício 5: Sistema de Formas Geométricas

**Objetivo**: Polimorfismo e métodos especiais.

**Enunciado**:
Crie um sistema de formas geométricas:
- Classe base `Forma` com métodos abstratos `area()` e `perimetro()`
- Classes `Retangulo`, `Circulo`, `Triangulo`
- Implementar `__str__`, `__eq__`, `__lt__` (comparação por área)
- Método de classe para criar formas a partir de string

```python
import math
from abc import ABC, abstractmethod

# Sua implementação aqui
class Forma(ABC):
    pass

class Retangulo(Forma):
    pass

class Circulo(Forma):
    pass

class Triangulo(Forma):
    pass

# Teste
formas = [
    Retangulo(5, 3),
    Circulo(2),
    Triangulo(3, 4, 5)
]

for forma in formas:
    print(f"{forma} - Área: {forma.area():.2f}")

formas_ordenadas = sorted(formas)
print("Formas ordenadas por área:", formas_ordenadas)
```

### Exercício 6: Decoradores Customizados

**Objetivo**: Criar e usar decoradores personalizados.

**Enunciado**:
Crie decoradores para:
- `@cronometrar`: mede tempo de execução de métodos
- `@cache_resultado`: armazena resultado de métodos em cache
- `@validar_tipos`: valida tipos dos argumentos
- Aplique os decoradores em uma classe `CalculadoraAvancada`

```python
from functools import wraps
import time
from typing import get_type_hints

# Sua implementação aqui
def cronometrar(func):
    pass

def cache_resultado(func):
    pass

def validar_tipos(func):
    pass

class CalculadoraAvancada:
    @cronometrar
    @cache_resultado
    def fibonacci(self, n: int) -> int:
        if n <= 1:
            return n
        return self.fibonacci(n-1) + self.fibonacci(n-2)
    
    @validar_tipos
    def potencia(self, base: float, expoente: int) -> float:
        return base ** expoente

# Teste
calc = CalculadoraAvancada()
print(calc.fibonacci(10))  # Deve mostrar tempo de execução
print(calc.fibonacci(10))  # Deve usar cache
print(calc.potencia(2.5, 3))  # 15.625
# calc.potencia("2", 3)  # Deve gerar erro de tipo
```

---

## 🔴 Exercícios Avançados

### Exercício 7: Metaclasses

**Objetivo**: Criar e usar metaclasses.

**Enunciado**:
Crie uma metaclasse `SingletonMeta` que:
- Garante que apenas uma instância da classe seja criada
- Registra todas as classes que usam a metaclasse
- Adiciona método `get_instance()` automaticamente

```python
# Sua implementação aqui
class SingletonMeta(type):
    pass

class Configuracao(metaclass=SingletonMeta):
    def __init__(self):
        self.configuracoes = {}
    
    def set_config(self, chave, valor):
        self.configuracoes[chave] = valor
    
    def get_config(self, chave):
        return self.configuracoes.get(chave)

# Teste
config1 = Configuracao()
config2 = Configuracao()
print(config1 is config2)  # True

config1.set_config("debug", True)
print(config2.get_config("debug"))  # True
```

### Exercício 8: Context Managers

**Objetivo**: Implementar context managers personalizados.

**Enunciado**:
Crie context managers para:
- `GerenciadorArquivo`: abre e fecha arquivos com tratamento de erro
- `GerenciadorTempo`: mede tempo de execução de blocos de código
- `GerenciadorTransacao`: simula transações com rollback

```python
from contextlib import contextmanager
import time

# Sua implementação aqui
class GerenciadorArquivo:
    pass

class GerenciadorTempo:
    pass

class GerenciadorTransacao:
    pass

# Teste
with GerenciadorArquivo("teste.txt", "w") as arquivo:
    arquivo.write("Teste de context manager")

with GerenciadorTempo() as timer:
    time.sleep(1)
    print(f"Tempo decorrido: {timer.tempo_decorrido:.2f}s")

with GerenciadorTransacao() as transacao:
    transacao.executar("INSERT INTO usuarios...")
    transacao.executar("UPDATE saldo...")
    # Se houver erro, faz rollback automático
```

### Exercício 9: Sistema de Plugins Avançado

**Objetivo**: Criar sistema de plugins com descoberta automática.

**Enunciado**:
Crie um sistema que:
- Descobre plugins automaticamente em um diretório
- Carrega plugins dinamicamente
- Gerencia dependências entre plugins
- Permite ativar/desativar plugins em runtime

```python
import importlib
import os
from abc import ABC, abstractmethod
from typing import Dict, List, Set

# Sua implementação aqui
class PluginInterface(ABC):
    pass

class PluginManager:
    pass

class PluginDependencyResolver:
    pass

# Exemplo de plugin
class PluginCalculadora(PluginInterface):
    nome = "calculadora"
    versao = "1.0.0"
    dependencias = []
    
    def ativar(self):
        print("Plugin Calculadora ativado")
    
    def desativar(self):
        print("Plugin Calculadora desativado")
    
    def somar(self, a, b):
        return a + b

# Teste
manager = PluginManager("./plugins")
manager.descobrir_plugins()
manager.carregar_plugin("calculadora")
manager.ativar_plugin("calculadora")

plugin = manager.obter_plugin("calculadora")
print(plugin.somar(2, 3))  # 5
```

---

## 🚀 Projetos Práticos

### Projeto 1: Sistema de E-commerce

**Objetivo**: Aplicar todos os conceitos em um projeto real.

**Requisitos**:
1. **Produtos**:
   - Hierarquia de produtos (Livro, Eletrônico, Roupa)
   - Cada tipo tem atributos específicos
   - Sistema de categorias e tags
   - Controle de estoque

2. **Usuários**:
   - Cliente, Vendedor, Administrador
   - Sistema de autenticação
   - Perfis e permissões

3. **Carrinho e Pedidos**:
   - Carrinho de compras
   - Cálculo de frete
   - Processamento de pedidos
   - Histórico de compras

4. **Pagamento**:
   - Diferentes formas de pagamento
   - Processamento de transações
   - Sistema de cupons e descontos

```python
# Estrutura base - implemente as classes
from abc import ABC, abstractmethod
from datetime import datetime
from enum import Enum
from typing import List, Dict, Optional

class StatusPedido(Enum):
    PENDENTE = "pendente"
    CONFIRMADO = "confirmado"
    ENVIADO = "enviado"
    ENTREGUE = "entregue"
    CANCELADO = "cancelado"

class Produto(ABC):
    def __init__(self, id: str, nome: str, preco: float, estoque: int):
        self.id = id
        self.nome = nome
        self.preco = preco
        self.estoque = estoque
        self.categorias: List[str] = []
        self.tags: List[str] = []
    
    @abstractmethod
    def calcular_frete(self, cep_destino: str) -> float:
        pass
    
    @abstractmethod
    def obter_detalhes(self) -> Dict[str, any]:
        pass

class Livro(Produto):
    def __init__(self, id: str, nome: str, preco: float, estoque: int, 
                 autor: str, isbn: str, paginas: int):
        super().__init__(id, nome, preco, estoque)
        self.autor = autor
        self.isbn = isbn
        self.paginas = paginas
    
    def calcular_frete(self, cep_destino: str) -> float:
        # Implementar cálculo de frete para livros
        pass
    
    def obter_detalhes(self) -> Dict[str, any]:
        # Implementar detalhes específicos do livro
        pass

# Continue implementando as outras classes...
class Usuario(ABC):
    pass

class Cliente(Usuario):
    pass

class CarrinhoCompras:
    pass

class Pedido:
    pass

class ProcessadorPagamento(ABC):
    pass

class ECommerce:
    pass

# Teste do sistema
if __name__ == "__main__":
    # Criar produtos
    livro = Livro("L001", "Python para Iniciantes", 49.90, 100, 
                  "João Silva", "978-1234567890", 300)
    
    # Criar cliente
    cliente = Cliente("C001", "Maria Santos", "maria@email.com")
    
    # Criar e-commerce
    loja = ECommerce("Minha Loja")
    loja.adicionar_produto(livro)
    loja.registrar_usuario(cliente)
    
    # Simular compra
    carrinho = cliente.obter_carrinho()
    carrinho.adicionar_item(livro, 2)
    
    pedido = loja.processar_pedido(cliente, carrinho)
    print(f"Pedido criado: {pedido.id}")
```

### Projeto 2: Sistema de Gerenciamento de Tarefas

**Objetivo**: Criar um sistema completo de gestão de projetos.

**Requisitos**:
1. **Tarefas e Projetos**:
   - Hierarquia de tarefas (tarefa, subtarefa)
   - Projetos com múltiplas tarefas
   - Estados e prioridades
   - Dependências entre tarefas

2. **Usuários e Equipes**:
   - Diferentes tipos de usuários
   - Equipes e permissões
   - Atribuição de tarefas

3. **Notificações**:
   - Sistema de notificações
   - Diferentes canais (email, push, SMS)
   - Regras de notificação

4. **Relatórios**:
   - Relatórios de produtividade
   - Gráficos e estatísticas
   - Exportação de dados

```python
# Estrutura base - implemente o sistema completo
from abc import ABC, abstractmethod
from datetime import datetime, timedelta
from enum import Enum
from typing import List, Dict, Optional, Set

class PrioridadeTarefa(Enum):
    BAIXA = 1
    MEDIA = 2
    ALTA = 3
    CRITICA = 4

class StatusTarefa(Enum):
    NOVA = "nova"
    EM_ANDAMENTO = "em_andamento"
    PAUSADA = "pausada"
    CONCLUIDA = "concluida"
    CANCELADA = "cancelada"

class Tarefa:
    def __init__(self, id: str, titulo: str, descricao: str):
        self.id = id
        self.titulo = titulo
        self.descricao = descricao
        self.status = StatusTarefa.NOVA
        self.prioridade = PrioridadeTarefa.MEDIA
        self.data_criacao = datetime.now()
        self.data_vencimento: Optional[datetime] = None
        self.responsavel: Optional['Usuario'] = None
        self.dependencias: Set['Tarefa'] = set()
        self.subtarefas: List['Tarefa'] = []
        self.comentarios: List['Comentario'] = []
        self.anexos: List['Anexo'] = []
    
    def pode_iniciar(self) -> bool:
        # Verificar se todas as dependências foram concluídas
        pass
    
    def calcular_progresso(self) -> float:
        # Calcular progresso baseado nas subtarefas
        pass
    
    def adicionar_dependencia(self, tarefa: 'Tarefa'):
        # Adicionar dependência com validação de ciclos
        pass

class Projeto:
    def __init__(self, id: str, nome: str, descricao: str):
        self.id = id
        self.nome = nome
        self.descricao = descricao
        self.tarefas: List[Tarefa] = []
        self.equipe: List['Usuario'] = []
        self.data_inicio: Optional[datetime] = None
        self.data_fim: Optional[datetime] = None
    
    def calcular_progresso_geral(self) -> float:
        # Calcular progresso do projeto
        pass
    
    def obter_caminho_critico(self) -> List[Tarefa]:
        # Implementar algoritmo de caminho crítico
        pass

# Continue implementando...
class Usuario(ABC):
    pass

class GerenciadorTarefas:
    pass

class SistemaNotificacoes:
    pass

class GeradorRelatorios:
    pass
```

---

## 🎯 Desafios

### Desafio 1: ORM Simples

**Objetivo**: Criar um ORM básico usando metaclasses e descritores.

**Requisitos**:
- Mapeamento automático de classes para tabelas
- Relacionamentos (OneToMany, ManyToMany)
- Query builder fluente
- Lazy loading
- Cache de consultas

### Desafio 2: Framework Web Minimalista

**Objetivo**: Criar um framework web usando conceitos avançados de OOP.

**Requisitos**:
- Sistema de roteamento
- Middleware pipeline
- Injeção de dependências
- Decoradores para autenticação
- Template engine simples

### Desafio 3: Sistema de Workflow

**Objetivo**: Implementar um sistema de workflow usando State Pattern.

**Requisitos**:
- Estados e transições configuráveis
- Validações de transição
- Histórico de mudanças
- Notificações automáticas
- Interface gráfica para design de workflows

---

## 📝 Critérios de Avaliação

### Para cada exercício, considere:

1. **Correção** (25%):
   - O código funciona conforme especificado?
   - Todos os requisitos foram atendidos?

2. **Design OOP** (25%):
   - Uso adequado de herança, polimorfismo e encapsulamento
   - Aplicação correta de padrões de design
   - Separação de responsabilidades

3. **Qualidade do Código** (25%):
   - Legibilidade e organização
   - Nomenclatura adequada
   - Documentação e comentários
   - Tratamento de erros

4. **Eficiência** (25%):
   - Performance adequada
   - Uso eficiente de memória
   - Complexidade algorítmica apropriada

### Dicas para Sucesso:

- 📖 **Leia atentamente** os requisitos antes de começar
- 🎯 **Planeje** a estrutura antes de codificar
- 🧪 **Teste** cada funcionalidade conforme implementa
- 🔄 **Refatore** o código para melhorar a qualidade
- 📚 **Documente** suas decisões de design
- 🤝 **Colabore** e peça feedback quando necessário

---

**🚀 Boa sorte com os exercícios!** Lembre-se: a prática leva à perfeição. Comece pelos exercícios básicos e vá progredindo gradualmente para os mais avançados.