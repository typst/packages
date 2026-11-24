#import "../../components.typ": *
#import "../../packages.typ": *

= Material e métodos <capítulo:métodos>


== Citações <seção:citações>

Para incluir uma citação direta, utilize o comando `quote`.
Ele recebe um argumento posicional.
Devemos abrir colchetes após sua chamada e escrever dentro deles a citação.

=== Citação curta

A @abnt determina que uma citação curta, de até três linhas, deve ser inclusa em texto corrido.
Para incluir uma referência nessa forma, utilize o comando `cite_prose`.

==== Exemplo

No livro "O que eu vi, o que nós veremos",
#cite_prose(supplement: [p. 49], <dumont:1918:o_que_eu_vi_o_que_nos_veremos>) escreveu
#quote[
  Perguntar-me-á o leitor porque não o construí mais cedo, ao mesmo tempo que os meus dirigíveis
].

=== Citação longa

Para citações que ocupem mais que três linhas, devemos utilizar dois argumentos na chamada do comando `quote`.
O primeiro é o argumento `block`, que deve ser definido como `true`.

Outro argumento necessário é o `attribution`, em que podemos incluir qualquer texto para descrever a fonte da citação.

Nesse argumento, podemos usar uma das referências já definidas previamente na bibliografia em sua forma parentética.
Para isso, apenas utilize o símbolo `@` antes do nome da referência.

==== Exemplo

#quote(
  attribution: [@dumont:1918:o_que_eu_vi_o_que_nos_veremos[p. 49].],
  block: true,
)[
  Perguntar-me-á o leitor porque não o construí mais cedo, ao mesmo tempo que os meus dirigíveis.
  É que o inventor, como a natureza de Linneu, não faz saltos; progride de manso, evolui.
  Comecei por fazer-me bom piloto de balão livre e só depois ataquei o problema de sua dirigibilidade.
  Fiz-me bom aeronauta no manejo dos meus dirigíveis; durante muitos anos, estudei a fundo o motor a petróleo e só quando verifiquei que o seu estado de perfeição era bastante para fazer voar, ataquei o problema do mais pesado que o ar
]


== Ilustrações <seção:ilustrações>

De acordo com a seção 5.8 da @nbr:short 14724:2024, uma ilustração se trata da
#quote(attribution: <abnt:2025:nbr_14724_2024>)[
  designação genérica de imagem, que ilustra ou elucida um texto
].
Incluem-se nessa categoria desenhos, esquemas, fluxogramas,
fotografias, gráficos, mapas, organogramas, plantas, quadros, retratos, figuras e imagens #cite(<ibge:2023:manual_elaboracao_trabalhos>).

Acima de cada ilustração deve constar uma legenda que descreva brevemente seu conteúdo, iniciada em letra maiúscula e sem finalização com ponto final.
Ela deve ser precedida do termo que melhor a descreve, como "Figura", "Quadro", "Gráfico", etc., seguido de seu número sequencial #cite(<abnt:2025:nbr_14724_2024>).
Em geral, o Typst é capaz de identificar automaticamente o tipo de ilustração e gerar a legenda correta.

Para inserir uma ilustração, deve-se utilizar o comando `figure()`.
Ele recebe como parâmetros:
+ `caption`, a legenda da ilustração;
+ `supplement`, o termo descritor, caso o Typst não seja capaz de inferi-lo;
+ `kind`, o tipo da ilustração, caso seja não trivial, e
+ seu conteúdo;
+ além de demais parâmetros opcionais.

Em seguida está um exemplo de figura.

#figure(
  caption: [
    Ilustração composta de texto
  ],
  supplement: "Texto",
  kind: "text",
  par()[
    Essa ilustração se trata de uma sequência de frases.\
    Sim, uma ilustração pode ser composta de texto.\
    Ela pode ser utilizada para ilustrar uma ideia ou conceito.
  ],
)

O conteúdo de uma ilustração pode ser uma imagem, a qual deve ser inserida com o comando `image()`.
Ele recebe como parâmetro obrigatório o caminho do arquivo.
Já como opcionais elencam-se:
+ `width`: a largura, que pode ser especificada em centímetros ou em porcentagem em relação à pagina (como `50%`); e
+ `height`: a altura, que pode ser especificada da mesma forma.

Abaixo está um exemplo de ilustração composta por uma imagem, com largura de 10cm e altura de 5cm.
Ela é importada por meio do caminho relativo `./../../assets/images/black_square.png`, que deve ser ajustado de acordo com a estrutura do projeto.

#figure(
  caption: [
    Retângulo preto
  ],
  image(
    width: 10cm,
    height: 5cm,
    "./../../assets/images/black_square.png",
  ),
)

=== Ambiente de descrição

Todas as ilustrações devem ser citadas no texto e inseridas o mais próximo possível da sua primeira citação #cite(<abnt:2025:nbr_14724_2024>).

Para isso, deve-se atribuir um rótulo à ilustração.
Pode-se fazê-lo abrindo aspas angulares (`<>`) após o comando `figure()`, da seguinte forma: `<nome_da_ilustração>`.

Para a ilustração abaixo, o rótulo é `figura:quadrado_preto_sem_fonte`.
Então, para referenciá-la no texto, deve-se utilizar o comando `ref()`, que recebe como parâmetro o rótulo da ilustração.
Alternativamente, pode-se utilizar o caractere `@` seguido do rótulo.

Essa é uma referência para a #ref(<figura:quadrado_preto_sem_fonte>).
Essa também é uma referência para a @figura:quadrado_preto_sem_fonte.
#figure(
  caption: [
    Quadrado preto
  ],
  image(
    "./../../assets/images/black_square.png",
  ),
)<figura:quadrado_preto_sem_fonte>

A @nbr:short 14724:2024 determina que todas as ilustrações apresentem sua fonte.
Elas também podem contar com uma nota explicativa.
Ambas as informações devem ser apresentadas após a ilustração e alinhadas à sua margem esquerda.
Elas também  devem ser apresentadas em fonte menor que a do texto principal e limitadas pela largura da ilustração #cite(<abnt:2025:nbr_14724_2024>).

Para cumprir essa exigência, devemos utilizar o ambiente `describe_figure()` em torno da ilustração.
Esse comando recebe como parâmetros opcionais:
+ `source`: a fonte da ilustração; e
+ `note`: uma nota sobre a ilustração.

Caso a fonte não seja informada, ela será automaticamente preenchida com o texto "#source_for_content_created_by_authors()".

A @figura:quadrado_vermelho_com_fonte_implícita mostra o uso desses parâmetros.

#describe_figure(
  [
    #figure(
      caption: [
        Quadrado vermelho com fonte implícita
      ],
      rect(
        fill: red,
        height: 5cm,
        width: 5cm,
      ),
    )<figura:quadrado_vermelho_com_fonte_implícita>
  ],
)

Caso você queira eliminar totalmente a descrição da fonte de uma imagem, defina o atributo `source` com o valor `false`, como na @figura:quadrado_vermelho_sem_fonte.
Perceba, porém, que a @abnt exige que sempre seja  descrita a fonte.

#describe_figure(
  source: false,
  [
    #figure(
      caption: [
        Quadrado vermelho sem fonte
      ],
      rect(
        fill: red,
        height: 5cm,
        width: 5cm,
      ),
    )<figura:quadrado_vermelho_sem_fonte>
  ],
)

O @texto:ismália_guimarães_1960 mostra o resultado do uso do ambiente `describe_figure()` preenchendo os parâmetros de fonte e nota.
Nesse caso, é recomendado utilizar o comando `cite_prose` para incluir uma referência da bibliografia no formato de texto-livre.

#describe_figure(
  source: [
    #cite_prose(<guimaraes:1960:ismalia>).
  ],
  note: [
    Alphonsus Guimarães foi um poeta brasileiro, conhecido por sua obra lírica e simbolista.
  ],
  [
    #figure(
      caption: [
        Ismália
      ],
      supplement: "Texto",
      kind: "text",

      text()[
        *Ismália*
        #parbreak()
        Quando Ismália enlouqueceu,\
        Pôs-se na torre a sonhar...\
        Viu uma lua no céu,\
        Viu outra lua no mar.\
        No sonho em que se perdeu,\
        Banhou-se toda em luar...\
        Queria subir ao céu,\
        Queria descer ao mar...\
        E, no desvario seu,\
        Na torre pôs-se a cantar...\
        Estava perto do céu,\
        Estava longe do mar...\
        E como um anjo pendeu\
        As asas para voar...\
        Queria a lua do céu,\
        Queria a lua do mar...\
        As asas que Deus lhe deu\
        Ruflaram de par em par...\
        Sua alma subiu ao céu,\
        Seu corpo desceu ao mar...
      ],
    )<texto:ismália_guimarães_1960>
  ],
)

Também é possível definir mais de uma nota na mesma figura.
Para isso, basta definir o parâmetro `note` como uma lista de notas.
Uma lista é representada com a abertura de parênteses, e cada item é separado com vírgula, como em: `(nota1, nota2)`.
Observe o exemplo da @figura:retângulo_vermelho_com_múltiplas_notas.

#describe_figure(
  note: (
    [
      #lorem(5)
    ],
    [
      #lorem(40)
    ],
  ),
  [
    #figure(
      caption: [
        Retângulo vermelho com múltiplas notas
      ],
      rect(
        fill: red,
        height: 5cm,
        width: 100%,
      ),
    )<figura:retângulo_vermelho_com_múltiplas_notas>
  ],
)

=== Posicionamento

Para ilustrações que ficam mal posicionadas na página, como aquelas com altura muito elevada, pode-se utilizar o parâmetro `placement: auto` no ambiente `describe_figure()`, para que o Typst escolha automaticamente uma melhor posição.

A @figura:retângulo_vermelho_alto apresenta um retângulo vermelho com largura de 100% da página e altura de 20cm, com fonte de autoria e nota geradas automaticamente para ocupar mais de uma linha.
Nela, o parâmetro `placement: auto` foi definido.

#describe_figure(
  placement: auto,
  source: [
    #lorem(20)
  ],
  note: [
    #lorem(40)
  ],
  [
    #figure(
      caption: [
        #lorem(25)
      ],
      rect(
        fill: red,
        height: 20cm,
        width: 100%,
      ),
    )<figura:retângulo_vermelho_alto>
  ],
)

=== Sub-ilustrações

Quando for necessário apresentar várias ilustrações que constituem um conteúdo único, pode-se utilizar o ambiente `subpar.super()`, que permite criar sub-ilustrações.

Esse ambiente recebe como parâmetros:
+ `label`: o rótulo da ilustração;
+ `caption`: a legenda da ilustração; e
+ `grid`, que define a grade de sub-ilustrações.
Você pode encapsular o ambiente `subpar.super()` em um `block()` com o parâmetro `sticky: true`, para que as sub-ilustrações sejam dispostas na mesma página.

A @figura:três_sub-figuras apresenta três sub-ilustrações, cada uma com sua própria legenda.
Esta é a primeira sub-ilustração: @figura:primeira_sub-figura;
esta é a segunda sub-ilustração: @figura:segunda_sub-figura; e
esta é a terceira sub-ilustração: @figura:terceira_sub-figura.

#describe_figure(
  source: [
    #lorem(20)
  ],
  note: [
    #lorem(40)
  ],
  placement: auto,

  subpar.super(
    label: <figura:três_sub-figuras>,
    caption: [Uma figura composta de três sub-figuras],

    block()[
      #grid(
        columns: (1fr, 1fr),

        grid.cell()[
          #figure(
            caption: [
              #lorem(5)
            ],
            image("./../../assets/images/black_square.png", width: 5cm),
          )<figura:primeira_sub-figura>
        ],

        grid.cell()[
          #figure(
            caption: [
              #lorem(10)
            ],
            image("./../../assets/images/black_square.png", width: 5cm),
          )<figura:segunda_sub-figura>
        ],

        grid.cell(colspan: 2)[
          #figure(
            caption: [
              #lorem(15)
            ],
            image("./../../assets/images/black_square.png", width: 10cm),
          )<figura:terceira_sub-figura>
        ],
      )
    ],
  ),
)

=== Tipos de ilustrações

A seguir estão os tipos de ilustrações mais comuns, com exemplos de cada um.

==== Figura

Uma figura deve ser inserida com o comando `image`, que recebe como parâmetro obrigatório o caminho do arquivo.

Então, ela deve ser inserida dentro do ambiente `figure`, que, por sua vez, deve ser encapsulado no ambiente `describe_figure` para que a fonte e a nota sejam apresentadas corretamente.

A @figura:quadrado_preto apresenta uma imagem importada do arquivo `./../../assets/images/black_square.png`, com largura de 10cm e altura ajustada proporcionalmente.

#describe_figure(
  [
    #figure(
      caption: [
        Quadrado preto
      ],
      image(
        width: 10cm,
        "./../../assets/images/black_square.png",
      ),
    )<figura:quadrado_preto>
  ],
)

==== Quadro

Um quadro se trata de uma tabela fechada nas extremidades.
Ele deve ter uma legenda iniciada com o termo "Quadro", seguido de seu número sequencial e do título.
Para tal, deve-se utilizar no comando `figure` o parâmetro `kind: "board"` e o parâmetro `supplement: "Quadro"`.

Então, o conteúdo da ilustração deve ser uma tabela, que pode ser criada com o comando `table`.
O @quadro:exemplo_de_quadro ilustra o uso esperado.

#describe_figure(
  [
    #figure(
      kind: "board",
      supplement: "Quadro",
      caption: [
        Exemplo de quadro
      ],

      table(
        columns: (1fr, 1fr, 1fr),
        align: center + horizon,

        table.header(
          table.cell()[#strong("Cabeçalho 1")],
          table.cell()[#strong("Cabeçalho 2")],
          table.cell()[#strong("Cabeçalho 3")],
        ),

        table.cell(
          rowspan: 2,
        )[Linhas 1 e 2, Coluna 1],
        table.cell()[Linha 1, Coluna 3],

        table.cell()[Linha 2, Coluna 1],
        table.cell()[Linha 2, Coluna 2],
        table.cell()[Linha 2, Coluna 3],

        table.cell()[Linha 3, Coluna 1],
        table.cell(
          colspan: 2,
        )[Linha 3, Colunas 2 e 3],
      ),
    )<quadro:exemplo_de_quadro>
  ],
)


== Tabelas

A formatação de tabelas é definida pelas Normas de apresentação tabular do @ibge #cite(<ibge:1993:normas_apresentacao_tabular>).
Para inclui-las no documento, utilizamos os comandos `describe_figure` e `figure`.

Dentro desse bloco, abrimos um ambiente de formatação da tabela com o comando `format_table`.
Dentro dele, utilizamos o ambiente `table`, definido pelo Typst.

A @tabela:ingredientes se trata de uma tabela simples, com poucas linhas de dados, que representa quantidades de ingredientes para uma receita de bolo de chocolate.

#describe_figure(
  note: [Não testamos essa receita.],
  [#figure(
    caption: "Quantidades dos ingredientes para uma receita de bolo de chocolate",
    block(
      width: 50%,
      format_table(
        table(
          columns: (5fr, 3fr),
          table.header([Ingrediente], [Quantidade]),
          [Farinha de trigo], [2 xícaras],
          [Açúcar], [1 e 1/2 xícaras],
          [Cacau em pó], [1/2 xícara],
          [Ovos], [3 unidades],
          [Leite], [1 xícara],
          [Óleo], [1/2 xícara],
          [Fermento em pó], [1 colher de sopa],
        ),
      ),
    ),
  )<tabela:ingredientes>],
)


Já a @tabela:vendas_mensais é um exemplo de tabela longa, com muitas linhas, que representa dados sintéticos de vendas mensais por região no Brasil (2023-2024).

Essa tabela utilizou os comandos `table.header` para criar seu cabeçalho e `table.footer` para seu rodapé.
Dessa forma, ambos são incluídos em todas as páginas que a tabela ocupar.

#describe_figure(
  [#figure(
    caption: "Dados de vendas mensais por região no Brasil (2023-2024)",
    format_table(
      table(
        columns: (1.25fr, 1fr, 1fr, 1fr, 1fr),
        table.header([Região], [Mês/Ano], [Vendas (R#sym.dollar)], [Unidades], [Crescimento (%)]),
        [Norte], [Jan/2023], [R#sym.dollar 125.430,00], [1.254], [--],
        [Norte], [Fev/2023], [R#sym.dollar 134.567,00], [1.346], [7,3%],
        [Norte], [Mar/2023], [R#sym.dollar 142.890,00], [1.429], [6,2%],
        [Norte], [Abr/2023], [R#sym.dollar 138.234,00], [1.382], [-3,3%],
        [Norte], [Mai/2023], [R#sym.dollar 156.789,00], [1.568], [13,4%],
        [Norte], [Jun/2023], [R#sym.dollar 167.234,00], [1.672], [6,7%],
        [Nordeste], [Jan/2023], [R#sym.dollar 234.567,00], [2.346], [--],
        [Nordeste], [Fev/2023], [R#sym.dollar 245.890,00], [2.459], [4,8%],
        [Nordeste], [Mar/2023], [R#sym.dollar 267.123,00], [2.671], [8,6%],
        [Nordeste], [Abr/2023], [R#sym.dollar 278.456,00], [2.785], [4,2%],
        [Nordeste], [Mai/2023], [R#sym.dollar 289.789,00], [2.898], [4,1%],
        [Nordeste], [Jun/2023], [R#sym.dollar 312.345,00], [3.123], [7,8%],
        [Centro-Oeste], [Jan/2023], [R#sym.dollar 187.654,00], [1.877], [--],
        [Centro-Oeste], [Fev/2023], [R#sym.dollar 195.432,00], [1.954], [4,1%],
        [Centro-Oeste], [Mar/2023], [R#sym.dollar 203.876,00], [2.039], [4,3%],
        [Centro-Oeste], [Abr/2023], [R#sym.dollar 198.234,00], [1.982], [-2,8%],
        [Centro-Oeste], [Mai/2023], [R#sym.dollar 214.567,00], [2.146], [8,2%],
        [Centro-Oeste], [Jun/2023], [R#sym.dollar 225.890,00], [2.259], [5,3%],
        [Sudeste], [Jan/2023], [R#sym.dollar 456.789,00], [4.568], [--],
        [Sudeste], [Fev/2023], [R#sym.dollar 478.234,00], [4.782], [4,7%],
        [Sudeste], [Mar/2023], [R#sym.dollar 495.678,00], [4.957], [3,6%],
        [Sudeste], [Abr/2023], [R#sym.dollar 512.345,00], [5.123], [3,4%],
        [Sudeste], [Mai/2023], [R#sym.dollar 534.567,00], [5.346], [4,3%],
        [Sudeste], [Jun/2023], [R#sym.dollar 567.890,00], [5.679], [6,2%],
        [Sul], [Jan/2023], [R#sym.dollar 298.765,00], [2.988], [--],
        [Sul], [Fev/2023], [R#sym.dollar 312.456,00], [3.125], [4,6%],
        [Sul], [Mar/2023], [R#sym.dollar 325.789,00], [3.258], [4,3%],
        [Sul], [Abr/2023], [R#sym.dollar 334.567,00], [3.346], [2,7%],
        [Sul], [Mai/2023], [R#sym.dollar 345.890,00], [3.459], [3,4%],
        [Sul], [Jun/2023], [R#sym.dollar 356.234,00], [3.562], [3,0%],
        [Norte], [Jul/2023], [R#sym.dollar 172.567,00], [1.726], [3,2%],
        [Norte], [Ago/2023], [R#sym.dollar 165.432,00], [1.654], [-4,1%],
        [Norte], [Set/2023], [R#sym.dollar 178.890,00], [1.789], [8,1%],
        [Norte], [Out/2023], [R#sym.dollar 184.567,00], [1.846], [3,2%],
        [Norte], [Nov/2023], [R#sym.dollar 192.345,00], [1.923], [4,2%],
        [Norte], [Dez/2023], [R#sym.dollar 205.678,00], [2.057], [6,9%],
        [Nordeste], [Jul/2023], [R#sym.dollar 323.456,00], [3.235], [3,6%],
        [Nordeste], [Ago/2023], [R#sym.dollar 334.789,00], [3.348], [3,5%],
        [Nordeste], [Set/2023], [R#sym.dollar 345.123,00], [3.451], [3,1%],
        [Nordeste], [Out/2023], [R#sym.dollar 356.789,00], [3.568], [3,4%],
        [Nordeste], [Nov/2023], [R#sym.dollar 367.234,00], [3.672], [2,9%],
        [Nordeste], [Dez/2023], [R#sym.dollar 389.567,00], [3.896], [6,1%],
        table.footer(
          table.hline(stroke: 1pt),
          table.cell(
            align: center,
            [Região],
          ),
          table.cell(
            align: center,
            [Mês/Ano],
          ),
          table.cell(
            align: center,
            [Vendas (R#sym.dollar)],
          ),
          table.cell(
            align: center,
            [Unidades],
          ),
          table.cell(
            align: center,
            [Crescimento (%)],
          ),
        ),
      ),
    ),
  )<tabela:vendas_mensais>],
)



== Equações

Equações podem ser escritas dentro de um ambiente cercado por `$ ... $`.

$ a^2 + b^2 = c^2 $

Elas serão automaticamente numeradas.
Caso deseje que uma equação não seja numerada, abra um bloco com `#[]`.
Dentro dele, utilize o comando `set math.equation()` e defina o parâmetro `numbering: none`.

#[
  #set math.equation(numbering: none)
  $ 1 + 1 = 2 $
]

Caso deseje inserir texto descritivo para a equação, utilize o comando `equation` para abrir um bloco.
Esse ambiente recebe como argumento opcional `width`, para determinar a largura do bloco de equações.

#equation(
  width: 41.82%,
)[
  $ 1 + X = 2 $
  - X tem o valor de 1.
]

=== Equações com rótulos

Você pode atribuir rótulos a uma equação para citá-la no texto.
Por exemplo, essa é a @equação:teorema_pitagórico e essa é a @equação:número_triangular.

#equation(
  width: 75%,
)[
  Sejam $a$, $b$ e $c$ o comprimento dos lados de um triângulo retângulo.
  Então, sabemos que:
  $ a^2 + b^2 = c^2 $ <equação:teorema_pitagórico>

  Prove por indução:
  $ sum_(k=1)^n k = (n(n+1)) / 2 $ <equação:número_triangular>
]

=== Esquemas

Além disso, caso deseje dar mais destaque a uma equação, você pode usar os comandos `describe_figure` e `figure` para criar um esquema de equações.

Nessa caso, defina os seguinte atributos para o comando `figure`: `supplement: "Esquema"` e `kind: "scheme"`.
Veja o exemplo do @esquema:soma.

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
      $ 1 + 1 = 2 $
    ]
  ] <esquema:soma>
]

== Sub-equações

Caso você queira dividir uma equação em partes diferentes, numeradas com o mesmo índice principal, você pode utilizar o pacote `equate`.

Ele fornece um ambiente de mesmo nome, `equate`, e apresenta um parâmetro chamado `sub-numbering`, que deve ser preenchido como `true`.

Dentro desse ambiente, você pode quebrar a equação em diferentes linhas usado o caractere `\` (contra-barra).
Cada linha receberá um sub-índice diferente de forma incremental.

Caso você, por acaso, queira exibir o símbolo de contra-barra no documento final, basta digitá-lo duas vezes em seguida, como `\\`.
Isso será interpretado pelo Typst como apenas um `\` que se deseja exibir.

Esses ambientes são exemplificados pelo @esquema:uct_adaptada abaixo, que é composto pela @equação:uct_adaptada e sua descrição.

#describe_figure(
  // placement: auto,
  source: [
    adaptado de
    #cite_prose(
      supplement: [p. 2505],
      <swiechowski:2022:monte_carlo_tree_search>,
    )
    #cite_prose(supplement: [p. 486], <silver:2016:mastering_game_go>).
  ],
)[
  #figure(
    supplement: "Esquema",
    kind: "scheme",
    caption: [
      Cálculo de @fitness da diretriz de @uct usada pela @mcts adaptada pelo @alphazero
    ],
  )[
    #equation[
      #equate.equate(
        sub-numbering: true,
      )[
        $
          m^* = max(m in M(s)) = Q(s,m) + X(s,m)\
          X(s,m) = C times
          P(s,m) / (V(s,m) + 1)
        $ <equação:uct_adaptada>

        Na qual:
        - $m^*$ é o nó que representa o @movimento ótimo selecionado pela diretriz;
        - $M(s)$ é o conjunto de nós que representam os @movimento:pl válidos a partir do @estado $s$, segundo as regras do @jogo;
        - $Q(s,m)$ é a qualidade da @partida calculada por meio de simulações ao jogar o @movimento $m$ no @estado $s$;
        - $X(s,m)$ é o componente de @exploração (#glossarium.gls-custom("exploração")) calculado ao jogar o @movimento $m$ no @estado $s$;
        - $V(s)$ é quantidade de vezes em que o nó que guarda o @estado $s$ foi visitado nas iterações anteriores;
        - $V(s,m)$ é a quantidade de vezes em que o nó que representa o @movimento $m$ foi visitado nas interações anteriores;
        - $P(s,m)$ é a qualidade previamente atribuída pelo modelo de @resnet para jogar o @movimento $m$ no estado $s$;
        - $C$ é o coeficiente que regula a relação entre @exploração e @aproveitamento.
      ]
    ]
  ] <esquema:uct_adaptada>
]
