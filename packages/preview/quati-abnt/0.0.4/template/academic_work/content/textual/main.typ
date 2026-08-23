#import "../../components.typ": describe_figure, equation, note_from_alice, note_from_eduardo, todo_note
#import "../../util.typ": get_term

= Introdução <capitulo:introdução>

Este é o @capitulo:introdução, de introdução.

= Fundamentação teórica

== Citação

#quote(
  attribution: [
    @dumont:1918:o_que_eu_vi_o_que_nos_veremos[p. 15].
  ],
  block: true,
)[
  --- Quero um balão de cem metros cúbicos.

  Grande espanto!
  Creio mesmo que pensaram que eu era doido.
  Alguns meses depois, o "Brasil", com grande espanto de todos os entendidos, atravessava Paris, lindo na sua transparência, como uma grande bola de sabão
]

== Ilustração

#describe_figure(
  sticky: true,
  [
    #figure(
      caption: [
        Quadrado preto
      ],
      image(
        width: 4.75cm,
        "./../../assets/images/black_square.png",
      ),
    )<figura:quadrado_preto>
  ],
)

Esta é a @figura:quadrado_preto.

== Nota de rodapé

Exemplo de nota de rodapé
#footnote[
  #lorem(10)
].

== Nota de editor

#note_from_alice()[
  Nota da Alice.
]

#note_from_eduardo(note: todo_note)[
  Nota de afazeres do Eduardo.
]

== Texto mono-espaçado

```
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
sed do eiusmod tempor incididunt ut labore et dolore magnam
aliquam quaerat voluptatem.
```

== Equações

#describe_figure(
  // placement: auto,
)[
  #figure(
    supplement: "Esquema",
    kind: "scheme",
    caption: [
      Soma entre dois números.
    ],
  )[
    #equation(
      width: 41.82%,
    )[
      $ 1 + 1 = 2 $ <equação:soma>
    ]
  ]
]

== Glossário

Exemplo de uso de texto no glossário:
@rn.

Exemplo de uso de termo útil: #get_term("software").

= Material e métodos

= Resultados

= Considerações finais

= Título primário
== Título secundário
=== Título terciário
==== Título quaternário
===== Título quinário
