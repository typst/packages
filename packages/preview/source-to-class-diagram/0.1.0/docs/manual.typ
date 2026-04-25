// =============================================================================
// source-to-class-diagram — Manual
// =============================================================================

#import "../src/lib.typ": class-diagram, setup-classuml

#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "Segoe UI", size: 11pt)
#set heading(numbering: "1.1.")
#show heading.where(level: 1): h => {
  pagebreak(weak: true)
  block(above: 1.5em, below: 0.8em, h)
}
#show raw: it => {
  if it.block {
    block(
      fill: luma(245),
      radius: 4pt,
      inset: (x: 10pt, y: 8pt),
      text(font: "Cascadia Code", size: 9.5pt, it),
    )
  } else {
    box(fill: luma(245), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt, it)
  }
}

// NÃO aplicar setup-classuml globalmente no manual para que os exemplos de
// código não sejam renderizados como diagramas. Use #class-diagram() onde
// quiser exibir um diagrama de verdade.

// Capa
#align(center)[
  #v(6em)
  #text(size: 28pt, weight: "bold")[source-to-class-diagram]
  #v(0.6em)
  #text(size: 14pt, fill: luma(60))[
    Geração de Diagramas de Classe UML a partir de código-fonte
  ]
  #v(0.4em)
  #text(size: 10pt, fill: luma(100))[Manual de Referência]
  #v(4em)
]

#pagebreak()

// Índice
#outline(depth: 2, indent: 1.5em)

// ===========================================================================
= Visão Geral

*source-to-class-diagram* é um pacote Typst que gera diagramas de classe UML diretamente
de código-fonte Java ou C\#, sem necessidade de notação PlantUML ou DDL
específica. O pacote:

- *Infere relacionamentos* (herança, implementação, associação, agregação,
  composição) a partir da leitura do código-fonte real.
- *Renderiza* a caixa de classe com atributos, métodos e estereótipos (`«interface»`,
  `«enum»`, `«abstract»`).
- *Posiciona* as classes em um layout automático com suporte a posicionamento
  manual via anotação `@Layout`.
- *Escala* o diagrama para caber na largura disponível e, opcionalmente,
  em uma altura máxima definida pelo autor.

// ===========================================================================
= Instalação

Copie a pasta `src/` do pacote para o seu projeto e importe `lib.typ`:


```typst
#import "@preview/source-to-class-diagram:0.1.0": setup-classuml, class-diagram
```

// ===========================================================================
= Formas de Uso

== Via code fences (show-rule)

Ative o interceptador de code fences com `setup-classuml` e use blocos de
código com a linguagem correta. *Importante: não inclua `\#show: setup-classuml`
em documentos onde você quer mostrar exemplos de código sem renderizá-los —
prefira a função direta nesses casos.*

```typst
#import "@preview/source-to-class-diagram:0.1.0": setup-classuml
#show: setup-classuml
```

Em seguida, use blocos de código com a linguagem correspondente:

````typst
```class-diagram-java
class Produto {
  private String nome;
  private double preco;
  public String getNome() {}
}
```
````

As linguagens suportadas são:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Fence language*], [*Gramática*],
  [`class-diagram-java`], [Código-fonte Java],
  [`class-diagram-csharp`], [Código-fonte C\#],
)

=== Nota sobre fences aninhados em documentos de documentação

Em documentos como este manual, onde você quer *mostrar* exemplos de código
sem renderizá-los, há dois cuidados:

1. *Não aplique `\#show: setup-classuml` globalmente* — use `\#class-diagram()`
  onde quiser renderizar.
2. Para exibir um fence de 3 backticks *dentro* de um bloco de código, use
  *4 backticks* no fence externo:

`````typst
````typst
```class-diagram-java
class Foo {}
```
````
`````

== Via função `class-diagram`

Use a função diretamente para controlar parâmetros por diagrama:

```typst
#import "@preview/source-to-class-diagram:0.1.0": class-diagram

#class-diagram(
  "class Foo { private Bar bar; }",
  grammar: "java",
)
```

Parâmetros disponíveis:

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Parâmetro*], [*Padrão*], [*Descrição*],
  [`grammar`], [`"java"`], [Grammar: `"java"` ou `"csharp"`],
  [`theme`], [`auto`], [Tema visual],
  [`spacing`], [`(x: 4.0, y: 3.5)`], [Espaçamento entre caixas em unidades CeTZ],
  [`fit`], [`true`], [Escalar para caber na largura da página],
  [`max-height`], [`none`], [Altura máxima; o diagrama é reduzido se exceder],
)

=== Exemplo renderizado

#class-diagram(
  "class Produto {
  private String nome;
  private double preco;
  public String getNome() {}
}
class Estoque {
  private List<Produto> produtos;
  public Estoque() {
    produtos = new ArrayList<>();
  }
}",
  grammar: "java",
  max-height: 8cm,
)

// ===========================================================================
= Importando Arquivos de Código-Fonte

Em vez de colar código dentro do documento Typst, leia os arquivos `.java`
ou `.cs` diretamente com `read()`:

```typst
#import "@preview/source-to-class-diagram:0.1.0": class-diagram

#let src = (
  read("../tests/java/Alimentavel.java"),
  read("../tests/java/Animal.java"),
  read("../tests/java/Gato.java"),
  read("../tests/java/Cachorro.java"),
).join("\n\n")

#class-diagram(src, grammar: "java", max-height: 8cm)
```

Você pode intercalar strings literais com `read()` para injetar anotações
`@Layout` sem modificar os arquivos fonte:

```typst
#let src = (
  "@Layout(level=1, order=0)",
  read("../tests/java/Alimentavel.java"),
  read("../tests/java/Animal.java"),
  read("../tests/java/Gato.java"),
  read("../tests/java/Cachorro.java"),
).join("\n\n")

#class-diagram(src, grammar: "java", max-height: 8cm)
```
#let src = (
  "@Layout(level=1, order=0)",
  read("../tests/java/Alimentavel.java"),
  read("../tests/java/Animal.java"),
  read("../tests/java/Gato.java"),
  read("../tests/java/Cachorro.java"),
).join("\n\n")

#class-diagram(src, grammar: "java", max-height: 8cm)

// ===========================================================================
= Controle de Tamanho do Diagrama

== Ajuste à largura da página (`fit`)

Por padrão (`fit: true`), o diagrama é reduzido proporcionalmente para nunca
ultrapassar a largura disponível da página. Para desativar:

```typst
#class-diagram(src, grammar: "java", fit: false)
```

== Altura máxima (`max-height`)

O parâmetro `max-height` garante que o diagrama nunca ultrapasse uma altura
definida, evitando quebras de página indesejadas. Quando usado em conjunto
com `fit: true`, o menor dos dois fatores de escala é aplicado, mantendo
a proporção original:

```typst
// Diagrama nunca ocupa mais de 15 cm de altura
#class-diagram(src, grammar: "java", max-height: 15cm)

// Combinando largura e altura
#class-diagram(src, grammar: "java", fit: true, max-height: 12cm)
```

Se definido via `setup-classuml`, aplica-se a todos os diagramas do documento:

```typst
#show: setup-classuml.with(max-height: 18cm)
```

// ===========================================================================
= Posicionamento com `@Layout`

Por padrão, o layout é calculado com base nos relacionamentos. Para forçar
uma posição específica, use `@Layout` imediatamente antes da declaração da
classe:

```java
@Layout(level=0, order=0)
class Animal { ... }

@Layout(level=1, order=0)
class Cachorro extends Animal { ... }

@Layout(level=1, order=1)
class Gato extends Animal { ... }
```

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Propriedade*], [*Significado*],
  [`level`], [Linha vertical — 0 = topo; valores maiores ficam abaixo],
  [`order`], [Posição horizontal dentro do mesmo nível — 0 = esquerda],
)

Em C\#, use a sintaxe de atributo `[Layout(...)]` (Pascal Case):

```csharp
[Layout(Level = 0, Order = 0)]
public abstract class Animal { ... }

[Layout(Level = 1, Order = 0)]
public class Cachorro : Animal { ... }
```

// ===========================================================================
= Inferência de Relacionamentos

O parser analisa o código-fonte e infere os relacionamentos UML automaticamente.

== Herança e Implementação

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Java*], [*C\#*], [*Relação UML*],
  [`extends Foo`], [`: Foo`], [Herança (seta vazia)],
  [`implements IBar`], [`: IBar`], [Implementação (seta tracejada vazia)],
  [`throw new Exc()`], [`throw new Exc()`], [Dependência (seta tracejada)],
)

== Associação, Agregação e Composição

As relações são inferidas a partir dos campos da classe com promoção baseada
no comportamento do código:

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Situação no código*], [*Relação gerada*],
  [Campo do tipo `Foo` (não-primitivo)], [*Associação* — label = nome do campo],
  [`new Foo(...)` em qualquer ponto da classe], [Promove para *Composição*],
  [Parâmetro `Foo foo` no construtor], [Promove para *Agregação*],
)

A promoção *nunca desce de nível*: `associação → composição → agregação`.

*Exemplo:*
```java
class Pedido {
  private List<Item> itens;     // associação Pedido → Item (label: "itens")
                                // List<Item>: target é Item, não List
  public void addItem(String n) {
    itens.add(new Item(n));     // new Item() → promove para composição
  }
}

class Nota {
  private Pedido pedido;        // associação Nota → Pedido

  public Nota(Pedido pedido) {  // parâmetro do construtor → agora é agregação
    this.pedido = pedido;
  }
}
```

== Enums

Os valores do enum são listados como atributos na caixa UML:

```java
enum Porte {
  PEQUENO,
  MEDIO,
  GRANDE
}
```
#show: setup-classuml

```class-diagram-java
enum Porte {
  PEQUENO,
  MEDIO,
  GRANDE
}
```

// ===========================================================================
= Criando Novas Gramáticas

Para adicionar suporte a uma nova linguagem (ex: Kotlin), são necessários
apenas 3 passos.

== Passo 1 — Criar o arquivo de gramática

Crie `src/grammars/kotlin.typ` exportando uma função `parse`:

```typst
#import "../ir.typ"
#import "../parser/utils.typ" as putils

#let parse(source) = {
  let classes   = ()
  let relations = ()
  let packages  = ()

  // ... lógica de parsing ...

  ir.uml-diagram(classes: classes, relations: relations, packages: packages)
}
```

Construtores da IR disponíveis:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(230) } else { white },
  [*Função*], [*Parâmetros principais*],
  [`ir.uml-class(...)`], [`name`, `type` ∈ `"class"` `"abstract"` `"interface"` `"enum"`, `level`, `order`],
  [`ir.uml-member(...)`],
  [`name`, `return-type`, `visibility` ∈ `"public"` `"private"` `"protected"`, `kind` ∈ `"field"` `"method"`, `params`, `modifiers`],

  [`ir.uml-relation(...)`],
  [`from`, `to`, `type` ∈ `"inheritance"` `"implementation"` `"association"` `"aggregation"` `"composition"` `"dependency"`, `label`, `from-card`, `to-card`],
)

== Passo 2 — Registrar em `mod.typ`

```typst
// src/grammars/mod.typ
#import "java.typ"
#import "csharp.typ"
#import "kotlin.typ"         // ← novo

#let builtin-grammars = (
  java:   java.parse,
  csharp: csharp.parse,
  kotlin: kotlin.parse,      // ← novo
)
```

== Passo 3 — Registrar o code fence em `lib.typ`

```typst
// dentro de setup-classuml em src/lib.typ
show raw.where(lang: "class-diagram-kotlin"): it => {
  _render-diagram(it.text, grammar: "kotlin", ...)
}
```

A partir deste ponto:

````typst
```class-diagram-kotlin
data class Produto(val nome: String)
```
````

Ou com a função:
```typst
#class-diagram(src, grammar: "kotlin")
```

=== Utilitários disponíveis

```typst
#import "../parser/utils.typ" as putils

putils.is-primitive-type("String")    // → true
putils.is-primitive-type("Produto")   // → false
putils.extract-between(str, "(", ")") // extrai conteúdo entre delimitadores
```

=== Cuidado: mutação em closures (Typst Gotcha)

Em Typst, *closures não conseguem mutar variáveis do escopo externo*. Faça
todos os `push` para `relations`, `classes` etc. *inline no loop principal*,
nunca dentro de funções auxiliares:

```typst
// ❌ Errado — flush() não consegue mutar `relations`
let flush = () => { relations.push(...) }
flush()

// ✓ Certo — push inline, sem delegação
for (target, rel) in field-rels {
  relations.push(ir.uml-relation(...))
}
```

