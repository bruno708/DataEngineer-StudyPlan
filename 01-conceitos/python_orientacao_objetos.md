# Orientação a Objetos com Python - Conceitos Fundamentais

## 📚 Índice

1. [Introdução à Orientação a Objetos](#introdução-à-orientação-a-objetos)
2. [Classes e Objetos](#classes-e-objetos)
3. [Atributos e Métodos](#atributos-e-métodos)
4. [Encapsulamento](#encapsulamento)
5. [Herança](#herança)
6. [Polimorfismo](#polimorfismo)
7. [Abstração](#abstração)
8. [Métodos Especiais (Magic Methods)](#métodos-especiais-magic-methods)
9. [Decoradores em OOP](#decoradores-em-oop)
10. [Padrões de Design](#padrões-de-design)
11. [Boas Práticas](#boas-práticas)

---

## 🎯 Introdução à Orientação a Objetos

### O que é Orientação a Objetos?

A **Orientação a Objetos (OOP)** é um paradigma de programação que organiza o código em torno de **objetos** e **classes**, em vez de funções e lógica.

### Princípios Fundamentais da OOP

1. **Encapsulamento**: Ocultar detalhes internos e expor apenas o necessário
2. **Herança**: Reutilizar código através de hierarquias de classes
3. **Polimorfismo**: Usar uma interface comum para diferentes tipos
4. **Abstração**: Simplificar complexidade através de modelos

### Vantagens da OOP

- ✅ **Reutilização de código**
- ✅ **Modularidade**
- ✅ **Manutenibilidade**
- ✅ **Escalabilidade**
- ✅ **Organização lógica**

---

## 🏗️ Classes e Objetos

### Definindo uma Classe

```python
class Pessoa:
    """Classe que representa uma pessoa."""
    
    # Atributo de classe (compartilhado por todas as instâncias)
    especie = "Homo sapiens"
    
    def __init__(self, nome, idade):
        """Construtor da classe."""
        # Atributos de instância
        self.nome = nome
        self.idade = idade
    
    def apresentar(self):
        """Método de instância."""
        return f"Olá, eu sou {self.nome} e tenho {self.idade} anos."
    
    @classmethod
    def criar_bebe(cls, nome):
        """Método de classe."""
        return cls(nome, 0)
    
    @staticmethod
    def eh_maior_idade(idade):
        """Método estático."""
        return idade >= 18
```

### Criando e Usando Objetos

```python
# Criando objetos (instâncias)
pessoa1 = Pessoa("Ana", 25)
pessoa2 = Pessoa("João", 17)
bebe = Pessoa.criar_bebe("Maria")

# Usando métodos
print(pessoa1.apresentar())  # Olá, eu sou Ana e tenho 25 anos.
print(Pessoa.eh_maior_idade(pessoa2.idade))  # False

# Acessando atributos
print(pessoa1.nome)  # Ana
print(Pessoa.especie)  # Homo sapiens
```

---

## 🔧 Atributos e Métodos

### Tipos de Atributos

```python
class ContaBancaria:
    # Atributo de classe
    banco = "Banco Python"
    _taxa_juros = 0.05  # Protegido
    __codigo_banco = "001"  # Privado
    
    def __init__(self, titular, saldo_inicial=0):
        # Atributos de instância
        self.titular = titular
        self._saldo = saldo_inicial  # Protegido
        self.__numero_conta = self._gerar_numero()  # Privado
    
    def _gerar_numero(self):
        """Método protegido."""
        import random
        return random.randint(10000, 99999)
    
    def __validar_valor(self, valor):
        """Método privado."""
        return valor > 0
    
    def depositar(self, valor):
        """Método público."""
        if self.__validar_valor(valor):
            self._saldo += valor
            return True
        return False
    
    @property
    def saldo(self):
        """Getter para saldo."""
        return self._saldo
    
    @saldo.setter
    def saldo(self, valor):
        """Setter para saldo."""
        if self.__validar_valor(valor):
            self._saldo = valor
```

### Convenções de Nomenclatura

- **Público**: `atributo`, `metodo()`
- **Protegido**: `_atributo`, `_metodo()` (convenção, não força privacidade)
- **Privado**: `__atributo`, `__metodo()` (name mangling)

---

## 🔒 Encapsulamento

### Properties (Getters e Setters)

```python
class Temperatura:
    def __init__(self, celsius=0):
        self._celsius = celsius
    
    @property
    def celsius(self):
        return self._celsius
    
    @celsius.setter
    def celsius(self, valor):
        if valor < -273.15:
            raise ValueError("Temperatura não pode ser menor que zero absoluto")
        self._celsius = valor
    
    @property
    def fahrenheit(self):
        return (self._celsius * 9/5) + 32
    
    @fahrenheit.setter
    def fahrenheit(self, valor):
        self.celsius = (valor - 32) * 5/9
    
    @property
    def kelvin(self):
        return self._celsius + 273.15

# Uso
temp = Temperatura(25)
print(temp.fahrenheit)  # 77.0
temp.fahrenheit = 86
print(temp.celsius)  # 30.0
```

### Validação e Controle de Acesso

```python
class Usuario:
    def __init__(self, email, senha):
        self.email = email
        self._senha_hash = self._hash_senha(senha)
        self._tentativas_login = 0
        self._bloqueado = False
    
    def _hash_senha(self, senha):
        import hashlib
        return hashlib.sha256(senha.encode()).hexdigest()
    
    def verificar_senha(self, senha):
        if self._bloqueado:
            return False
        
        if self._hash_senha(senha) == self._senha_hash:
            self._tentativas_login = 0
            return True
        else:
            self._tentativas_login += 1
            if self._tentativas_login >= 3:
                self._bloqueado = True
            return False
    
    def alterar_senha(self, senha_atual, nova_senha):
        if self.verificar_senha(senha_atual):
            self._senha_hash = self._hash_senha(nova_senha)
            return True
        return False
```

---

## 🧬 Herança

### Herança Simples

```python
class Veiculo:
    def __init__(self, marca, modelo, ano):
        self.marca = marca
        self.modelo = modelo
        self.ano = ano
        self._ligado = False
    
    def ligar(self):
        self._ligado = True
        return f"{self.modelo} ligado!"
    
    def desligar(self):
        self._ligado = False
        return f"{self.modelo} desligado!"
    
    def info(self):
        return f"{self.marca} {self.modelo} ({self.ano})"

class Carro(Veiculo):
    def __init__(self, marca, modelo, ano, portas):
        super().__init__(marca, modelo, ano)  # Chama construtor da classe pai
        self.portas = portas
    
    def acelerar(self):
        if self._ligado:
            return f"{self.modelo} acelerando..."
        return "Carro precisa estar ligado!"
    
    def info(self):  # Sobrescrevendo método da classe pai
        return f"{super().info()} - {self.portas} portas"

class Moto(Veiculo):
    def __init__(self, marca, modelo, ano, cilindradas):
        super().__init__(marca, modelo, ano)
        self.cilindradas = cilindradas
    
    def empinar(self):
        if self._ligado:
            return f"{self.modelo} empinando!"
        return "Moto precisa estar ligada!"
```

### Herança Múltipla

```python
class Voador:
    def __init__(self):
        self.altitude = 0
    
    def voar(self):
        self.altitude += 100
        return f"Voando a {self.altitude}m de altitude"
    
    def pousar(self):
        self.altitude = 0
        return "Pousou com segurança"

class Aquatico:
    def __init__(self):
        self.profundidade = 0
    
    def mergulhar(self):
        self.profundidade += 10
        return f"Mergulhando a {self.profundidade}m de profundidade"
    
    def emergir(self):
        self.profundidade = 0
        return "Emergiu à superfície"

class VeiculoAnfibio(Veiculo, Voador, Aquatico):
    def __init__(self, marca, modelo, ano):
        Veiculo.__init__(self, marca, modelo, ano)
        Voador.__init__(self)
        Aquatico.__init__(self)
    
    def modo_terrestre(self):
        self.altitude = 0
        self.profundidade = 0
        return "Modo terrestre ativado"

# Method Resolution Order (MRO)
print(VeiculoAnfibio.__mro__)
```

---

## 🎭 Polimorfismo

### Polimorfismo por Herança

```python
class Animal:
    def __init__(self, nome):
        self.nome = nome
    
    def fazer_som(self):
        pass
    
    def mover(self):
        pass

class Cachorro(Animal):
    def fazer_som(self):
        return f"{self.nome} faz: Au au!"
    
    def mover(self):
        return f"{self.nome} corre"

class Gato(Animal):
    def fazer_som(self):
        return f"{self.nome} faz: Miau!"
    
    def mover(self):
        return f"{self.nome} caminha silenciosamente"

class Passaro(Animal):
    def fazer_som(self):
        return f"{self.nome} faz: Piu piu!"
    
    def mover(self):
        return f"{self.nome} voa"

# Polimorfismo em ação
def interagir_com_animal(animal):
    print(animal.fazer_som())
    print(animal.mover())

animais = [
    Cachorro("Rex"),
    Gato("Mimi"),
    Passaro("Tweety")
]

for animal in animais:
    interagir_com_animal(animal)
```

### Duck Typing

```python
class Pato:
    def quack(self):
        return "Quack!"
    
    def voar(self):
        return "Voando como um pato"

class Pessoa:
    def quack(self):
        return "Imitando um pato: Quack!"
    
    def voar(self):
        return "Não posso voar, mas posso pular!"

class Robo:
    def quack(self):
        return "Som eletrônico: QUACK.exe"
    
    def voar(self):
        return "Ativando propulsores..."

def fazer_como_pato(obj):
    """Se anda como pato e fala como pato, é um pato!"""
    print(obj.quack())
    print(obj.voar())

# Todos podem "ser" patos
objetos = [Pato(), Pessoa(), Robo()]
for obj in objetos:
    fazer_como_pato(obj)
```

---

## 🎨 Abstração

### Classes Abstratas

```python
from abc import ABC, abstractmethod

class Forma(ABC):
    """Classe abstrata para formas geométricas."""
    
    def __init__(self, nome):
        self.nome = nome
    
    @abstractmethod
    def calcular_area(self):
        """Método abstrato que deve ser implementado pelas subclasses."""
        pass
    
    @abstractmethod
    def calcular_perimetro(self):
        """Método abstrato que deve ser implementado pelas subclasses."""
        pass
    
    def info(self):
        """Método concreto disponível para todas as subclasses."""
        return f"Forma: {self.nome}"

class Retangulo(Forma):
    def __init__(self, largura, altura):
        super().__init__("Retângulo")
        self.largura = largura
        self.altura = altura
    
    def calcular_area(self):
        return self.largura * self.altura
    
    def calcular_perimetro(self):
        return 2 * (self.largura + self.altura)

class Circulo(Forma):
    def __init__(self, raio):
        super().__init__("Círculo")
        self.raio = raio
    
    def calcular_area(self):
        import math
        return math.pi * self.raio ** 2
    
    def calcular_perimetro(self):
        import math
        return 2 * math.pi * self.raio

# Uso
formas = [
    Retangulo(5, 3),
    Circulo(4)
]

for forma in formas:
    print(f"{forma.info()}:")
    print(f"  Área: {forma.calcular_area():.2f}")
    print(f"  Perímetro: {forma.calcular_perimetro():.2f}")
```

### Interfaces com Protocol

```python
from typing import Protocol

class Drawable(Protocol):
    """Interface para objetos que podem ser desenhados."""
    
    def draw(self) -> str:
        ...
    
    def get_area(self) -> float:
        ...

class Quadrado:
    def __init__(self, lado):
        self.lado = lado
    
    def draw(self):
        return f"Desenhando quadrado {self.lado}x{self.lado}"
    
    def get_area(self):
        return self.lado ** 2

class TrianguloEquilatero:
    def __init__(self, lado):
        self.lado = lado
    
    def draw(self):
        return f"Desenhando triângulo equilátero lado {self.lado}"
    
    def get_area(self):
        import math
        return (math.sqrt(3) / 4) * self.lado ** 2

def desenhar_forma(forma: Drawable):
    print(forma.draw())
    print(f"Área: {forma.get_area():.2f}")
```

---

## ✨ Métodos Especiais (Magic Methods)

### Métodos Fundamentais

```python
class Produto:
    def __init__(self, nome, preco):
        self.nome = nome
        self.preco = preco
    
    def __str__(self):
        """Representação amigável para usuários."""
        return f"{self.nome} - R$ {self.preco:.2f}"
    
    def __repr__(self):
        """Representação técnica para desenvolvedores."""
        return f"Produto('{self.nome}', {self.preco})"
    
    def __eq__(self, other):
        """Igualdade."""
        if isinstance(other, Produto):
            return self.nome == other.nome and self.preco == other.preco
        return False
    
    def __lt__(self, other):
        """Menor que."""
        if isinstance(other, Produto):
            return self.preco < other.preco
        return NotImplemented
    
    def __hash__(self):
        """Hash para usar em sets e como chave de dict."""
        return hash((self.nome, self.preco))

# Uso
p1 = Produto("Notebook", 2500.00)
p2 = Produto("Mouse", 50.00)

print(str(p1))  # Notebook - R$ 2500.00
print(repr(p1))  # Produto('Notebook', 2500.0)
print(p1 == p2)  # False
print(p1 > p2)   # True
```

### Métodos de Container

```python
class Carrinho:
    def __init__(self):
        self._itens = []
    
    def __len__(self):
        """Tamanho do carrinho."""
        return len(self._itens)
    
    def __getitem__(self, index):
        """Acesso por índice."""
        return self._itens[index]
    
    def __setitem__(self, index, valor):
        """Atribuição por índice."""
        self._itens[index] = valor
    
    def __delitem__(self, index):
        """Remoção por índice."""
        del self._itens[index]
    
    def __contains__(self, item):
        """Operador 'in'."""
        return item in self._itens
    
    def __iter__(self):
        """Iteração."""
        return iter(self._itens)
    
    def adicionar(self, produto):
        self._itens.append(produto)
    
    def total(self):
        return sum(produto.preco for produto in self._itens)

# Uso
carrinho = Carrinho()
carrinho.adicionar(Produto("Notebook", 2500.00))
carrinho.adicionar(Produto("Mouse", 50.00))

print(len(carrinho))  # 2
print(carrinho[0])    # Notebook - R$ 2500.00
print(Produto("Mouse", 50.00) in carrinho)  # True

for produto in carrinho:
    print(produto)
```

### Métodos Matemáticos

```python
class Vetor:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, other):
        """Soma de vetores."""
        if isinstance(other, Vetor):
            return Vetor(self.x + other.x, self.y + other.y)
        return NotImplemented
    
    def __sub__(self, other):
        """Subtração de vetores."""
        if isinstance(other, Vetor):
            return Vetor(self.x - other.x, self.y - other.y)
        return NotImplemented
    
    def __mul__(self, scalar):
        """Multiplicação por escalar."""
        if isinstance(scalar, (int, float)):
            return Vetor(self.x * scalar, self.y * scalar)
        return NotImplemented
    
    def __rmul__(self, scalar):
        """Multiplicação reversa."""
        return self.__mul__(scalar)
    
    def __abs__(self):
        """Magnitude do vetor."""
        import math
        return math.sqrt(self.x**2 + self.y**2)
    
    def __str__(self):
        return f"Vetor({self.x}, {self.y})"

# Uso
v1 = Vetor(3, 4)
v2 = Vetor(1, 2)

print(v1 + v2)    # Vetor(4, 6)
print(v1 * 2)     # Vetor(6, 8)
print(2 * v1)     # Vetor(6, 8)
print(abs(v1))    # 5.0
```

---

## 🎯 Decoradores em OOP

### Property, Classmethod e Staticmethod

```python
class Funcionario:
    _contador = 0
    _salario_minimo = 1320.00
    
    def __init__(self, nome, salario):
        self._nome = nome
        self._salario = salario
        Funcionario._contador += 1
        self._id = Funcionario._contador
    
    @property
    def nome(self):
        return self._nome
    
    @nome.setter
    def nome(self, valor):
        if not valor.strip():
            raise ValueError("Nome não pode estar vazio")
        self._nome = valor.strip().title()
    
    @property
    def salario(self):
        return self._salario
    
    @salario.setter
    def salario(self, valor):
        if valor < self._salario_minimo:
            raise ValueError(f"Salário não pode ser menor que {self._salario_minimo}")
        self._salario = valor
    
    @classmethod
    def total_funcionarios(cls):
        return cls._contador
    
    @classmethod
    def definir_salario_minimo(cls, valor):
        cls._salario_minimo = valor
    
    @staticmethod
    def calcular_imposto(salario):
        if salario <= 2000:
            return 0
        elif salario <= 3000:
            return salario * 0.075
        elif salario <= 4500:
            return salario * 0.15
        else:
            return salario * 0.225
    
    def salario_liquido(self):
        return self.salario - self.calcular_imposto(self.salario)
```

### Decoradores Customizados

```python
def validar_tipo(*tipos):
    """Decorador para validar tipos de argumentos."""
    def decorador(func):
        def wrapper(self, *args, **kwargs):
            for i, (arg, tipo_esperado) in enumerate(zip(args, tipos)):
                if not isinstance(arg, tipo_esperado):
                    raise TypeError(
                        f"Argumento {i+1} deve ser do tipo {tipo_esperado.__name__}, "
                        f"recebido {type(arg).__name__}"
                    )
            return func(self, *args, **kwargs)
        return wrapper
    return decorador

def log_metodo(func):
    """Decorador para log de métodos."""
    def wrapper(self, *args, **kwargs):
        print(f"Chamando {func.__name__} em {self.__class__.__name__}")
        resultado = func(self, *args, **kwargs)
        print(f"Método {func.__name__} executado com sucesso")
        return resultado
    return wrapper

class ContaAvancada:
    def __init__(self, titular, saldo_inicial=0):
        self.titular = titular
        self._saldo = saldo_inicial
    
    @log_metodo
    @validar_tipo(float)
    def depositar(self, valor):
        if valor <= 0:
            raise ValueError("Valor deve ser positivo")
        self._saldo += valor
        return self._saldo
    
    @log_metodo
    @validar_tipo(float)
    def sacar(self, valor):
        if valor <= 0:
            raise ValueError("Valor deve ser positivo")
        if valor > self._saldo:
            raise ValueError("Saldo insuficiente")
        self._saldo -= valor
        return self._saldo
```

---

## 🏗️ Padrões de Design

### Singleton

```python
class Singleton:
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not self._initialized:
            self._initialized = True
            # Inicialização aqui
            self.dados = []

class Configuracao(Singleton):
    def __init__(self):
        if not hasattr(self, 'configurado'):
            super().__init__()
            self.configurado = True
            self.debug = False
            self.database_url = "sqlite:///app.db"
    
    def set_debug(self, valor):
        self.debug = valor

# Uso
config1 = Configuracao()
config2 = Configuracao()
print(config1 is config2)  # True
```

### Factory Method

```python
from abc import ABC, abstractmethod

class Veiculo(ABC):
    @abstractmethod
    def acelerar(self):
        pass
    
    @abstractmethod
    def frear(self):
        pass

class Carro(Veiculo):
    def acelerar(self):
        return "Carro acelerando..."
    
    def frear(self):
        return "Carro freando..."

class Moto(Veiculo):
    def acelerar(self):
        return "Moto acelerando..."
    
    def frear(self):
        return "Moto freando..."

class FabricaVeiculo:
    @staticmethod
    def criar_veiculo(tipo):
        if tipo.lower() == "carro":
            return Carro()
        elif tipo.lower() == "moto":
            return Moto()
        else:
            raise ValueError(f"Tipo de veículo '{tipo}' não suportado")

# Uso
veiculo = FabricaVeiculo.criar_veiculo("carro")
print(veiculo.acelerar())  # Carro acelerando...
```

### Observer

```python
class Observable:
    def __init__(self):
        self._observers = []
    
    def adicionar_observer(self, observer):
        if observer not in self._observers:
            self._observers.append(observer)
    
    def remover_observer(self, observer):
        if observer in self._observers:
            self._observers.remove(observer)
    
    def notificar_observers(self, *args, **kwargs):
        for observer in self._observers:
            observer.update(self, *args, **kwargs)

class TemperaturaSensor(Observable):
    def __init__(self):
        super().__init__()
        self._temperatura = 0
    
    @property
    def temperatura(self):
        return self._temperatura
    
    @temperatura.setter
    def temperatura(self, valor):
        self._temperatura = valor
        self.notificar_observers(valor)

class Display:
    def __init__(self, nome):
        self.nome = nome
    
    def update(self, observable, temperatura):
        print(f"{self.nome}: Temperatura atualizada para {temperatura}°C")

class Alerta:
    def __init__(self, limite):
        self.limite = limite
    
    def update(self, observable, temperatura):
        if temperatura > self.limite:
            print(f"🚨 ALERTA: Temperatura {temperatura}°C acima do limite {self.limite}°C!")

# Uso
sensor = TemperaturaSensor()
display1 = Display("Display Principal")
display2 = Display("Display Secundário")
alerta = Alerta(30)

sensor.adicionar_observer(display1)
sensor.adicionar_observer(display2)
sensor.adicionar_observer(alerta)

sensor.temperatura = 25  # Notifica todos os observers
sensor.temperatura = 35  # Dispara alerta também
```

---

## ✅ Boas Práticas

### 1. Nomenclatura Clara

```python
# ❌ Ruim
class c:
    def m(self, x):
        return x * 2

# ✅ Bom
class Calculadora:
    def multiplicar_por_dois(self, numero):
        return numero * 2
```

### 2. Responsabilidade Única

```python
# ❌ Ruim - muitas responsabilidades
class Usuario:
    def __init__(self, nome, email):
        self.nome = nome
        self.email = email
    
    def salvar_no_banco(self):
        # Lógica de banco de dados
        pass
    
    def enviar_email(self):
        # Lógica de email
        pass
    
    def validar_dados(self):
        # Lógica de validação
        pass

# ✅ Bom - responsabilidades separadas
class Usuario:
    def __init__(self, nome, email):
        self.nome = nome
        self.email = email

class RepositorioUsuario:
    def salvar(self, usuario):
        # Lógica de banco de dados
        pass

class ServicoEmail:
    def enviar(self, destinatario, assunto, corpo):
        # Lógica de email
        pass

class ValidadorUsuario:
    def validar(self, usuario):
        # Lógica de validação
        pass
```

### 3. Composição vs Herança

```python
# ✅ Preferir composição quando apropriado
class Motor:
    def __init__(self, potencia):
        self.potencia = potencia
    
    def ligar(self):
        return f"Motor {self.potencia}HP ligado"

class Carro:
    def __init__(self, marca, modelo, motor):
        self.marca = marca
        self.modelo = modelo
        self.motor = motor  # Composição
    
    def ligar(self):
        return self.motor.ligar()

# Uso
motor_v8 = Motor(400)
carro = Carro("Ford", "Mustang", motor_v8)
```

### 4. Documentação e Type Hints

```python
from typing import List, Optional, Union

class Produto:
    """Representa um produto no sistema.
    
    Attributes:
        nome: Nome do produto
        preco: Preço em reais
        categoria: Categoria do produto
    """
    
    def __init__(self, nome: str, preco: float, categoria: str) -> None:
        self.nome = nome
        self.preco = preco
        self.categoria = categoria
    
    def aplicar_desconto(self, percentual: float) -> float:
        """Aplica desconto ao produto.
        
        Args:
            percentual: Percentual de desconto (0-100)
            
        Returns:
            Novo preço com desconto aplicado
            
        Raises:
            ValueError: Se percentual for inválido
        """
        if not 0 <= percentual <= 100:
            raise ValueError("Percentual deve estar entre 0 e 100")
        
        desconto = self.preco * (percentual / 100)
        return self.preco - desconto

class Carrinho:
    """Carrinho de compras."""
    
    def __init__(self) -> None:
        self._produtos: List[Produto] = []
    
    def adicionar_produto(self, produto: Produto) -> None:
        """Adiciona produto ao carrinho."""
        self._produtos.append(produto)
    
    def buscar_produto(self, nome: str) -> Optional[Produto]:
        """Busca produto por nome."""
        for produto in self._produtos:
            if produto.nome.lower() == nome.lower():
                return produto
        return None
    
    def calcular_total(self) -> float:
        """Calcula total do carrinho."""
        return sum(produto.preco for produto in self._produtos)
```

### 5. Tratamento de Erros

```python
class ContaError(Exception):
    """Exceção base para operações de conta."""
    pass

class SaldoInsuficienteError(ContaError):
    """Exceção para saldo insuficiente."""
    pass

class ValorInvalidoError(ContaError):
    """Exceção para valor inválido."""
    pass

class Conta:
    def __init__(self, titular: str, saldo_inicial: float = 0) -> None:
        self.titular = titular
        self._saldo = saldo_inicial
    
    def sacar(self, valor: float) -> float:
        """Saca valor da conta.
        
        Raises:
            ValorInvalidoError: Se valor for <= 0
            SaldoInsuficienteError: Se saldo for insuficiente
        """
        if valor <= 0:
            raise ValorInvalidoError("Valor deve ser positivo")
        
        if valor > self._saldo:
            raise SaldoInsuficienteError(
                f"Saldo insuficiente. Saldo atual: R$ {self._saldo:.2f}"
            )
        
        self._saldo -= valor
        return self._saldo

# Uso com tratamento adequado
try:
    conta = Conta("João", 1000)
    conta.sacar(1500)
except SaldoInsuficienteError as e:
    print(f"Erro: {e}")
except ValorInvalidoError as e:
    print(f"Erro: {e}")
```

---

## 🎓 Resumo dos Conceitos

### Pilares da OOP
1. **Encapsulamento**: Controle de acesso e ocultação de detalhes
2. **Herança**: Reutilização e extensão de código
3. **Polimorfismo**: Interface comum para diferentes tipos
4. **Abstração**: Simplificação através de modelos

### Elementos Essenciais
- **Classes e Objetos**: Estrutura e instâncias
- **Atributos e Métodos**: Dados e comportamentos
- **Métodos Especiais**: Integração com Python
- **Decoradores**: Property, classmethod, staticmethod

### Padrões Importantes
- **Singleton**: Instância única
- **Factory**: Criação de objetos
- **Observer**: Notificação de mudanças
- **Strategy**: Algoritmos intercambiáveis

### Boas Práticas
- Nomenclatura clara e consistente
- Responsabilidade única por classe
- Preferir composição quando apropriado
- Documentação e type hints
- Tratamento adequado de erros

---

## 📚 Próximos Passos

1. **Pratique** com exercícios progressivos
2. **Estude** padrões de design mais avançados
3. **Explore** frameworks que usam OOP (Django, Flask)
4. **Implemente** projetos reais aplicando os conceitos
5. **Refatore** código existente aplicando princípios OOP

**Lembre-se**: A orientação a objetos é uma ferramenta poderosa, mas deve ser usada quando apropriada. Nem todo problema requer uma solução orientada a objetos!