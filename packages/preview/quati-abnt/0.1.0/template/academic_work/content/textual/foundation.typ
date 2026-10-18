#import "../../components.typ": *
#import "../../packages.typ": *


= Fundamentação teórica <capítulo:fundamentação>


== Notas

Você pode adicionar notas de editor para comunicar com seus colaboradores o progresso do trabalho.

No momento de exportar seu trabalho, lembre-se de desativar a exibição das notas.
Faça isso alterando a definição do modelo no arquivo `/main.typ`.
Defina o parâmetro `should_display_editor_notes: false`.

Para incluir uma nota auxiliar, deve-se utilizar um dos ambientes de definição de nota.

O primeiro ambiente é o `editor_note`.
Ele permite abrir uma caixa de texto, na qual você pode escrever sua nota.

#editor_note[
  Nota criada com o comando `editor_note`.
]

Você também pode definir os seguintes parâmetros nas notas:
+ `fill`: cor de preenchimento da nota;
+ `stroke`: definições da borda da nota.

#editor_note(
  fill: red.lighten(75%),
  stroke: red,
)[
  Nota criada com o comando `editor_note`, definindo as cores de preenchimento e da borda.
]

=== Notas prefixadas

Você pode criar uma nota com um prefixo.
Para isso, utilize o comando `editor_note`, definindo o parâmetro `prefixes` com o texto desejado no parâmetro `body`.

#editor_note(
  prefixes: (body: [Prefixo]),
)[
  Nota prefixada.
]

==== Personalização de notas prefixadas

Você pode definir os demais atributos normalmente para uma nota com prefixo.
+ Se definir uma cor com o parâmetro `fill`, o prefixo utilizará um tom mais acinzentado dessa mesma cor.
+ Já a cor do parâmetro `stroke` é utilizada com o mesmo tom para a borda do prefixo.

#editor_note(
  fill: yellow,
  prefixes: (body: [Prefixo]),
  stroke: blue,
)[
  Nota prefixada.
  Ela define a cor do preenchimento da nota como amarelo e sua borda como azul.
]

Você também pode definir a cor do prefixo diretamente, utilizando o parâmetro `fill` dentro da sua definição.

#editor_note(
  prefixes: (
    body: [Prefixo],
    fill: yellow,
  ),
)[
  Nota prefixada.
  Ela define diretamente a cor do prefixo como amarelo.
]

Sinta-se livre para editar cada uma dessas propriedades independentemente.

#editor_note(
  fill: blue.lighten(80%),
  stroke: blue.lighten(60%),
  prefixes: (
    body: [Prefixo],
    fill: yellow,
    stroke: yellow.darken(10%),
  ),
)[
  Nota prefixada.
  Ela define a cor da nota como azul claro, e a sua cor de borda como azul comum.
  Já o prefixo é preenchido com amarelo, e sua borda é um amarelo um pouco escurecido.
]

==== Uso de múltiplos prefixos

Uma nota pode ter vários prefixos.
Para fazer isso, basta preencher o parâmetro `prefixes` com uma lista de definições de `body` e os demais atributos de prefixo --- `fill`, e `stroke`.

#editor_note(
  prefixes: (
    (body: [Primeiro]),
    (body: [Segundo], fill: yellow),
    (body: [Terceiro], stroke: blue),
  ),
)[
  Nota colocada em linha.
  Ela inclui três prefixos.
]

=== Notas de estado

A biblioteca `quati_abnt` define algumas notas úteis para definir o estado de progressão de partes do texto.

A primeira é chamada `todo_note`, e deve ser utilizada para indicar um afazer que ainda não teve início.
#todo_note[
  Tarefa a fazer.
]

A segunda é chamada `progress_note`, e deve ser utilizada para indicar um afazer que teve início, mas ainda está em progresso.
#progress_note[
  Tarefa em progresso.
]

A terceira é chamada `done_note`, e deve ser utilizada para indicar um afazer que foi finalizado.
#done_note[
  Tarefa finalizada.
]

Você também pode definir novas notas de estado no arquivo `/components.typ`.
Neste modelo, definimos uma nota utilizada para indicar que se deve revisar determinado conteúdo, chamada `review_note`.
#review_note[
  Conteúdo que precisa ser revisado.
]

=== Notas de autores

Você também pode definir no arquivo `/components.typ` notas para cada um dos autores. Definimos neste guia notas para o Gabriel e para a Alice.

#note_from_gabriel[Nota do Gabriel.]
#note_from_alice[Nota da Alice.]

As notas de autores podem ser compostas com notas de estado. Para isso, defina o parâmetro `note` com o comando utilizado para criar a nota de estado desejada. O exemplo a seguir cria uma nota do tipo `todo_note` para o Gabriel.

#note_from_gabriel(
  note: todo_note,
)[
  Nota de afazeres do Gabriel.
]

=== Notas aninhadas

Se preferir, você ainda pode aninhar notas de diversas formas.

#editor_note[
  #todo_note[
    Nota de afazeres.
  ]
  #note_from_alice[
    Sugestão da Alice.
  ]
]

#todo_note[
  #note_from_gabriel[
    Nota do Gabriel.
  ]
  #note_from_alice[
    Nota da Alice.
  ]
]

Definimos mais duas notas padrão para representar discussões entre os editores.
A primeira, cujo comando é `open_discussion_note`, representa uma discussão ativa.

#open_discussion_note[
  #note_from_gabriel[
    Questionamento do Gabriel.
  ]
  #note_from_alice[
    Questionamento da Alice.
    #note_from_gabriel[
      Resposta do Gabriel.
    ]
  ]
]

Já o comando `closed_discussion_note` representa uma discussão já finalizada.

#closed_discussion_note[
  #note_from_gabriel[
    Comentário do Gabriel.
    #note_from_alice[
      Resposta da Alice.
      #note_from_gabriel[
        Réplica do Gabriel.
        #note_from_gabriel(note: todo_note)[
          Afazer do Gabriel baseado na discussão.
        ]
      ]
    ]
  ]
]


== Glossário

A @abnt define três tipos de listas de termos, cada uma com sua finalidade específica.
Todas são opcionais.
A primeira delas é a de abreviaturas e siglas, que deve constar nos elementos pré-textuais.
A segunda é a de símbolos, que também deve constar nos elementos pré-textuais.
A terceira é a lista de termos e definições, que deve constar nos elementos pós-textuais.

Caso um termo tenha uma forma curta e uma longa, a biblioteca irá expandir as duas formas na primeira vez em que você utilizar esse termo.
Nas seguintes, apenas as formas curtas aparecerão.

Você pode definir os elementos dessas listas no arquivo `/data/glossary.typ`.

=== Lista de abreviaturas e siglas

Observe exemplos de termos que representam abreviaturas ou siglas.

#list(
  [@abnt],
  [@ibge],
  [@bi],
)

=== Lista de símbolos

Observe exemplos de  termos que representam símbolos.
É recomendado que eles apresentem uma entrada de descrição, que será exibida no glossário.

#list(
  [@emptyset],
)

=== Lista de termos e definições no glossário

Observe exemplos de demais termos registrados no glossário.

#list(
  [@firewall],
  [@aprendizado_maquina],
  [@fitness],
)

=== Lista de termos simples, não adicionados ao glossário

Caso você utilize bastante algum termo, mas não deseja que ele seja colocado em nenhuma lista de glossário, você pode defini-lo como um termo útil.

Para isso, inclua-os no arquivo `/data/terms.typ`.
Então, você pode inseri-los no texto com o comando `get_term`.

Você também pode definir formas no plural e com letras maiúsculas.se caso, utilize os atributos `plural` e `capitalize` para acessá-las.

#list(
  [#get_term("script")],
  [#get_term("software")],
  [#get_term("web")],
  [#get_term("link")],
  [#get_term("link", capitalize: true)],
  [#get_term("link", plural: true)],
  [#get_term("link", capitalize: true, plural: true)],
)
