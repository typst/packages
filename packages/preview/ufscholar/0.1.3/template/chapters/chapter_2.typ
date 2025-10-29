#import "@preview/ufscholar:0.1.3": *

= Desenvolvimento

*Instruções do padrão genérico de @tcc:pl da BU:*

Deve-se inserir texto entre as seções.

== Exposição do tema ou matéria

É a parte principal e mais extensa do trabalho. Deve apresentar a fundamentação teórica, a metodologia, os resultados e a discussão. Divide-se em seções e subseções conforme a NBR 6024 (*NBR6024:2012*).

Quanto à sua estrutura e projeto gráfico, segue as recomendações da @abnt para preparação de trabalhos acadêmicos, a NBR 14724, de 2011 (*NBR14724:2011*).

#figure(
  label: "fig:elementos-trabalho",
  source: "Universidade Federal do Paraná (1996)",
  caption: "Elementos do trabalho acadêmico",
)[
  #image("../assets/images/elements-trabalho-academico.png", width: 70%)
]

=== Formatação do texto

No que diz respeito à estrutura do trabalho, recomenda-se que:

+ o texto deve ser justificado, digitado em cor preta, podendo utilizar outras cores somente para as ilustrações;
+ utilizar papel branco ou reciclado para impressão;
+ os elementos pré-textuais devem iniciar no anverso da folha, com exceção da ficha catalográfica ou ficha de identificação da obra;
+ os elementos textuais e pós-textuais devem ser difitados no anverso e verso das folhas, quando o trabalho for impresso. As seções primárias devem começar sempre em páginas ímpares, quando o trabalho for impresso. Deixar um espaço entre o título da seção/subseção e o texto e entre o texto e o título da subseção.

Na @tab:formatacao-texto estão as especificações para a formatação do texto.


#figure(
  label: "tab:formatacao-texto",
  caption: [Formatação do texto.],
  source: [*NBR14724:2011*],
  table(
    columns: 2,
    stroke: black.lighten(30%) + 0.6pt,

    table.header([Objeto], [Regra]),

    [Formato do papel], [A4],

    [Impressão],
    [A norma recomenda que caso seja necessário imprimir, deve-se utilizar a frente e o verso da página.],

    [Margens],
    [Superior: 3, Inferior: 2, Interna: 3 e Externa: 2. Usar margens espelhadas quando o trabalho for impresso.],

    [Paginação],
    [As páginas dos elementos pré-textuais devem ser contadas, mas não numeradas. Para trabalhos digitados somente no anverso, a numeração das páginas deve constar no canto superior direito da página, a 2 cm da borda, figurando a partir da primeira folha da parte textual. Para trabalhos digitados no anverso e no verso, a numeração deve constar no canto superior direito, no anverso, e no canto superior esquerdo no verso.],

    [Espaçamento],
    [O texto deve ser redigido com espaçamento entre linhas 1,5, excetuando-se as citações de mais de três linhas, notas de rodapé, referências, legendas das ilustrações e das tabelas, e a natureza (tipo do trabalho, objetivo, nome da instituição a que é submetido e área de concentração), que devem ser digitados em espaço simples, com fonte menor. As referências devem ser separadas entre si por um espaço simples em branco.],

    [Paginação],
    [A contagem inicia na folha de rosto, mas se insere o número da página a partir da introdução até o final do trabalho.],

    [Fontes sugeridas],
    [Arial ou Times New Roman.],

    [Tamanho da fonte],
    [Fonte tamanho 12 para o texto, incluindo os títulos das seções e subseções. As citações com mais de três linhas, notas de rodapé, paginação, dados internacionais de catalogação, legendas e fontes das ilustrações e das tabelas devem ser de tamanho menor. Adotamos, neste template, fonte tamanho 10.],

    [Nota de rodapé],
    [Devem ser digitadas dentro da margem, ficando separadas por um espaço simples entre as linhas e por filete de 5 cm a partir da margem esquerda. A partir da segunda linha, devem ser alinhadas abaixo da primeira letra da primeira palavra da primeira linha.],
  )
)

==== As ilustrações

Independentemente do tipo de ilustração (quadro, desenho, figura, fotografia, mapa, entre outros), a sua identificação aparece na parte superior, precedida da palavra designativa.

#quote(block: true)[
  Após a ilustração, na parte inferior, indicar a fonte consultada (elemento obrigatório, mesmo que seja produção do próprio autor), legenda, notas e outras informações necessárias à sua compreensão (se houver). A ilustração deve ser citada no texto e inserida o mais próximo possível do texto a que se refere. (*NBR14724:2011*)
]

==== Equações e fórmulas

As equações e fórmulas devem ser destacadas no texto para facilitar a leitura. Para numerá-las, usar algarismos arábicos entre parênteses e alinhados à direita. Pode-se adotar uma entrelinha maior do que a usada no texto (*NBR14724:2011*).

Exemplos, @eq:ex1 e @eq:ex2. Observe que o comando `\gls{}` é usado para criar um _hyperlink_ com a definição do símbolo na lista de símbolos.

$ #gls("circum", long: false) = 2 #gls("pi", long: false) #gls("radius", long: false) sqrt(gamma) + 10. $ <eq:ex1>

$ #gls("area", long: false) = #gls("pi", long: false) #gls("radius", long: false)^2. $ <eq:ex2>

#noindent[
  Aqui não há recuo porque o parágrafo não terminou, apenas foi iniciada uma nova frase após a equação. As equações fazem parte do texto, portanto estão sujeitas à pontuação (ponto final, vírgula, etc.).
]

===== Exemplo tabela

De acordo com *ibge1993*, tabela é uma forma não discursiva de apresentar informações em que os números representam a informação central. Ver @tab:ibge.

#figure(
  label: "tab:ibge",
  caption: [Médias concentrações urbanas 2010-2011.],
  source: [*ibge2016*],
  table(
    columns: (1.1fr, auto, auto, 1fr, 1fr, 1fr),

    table.header(
      [Média concentração urbana],
      table.cell(colspan: 2)[População],
      [Produto Interno Bruto -- PIB (bilhões R\$)],
      [Número de empresas],
      [Número de unidades locais]
    ),

    [*Nome*],
    [*Total*],
    [*No Brasil*],
    [],
    [],
    [],

    [Ji-Paraná (RO)],
    [116610],
    [116 610],
    [1,686],
    [2 734],
    [3 082],

    [Parintins (AM)],
    [102 033],
    [102 033],
    [0,675],
    [634],
    [683],

    [Boa Vista (RR)],
    [298 215],
    [298 215],
    [4,823],
    [4 852],
    [5 187],

    [Bragança (PA)],
    [113 227],
    [113 227],
    [0.452],
    [654],
    [686]
  ),
)
