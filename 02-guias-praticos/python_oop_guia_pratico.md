# Python Orientação a Objetos - Guia Prático

## 📚 Índice

1. [Projeto Prático: Sistema de Biblioteca](#projeto-prático-sistema-de-biblioteca)
2. [Implementação Passo a Passo](#implementação-passo-a-passo)
3. [Padrões de Design Aplicados](#padrões-de-design-aplicados)
4. [Testes e Validação](#testes-e-validação)
5. [Otimizações e Melhorias](#otimizações-e-melhorias)
6. [Casos de Uso Avançados](#casos-de-uso-avançados)
7. [Integração com Banco de Dados](#integração-com-banco-de-dados)
8. [API REST com OOP](#api-rest-com-oop)

---

## 🎯 Projeto Prático: Sistema de Biblioteca

Vamos construir um sistema completo de biblioteca que demonstra todos os conceitos de OOP em Python.

### Requisitos do Sistema

- **Gerenciar livros**: cadastro, busca, disponibilidade
- **Gerenciar usuários**: clientes e funcionários
- **Controlar empréstimos**: histórico, prazos, multas
- **Relatórios**: estatísticas e dashboards
- **Autenticação**: login e permissões
- **Persistência**: salvar dados em arquivo/banco

### Arquitetura do Sistema

```
Sistema Biblioteca
├── models/          # Modelos de dados
│   ├── pessoa.py
│   ├── livro.py
│   ├── emprestimo.py
│   └── biblioteca.py
├── services/        # Lógica de negócio
│   ├── auth_service.py
│   ├── emprestimo_service.py
│   └── relatorio_service.py
├── repositories/    # Acesso a dados
│   ├── base_repository.py
│   └── json_repository.py
├── utils/          # Utilitários
│   ├── validators.py
│   └── decorators.py
└── main.py         # Aplicação principal
```

---

## 🏗️ Implementação Passo a Passo

### Passo 1: Classes Base e Abstratas

```python
# models/pessoa.py
from abc import ABC, abstractmethod
from datetime import datetime
from typing import List, Optional
import uuid

class Pessoa(ABC):
    """Classe abstrata base para pessoas no sistema."""
    
    def __init__(self, nome: str, email: str, telefone: str):
        self._id = str(uuid.uuid4())
        self._nome = self._validar_nome(nome)
        self._email = self._validar_email(email)
        self._telefone = telefone
        self._data_cadastro = datetime.now()
        self._ativo = True
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def nome(self) -> str:
        return self._nome
    
    @nome.setter
    def nome(self, valor: str):
        self._nome = self._validar_nome(valor)
    
    @property
    def email(self) -> str:
        return self._email
    
    @email.setter
    def email(self, valor: str):
        self._email = self._validar_email(valor)
    
    @property
    def telefone(self) -> str:
        return self._telefone
    
    @telefone.setter
    def telefone(self, valor: str):
        self._telefone = valor
    
    @property
    def ativo(self) -> bool:
        return self._ativo
    
    def ativar(self):
        self._ativo = True
    
    def desativar(self):
        self._ativo = False
    
    @staticmethod
    def _validar_nome(nome: str) -> str:
        if not nome or not nome.strip():
            raise ValueError("Nome não pode estar vazio")
        if len(nome.strip()) < 2:
            raise ValueError("Nome deve ter pelo menos 2 caracteres")
        return nome.strip().title()
    
    @staticmethod
    def _validar_email(email: str) -> str:
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, email):
            raise ValueError("Email inválido")
        return email.lower()
    
    @abstractmethod
    def pode_emprestar_livro(self) -> bool:
        """Define se a pessoa pode emprestar livros."""
        pass
    
    def __str__(self) -> str:
        return f"{self.__class__.__name__}: {self.nome} ({self.email})"
    
    def __repr__(self) -> str:
        return f"{self.__class__.__name__}('{self.nome}', '{self.email}', '{self.telefone}')"
    
    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'nome': self.nome,
            'email': self.email,
            'telefone': self.telefone,
            'data_cadastro': self._data_cadastro.isoformat(),
            'ativo': self.ativo,
            'tipo': self.__class__.__name__
        }

class Cliente(Pessoa):
    """Cliente da biblioteca."""
    
    def __init__(self, nome: str, email: str, telefone: str, 
                 endereco: str = "", limite_livros: int = 3):
        super().__init__(nome, email, telefone)
        self.endereco = endereco
        self.limite_livros = limite_livros
        self._emprestimos_ativos: List[str] = []  # IDs dos empréstimos
        self._historico_emprestimos: List[str] = []
        self._multas_pendentes = 0.0
    
    @property
    def emprestimos_ativos(self) -> List[str]:
        return self._emprestimos_ativos.copy()
    
    @property
    def multas_pendentes(self) -> float:
        return self._multas_pendentes
    
    def adicionar_emprestimo(self, emprestimo_id: str):
        if len(self._emprestimos_ativos) >= self.limite_livros:
            raise ValueError(f"Cliente já possui {self.limite_livros} livros emprestados")
        self._emprestimos_ativos.append(emprestimo_id)
        self._historico_emprestimos.append(emprestimo_id)
    
    def remover_emprestimo(self, emprestimo_id: str):
        if emprestimo_id in self._emprestimos_ativos:
            self._emprestimos_ativos.remove(emprestimo_id)
    
    def adicionar_multa(self, valor: float):
        self._multas_pendentes += valor
    
    def pagar_multa(self, valor: float) -> float:
        if valor > self._multas_pendentes:
            troco = valor - self._multas_pendentes
            self._multas_pendentes = 0
            return troco
        else:
            self._multas_pendentes -= valor
            return 0
    
    def pode_emprestar_livro(self) -> bool:
        return (self.ativo and 
                len(self._emprestimos_ativos) < self.limite_livros and
                self._multas_pendentes == 0)
    
    def to_dict(self) -> dict:
        data = super().to_dict()
        data.update({
            'endereco': self.endereco,
            'limite_livros': self.limite_livros,
            'emprestimos_ativos': self._emprestimos_ativos,
            'historico_emprestimos': self._historico_emprestimos,
            'multas_pendentes': self._multas_pendentes
        })
        return data

class Funcionario(Pessoa):
    """Funcionário da biblioteca."""
    
    def __init__(self, nome: str, email: str, telefone: str,
                 cargo: str, salario: float, senha: str):
        super().__init__(nome, email, telefone)
        self.cargo = cargo
        self.salario = salario
        self._senha_hash = self._hash_senha(senha)
        self._permissoes = self._definir_permissoes(cargo)
    
    @staticmethod
    def _hash_senha(senha: str) -> str:
        import hashlib
        return hashlib.sha256(senha.encode()).hexdigest()
    
    def verificar_senha(self, senha: str) -> bool:
        return self._hash_senha(senha) == self._senha_hash
    
    def alterar_senha(self, senha_atual: str, nova_senha: str) -> bool:
        if self.verificar_senha(senha_atual):
            self._senha_hash = self._hash_senha(nova_senha)
            return True
        return False
    
    def _definir_permissoes(self, cargo: str) -> set:
        permissoes_por_cargo = {
            'bibliotecario': {'emprestar', 'devolver', 'cadastrar_livro', 'buscar'},
            'gerente': {'emprestar', 'devolver', 'cadastrar_livro', 'buscar', 
                       'relatorios', 'gerenciar_usuarios'},
            'admin': {'*'}  # Todas as permissões
        }
        return permissoes_por_cargo.get(cargo.lower(), {'buscar'})
    
    def tem_permissao(self, acao: str) -> bool:
        return '*' in self._permissoes or acao in self._permissoes
    
    def pode_emprestar_livro(self) -> bool:
        return False  # Funcionários não emprestam livros para si
    
    def to_dict(self) -> dict:
        data = super().to_dict()
        data.update({
            'cargo': self.cargo,
            'salario': self.salario,
            'permissoes': list(self._permissoes)
        })
        return data
```

### Passo 2: Modelo de Livro com Enum

```python
# models/livro.py
from enum import Enum
from datetime import datetime
from typing import List, Optional
import uuid

class StatusLivro(Enum):
    DISPONIVEL = "disponivel"
    EMPRESTADO = "emprestado"
    RESERVADO = "reservado"
    MANUTENCAO = "manutencao"
    PERDIDO = "perdido"

class CategoriaLivro(Enum):
    FICCAO = "ficcao"
    NAO_FICCAO = "nao_ficcao"
    CIENCIA = "ciencia"
    TECNOLOGIA = "tecnologia"
    HISTORIA = "historia"
    BIOGRAFIA = "biografia"
    INFANTIL = "infantil"
    ACADEMICO = "academico"

class Livro:
    """Representa um livro na biblioteca."""
    
    def __init__(self, titulo: str, autor: str, isbn: str, 
                 categoria: CategoriaLivro, ano_publicacao: int,
                 editora: str = "", paginas: int = 0):
        self._id = str(uuid.uuid4())
        self.titulo = titulo
        self.autor = autor
        self.isbn = self._validar_isbn(isbn)
        self.categoria = categoria
        self.ano_publicacao = self._validar_ano(ano_publicacao)
        self.editora = editora
        self.paginas = paginas
        self._status = StatusLivro.DISPONIVEL
        self._data_cadastro = datetime.now()
        self._historico_emprestimos: List[str] = []
        self._avaliacoes: List[dict] = []
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def status(self) -> StatusLivro:
        return self._status
    
    @property
    def disponivel(self) -> bool:
        return self._status == StatusLivro.DISPONIVEL
    
    @property
    def emprestado(self) -> bool:
        return self._status == StatusLivro.EMPRESTADO
    
    @property
    def avaliacao_media(self) -> float:
        if not self._avaliacoes:
            return 0.0
        return sum(av['nota'] for av in self._avaliacoes) / len(self._avaliacoes)
    
    def alterar_status(self, novo_status: StatusLivro):
        self._status = novo_status
    
    def emprestar(self):
        if not self.disponivel:
            raise ValueError(f"Livro não está disponível (status: {self.status.value})")
        self._status = StatusLivro.EMPRESTADO
    
    def devolver(self):
        if not self.emprestado:
            raise ValueError("Livro não está emprestado")
        self._status = StatusLivro.DISPONIVEL
    
    def adicionar_avaliacao(self, nota: int, comentario: str = "", usuario_id: str = ""):
        if not 1 <= nota <= 5:
            raise ValueError("Nota deve estar entre 1 e 5")
        
        avaliacao = {
            'nota': nota,
            'comentario': comentario,
            'usuario_id': usuario_id,
            'data': datetime.now().isoformat()
        }
        self._avaliacoes.append(avaliacao)
    
    def buscar_por_termo(self, termo: str) -> bool:
        """Verifica se o livro contém o termo de busca."""
        termo = termo.lower()
        campos_busca = [
            self.titulo.lower(),
            self.autor.lower(),
            self.isbn,
            self.categoria.value.lower(),
            self.editora.lower()
        ]
        return any(termo in campo for campo in campos_busca)
    
    @staticmethod
    def _validar_isbn(isbn: str) -> str:
        # Remove hífens e espaços
        isbn_limpo = ''.join(c for c in isbn if c.isdigit())
        if len(isbn_limpo) not in [10, 13]:
            raise ValueError("ISBN deve ter 10 ou 13 dígitos")
        return isbn_limpo
    
    @staticmethod
    def _validar_ano(ano: int) -> int:
        ano_atual = datetime.now().year
        if not 1000 <= ano <= ano_atual:
            raise ValueError(f"Ano deve estar entre 1000 e {ano_atual}")
        return ano
    
    def __str__(self) -> str:
        return f"{self.titulo} - {self.autor} ({self.ano_publicacao})"
    
    def __repr__(self) -> str:
        return f"Livro('{self.titulo}', '{self.autor}', '{self.isbn}')"
    
    def __eq__(self, other) -> bool:
        if isinstance(other, Livro):
            return self.isbn == other.isbn
        return False
    
    def __hash__(self) -> int:
        return hash(self.isbn)
    
    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'titulo': self.titulo,
            'autor': self.autor,
            'isbn': self.isbn,
            'categoria': self.categoria.value,
            'ano_publicacao': self.ano_publicacao,
            'editora': self.editora,
            'paginas': self.paginas,
            'status': self.status.value,
            'data_cadastro': self._data_cadastro.isoformat(),
            'historico_emprestimos': self._historico_emprestimos,
            'avaliacoes': self._avaliacoes,
            'avaliacao_media': self.avaliacao_media
        }
```

### Passo 3: Sistema de Empréstimos

```python
# models/emprestimo.py
from datetime import datetime, timedelta
from enum import Enum
from typing import Optional
import uuid

class StatusEmprestimo(Enum):
    ATIVO = "ativo"
    DEVOLVIDO = "devolvido"
    ATRASADO = "atrasado"
    PERDIDO = "perdido"

class Emprestimo:
    """Representa um empréstimo de livro."""
    
    PRAZO_PADRAO_DIAS = 14
    MULTA_POR_DIA = 2.0
    
    def __init__(self, cliente_id: str, livro_id: str, 
                 funcionario_id: str, prazo_dias: int = PRAZO_PADRAO_DIAS):
        self._id = str(uuid.uuid4())
        self.cliente_id = cliente_id
        self.livro_id = livro_id
        self.funcionario_id = funcionario_id
        self._data_emprestimo = datetime.now()
        self._data_prevista_devolucao = self._data_emprestimo + timedelta(days=prazo_dias)
        self._data_devolucao: Optional[datetime] = None
        self._status = StatusEmprestimo.ATIVO
        self._multa_aplicada = 0.0
        self._observacoes = ""
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def data_emprestimo(self) -> datetime:
        return self._data_emprestimo
    
    @property
    def data_prevista_devolucao(self) -> datetime:
        return self._data_prevista_devolucao
    
    @property
    def data_devolucao(self) -> Optional[datetime]:
        return self._data_devolucao
    
    @property
    def status(self) -> StatusEmprestimo:
        return self._status
    
    @property
    def ativo(self) -> bool:
        return self._status == StatusEmprestimo.ATIVO
    
    @property
    def atrasado(self) -> bool:
        if self._data_devolucao:
            return False  # Já foi devolvido
        return datetime.now() > self._data_prevista_devolucao
    
    @property
    def dias_atraso(self) -> int:
        if not self.atrasado:
            return 0
        
        data_referencia = self._data_devolucao or datetime.now()
        delta = data_referencia - self._data_prevista_devolucao
        return max(0, delta.days)
    
    @property
    def multa_calculada(self) -> float:
        return self.dias_atraso * self.MULTA_POR_DIA
    
    @property
    def multa_aplicada(self) -> float:
        return self._multa_aplicada
    
    def devolver(self, observacoes: str = "") -> float:
        """Devolve o livro e retorna o valor da multa."""
        if self._status != StatusEmprestimo.ATIVO:
            raise ValueError("Empréstimo não está ativo")
        
        self._data_devolucao = datetime.now()
        self._observacoes = observacoes
        
        # Calcula multa se houver atraso
        if self.atrasado:
            self._multa_aplicada = self.multa_calculada
            self._status = StatusEmprestimo.ATRASADO
        else:
            self._status = StatusEmprestimo.DEVOLVIDO
        
        return self._multa_aplicada
    
    def marcar_como_perdido(self, multa_personalizada: float = None):
        """Marca o livro como perdido."""
        self._status = StatusEmprestimo.PERDIDO
        self._data_devolucao = datetime.now()
        
        # Aplica multa personalizada ou valor padrão alto
        if multa_personalizada is not None:
            self._multa_aplicada = multa_personalizada
        else:
            self._multa_aplicada = 100.0  # Valor fixo para livro perdido
    
    def prorrogar(self, dias_adicionais: int) -> bool:
        """Prorroga o empréstimo se possível."""
        if self._status != StatusEmprestimo.ATIVO:
            return False
        
        if self.atrasado:
            return False  # Não pode prorrogar se já está atrasado
        
        self._data_prevista_devolucao += timedelta(days=dias_adicionais)
        return True
    
    def __str__(self) -> str:
        return f"Empréstimo {self.id[:8]} - Status: {self.status.value}"
    
    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'cliente_id': self.cliente_id,
            'livro_id': self.livro_id,
            'funcionario_id': self.funcionario_id,
            'data_emprestimo': self._data_emprestimo.isoformat(),
            'data_prevista_devolucao': self._data_prevista_devolucao.isoformat(),
            'data_devolucao': self._data_devolucao.isoformat() if self._data_devolucao else None,
            'status': self.status.value,
            'multa_aplicada': self._multa_aplicada,
            'observacoes': self._observacoes,
            'atrasado': self.atrasado,
            'dias_atraso': self.dias_atraso
        }
```

### Passo 4: Decoradores Customizados

```python
# utils/decorators.py
from functools import wraps
from datetime import datetime
from typing import Callable, Any

def log_operacao(func: Callable) -> Callable:
    """Decorador para log de operações do sistema."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        inicio = datetime.now()
        classe = args[0].__class__.__name__ if args else "Função"
        
        print(f"[{inicio.strftime('%H:%M:%S')}] Iniciando {classe}.{func.__name__}")
        
        try:
            resultado = func(*args, **kwargs)
            fim = datetime.now()
            duracao = (fim - inicio).total_seconds()
            print(f"[{fim.strftime('%H:%M:%S')}] {classe}.{func.__name__} concluído em {duracao:.3f}s")
            return resultado
        except Exception as e:
            fim = datetime.now()
            print(f"[{fim.strftime('%H:%M:%S')}] ERRO em {classe}.{func.__name__}: {e}")
            raise
    
    return wrapper

def requer_permissao(permissao: str):
    """Decorador para verificar permissões de funcionário."""
    def decorador(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(self, funcionario, *args, **kwargs):
            if not hasattr(funcionario, 'tem_permissao'):
                raise ValueError("Usuário deve ser um funcionário")
            
            if not funcionario.tem_permissao(permissao):
                raise PermissionError(f"Funcionário não tem permissão: {permissao}")
            
            return func(self, funcionario, *args, **kwargs)
        
        return wrapper
    return decorador

def validar_tipos(**tipos):
    """Decorador para validação de tipos de argumentos."""
    def decorador(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Validar argumentos posicionais
            func_args = func.__code__.co_varnames[:func.__code__.co_argcount]
            
            for i, (arg_name, arg_value) in enumerate(zip(func_args, args)):
                if arg_name in tipos:
                    tipo_esperado = tipos[arg_name]
                    if not isinstance(arg_value, tipo_esperado):
                        raise TypeError(
                            f"Argumento '{arg_name}' deve ser do tipo {tipo_esperado.__name__}, "
                            f"recebido {type(arg_value).__name__}"
                        )
            
            # Validar argumentos nomeados
            for arg_name, arg_value in kwargs.items():
                if arg_name in tipos:
                    tipo_esperado = tipos[arg_name]
                    if not isinstance(arg_value, tipo_esperado):
                        raise TypeError(
                            f"Argumento '{arg_name}' deve ser do tipo {tipo_esperado.__name__}, "
                            f"recebido {type(arg_value).__name__}"
                        )
            
            return func(*args, **kwargs)
        
        return wrapper
    return decorador

def cache_resultado(tempo_cache_segundos: int = 300):
    """Decorador para cache de resultados de métodos."""
    def decorador(func: Callable) -> Callable:
        cache = {}
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Criar chave do cache
            chave = str(args) + str(sorted(kwargs.items()))
            agora = datetime.now()
            
            # Verificar se existe no cache e não expirou
            if chave in cache:
                resultado, timestamp = cache[chave]
                if (agora - timestamp).total_seconds() < tempo_cache_segundos:
                    print(f"Cache hit para {func.__name__}")
                    return resultado
            
            # Executar função e armazenar no cache
            resultado = func(*args, **kwargs)
            cache[chave] = (resultado, agora)
            print(f"Cache miss para {func.__name__} - resultado armazenado")
            
            return resultado
        
        return wrapper
    return decorador

def retry(max_tentativas: int = 3, delay_segundos: float = 1.0):
    """Decorador para retry automático em caso de falha."""
    def decorador(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            import time
            
            ultima_excecao = None
            
            for tentativa in range(max_tentativas):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    ultima_excecao = e
                    if tentativa < max_tentativas - 1:
                        print(f"Tentativa {tentativa + 1} falhou: {e}. Tentando novamente em {delay_segundos}s...")
                        time.sleep(delay_segundos)
                    else:
                        print(f"Todas as {max_tentativas} tentativas falharam")
            
            raise ultima_excecao
        
        return wrapper
    return decorador
```

### Passo 5: Serviços de Negócio

```python
# services/emprestimo_service.py
from typing import List, Optional
from datetime import datetime, timedelta
from models.emprestimo import Emprestimo, StatusEmprestimo
from models.pessoa import Cliente, Funcionario
from models.livro import Livro, StatusLivro
from utils.decorators import log_operacao, requer_permissao, validar_tipos

class EmprestimoService:
    """Serviço para gerenciar empréstimos de livros."""
    
    def __init__(self, biblioteca):
        self.biblioteca = biblioteca
        self._emprestimos: List[Emprestimo] = []
    
    @log_operacao
    @requer_permissao('emprestar')
    @validar_tipos(funcionario=Funcionario, cliente=Cliente, livro=Livro)
    def emprestar_livro(self, funcionario: Funcionario, cliente: Cliente, 
                       livros_disponiveis = self.biblioteca.buscar_livros(
            apenas_disponiveis=True
        )
        self.assertEqual(len(livros_disponiveis), 2)  # 3 total - 1 emprestado
    
    def test_relatorio_emprestimos(self):
        """Testa geração de relatórios."""
        # Fazer alguns empréstimos
        for i in range(2):
            self.biblioteca.emprestar_livro(
                self.clientes[i].id, self.livros[i].id
            )
        
        # Devolver um
        emprestimos_ativos = self.biblioteca._emprestimo_service.listar_emprestimos_ativos()
        self.biblioteca.devolver_livro(emprestimos_ativos[0].id)
        
        # Gerar relatório
        relatorio = self.biblioteca._emprestimo_service.gerar_relatorio_emprestimos()
        
        self.assertEqual(relatorio['total_emprestimos'], 2)
        self.assertEqual(relatorio['emprestimos_devolvidos'], 1)
        self.assertGreaterEqual(relatorio['taxa_devolucao'], 0.5)

if __name__ == '__main__':
    unittest.main()
```

---

## 🎨 Padrões de Design Aplicados

### Singleton - Configuração Global

```python
# utils/config.py
class Configuracao:
    """Singleton para configurações globais do sistema."""
    
    _instancia = None
    _inicializado = False
    
    def __new__(cls):
        if cls._instancia is None:
            cls._instancia = super().__new__(cls)
        return cls._instancia
    
    def __init__(self):
        if not self._inicializado:
            self.prazo_padrao_dias = 14
            self.multa_por_dia = 2.0
            self.limite_livros_cliente = 3
            self.limite_renovacoes = 2
            self.dias_maximos_renovacao = 14
            self.valor_multa_livro_perdido = 100.0
            self._inicializado = True
    
    def atualizar_configuracao(self, **kwargs):
        """Atualiza configurações dinamicamente."""
        for chave, valor in kwargs.items():
            if hasattr(self, chave):
                setattr(self, chave, valor)
            else:
                raise ValueError(f"Configuração '{chave}' não existe")
    
    def to_dict(self) -> dict:
        return {
            attr: getattr(self, attr)
            for attr in dir(self)
            if not attr.startswith('_') and not callable(getattr(self, attr))
        }

# Uso do Singleton
config = Configuracao()
config2 = Configuracao()
print(config is config2)  # True - mesma instância
```

### Factory Method - Criação de Relatórios

```python
# services/relatorio_service.py
from abc import ABC, abstractmethod
from typing import Dict, Any
from datetime import datetime, timedelta

class RelatorioBase(ABC):
    """Classe base para relatórios."""
    
    def __init__(self, biblioteca):
        self.biblioteca = biblioteca
        self.data_geracao = datetime.now()
    
    @abstractmethod
    def gerar_dados(self) -> Dict[str, Any]:
        """Gera os dados do relatório."""
        pass
    
    @abstractmethod
    def formatar_saida(self, dados: Dict[str, Any]) -> str:
        """Formata a saída do relatório."""
        pass
    
    def gerar_relatorio(self) -> str:
        """Template method para gerar relatório completo."""
        dados = self.gerar_dados()
        return self.formatar_saida(dados)

class RelatorioEmprestimos(RelatorioBase):
    """Relatório de empréstimos."""
    
    def __init__(self, biblioteca, data_inicio=None, data_fim=None):
        super().__init__(biblioteca)
        self.data_inicio = data_inicio or (datetime.now() - timedelta(days=30))
        self.data_fim = data_fim or datetime.now()
    
    def gerar_dados(self) -> Dict[str, Any]:
        return self.biblioteca._emprestimo_service.gerar_relatorio_emprestimos(
            self.data_inicio, self.data_fim
        )
    
    def formatar_saida(self, dados: Dict[str, Any]) -> str:
        return f"""
=== RELATÓRIO DE EMPRÉSTIMOS ===
Período: {dados['periodo']['inicio'][:10]} a {dados['periodo']['fim'][:10]}

Resumo:
- Total de empréstimos: {dados['total_emprestimos']}
- Empréstimos devolvidos: {dados['emprestimos_devolvidos']}
- Empréstimos atrasados: {dados['emprestimos_atrasados']}
- Taxa de devolução: {dados['taxa_devolucao']:.1%}
- Total de multas: R$ {dados['total_multas']:.2f}

Gerado em: {self.data_geracao.strftime('%d/%m/%Y %H:%M:%S')}
"""

class RelatorioLivrosPopulares(RelatorioBase):
    """Relatório de livros mais populares."""
    
    def __init__(self, biblioteca, limite=10):
        super().__init__(biblioteca)
        self.limite = limite
    
    def gerar_dados(self) -> Dict[str, Any]:
        livros_populares = self.biblioteca.listar_livros_populares(self.limite)
        return {
            'livros': [{
                'titulo': livro.titulo,
                'autor': livro.autor,
                'avaliacao_media': livro.avaliacao_media,
                'total_avaliacoes': len(livro._avaliacoes)
            } for livro in livros_populares]
        }
    
    def formatar_saida(self, dados: Dict[str, Any]) -> str:
        saida = "=== LIVROS MAIS POPULARES ===\n\n"
        
        for i, livro in enumerate(dados['livros'], 1):
            saida += f"{i}. {livro['titulo']} - {livro['autor']}\n"
            saida += f"   Avaliação: {livro['avaliacao_media']:.1f}/5.0 "
            saida += f"({livro['total_avaliacoes']} avaliações)\n\n"
        
        saida += f"Gerado em: {self.data_geracao.strftime('%d/%m/%Y %H:%M:%S')}"
        return saida

class RelatorioFactory:
    """Factory para criação de relatórios."""
    
    @staticmethod
    def criar_relatorio(tipo: str, biblioteca, **kwargs):
        """Cria relatório baseado no tipo especificado."""
        
        tipos_relatorio = {
            'emprestimos': RelatorioEmprestimos,
            'livros_populares': RelatorioLivrosPopulares,
        }
        
        if tipo not in tipos_relatorio:
            raise ValueError(f"Tipo de relatório '{tipo}' não suportado")
        
        classe_relatorio = tipos_relatorio[tipo]
        return classe_relatorio(biblioteca, **kwargs)

# Uso do Factory
factory = RelatorioFactory()
relatorio_emprestimos = factory.criar_relatorio(
    'emprestimos', biblioteca, 
    data_inicio=datetime(2024, 1, 1)
)
print(relatorio_emprestimos.gerar_relatorio())
```

### Observer - Sistema de Notificações

```python
# services/notificacao_service.py
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime

class Observer(ABC):
    """Interface para observadores."""
    
    @abstractmethod
    def notificar(self, evento: str, dados: Dict[str, Any]):
        """Recebe notificação de evento."""
        pass

class Subject:
    """Classe base para objetos observáveis."""
    
    def __init__(self):
        self._observers: List[Observer] = []
    
    def adicionar_observer(self, observer: Observer):
        """Adiciona observador."""
        if observer not in self._observers:
            self._observers.append(observer)
    
    def remover_observer(self, observer: Observer):
        """Remove observador."""
        if observer in self._observers:
            self._observers.remove(observer)
    
    def notificar_observers(self, evento: str, dados: Dict[str, Any]):
        """Notifica todos os observadores."""
        for observer in self._observers:
            observer.notificar(evento, dados)

class NotificadorEmail(Observer):
    """Observador que envia notificações por email."""
    
    def notificar(self, evento: str, dados: Dict[str, Any]):
        print(f"📧 EMAIL: {evento}")
        print(f"   Para: {dados.get('email', 'N/A')}")
        print(f"   Assunto: {dados.get('assunto', 'Notificação da Biblioteca')}")
        print(f"   Mensagem: {dados.get('mensagem', '')}")
        print()

class NotificadorSMS(Observer):
    """Observador que envia notificações por SMS."""
    
    def notificar(self, evento: str, dados: Dict[str, Any]):
        print(f"📱 SMS: {evento}")
        print(f"   Para: {dados.get('telefone', 'N/A')}")
        print(f"   Mensagem: {dados.get('mensagem', '')}")
        print()

class LogNotificacoes(Observer):
    """Observador que registra notificações em log."""
    
    def __init__(self):
        self.historico: List[Dict] = []
    
    def notificar(self, evento: str, dados: Dict[str, Any]):
        entrada_log = {
            'timestamp': datetime.now().isoformat(),
            'evento': evento,
            'dados': dados.copy()
        }
        self.historico.append(entrada_log)
        print(f"📝 LOG: {evento} registrado")

# Integração com o sistema de empréstimos
class EmprestimoServiceComNotificacoes(Subject):
    """Serviço de empréstimos com sistema de notificações."""
    
    def __init__(self, biblioteca):
        super().__init__()
        self.biblioteca = biblioteca
        self._emprestimos = []
    
    def emprestar_livro(self, funcionario, cliente, livro, prazo_dias=14):
        """Empresta livro e notifica observadores."""
        # Lógica de empréstimo (simplificada)
        emprestimo = Emprestimo(
            cliente.id, livro.id, funcionario.id, prazo_dias
        )
        
        livro.emprestar()
        cliente.adicionar_emprestimo(emprestimo.id)
        self._emprestimos.append(emprestimo)
        
        # Notificar observadores
        self.notificar_observers('emprestimo_realizado', {
            'cliente_nome': cliente.nome,
            'cliente_email': cliente.email,
            'cliente_telefone': cliente.telefone,
            'livro_titulo': livro.titulo,
            'data_devolucao': emprestimo.data_prevista_devolucao.strftime('%d/%m/%Y'),
            'assunto': 'Empréstimo Realizado',
            'mensagem': f'Livro "{livro.titulo}" emprestado. Devolução até {emprestimo.data_prevista_devolucao.strftime("%d/%m/%Y")}'
        })
        
        return emprestimo
    
    def verificar_emprestimos_vencendo(self):
        """Verifica empréstimos que vencem em breve."""
        from datetime import timedelta
        
        amanha = datetime.now() + timedelta(days=1)
        
        for emprestimo in self._emprestimos:
            if (emprestimo.ativo and 
                emprestimo.data_prevista_devolucao.date() == amanha.date()):
                
                cliente = self.biblioteca.buscar_cliente_por_id(emprestimo.cliente_id)
                livro = self.biblioteca.buscar_livro_por_id(emprestimo.livro_id)
                
                if cliente and livro:
                    self.notificar_observers('lembrete_devolucao', {
                        'cliente_nome': cliente.nome,
                        'cliente_email': cliente.email,
                        'cliente_telefone': cliente.telefone,
                        'livro_titulo': livro.titulo,
                        'assunto': 'Lembrete: Devolução de Livro',
                        'mensagem': f'Lembre-se de devolver o livro "{livro.titulo}" amanhã!'
                    })

# Exemplo de uso
servico_emprestimos = EmprestimoServiceComNotificacoes(biblioteca)

# Adicionar observadores
servico_emprestimos.adicionar_observer(NotificadorEmail())
servico_emprestimos.adicionar_observer(NotificadorSMS())
servico_emprestimos.adicionar_observer(LogNotificacoes())

# Realizar empréstimo (irá notificar todos os observadores)
# servico_emprestimos.emprestar_livro(funcionario, cliente, livro)
```

---

## 🚀 Otimizações e Melhorias

### Context Managers para Transações

```python
# utils/transaction_manager.py
from contextlib import contextmanager
from typing import Any, Dict
import json
import os
from datetime import datetime

class TransactionManager:
    """Gerenciador de transações para operações da biblioteca."""
    
    def __init__(self, biblioteca):
        self.biblioteca = biblioteca
        self.backup_path = "backup_transacao.json"
    
    @contextmanager
    def transacao(self, operacao: str):
        """Context manager para transações seguras."""
        
        # Criar backup antes da operação
        backup_data = self._criar_backup()
        
        try:
            print(f"🔄 Iniciando transação: {operacao}")
            yield self
            print(f"✅ Transação concluída: {operacao}")
            
        except Exception as e:
            print(f"❌ Erro na transação: {operacao}")
            print(f"   Erro: {e}")
            print("🔄 Restaurando estado anterior...")
            
            # Restaurar backup em caso de erro
            self._restaurar_backup(backup_data)
            print("✅ Estado restaurado")
            
            raise  # Re-raise a exceção
        
        finally:
            # Limpar backup temporário
            if os.path.exists(self.backup_path):
                os.remove(self.backup_path)
    
    def _criar_backup(self) -> Dict[str, Any]:
        """Cria backup do estado atual."""
        backup = {
            'timestamp': datetime.now().isoformat(),
            'clientes': [c.to_dict() for c in self.biblioteca._clientes],
            'funcionarios': [f.to_dict() for f in self.biblioteca._funcionarios],
            'livros': [l.to_dict() for l in self.biblioteca._livros],
            'emprestimos': [e.to_dict() for e in self.biblioteca._emprestimo_service._emprestimos]
        }
        
        # Salvar backup em arquivo
        with open(self.backup_path, 'w', encoding='utf-8') as f:
            json.dump(backup, f, indent=2, ensure_ascii=False)
        
        return backup
    
    def _restaurar_backup(self, backup_data: Dict[str, Any]):
        """Restaura estado a partir do backup."""
        # Implementação simplificada - em um sistema real,
        # seria necessário reconstruir os objetos completamente
        print(f"Restaurando backup de {backup_data['timestamp']}")
        # Aqui você implementaria a lógica de restauração completa

# Exemplo de uso
transaction_manager = TransactionManager(biblioteca)

# Operação segura com rollback automático
try:
    with transaction_manager.transacao("Empréstimo múltiplo"):
        # Operações que podem falhar
        biblioteca.emprestar_livro(cliente1.id, livro1.id)
        biblioteca.emprestar_livro(cliente2.id, livro2.id)
        
        # Se alguma operação falhar, tudo será revertido
        if alguma_condicao_de_erro:
            raise ValueError("Erro simulado")
        
except ValueError as e:
    print(f"Operação cancelada: {e}")
```

### Metaclasses para Validação Automática

```python
# utils/metaclasses.py
class ValidatedMeta(type):
    """Metaclasse para validação automática de atributos."""
    
    def __new__(mcs, name, bases, namespace):
        # Coletar validadores definidos na classe
        validators = {}
        
        for attr_name, attr_value in namespace.items():
            if hasattr(attr_value, '_validator'):
                validators[attr_name] = attr_value._validator
        
        # Criar a classe
        cls = super().__new__(mcs, name, bases, namespace)
        cls._validators = validators
        
        return cls
    
    def __call__(cls, *args, **kwargs):
        # Criar instância
        instance = super().__call__(*args, **kwargs)
        
        # Aplicar validações
        for attr_name, validator in cls._validators.items():
            if hasattr(instance, attr_name):
                value = getattr(instance, attr_name)
                if not validator(value):
                    raise ValueError(f"Validação falhou para {attr_name}: {value}")
        
        return instance

def validator(func):
    """Decorador para marcar funções como validadores."""
    func._validator = func
    return func

# Exemplo de uso
class ProdutoValidado(metaclass=ValidatedMeta):
    """Produto com validação automática."""
    
    def __init__(self, nome: str, preco: float, categoria: str):
        self.nome = nome
        self.preco = preco
        self.categoria = categoria
    
    @validator
    def nome(self, value: str) -> bool:
        return isinstance(value, str) and len(value.strip()) >= 2
    
    @validator
    def preco(self, value: float) -> bool:
        return isinstance(value, (int, float)) and value > 0
    
    @validator
    def categoria(self, value: str) -> bool:
        categorias_validas = ['livro', 'revista', 'jornal']
        return value.lower() in categorias_validas

# Teste
try:
     produto = ProdutoValidado("Livro Python", 29.90, "livro")  # ✅ Válido
     produto_invalido = ProdutoValidado("", -10, "categoria_inexistente")  # ❌ Erro
 except ValueError as e:
     print(f"Erro de validação: {e}")
 ```

---

## 🔧 Casos de Uso Avançados

### Sistema de Plugins

```python
# plugins/plugin_interface.py
from abc import ABC, abstractmethod
from typing import Dict, Any

class PluginInterface(ABC):
    """Interface base para plugins do sistema."""
    
    @property
    @abstractmethod
    def nome(self) -> str:
        """Nome do plugin."""
        pass
    
    @property
    @abstractmethod
    def versao(self) -> str:
        """Versão do plugin."""
        pass
    
    @abstractmethod
    def inicializar(self, biblioteca) -> bool:
        """Inicializa o plugin."""
        pass
    
    @abstractmethod
    def executar(self, **kwargs) -> Dict[str, Any]:
        """Executa a funcionalidade principal do plugin."""
        pass
    
    @abstractmethod
    def finalizar(self) -> bool:
        """Finaliza o plugin."""
        pass

class PluginManager:
    """Gerenciador de plugins."""
    
    def __init__(self):
        self._plugins: Dict[str, PluginInterface] = {}
        self._plugins_ativos: Dict[str, bool] = {}
    
    def registrar_plugin(self, plugin: PluginInterface) -> bool:
        """Registra um novo plugin."""
        try:
            nome = plugin.nome
            if nome in self._plugins:
                print(f"⚠️  Plugin '{nome}' já está registrado")
                return False
            
            self._plugins[nome] = plugin
            self._plugins_ativos[nome] = False
            print(f"✅ Plugin '{nome}' v{plugin.versao} registrado")
            return True
            
        except Exception as e:
            print(f"❌ Erro ao registrar plugin: {e}")
            return False
    
    def ativar_plugin(self, nome: str, biblioteca) -> bool:
        """Ativa um plugin."""
        if nome not in self._plugins:
            print(f"❌ Plugin '{nome}' não encontrado")
            return False
        
        if self._plugins_ativos[nome]:
            print(f"⚠️  Plugin '{nome}' já está ativo")
            return True
        
        try:
            plugin = self._plugins[nome]
            if plugin.inicializar(biblioteca):
                self._plugins_ativos[nome] = True
                print(f"✅ Plugin '{nome}' ativado")
                return True
            else:
                print(f"❌ Falha ao inicializar plugin '{nome}'")
                return False
                
        except Exception as e:
            print(f"❌ Erro ao ativar plugin '{nome}': {e}")
            return False
    
    def desativar_plugin(self, nome: str) -> bool:
        """Desativa um plugin."""
        if nome not in self._plugins or not self._plugins_ativos[nome]:
            return True
        
        try:
            plugin = self._plugins[nome]
            if plugin.finalizar():
                self._plugins_ativos[nome] = False
                print(f"✅ Plugin '{nome}' desativado")
                return True
            else:
                print(f"❌ Falha ao finalizar plugin '{nome}'")
                return False
                
        except Exception as e:
            print(f"❌ Erro ao desativar plugin '{nome}': {e}")
            return False
    
    def executar_plugin(self, nome: str, **kwargs) -> Dict[str, Any]:
        """Executa um plugin ativo."""
        if nome not in self._plugins:
            raise ValueError(f"Plugin '{nome}' não encontrado")
        
        if not self._plugins_ativos[nome]:
            raise ValueError(f"Plugin '{nome}' não está ativo")
        
        return self._plugins[nome].executar(**kwargs)
    
    def listar_plugins(self) -> Dict[str, Dict[str, Any]]:
        """Lista todos os plugins registrados."""
        return {
            nome: {
                'versao': plugin.versao,
                'ativo': self._plugins_ativos[nome]
            }
            for nome, plugin in self._plugins.items()
        }

# Exemplo de plugin
class PluginRelatorioAvancado(PluginInterface):
    """Plugin para relatórios avançados."""
    
    def __init__(self):
        self._biblioteca = None
    
    @property
    def nome(self) -> str:
        return "relatorio_avancado"
    
    @property
    def versao(self) -> str:
        return "1.0.0"
    
    def inicializar(self, biblioteca) -> bool:
        self._biblioteca = biblioteca
        print("📊 Plugin de Relatórios Avançados inicializado")
        return True
    
    def executar(self, **kwargs) -> Dict[str, Any]:
        tipo_relatorio = kwargs.get('tipo', 'geral')
        
        if tipo_relatorio == 'tendencias':
            return self._gerar_relatorio_tendencias()
        elif tipo_relatorio == 'performance':
            return self._gerar_relatorio_performance()
        else:
            return self._gerar_relatorio_geral()
    
    def _gerar_relatorio_tendencias(self) -> Dict[str, Any]:
        # Análise de tendências de empréstimos
        categorias_populares = {}
        for livro in self._biblioteca._livros:
            categoria = livro.categoria.value
            if categoria not in categorias_populares:
                categorias_populares[categoria] = 0
            categorias_populares[categoria] += len(livro._historico_emprestimos)
        
        return {
            'tipo': 'tendencias',
            'categorias_populares': categorias_populares,
            'categoria_mais_popular': max(categorias_populares, key=categorias_populares.get) if categorias_populares else None
        }
    
    def _gerar_relatorio_performance(self) -> Dict[str, Any]:
        # Análise de performance do sistema
        total_livros = len(self._biblioteca._livros)
        livros_nunca_emprestados = len([l for l in self._biblioteca._livros if not l._historico_emprestimos])
        
        return {
            'tipo': 'performance',
            'total_livros': total_livros,
            'livros_nunca_emprestados': livros_nunca_emprestados,
            'taxa_utilizacao_acervo': (total_livros - livros_nunca_emprestados) / total_livros if total_livros > 0 else 0
        }
    
    def _gerar_relatorio_geral(self) -> Dict[str, Any]:
        return self._biblioteca.gerar_estatisticas_gerais()
    
    def finalizar(self) -> bool:
        print("📊 Plugin de Relatórios Avançados finalizado")
        return True

# Uso do sistema de plugins
plugin_manager = PluginManager()
plugin_relatorio = PluginRelatorioAvancado()

plugin_manager.registrar_plugin(plugin_relatorio)
plugin_manager.ativar_plugin("relatorio_avancado", biblioteca)

# Executar plugin
resultado = plugin_manager.executar_plugin("relatorio_avancado", tipo="tendencias")
print(resultado)
```

### Sistema de Cache Inteligente

```python
# utils/cache_system.py
from typing import Any, Dict, Optional, Callable
from datetime import datetime, timedelta
from functools import wraps
import hashlib
import pickle
import threading

class CacheEntry:
    """Entrada do cache com metadados."""
    
    def __init__(self, valor: Any, ttl_segundos: int = 300):
        self.valor = valor
        self.timestamp = datetime.now()
        self.ttl = timedelta(seconds=ttl_segundos)
        self.acessos = 0
        self.ultimo_acesso = self.timestamp
    
    @property
    def expirado(self) -> bool:
        return datetime.now() > (self.timestamp + self.ttl)
    
    def acessar(self) -> Any:
        self.acessos += 1
        self.ultimo_acesso = datetime.now()
        return self.valor

class CacheInteligente:
    """Sistema de cache com políticas de expiração e limpeza."""
    
    def __init__(self, tamanho_maximo: int = 1000, ttl_padrao: int = 300):
        self._cache: Dict[str, CacheEntry] = {}
        self._lock = threading.RLock()
        self.tamanho_maximo = tamanho_maximo
        self.ttl_padrao = ttl_padrao
        self._estatisticas = {
            'hits': 0,
            'misses': 0,
            'evictions': 0
        }
    
    def _gerar_chave(self, *args, **kwargs) -> str:
        """Gera chave única para os argumentos."""
        conteudo = str(args) + str(sorted(kwargs.items()))
        return hashlib.md5(conteudo.encode()).hexdigest()
    
    def get(self, chave: str) -> Optional[Any]:
        """Recupera valor do cache."""
        with self._lock:
            if chave in self._cache:
                entrada = self._cache[chave]
                
                if entrada.expirado:
                    del self._cache[chave]
                    self._estatisticas['misses'] += 1
                    return None
                
                self._estatisticas['hits'] += 1
                return entrada.acessar()
            
            self._estatisticas['misses'] += 1
            return None
    
    def set(self, chave: str, valor: Any, ttl: Optional[int] = None) -> None:
        """Armazena valor no cache."""
        with self._lock:
            # Verificar se precisa fazer limpeza
            if len(self._cache) >= self.tamanho_maximo:
                self._limpar_cache()
            
            ttl_usar = ttl or self.ttl_padrao
            self._cache[chave] = CacheEntry(valor, ttl_usar)
    
    def _limpar_cache(self) -> None:
        """Remove entradas antigas usando política LRU."""
        # Remover entradas expiradas primeiro
        chaves_expiradas = [
            chave for chave, entrada in self._cache.items()
            if entrada.expirado
        ]
        
        for chave in chaves_expiradas:
            del self._cache[chave]
            self._estatisticas['evictions'] += 1
        
        # Se ainda estiver cheio, remover as menos acessadas
        if len(self._cache) >= self.tamanho_maximo:
            entradas_ordenadas = sorted(
                self._cache.items(),
                key=lambda x: (x[1].acessos, x[1].ultimo_acesso)
            )
            
            # Remover 25% das entradas menos usadas
            quantidade_remover = max(1, len(entradas_ordenadas) // 4)
            
            for chave, _ in entradas_ordenadas[:quantidade_remover]:
                del self._cache[chave]
                self._estatisticas['evictions'] += 1
    
    def invalidar(self, padrao: str = None) -> int:
        """Invalida entradas do cache."""
        with self._lock:
            if padrao is None:
                # Limpar tudo
                quantidade = len(self._cache)
                self._cache.clear()
                return quantidade
            
            # Limpar por padrão
            chaves_remover = [
                chave for chave in self._cache.keys()
                if padrao in chave
            ]
            
            for chave in chaves_remover:
                del self._cache[chave]
            
            return len(chaves_remover)
    
    def estatisticas(self) -> Dict[str, Any]:
        """Retorna estatísticas do cache."""
        total_requests = self._estatisticas['hits'] + self._estatisticas['misses']
        hit_rate = self._estatisticas['hits'] / total_requests if total_requests > 0 else 0
        
        return {
            'tamanho_atual': len(self._cache),
            'tamanho_maximo': self.tamanho_maximo,
            'hits': self._estatisticas['hits'],
            'misses': self._estatisticas['misses'],
            'hit_rate': hit_rate,
            'evictions': self._estatisticas['evictions']
        }

# Decorador para cache automático
def cache_resultado(cache_instance: CacheInteligente, ttl: int = 300):
    """Decorador para cache automático de resultados de métodos."""
    def decorador(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Gerar chave do cache
            chave_base = f"{func.__module__}.{func.__qualname__}"
            chave_args = cache_instance._gerar_chave(*args[1:], **kwargs)  # Pular 'self'
            chave_completa = f"{chave_base}:{chave_args}"
            
            # Tentar recuperar do cache
            resultado = cache_instance.get(chave_completa)
            if resultado is not None:
                return resultado
            
            # Executar função e armazenar resultado
            resultado = func(*args, **kwargs)
            cache_instance.set(chave_completa, resultado, ttl)
            
            return resultado
        
        return wrapper
    return decorador

# Integração com a biblioteca
cache_global = CacheInteligente(tamanho_maximo=500, ttl_padrao=600)

class BibliotecaComCache(Biblioteca):
    """Biblioteca com sistema de cache integrado."""
    
    def __init__(self, nome: str, endereco: str = ""):
        super().__init__(nome, endereco)
        self.cache = cache_global
    
    @cache_resultado(cache_global, ttl=300)
    def buscar_livros(self, termo: str = "", categoria=None, status=None, apenas_disponiveis: bool = False):
        """Busca livros com cache automático."""
        return super().buscar_livros(termo, categoria, status, apenas_disponiveis)
    
    @cache_resultado(cache_global, ttl=600)
    def gerar_estatisticas_gerais(self):
        """Estatísticas com cache de 10 minutos."""
        return super().gerar_estatisticas_gerais()
    
    def invalidar_cache_livros(self):
        """Invalida cache relacionado a livros."""
        return self.cache.invalidar("buscar_livros")
    
    def estatisticas_cache(self):
        """Retorna estatísticas do cache."""
        return self.cache.estatisticas()
```

---

## 🗄️ Integração com Banco de Dados

### Repository Pattern com SQLAlchemy

```python
# repositories/database.py
from sqlalchemy import create_engine, Column, String, Integer, Float, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import uuid

Base = declarative_base()

class ClienteDB(Base):
    __tablename__ = 'clientes'
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    nome = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    telefone = Column(String(20))
    endereco = Column(Text)
    limite_livros = Column(Integer, default=3)
    ativo = Column(Boolean, default=True)
    data_cadastro = Column(DateTime, default=datetime.now)
    multas_pendentes = Column(Float, default=0.0)
    
    # Relacionamentos
    emprestimos = relationship("EmprestimoDB", back_populates="cliente")

class LivroDB(Base):
    __tablename__ = 'livros'
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    titulo = Column(String(200), nullable=False)
    autor = Column(String(100), nullable=False)
    isbn = Column(String(13), unique=True, nullable=False)
    categoria = Column(String(50), nullable=False)
    ano_publicacao = Column(Integer)
    editora = Column(String(100))
    paginas = Column(Integer)
    status = Column(String(20), default='disponivel')
    data_cadastro = Column(DateTime, default=datetime.now)
    
    # Relacionamentos
    emprestimos = relationship("EmprestimoDB", back_populates="livro")

class EmprestimoDB(Base):
    __tablename__ = 'emprestimos'
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    cliente_id = Column(String(36), ForeignKey('clientes.id'), nullable=False)
    livro_id = Column(String(36), ForeignKey('livros.id'), nullable=False)
    funcionario_id = Column(String(36), nullable=False)
    data_emprestimo = Column(DateTime, default=datetime.now)
    data_prevista_devolucao = Column(DateTime, nullable=False)
    data_devolucao = Column(DateTime)
    status = Column(String(20), default='ativo')
    multa_aplicada = Column(Float, default=0.0)
    observacoes = Column(Text)
    
    # Relacionamentos
    cliente = relationship("ClienteDB", back_populates="emprestimos")
    livro = relationship("LivroDB", back_populates="emprestimos")

class DatabaseManager:
    """Gerenciador de conexão com banco de dados."""
    
    def __init__(self, database_url: str = "sqlite:///biblioteca.db"):
        self.engine = create_engine(database_url, echo=False)
        self.SessionLocal = sessionmaker(bind=self.engine)
        self._criar_tabelas()
    
    def _criar_tabelas(self):
        """Cria tabelas no banco de dados."""
        Base.metadata.create_all(bind=self.engine)
    
    def get_session(self):
        """Retorna nova sessão do banco."""
        return self.SessionLocal()
    
    @contextmanager
    def session_scope(self):
        """Context manager para sessões com commit/rollback automático."""
        session = self.get_session()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()

# Repository base
from abc import ABC, abstractmethod
from typing import List, Optional, TypeVar, Generic

T = TypeVar('T')

class BaseRepository(ABC, Generic[T]):
    """Repository base com operações CRUD."""
    
    def __init__(self, db_manager: DatabaseManager, model_class):
        self.db_manager = db_manager
        self.model_class = model_class
    
    def criar(self, obj: T) -> T:
        """Cria novo registro."""
        with self.db_manager.session_scope() as session:
            db_obj = self._to_db_model(obj)
            session.add(db_obj)
            session.flush()  # Para obter o ID
            return self._from_db_model(db_obj)
    
    def buscar_por_id(self, obj_id: str) -> Optional[T]:
        """Busca registro por ID."""
        with self.db_manager.session_scope() as session:
            db_obj = session.query(self.model_class).filter(
                self.model_class.id == obj_id
            ).first()
            
            return self._from_db_model(db_obj) if db_obj else None
    
    def listar_todos(self) -> List[T]:
        """Lista todos os registros."""
        with self.db_manager.session_scope() as session:
            db_objs = session.query(self.model_class).all()
            return [self._from_db_model(db_obj) for db_obj in db_objs]
    
    def atualizar(self, obj: T) -> T:
        """Atualiza registro existente."""
        with self.db_manager.session_scope() as session:
            db_obj = session.query(self.model_class).filter(
                self.model_class.id == obj.id
            ).first()
            
            if not db_obj:
                raise ValueError(f"Registro com ID {obj.id} não encontrado")
            
            self._update_db_model(db_obj, obj)
            return self._from_db_model(db_obj)
    
    def deletar(self, obj_id: str) -> bool:
        """Deleta registro por ID."""
        with self.db_manager.session_scope() as session:
            db_obj = session.query(self.model_class).filter(
                self.model_class.id == obj_id
            ).first()
            
            if db_obj:
                session.delete(db_obj)
                return True
            return False
    
    @abstractmethod
    def _to_db_model(self, obj: T):
        """Converte objeto de domínio para modelo do banco."""
        pass
    
    @abstractmethod
    def _from_db_model(self, db_obj) -> T:
        """Converte modelo do banco para objeto de domínio."""
        pass
    
    @abstractmethod
    def _update_db_model(self, db_obj, obj: T):
        """Atualiza modelo do banco com dados do objeto de domínio."""
        pass

# Repository específico para clientes
class ClienteRepository(BaseRepository[Cliente]):
    """Repository para clientes."""
    
    def __init__(self, db_manager: DatabaseManager):
        super().__init__(db_manager, ClienteDB)
    
    def buscar_por_email(self, email: str) -> Optional[Cliente]:
        """Busca cliente por email."""
        with self.db_manager.session_scope() as session:
            db_obj = session.query(ClienteDB).filter(
                ClienteDB.email == email
            ).first()
            
            return self._from_db_model(db_obj) if db_obj else None
    
    def _to_db_model(self, cliente: Cliente) -> ClienteDB:
        return ClienteDB(
            id=cliente.id,
            nome=cliente.nome,
            email=cliente.email,
            telefone=cliente.telefone,
            endereco=cliente.endereco,
            limite_livros=cliente.limite_livros,
            ativo=cliente.ativo,
            multas_pendentes=cliente.multas_pendentes
        )
    
    def _from_db_model(self, db_obj: ClienteDB) -> Cliente:
        cliente = Cliente(
            nome=db_obj.nome,
            email=db_obj.email,
            telefone=db_obj.telefone,
            endereco=db_obj.endereco,
            limite_livros=db_obj.limite_livros
        )
        
        # Definir propriedades que não são passadas no construtor
        cliente._id = db_obj.id
        cliente._ativo = db_obj.ativo
        cliente._multas_pendentes = db_obj.multas_pendentes
        cliente._data_cadastro = db_obj.data_cadastro
        
        return cliente
    
    def _update_db_model(self, db_obj: ClienteDB, cliente: Cliente):
        db_obj.nome = cliente.nome
        db_obj.email = cliente.email
        db_obj.telefone = cliente.telefone
        db_obj.endereco = cliente.endereco
        db_obj.limite_livros = cliente.limite_livros
        db_obj.ativo = cliente.ativo
        db_obj.multas_pendentes = cliente.multas_pendentes

# Integração com a biblioteca
class BibliotecaComBancoDados(Biblioteca):
    """Biblioteca integrada com banco de dados."""
    
    def __init__(self, nome: str, endereco: str = "", database_url: str = "sqlite:///biblioteca.db"):
        super().__init__(nome, endereco)
        self.db_manager = DatabaseManager(database_url)
        self.cliente_repo = ClienteRepository(self.db_manager)
        # Adicionar outros repositories conforme necessário
    
    def cadastrar_cliente(self, nome: str, email: str, telefone: str, 
                         endereco: str = "", limite_livros: int = 3) -> Cliente:
        """Cadastra cliente no banco de dados."""
        
        # Verificar se email já existe
        if self.cliente_repo.buscar_por_email(email):
            raise ValueError(f"Cliente com email {email} já existe")
        
        # Criar cliente
        cliente = Cliente(nome, email, telefone, endereco, limite_livros)
        
        # Salvar no banco
        cliente_salvo = self.cliente_repo.criar(cliente)
        
        # Adicionar à lista em memória (para compatibilidade)
        self._clientes.append(cliente_salvo)
        
        print(f"Cliente cadastrado no banco: {cliente_salvo.nome}")
        return cliente_salvo
    
    def buscar_cliente_por_email(self, email: str) -> Optional[Cliente]:
        """Busca cliente por email no banco de dados."""
        return self.cliente_repo.buscar_por_email(email)
    
    def listar_clientes_do_banco(self) -> List[Cliente]:
         """Lista todos os clientes do banco de dados."""
         return self.cliente_repo.listar_todos()
 ```

---

## 🌐 API REST com FastAPI

### Estrutura da API

```python
# api/main.py
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional
from datetime import datetime, date
import uvicorn

# Modelos Pydantic para API
class ClienteCreate(BaseModel):
    nome: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    telefone: str = Field(..., min_length=10, max_length=20)
    endereco: Optional[str] = ""
    limite_livros: int = Field(default=3, ge=1, le=10)

class ClienteResponse(BaseModel):
    id: str
    nome: str
    email: str
    telefone: str
    endereco: str
    limite_livros: int
    ativo: bool
    data_cadastro: datetime
    multas_pendentes: float
    
    class Config:
        from_attributes = True

class LivroCreate(BaseModel):
    titulo: str = Field(..., min_length=1, max_length=200)
    autor: str = Field(..., min_length=1, max_length=100)
    isbn: str = Field(..., min_length=10, max_length=13)
    categoria: str
    ano_publicacao: Optional[int] = Field(None, ge=1000, le=2030)
    editora: Optional[str] = Field(None, max_length=100)
    paginas: Optional[int] = Field(None, ge=1)

class LivroResponse(BaseModel):
    id: str
    titulo: str
    autor: str
    isbn: str
    categoria: str
    ano_publicacao: Optional[int]
    editora: Optional[str]
    paginas: Optional[int]
    status: str
    data_cadastro: datetime
    
    class Config:
        from_attributes = True

class EmprestimoCreate(BaseModel):
    cliente_id: str
    livro_id: str
    funcionario_id: str
    prazo_dias: int = Field(default=14, ge=1, le=90)
    observacoes: Optional[str] = ""

class EmprestimoResponse(BaseModel):
    id: str
    cliente_id: str
    livro_id: str
    funcionario_id: str
    data_emprestimo: datetime
    data_prevista_devolucao: datetime
    data_devolucao: Optional[datetime]
    status: str
    multa_aplicada: float
    observacoes: str
    
    class Config:
        from_attributes = True

# Configuração da aplicação
app = FastAPI(
    title="Sistema de Biblioteca",
    description="API REST para gerenciamento de biblioteca",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar domínios
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependência para obter instância da biblioteca
def get_biblioteca() -> BibliotecaComBancoDados:
    return BibliotecaComBancoDados(
        nome="Biblioteca Central",
        endereco="Rua das Flores, 123",
        database_url="sqlite:///biblioteca_api.db"
    )

# Endpoints para Clientes
@app.post("/clientes/", response_model=ClienteResponse, status_code=status.HTTP_201_CREATED)
async def criar_cliente(cliente_data: ClienteCreate, biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Cria um novo cliente."""
    try:
        cliente = biblioteca.cadastrar_cliente(
            nome=cliente_data.nome,
            email=cliente_data.email,
            telefone=cliente_data.telefone,
            endereco=cliente_data.endereco,
            limite_livros=cliente_data.limite_livros
        )
        return ClienteResponse.from_orm(cliente)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.get("/clientes/", response_model=List[ClienteResponse])
async def listar_clientes(biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Lista todos os clientes."""
    try:
        clientes = biblioteca.listar_clientes_do_banco()
        return [ClienteResponse.from_orm(cliente) for cliente in clientes]
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.get("/clientes/{cliente_id}", response_model=ClienteResponse)
async def obter_cliente(cliente_id: str, biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Obtém cliente por ID."""
    try:
        cliente = biblioteca.cliente_repo.buscar_por_id(cliente_id)
        if not cliente:
            raise HTTPException(status_code=404, detail="Cliente não encontrado")
        return ClienteResponse.from_orm(cliente)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.get("/clientes/email/{email}", response_model=ClienteResponse)
async def obter_cliente_por_email(email: str, biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Obtém cliente por email."""
    try:
        cliente = biblioteca.buscar_cliente_por_email(email)
        if not cliente:
            raise HTTPException(status_code=404, detail="Cliente não encontrado")
        return ClienteResponse.from_orm(cliente)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.put("/clientes/{cliente_id}", response_model=ClienteResponse)
async def atualizar_cliente(cliente_id: str, cliente_data: ClienteCreate, biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Atualiza dados do cliente."""
    try:
        cliente = biblioteca.cliente_repo.buscar_por_id(cliente_id)
        if not cliente:
            raise HTTPException(status_code=404, detail="Cliente não encontrado")
        
        # Atualizar dados
        cliente.nome = cliente_data.nome
        cliente.email = cliente_data.email
        cliente.telefone = cliente_data.telefone
        cliente.endereco = cliente_data.endereco
        cliente.limite_livros = cliente_data.limite_livros
        
        cliente_atualizado = biblioteca.cliente_repo.atualizar(cliente)
        return ClienteResponse.from_orm(cliente_atualizado)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.delete("/clientes/{cliente_id}", status_code=status.HTTP_204_NO_CONTENT)
async def deletar_cliente(cliente_id: str, biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Deleta cliente."""
    try:
        sucesso = biblioteca.cliente_repo.deletar(cliente_id)
        if not sucesso:
            raise HTTPException(status_code=404, detail="Cliente não encontrado")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

# Endpoints para Estatísticas
@app.get("/estatisticas/")
async def obter_estatisticas(biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Obtém estatísticas gerais da biblioteca."""
    try:
        stats = biblioteca.gerar_estatisticas_gerais()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

@app.get("/estatisticas/cache")
async def obter_estatisticas_cache(biblioteca: BibliotecaComBancoDados = Depends(get_biblioteca)):
    """Obtém estatísticas do cache."""
    try:
        if hasattr(biblioteca, 'estatisticas_cache'):
            return biblioteca.estatisticas_cache()
        else:
            return {"message": "Cache não disponível nesta instância"}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro interno do servidor")

# Middleware para logging
@app.middleware("http")
async def log_requests(request, call_next):
    start_time = datetime.now()
    response = await call_next(request)
    process_time = (datetime.now() - start_time).total_seconds()
    
    print(f"{request.method} {request.url} - {response.status_code} - {process_time:.3f}s")
    return response

# Handler para erros não tratados
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    print(f"Erro não tratado: {exc}")
    return HTTPException(status_code=500, detail="Erro interno do servidor")

# Endpoint de health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
```

### Cliente HTTP para Testes

```python
# tests/api_client.py
import requests
import json
from typing import Dict, Any, Optional

class BibliotecaAPIClient:
    """Cliente para interagir com a API da biblioteca."""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
    
    def _make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """Faz requisição HTTP."""
        url = f"{self.base_url}{endpoint}"
        response = self.session.request(method, url, **kwargs)
        return response
    
    # Métodos para clientes
    def criar_cliente(self, cliente_data: Dict[str, Any]) -> Dict[str, Any]:
        """Cria novo cliente."""
        response = self._make_request("POST", "/clientes/", json=cliente_data)
        response.raise_for_status()
        return response.json()
    
    def listar_clientes(self) -> List[Dict[str, Any]]:
        """Lista todos os clientes."""
        response = self._make_request("GET", "/clientes/")
        response.raise_for_status()
        return response.json()
    
    def obter_cliente(self, cliente_id: str) -> Dict[str, Any]:
        """Obtém cliente por ID."""
        response = self._make_request("GET", f"/clientes/{cliente_id}")
        response.raise_for_status()
        return response.json()
    
    def obter_cliente_por_email(self, email: str) -> Dict[str, Any]:
        """Obtém cliente por email."""
        response = self._make_request("GET", f"/clientes/email/{email}")
        response.raise_for_status()
        return response.json()
    
    def atualizar_cliente(self, cliente_id: str, cliente_data: Dict[str, Any]) -> Dict[str, Any]:
        """Atualiza cliente."""
        response = self._make_request("PUT", f"/clientes/{cliente_id}", json=cliente_data)
        response.raise_for_status()
        return response.json()
    
    def deletar_cliente(self, cliente_id: str) -> bool:
        """Deleta cliente."""
        response = self._make_request("DELETE", f"/clientes/{cliente_id}")
        return response.status_code == 204
    
    def obter_estatisticas(self) -> Dict[str, Any]:
        """Obtém estatísticas gerais."""
        response = self._make_request("GET", "/estatisticas/")
        response.raise_for_status()
        return response.json()
    
    def health_check(self) -> Dict[str, Any]:
        """Verifica saúde da API."""
        response = self._make_request("GET", "/health")
        response.raise_for_status()
        return response.json()

# Exemplo de uso
if __name__ == "__main__":
    client = BibliotecaAPIClient()
    
    # Verificar saúde da API
    print("Health check:", client.health_check())
    
    # Criar cliente
    novo_cliente = {
        "nome": "João Silva",
        "email": "joao@email.com",
        "telefone": "11999999999",
        "endereco": "Rua A, 123",
        "limite_livros": 5
    }
    
    try:
        cliente_criado = client.criar_cliente(novo_cliente)
        print("Cliente criado:", cliente_criado)
        
        # Listar clientes
        clientes = client.listar_clientes()
        print(f"Total de clientes: {len(clientes)}")
        
        # Obter estatísticas
        stats = client.obter_estatisticas()
        print("Estatísticas:", stats)
        
    except requests.exceptions.HTTPError as e:
        print(f"Erro HTTP: {e}")
    except Exception as e:
        print(f"Erro: {e}")
```

---

## 📋 Resumo e Próximos Passos

### O que Aprendemos

1. **Conceitos Fundamentais de OOP**:
   - Classes, objetos, atributos e métodos
   - Encapsulamento com propriedades
   - Herança e polimorfismo
   - Abstração com classes abstratas

2. **Recursos Avançados do Python**:
   - Métodos especiais (magic methods)
   - Decoradores (@property, @classmethod, @staticmethod)
   - Context managers
   - Metaclasses
   - Type hints

3. **Padrões de Design**:
   - Singleton para instâncias únicas
   - Factory Method para criação de objetos
   - Observer para notificações
   - Repository para acesso a dados

4. **Arquitetura e Boas Práticas**:
   - Separação de responsabilidades
   - Injeção de dependências
   - Sistema de plugins
   - Cache inteligente
   - Integração com banco de dados
   - API REST

### Próximos Passos

1. **Testes Avançados**:
   - Testes de integração com banco de dados
   - Testes de performance
   - Testes de carga na API
   - Mocking e fixtures

2. **Deploy e Produção**:
   - Containerização com Docker
   - Configuração de ambiente
   - Logging estruturado
   - Monitoramento e métricas
   - CI/CD

3. **Funcionalidades Adicionais**:
   - Sistema de autenticação e autorização
   - Notificações em tempo real
   - Relatórios avançados
   - Interface web
   - Mobile app

4. **Otimizações**:
   - Async/await para operações I/O
   - Conexão pool para banco de dados
   - Cache distribuído (Redis)
   - Balanceamento de carga
   - Microserviços

### Recursos para Estudo Contínuo

- **Documentação Oficial**: [docs.python.org](https://docs.python.org)
- **PEP 8**: Guia de estilo para Python
- **Design Patterns**: "Gang of Four" patterns
- **Clean Code**: Princípios de código limpo
- **SOLID Principles**: Princípios de design orientado a objetos
- **FastAPI Docs**: [fastapi.tiangolo.com](https://fastapi.tiangolo.com)
- **SQLAlchemy Docs**: [docs.sqlalchemy.org](https://docs.sqlalchemy.org)

---

**🎯 Parabéns!** Você completou um guia abrangente de Orientação a Objetos com Python, desde conceitos básicos até implementações avançadas com banco de dados e API REST. Continue praticando e explorando novos desafios!
        if not cliente.pode_emprestar_livro():
            raise ValueError("Cliente não pode emprestar livros no momento")
        
        if not livro.disponivel:
            raise ValueError(f"Livro não está disponível (status: {livro.status.value})")
        
        if prazo_dias <= 0 or prazo_dias > 30:
            raise ValueError("Prazo deve estar entre 1 e 30 dias")
        
        # Criar empréstimo
        emprestimo = Emprestimo(
            cliente_id=cliente.id,
            livro_id=livro.id,
            funcionario_id=funcionario.id,
            prazo_dias=prazo_dias
        )
        
        # Atualizar estados
        livro.emprestar()
        cliente.adicionar_emprestimo(emprestimo.id)
        self._emprestimos.append(emprestimo)
        
        print(f"Livro '{livro.titulo}' emprestado para {cliente.nome}")
        return emprestimo
    
    @log_operacao
    @requer_permissao('devolver')
    def devolver_livro(self, funcionario: Funcionario, emprestimo_id: str, 
                      observacoes: str = "") -> float:
        """Realiza devolução de um livro."""
        
        emprestimo = self.buscar_emprestimo_por_id(emprestimo_id)
        if not emprestimo:
            raise ValueError("Empréstimo não encontrado")
        
        if not emprestimo.ativo:
            raise ValueError("Empréstimo não está ativo")
        
        # Buscar cliente e livro
        cliente = self.biblioteca.buscar_cliente_por_id(emprestimo.cliente_id)
        livro = self.biblioteca.buscar_livro_por_id(emprestimo.livro_id)
        
        if not cliente or not livro:
            raise ValueError("Cliente ou livro não encontrado")
        
        # Processar devolução
        multa = emprestimo.devolver(observacoes)
        livro.devolver()
        cliente.remover_emprestimo(emprestimo_id)
        
        # Aplicar multa se houver
        if multa > 0:
            cliente.adicionar_multa(multa)
            print(f"Multa de R$ {multa:.2f} aplicada por atraso de {emprestimo.dias_atraso} dias")
        
        print(f"Livro '{livro.titulo}' devolvido por {cliente.nome}")
        return multa
    
    @log_operacao
    def prorrogar_emprestimo(self, emprestimo_id: str, dias_adicionais: int) -> bool:
        """Prorroga um empréstimo."""
        
        emprestimo = self.buscar_emprestimo_por_id(emprestimo_id)
        if not emprestimo:
            raise ValueError("Empréstimo não encontrado")
        
        if dias_adicionais <= 0 or dias_adicionais > 14:
            raise ValueError("Dias adicionais deve estar entre 1 e 14")
        
        sucesso = emprestimo.prorrogar(dias_adicionais)
        if sucesso:
            print(f"Empréstimo prorrogado por {dias_adicionais} dias")
        else:
            print("Não foi possível prorrogar o empréstimo")
        
        return sucesso
    
    def buscar_emprestimo_por_id(self, emprestimo_id: str) -> Optional[Emprestimo]:
        """Busca empréstimo por ID."""
        return next((e for e in self._emprestimos if e.id == emprestimo_id), None)
    
    def listar_emprestimos_ativos(self) -> List[Emprestimo]:
        """Lista todos os empréstimos ativos."""
        return [e for e in self._emprestimos if e.ativo]
    
    def listar_emprestimos_atrasados(self) -> List[Emprestimo]:
        """Lista empréstimos atrasados."""
        return [e for e in self._emprestimos if e.ativo and e.atrasado]
    
    def listar_emprestimos_cliente(self, cliente_id: str) -> List[Emprestimo]:
        """Lista empréstimos de um cliente específico."""
        return [e for e in self._emprestimos if e.cliente_id == cliente_id]
    
    def calcular_multas_pendentes(self, cliente_id: str) -> float:
        """Calcula total de multas pendentes de um cliente."""
        emprestimos_cliente = self.listar_emprestimos_cliente(cliente_id)
        total_multas = 0.0
        
        for emprestimo in emprestimos_cliente:
            if emprestimo.ativo and emprestimo.atrasado:
                total_multas += emprestimo.multa_calculada
            elif emprestimo.multa_aplicada > 0:
                total_multas += emprestimo.multa_aplicada
        
        return total_multas
    
    def gerar_relatorio_emprestimos(self, data_inicio: datetime = None, 
                                   data_fim: datetime = None) -> dict:
        """Gera relatório de empréstimos por período."""
        
        if not data_inicio:
            data_inicio = datetime.now() - timedelta(days=30)
        if not data_fim:
            data_fim = datetime.now()
        
        emprestimos_periodo = [
            e for e in self._emprestimos 
            if data_inicio <= e.data_emprestimo <= data_fim
        ]
        
        total_emprestimos = len(emprestimos_periodo)
        emprestimos_devolvidos = len([e for e in emprestimos_periodo if e.data_devolucao])
        emprestimos_atrasados = len([e for e in emprestimos_periodo if e.atrasado])
        total_multas = sum(e.multa_aplicada for e in emprestimos_periodo)
        
        return {
            'periodo': {
                'inicio': data_inicio.isoformat(),
                'fim': data_fim.isoformat()
            },
            'total_emprestimos': total_emprestimos,
            'emprestimos_devolvidos': emprestimos_devolvidos,
            'emprestimos_atrasados': emprestimos_atrasados,
            'taxa_devolucao': emprestimos_devolvidos / total_emprestimos if total_emprestimos > 0 else 0,
            'total_multas': total_multas,
            'emprestimos': [e.to_dict() for e in emprestimos_periodo]
        }
```

### Passo 6: Sistema Principal da Biblioteca

```python
# models/biblioteca.py
from typing import List, Optional, Dict
from datetime import datetime
from models.pessoa import Cliente, Funcionario
from models.livro import Livro, CategoriaLivro, StatusLivro
from services.emprestimo_service import EmprestimoService
from utils.decorators import log_operacao, cache_resultado

class Biblioteca:
    """Sistema principal da biblioteca."""
    
    def __init__(self, nome: str, endereco: str = ""):
        self.nome = nome
        self.endereco = endereco
        self._clientes: List[Cliente] = []
        self._funcionarios: List[Funcionario] = []
        self._livros: List[Livro] = []
        self._emprestimo_service = EmprestimoService(self)
        self._funcionario_logado: Optional[Funcionario] = None
    
    # === AUTENTICAÇÃO ===
    
    def fazer_login(self, email: str, senha: str) -> bool:
        """Realiza login de funcionário."""
        funcionario = self.buscar_funcionario_por_email(email)
        if funcionario and funcionario.verificar_senha(senha):
            self._funcionario_logado = funcionario
            print(f"Login realizado: {funcionario.nome} ({funcionario.cargo})")
            return True
        return False
    
    def fazer_logout(self):
        """Realiza logout."""
        if self._funcionario_logado:
            print(f"Logout: {self._funcionario_logado.nome}")
            self._funcionario_logado = None
    
    @property
    def funcionario_logado(self) -> Optional[Funcionario]:
        return self._funcionario_logado
    
    # === GESTÃO DE CLIENTES ===
    
    @log_operacao
    def cadastrar_cliente(self, nome: str, email: str, telefone: str, 
                         endereco: str = "", limite_livros: int = 3) -> Cliente:
        """Cadastra novo cliente."""
        
        # Verificar se email já existe
        if self.buscar_cliente_por_email(email):
            raise ValueError(f"Cliente com email {email} já existe")
        
        cliente = Cliente(nome, email, telefone, endereco, limite_livros)
        self._clientes.append(cliente)
        
        print(f"Cliente cadastrado: {cliente.nome}")
        return cliente
    
    def buscar_cliente_por_id(self, cliente_id: str) -> Optional[Cliente]:
        return next((c for c in self._clientes if c.id == cliente_id), None)
    
    def buscar_cliente_por_email(self, email: str) -> Optional[Cliente]:
        return next((c for c in self._clientes if c.email == email), None)
    
    def buscar_clientes_por_nome(self, nome: str) -> List[Cliente]:
        nome_lower = nome.lower()
        return [c for c in self._clientes if nome_lower in c.nome.lower()]
    
    def listar_clientes(self, apenas_ativos: bool = True) -> List[Cliente]:
        if apenas_ativos:
            return [c for c in self._clientes if c.ativo]
        return self._clientes.copy()
    
    # === GESTÃO DE FUNCIONÁRIOS ===
    
    @log_operacao
    def cadastrar_funcionario(self, nome: str, email: str, telefone: str,
                             cargo: str, salario: float, senha: str) -> Funcionario:
        """Cadastra novo funcionário."""
        
        if self.buscar_funcionario_por_email(email):
            raise ValueError(f"Funcionário com email {email} já existe")
        
        funcionario = Funcionario(nome, email, telefone, cargo, salario, senha)
        self._funcionarios.append(funcionario)
        
        print(f"Funcionário cadastrado: {funcionario.nome} ({funcionario.cargo})")
        return funcionario
    
    def buscar_funcionario_por_id(self, funcionario_id: str) -> Optional[Funcionario]:
        return next((f for f in self._funcionarios if f.id == funcionario_id), None)
    
    def buscar_funcionario_por_email(self, email: str) -> Optional[Funcionario]:
        return next((f for f in self._funcionarios if f.email == email), None)
    
    # === GESTÃO DE LIVROS ===
    
    @log_operacao
    def cadastrar_livro(self, titulo: str, autor: str, isbn: str,
                       categoria: CategoriaLivro, ano_publicacao: int,
                       editora: str = "", paginas: int = 0) -> Livro:
        """Cadastra novo livro."""
        
        # Verificar se ISBN já existe
        if self.buscar_livro_por_isbn(isbn):
            raise ValueError(f"Livro com ISBN {isbn} já existe")
        
        livro = Livro(titulo, autor, isbn, categoria, ano_publicacao, editora, paginas)
        self._livros.append(livro)
        
        print(f"Livro cadastrado: {livro.titulo}")
        return livro
    
    def buscar_livro_por_id(self, livro_id: str) -> Optional[Livro]:
        return next((l for l in self._livros if l.id == livro_id), None)
    
    def buscar_livro_por_isbn(self, isbn: str) -> Optional[Livro]:
        isbn_limpo = ''.join(c for c in isbn if c.isdigit())
        return next((l for l in self._livros if l.isbn == isbn_limpo), None)
    
    @cache_resultado(tempo_cache_segundos=60)
    def buscar_livros(self, termo: str = "", categoria: CategoriaLivro = None,
                     status: StatusLivro = None, apenas_disponiveis: bool = False) -> List[Livro]:
        """Busca livros com filtros."""
        
        livros_filtrados = self._livros.copy()
        
        # Filtro por termo de busca
        if termo:
            livros_filtrados = [l for l in livros_filtrados if l.buscar_por_termo(termo)]
        
        # Filtro por categoria
        if categoria:
            livros_filtrados = [l for l in livros_filtrados if l.categoria == categoria]
        
        # Filtro por status
        if status:
            livros_filtrados = [l for l in livros_filtrados if l.status == status]
        
        # Filtro apenas disponíveis
        if apenas_disponiveis:
            livros_filtrados = [l for l in livros_filtrados if l.disponivel]
        
        return livros_filtrados
    
    def listar_livros_populares(self, limite: int = 10) -> List[Livro]:
        """Lista livros mais bem avaliados."""
        livros_com_avaliacao = [l for l in self._livros if l.avaliacao_media > 0]
        return sorted(livros_com_avaliacao, 
                     key=lambda l: l.avaliacao_media, 
                     reverse=True)[:limite]
    
    # === EMPRÉSTIMOS ===
    
    def emprestar_livro(self, cliente_id: str, livro_id: str, prazo_dias: int = 14):
        """Empresta livro para cliente."""
        if not self._funcionario_logado:
            raise PermissionError("É necessário estar logado para emprestar livros")
        
        cliente = self.buscar_cliente_por_id(cliente_id)
        livro = self.buscar_livro_por_id(livro_id)
        
        if not cliente:
            raise ValueError("Cliente não encontrado")
        if not livro:
            raise ValueError("Livro não encontrado")
        
        return self._emprestimo_service.emprestar_livro(
            self._funcionario_logado, cliente, livro, prazo_dias
        )
    
    def devolver_livro(self, emprestimo_id: str, observacoes: str = ""):
        """Devolve livro emprestado."""
        if not self._funcionario_logado:
            raise PermissionError("É necessário estar logado para devolver livros")
        
        return self._emprestimo_service.devolver_livro(
            self._funcionario_logado, emprestimo_id, observacoes
        )
    
    # === RELATÓRIOS ===
    
    @cache_resultado(tempo_cache_segundos=300)
    def gerar_estatisticas_gerais(self) -> Dict:
        """Gera estatísticas gerais da biblioteca."""
        
        total_livros = len(self._livros)
        livros_disponiveis = len([l for l in self._livros if l.disponivel])
        livros_emprestados = len([l for l in self._livros if l.emprestado])
        
        total_clientes = len(self._clientes)
        clientes_ativos = len([c for c in self._clientes if c.ativo])
        
        emprestimos_ativos = len(self._emprestimo_service.listar_emprestimos_ativos())
        emprestimos_atrasados = len(self._emprestimo_service.listar_emprestimos_atrasados())
        
        return {
            'biblioteca': {
                'nome': self.nome,
                'endereco': self.endereco
            },
            'livros': {
                'total': total_livros,
                'disponiveis': livros_disponiveis,
                'emprestados': livros_emprestados,
                'taxa_utilizacao': livros_emprestados / total_livros if total_livros > 0 else 0
            },
            'clientes': {
                'total': total_clientes,
                'ativos': clientes_ativos
            },
            'emprestimos': {
                'ativos': emprestimos_ativos,
                'atrasados': emprestimos_atrasados,
                'taxa_atraso': emprestimos_atrasados / emprestimos_ativos if emprestimos_ativos > 0 else 0
            },
            'data_relatorio': datetime.now().isoformat()
        }
    
    def __str__(self) -> str:
        return f"Biblioteca {self.nome} - {len(self._livros)} livros, {len(self._clientes)} clientes"
```

---

## 🧪 Testes e Validação

### Testes Unitários

```python
# tests/test_biblioteca.py
import unittest
from datetime import datetime, timedelta
from models.biblioteca import Biblioteca
from models.livro import CategoriaLivro
from models.pessoa import Cliente, Funcionario

class TestBiblioteca(unittest.TestCase):
    
    def setUp(self):
        """Configuração inicial para cada teste."""
        self.biblioteca = Biblioteca("Biblioteca Central", "Rua das Flores, 123")
        
        # Criar funcionário para testes
        self.funcionario = self.biblioteca.cadastrar_funcionario(
            "Ana Silva", "ana@biblioteca.com", "11999999999",
            "bibliotecario", 3000.0, "senha123"
        )
        
        # Fazer login
        self.biblioteca.fazer_login("ana@biblioteca.com", "senha123")
        
        # Criar cliente para testes
        self.cliente = self.biblioteca.cadastrar_cliente(
            "João Santos", "joao@email.com", "11888888888"
        )
        
        # Criar livro para testes
        self.livro = self.biblioteca.cadastrar_livro(
            "Python para Iniciantes", "Autor Teste", "1234567890",
            CategoriaLivro.TECNOLOGIA, 2023
        )
    
    def test_cadastrar_cliente(self):
        """Testa cadastro de cliente."""
        cliente = self.biblioteca.cadastrar_cliente(
            "Maria Silva", "maria@email.com", "11777777777"
        )
        
        self.assertIsNotNone(cliente.id)
        self.assertEqual(cliente.nome, "Maria Silva")
        self.assertEqual(cliente.email, "maria@email.com")
        self.assertTrue(cliente.ativo)
    
    def test_cadastrar_cliente_email_duplicado(self):
        """Testa erro ao cadastrar cliente com email duplicado."""
        with self.assertRaises(ValueError):
            self.biblioteca.cadastrar_cliente(
                "Outro João", "joao@email.com", "11666666666"
            )
    
    def test_cadastrar_livro(self):
        """Testa cadastro de livro."""
        livro = self.biblioteca.cadastrar_livro(
            "Java Avançado", "Outro Autor", "0987654321",
            CategoriaLivro.TECNOLOGIA, 2022
        )
        
        self.assertIsNotNone(livro.id)
        self.assertEqual(livro.titulo, "Java Avançado")
        self.assertTrue(livro.disponivel)
    
    def test_emprestar_livro(self):
        """Testa empréstimo de livro."""
        emprestimo = self.biblioteca.emprestar_livro(
            self.cliente.id, self.livro.id
        )
        
        self.assertIsNotNone(emprestimo)
        self.assertTrue(emprestimo.ativo)
        self.assertTrue(self.livro.emprestado)
        self.assertIn(emprestimo.id, self.cliente.emprestimos_ativos)
    
    def test_devolver_livro(self):
        """Testa devolução de livro."""
        # Primeiro emprestar
        emprestimo = self.biblioteca.emprestar_livro(
            self.cliente.id, self.livro.id
        )
        
        # Depois devolver
        multa = self.biblioteca.devolver_livro(emprestimo.id)
        
        self.assertEqual(multa, 0.0)  # Sem atraso, sem multa
        self.assertTrue(self.livro.disponivel)
        self.assertNotIn(emprestimo.id, self.cliente.emprestimos_ativos)
    
    def test_buscar_livros(self):
        """Testa busca de livros."""
        # Busca por termo
        resultados = self.biblioteca.buscar_livros("Python")
        self.assertEqual(len(resultados), 1)
        self.assertEqual(resultados[0].titulo, "Python para Iniciantes")
        
        # Busca por categoria
        resultados = self.biblioteca.buscar_livros(
            categoria=CategoriaLivro.TECNOLOGIA
        )
        self.assertEqual(len(resultados), 1)
    
    def test_estatisticas_gerais(self):
        """Testa geração de estatísticas."""
        stats = self.biblioteca.gerar_estatisticas_gerais()
        
        self.assertEqual(stats['livros']['total'], 1)
        self.assertEqual(stats['livros']['disponiveis'], 1)
        self.assertEqual(stats['clientes']['total'], 1)
        self.assertIn('data_relatorio', stats)

class TestModelos(unittest.TestCase):
    
    def test_validacao_email_cliente(self):
        """Testa validação de email."""
        with self.assertRaises(ValueError):
            Cliente("Nome", "email_invalido", "11999999999")
    
    def test_validacao_isbn_livro(self):
        """Testa validação de ISBN."""
        with self.assertRaises(ValueError):
            from models.livro import Livro
            Livro("Título", "Autor", "123", CategoriaLivro.FICCAO, 2023)
    
    def test_calculo_multa_emprestimo(self):
        """Testa cálculo de multa por atraso."""
        from models.emprestimo import Emprestimo
        
        # Criar empréstimo com data no passado
        emprestimo = Emprestimo("cliente_id", "livro_id", "funcionario_id", 1)
        
        # Simular atraso alterando data de empréstimo
        emprestimo._data_emprestimo = datetime.now() - timedelta(days=20)
        emprestimo._data_prevista_devolucao = datetime.now() - timedelta(days=5)
        
        self.assertTrue(emprestimo.atrasado)
        self.assertEqual(emprestimo.dias_atraso, 5)
        self.assertEqual(emprestimo.multa_calculada, 10.0)  # 5 dias * R$ 2,00

if __name__ == '__main__':
    unittest.main()
```

### Testes de Integração

```python
# tests/test_integracao.py
import unittest
from datetime import datetime, timedelta
from models.biblioteca import Biblioteca
from models.livro import CategoriaLivro

class TestIntegracao(unittest.TestCase):
    
    def setUp(self):
        self.biblioteca = Biblioteca("Biblioteca Teste")
        
        # Setup completo do sistema
        self.funcionario = self.biblioteca.cadastrar_funcionario(
            "Admin", "admin@test.com", "11999999999",
            "admin", 5000.0, "admin123"
        )
        
        self.biblioteca.fazer_login("admin@test.com", "admin123")
        
        # Múltiplos clientes
        self.clientes = []
        for i in range(3):
            cliente = self.biblioteca.cadastrar_cliente(
                f"Cliente {i+1}", f"cliente{i+1}@test.com", f"1199999999{i}"
            )
            self.clientes.append(cliente)
        
        # Múltiplos livros
        self.livros = []
        categorias = [CategoriaLivro.FICCAO, CategoriaLivro.TECNOLOGIA, CategoriaLivro.CIENCIA]
        for i, categoria in enumerate(categorias):
            livro = self.biblioteca.cadastrar_livro(
                f"Livro {i+1}", f"Autor {i+1}", f"123456789{i}",
                categoria, 2020 + i
            )
            self.livros.append(livro)
    
    def test_fluxo_completo_emprestimo(self):
        """Testa fluxo completo de empréstimo e devolução."""
        cliente = self.clientes[0]
        livro = self.livros[0]
        
        # Estado inicial
        self.assertTrue(livro.disponivel)
        self.assertEqual(len(cliente.emprestimos_ativos), 0)
        
        # Emprestar
        emprestimo = self.biblioteca.emprestar_livro(cliente.id, livro.id)
        
        # Verificar estado após empréstimo
        self.assertTrue(livro.emprestado)
        self.assertEqual(len(cliente.emprestimos_ativos), 1)
        self.assertTrue(emprestimo.ativo)
        
        # Devolver
        multa = self.biblioteca.devolver_livro(emprestimo.id)
        
        # Verificar estado após devolução
        self.assertTrue(livro.disponivel)
        self.assertEqual(len(cliente.emprestimos_ativos), 0)
        self.assertEqual(multa, 0.0)
        self.assertFalse(emprestimo.ativo)
    
    def test_limite_emprestimos_cliente(self):
        """Testa limite de empréstimos por cliente."""
        cliente = self.clientes[0]
        
        # Emprestar até o limite (3 livros)
        for i in range(3):
            self.biblioteca.emprestar_livro(cliente.id, self.livros[i].id)
        
        # Tentar emprestar o 4º livro (deve falhar)
        with self.assertRaises(ValueError):
            # Precisamos de um 4º livro
            livro_extra = self.biblioteca.cadastrar_livro(
                "Livro Extra", "Autor Extra", "9999999999",
                CategoriaLivro.FICCAO, 2024
            )
            self.biblioteca.emprestar_livro(cliente.id, livro_extra.id)
    
    def test_busca_avancada_livros(self):
        """Testa funcionalidades de busca."""
        # Busca por categoria
        livros_ficcao = self.biblioteca.buscar_livros(
            categoria=CategoriaLivro.FICCAO
        )
        self.assertEqual(len(livros_ficcao), 1)
        
        # Busca por termo
        livros_autor1 = self.biblioteca.buscar_livros("Autor 1")
        self.assertEqual(len(livros_autor1), 1)
        
        # Emprestar um livro e buscar apenas disponíveis
        self.biblioteca.emprestar_livro(
            self.clientes[0].id, self.livros[0].id
        )
        
        liv