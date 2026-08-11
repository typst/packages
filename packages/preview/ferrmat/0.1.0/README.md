# FerrMat

**Ferramentas Matemáticas** — Caixas decorativas, ambientes matemáticos e código estilizado em português para [Typst](https://typst.app).

---

## Sobre o Projeto

O **FerrMat** é um pacote Typst que oferece componentes visuais e matemáticos com nomes em português. Inclui caixas coloridas estilo tcolorbox, ambientes de teoremas com numeração automática, operadores matemáticos em português, estilização de código e gráficos de Gantt.

Este pacote é o companheiro do **[ABNTyp](https://github.com/3sdras/abntyp)**, que cuida da formatação conforme normas ABNT. O FerrMat fornece componentes independentes de normas, que podem ser usados em qualquer documento Typst.

---

## Instalação

### Via Typst Universe (recomendado)

```typst
#import "@preview/ferrmat:0.1.0": *
```

### Via Clone Local

```bash
git clone https://github.com/3sdras/ferrmat.git
```

```typst
#import "caminho/para/ferrmat/lib.typ": *
```

---

## Módulos

### Caixas Coloridas (`caixas.typ`)

Caixas decorativas estilo tcolorbox com bordas, cores e numeração automática.

```typst
// Caixa simples
#caixa(titulo: "Informação", cor: blue)[
  Conteúdo da caixa.
]

// Caixa com borda completa
#caixa(titulo: "Aviso", cor: red, borda: "completa", raio: 4pt)[
  Conteúdo importante.
]

// Estilo reutilizável com numeração automática
#let nota = caixa-estilo(
  cor: orange,
  borda: "completa",
  raio: 3pt,
  prefixo: "Nota",
)
#nota[Lembre-se: $1$ não é considerado primo.]
```

### Ambientes Matemáticos (`matematica.typ`)

Ambientes de teoremas, definições, exemplos e provas com numeração automática e estilos configuráveis.

**Ambientes disponíveis:** `teorema`, `lema`, `corolario`, `proposicao`, `axioma`, `conjectura`, `afirmacao`, `definicao`, `notacao`, `propriedade`, `exemplo`, `problema`, `observacao`

```typst
#teorema(titulo: "Pitágoras")[
  Em todo triângulo retângulo, $a^2 = b^2 + c^2$.
]

#demonstracao[
  A demonstração clássica usa a comparação de áreas...
]

#definicao[
  Um número $p > 1$ é *primo* se seus únicos divisores são $1$ e $p$.
]

// Configurar estilo e numeração
#configurar-ambientes("cinza")          // "colorido", "cinza", "sem-caixa"
#show: configurar-numeracao("por-tipo", por-secao: true)
```

**Operadores em português:** `sen`, `tg`, `csc`, `ctg`, `arcsen`, `arctg`, `senh`, `tgh`, `mdc`, `mmc`

**Funções matemáticas:**

```typst
$fracao(a+b, c+d)$                      // fração vertical
$matriz(1, 2; 3, 4)$                    // matriz com parênteses
$colchete(1, 2; 3, 4)$                  // matriz com colchetes
$binomio(n, k)$                         // coeficiente binomial
$raiz(2)$  $raiz(3, 8)$                 // raiz quadrada / cúbica
$leibniz(y, x)$  $leibniz(y, x, 2)$    // derivadas de Leibniz
$parcial(f, x)$  $parcial(f, x, y)$    // derivadas parciais
$porPartes(x, se x > 0; -x, se x < 0)$ // função por partes
```

**Símbolos em português:** `integral`, `somatorio`, `produtorio`, `uniao`, `inter`, `vezes`, `implica`, `sse`, `portanto`, `paraTodo`, `existe`, letras gregas (`alfa`, `gama`, `teta`, etc.)

### Código Estilizado (`codigo.typ`)

```typst
// Código inline
O comando #codigo-inline(`print("hello")`) imprime uma saudação.

// Bloco de código com título e numeração de linhas
#codigo-bloco(
  lang: "python",
  titulo: "script.py",
  numerar-linhas: true,
  ```python
  def fatorial(n):
      if n <= 1:
          return 1
      return n * fatorial(n - 1)
  ```.text
)
```

### Cronograma de Gantt (`cronograma.typ`)

Gráficos de Gantt com tarefas, marcos, dependências e progresso (usa CeTZ).

```typst
#cronograma(
  hoje: data(15, 3, 2026),
  mostrar-dependencias: true,
  (
    tarefa("Planejamento", data(1, 3, 2026), data(7, 3, 2026),
      progresso: 100, cor: verde),
    tarefa("Design", data(5, 3, 2026), data(14, 3, 2026),
      progresso: 50, cor: azul),
    tarefa("Entrega", data(28, 3, 2026), data(28, 3, 2026),
      marco: true, cor: vermelho),
  ),
)
```

### Unidades e Números (`unidades.typ`)

Formatação de números e unidades SI em locale brasileiro, equivalente ao `siunitx` do LaTeX.

```typst
#num(3.14159)                          // 3,14159
#num(1234567)                          // 1 234 567
#num(2.998e8)                          // 2,998 × 10⁸
#qtd(9.81, "m/s^2")                    // 9,81 m/s²
#unidade("kg.m/s^2")                   // kg·m/s²
#faixa-qtd(20, 25, "°C")              // 20 °C a 25 °C
#ang(45, minutos: 30)                  // 45°30′
```

**Funções:** `num`, `unidade` (`un`), `qtd`, `faixa-num`, `faixa-qtd`, `lista-num`, `lista-qtd`, `ang`, `tablenum`, `declarar-unidade`, `configurar-numeros`

### Índice Remissivo (`indice.typ`)

Sistema de índice remissivo equivalente ao `makeidx` do LaTeX.

```typst
A #irem("derivada") derivada de uma função...
A #irem-def("integral") é definida como...    // exibe "integral" em negrito
#irem("velocidade", ver: "cinemática")         // remissiva "ver"

// No final do documento:
#imprimir-indice()
```

### Provas e Avaliações (`prova.typ`)

Módulo para criação de provas e testes, similar ao `exam.cls` do LaTeX.

```typst
#cabecalho-prova(
  instituicao: "UFJ", disciplina: "Cálculo I",
  professor: "Dr. Silva", data: "22/02/2026",
)
#questao(pontos: 2.5)[Calcule a derivada de $f(x) = x^2$.]
#alternativas("$2x$", "$x^2$", "$2$", "$0$")
#questao(pontos: 3.0)[Resolva a integral.]
#espaco-resposta(altura: 5cm)
#total-pontos()
```

**Funções:** `cabecalho-prova`, `questao`, `subquestao`, `alternativas`, `verdadeiro-falso`, `preencher-linhas`, `espaco-resposta`, `total-pontos`, `tabela-pontos`

### Anotações e Notas Marginais (`anotacoes.typ`)

Sistema de anotações TODO e notas marginais, similar ao `todonotes` do LaTeX.

```typst
#registrar-autores(("Alice": blue, "Bob": red))
#afazer(autor: "Alice")[Revisar esta seção.]
#urgente[Corrigir erro na fórmula!]
#nota-margem[Nota explicativa.]
#lista-de-tarefas()                    // sumário de pendências
#show: esconder-tarefas               // oculta tudo na versão final
```

### Formatação de Seções (`secoes.typ`)

Personalização de títulos de seções, equivalente ao `titlesec` do LaTeX.

```typst
#show heading.where(level: 1): formatar-secao.with(
  peso: "bold", tamanho: 16pt, forma: "bloco", quebra-pagina: true,
)
```

### Colunas e Grades (`colunas.typ`)

Wrappers em português para layout de colunas e grades.

```typst
#colunas(quantidade: 2)[Texto em duas colunas.]
#grade(colunas: (1fr, 1fr), [Célula 1], [Célula 2])
```

### Cores em Português (`cores.typ`)

Constantes de cores: `preto`, `branco`, `azul`, `vermelho`, `verde`, `amarelo`, `laranja`, `roxo`, `cinza`, `prata`, `azul-marinho`, `azul-petroleo`, `bordo`, `oliva`, `lima`, `agua`, `fucsia`, `oriental`

### Configuração de Página (`pagina.typ`)

```typst
#show: configurar-pagina.with(papel: "a4", margem: margem(superior: 3cm, inferior: 2cm))
#quebra-pagina()
```

---

## Dependências

- [CeTZ](https://typst.app/universe/package/cetz) 0.4.0 (para o módulo de cronograma)

---

## Licença

Distribuído sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE).

---

## Créditos

O FerrMat é uma adaptação do trabalho **"Uma breve introdução ao LaTeX 2e"** do Prof. Dr. **Lenimar Nunes de Andrade** (DM/UFPB), transpondo seu excelente material didático para o contexto do Typst.

---

_FerrMat — Ferramentas Matemáticas para Typst, com nomes em português._
