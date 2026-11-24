#import "@preview/mkuipers-ulusofona:0.3.3": *

#chapter("Exemplos de Formatação", l: "exemplos")

#guidance[
Este anexo mostra como escrever listas, figuras, tabelas, referências cruzadas e citações bibliográficas neste modelo. Copie o código dos exemplos para os seus capítulos e elimine este anexo antes da entrega.
]

== Listas

=== Lista de itens (bullets)

Utilize `-` no início da linha para criar uma lista de itens, e indente para criar sub-itens:

- Primeiro item
  - Sub-item A
  - Sub-item B
    - Sub-sub-item
- Segundo item
- Terceiro item

=== Lista numerada

Utilize `+` para numeração automática:

+ Primeiro passo
  + Sub-passo
  + Outro sub-passo
+ Segundo passo
+ Terceiro passo

=== Lista de descrições

Utilize `/ Termo: descrição` para definições:

/ Requisito funcional: descreve o que o sistema deve fazer.
/ Requisito não-funcional: descreve como o sistema se deve comportar (desempenho, segurança, etc.).

== Figuras

As figuras devem ter legenda e uma etiqueta (`<fig-lisboa>`), para que possam ser referidas no texto com `@fig-lisboa`. A @fig-lisboa mostra um exemplo.

#figure(
  image("images/lisbon.jpg", width: 50%),
  caption: [Exemplo de figura com legenda.],
) <fig-lisboa>

Utilize `width` para ajustar o tamanho da imagem. Os ficheiros de imagem devem estar na pasta do projeto (por exemplo, em `chapters/images/`).

== Tabelas

As tabelas seguem a mesma lógica: legenda e etiqueta (`<tab-requisitos>`), referidas com `@tab-requisitos`. A @tab-requisitos mostra um exemplo de tabela de requisitos.

#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (center, left, center, center),
    table.header[*ID*][*Descrição*][*Tipo*][*Estado*],
    [R1], [O utilizador pode autenticar-se.], [Funcional], [Realizado],
    [R2], [O sistema responde em menos de 2 s.], [Não-funcional], [Parcial],
    [R3], [Exportação de relatórios em PDF.], [Funcional], [Não realizado],
  ),
  caption: [Exemplo de tabela de requisitos.],
) <tab-requisitos>

== Referências

=== Referências cruzadas

Pode referir capítulos e secções através de etiquetas: @intro apresenta a introdução e @testes descreve os testes e a validação. Para o fazer, atribua uma etiqueta ao capítulo com `#chapter("Título", l: "etiqueta")` ou a uma secção com `== Título <etiqueta>`.

=== Citações bibliográficas

As fontes são definidas em `bibliography.yaml` (formato Hayagriva) e citadas com `@chave`. Por exemplo, o regulamento do TFC @DEISI24 e o livro de Tanenbaum e Wetherall @TaWe20. Pode indicar a página: @TaWe20[p.~42]. A lista de referências é gerada automaticamente no fim do documento com as fontes citadas.

Exemplo de entrada em `bibliography.yaml`:

```yaml
TaWe20:
  type: book
  title: Computer Networks
  author:
    - Tanenbaum, Andrew
    - Wetherall, David
  publisher: Prentice Hall
  edition: 6
  date: 2020
```

=== Siglas e glossário

As siglas definidas em `glossary.yaml` expandem-se na primeira utilização e ficam abreviadas nas seguintes: #acr("TFC") e, de novo, #acr("TFC"). Utilize `#acrfull("TFC")` para forçar a forma completa.
