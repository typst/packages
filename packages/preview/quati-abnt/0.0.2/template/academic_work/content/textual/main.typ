#import "../../components.typ": describe_figure, note_from_alice, note_from_eduardo, todo_note
#import "../../util.typ": get_term

= Introdução <capitulo:introducao>

Este é o @capitulo:introducao, de introdução.

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

#describe_figure(
  sticky: true,
  [
    #figure(
      caption: [
        Quadrado preto
      ],
      image(
        width: 5cm,
        "../../assets/images/black_square.png",
      ),
    )<figura:figure_of_an_image_of_a_black_square>
  ],
)

#lorem(50)

#note_from_alice()[
  Nota da Alice.
]

#note_from_eduardo(note: todo_note)[
  Nota de afazeres do Eduardo.
]

Exemplo de uso de texto no glossário:
@rn.

= Fundamentação teórica

= Material e métodos

= Resultados

= Considerações finais
