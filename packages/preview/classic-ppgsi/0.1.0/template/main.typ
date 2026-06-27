#import "@preview/classic-ppgsi:0.1.0" as ppgsi

#show: ppgsi.thesis.with(
  title: "Título do trabalho: subtítulo do trabalho",
  title-en: "Work title: work subtitle",
  author: (given: "Fulano de", surname: "Tal"),
  location: "São Paulo",
  date: "2015",
  bibliography: read("referencias.bib"),
  catalog-card: image("assets/ficha-1.png", width: 100%, height: 100%, fit: "contain"),
  preamble: [
    Versão original

    Dissertação apresentada à Escola de Artes, Ciências e Humanidades da Universidade de São Paulo para obtenção do título de Mestre em Ciências pelo Programa de Pós-graduação em Sistemas de Informação.

    Área de concentração: Metodologia e Técnicas da Computação

    Versão corrigida contendo as alterações solicitadas pela comissão julgadora em xx de xxxxxxxxxxxxxxx de xxxx. A versão original encontra-se em acervo reservado na Biblioteca da EACH-USP e na Biblioteca Digital de Teses e Dissertações da USP (BDTD), de acordo com a Resolução CoPGr 6018, de 13 de outubro de 2011.
  ],
  advisor: [Orientador: Prof. Dr. Fulano de Tal],
  co-advisor: [Coorientador: Prof. Dr. Fulano de Tal],
  errata: [Elemento opcional para versão corrigida, depois de depositada.],
  approval-text: [
    Dissertação de autoria de Fulano de Tal, sob o título *"Título do trabalho: subtítulo do trabalho"*, apresentada à Escola de Artes, Ciências e Humanidades da Universidade de São Paulo, para obtenção do título de Mestre em Ciências pelo Programa de Pós-graduação em Sistemas de Informação, na área de concentração Metodologia e Técnicas da Computação, aprovada em #h(0.3em)#box(width: 0.85cm, line(length: 100%, stroke: 0.5pt))#h(0.3em) de #h(0.3em)#box(width: 3.5cm, line(length: 100%, stroke: 0.5pt))#h(0.3em) de #h(0.3em)#box(width: 1.25cm, line(length: 100%, stroke: 0.5pt))#h(0.3em) pela comissão julgadora constituída pelos doutores:
  ],
  committee: (
    [Prof. Dr. \ Instituição \ Presidente],
    [Prof. Dr. \ Instituição],
    [Prof. Dr. \ Instituição],
    [Prof. Dr. \ Instituição],
    [Prof. Dr. \ Instituição],
  ),
  dedication: [Escreva aqui sua dedicatória, se desejar, ou remova esta página...],
  acknowledgments: [
    #lorem(80)

    #lorem(80)

    #lorem(80)
  ],
  epigraph: ["Escreva aqui uma epígrafe, se desejar, ou remova esta página..." \ (Autor da epígrafe)],
  // a referência (citation) é gerada automaticamente a partir de autor, título,
  // ano, nº de folhas, grau e instituição; passe citation: [...] para sobrescrever
  // ou citation: none para omitir. A versão enUS usa o title-en.
  abstract: (
    pt-br: (
      body: [Escreva aqui o texto do seu resumo... (redigido em parágrafo único, no máximo em uma página, contendo no "máximo 500 palavras", e apresentando um resumo de todos o seu trabalho, incluindo objetivos, metodologia, resultados e conclusões; não inclua apenas a contextualização até chegar nos objetivos, é importante fazer um resumo de todos os capítulos do texto, até chegar à conclusão). #lorem(40)],
      keywords: ("Palavra1", "Palavra2", "Palavra3"),
    ),
    en-us: (
      body: [Write here the English version of your "Resumo". #lorem(70)],
      keywords: ("Keyword1", "Keyword2", "Keyword3"),
    ),
  ),
  // Siglas gerenciadas pelo glossy: defina chave + forma curta + extenso, e
  // referencie no texto com @chave (expande na 1ª menção, encurta nas demais).
  acronyms: (
    "abnt": (short: "ABNT", long: "Associação Brasileira de Normas Técnicas"),
    "usp": (short: "USP", long: "Universidade de São Paulo"),
    "each": (short: "EACH", long: "Escola de Artes, Ciências e Humanidades"),
    "ppgsi": (short: "PPgSI", long: "Programa de Pós-Graduação em Sistemas de Informação"),
    "svm": (short: "SVM", long: "máquina de vetores de suporte"),
    "api": (short: "API", long: "interface de programação de aplicações"),
    "http": (short: "HTTP", long: "protocolo de transferência de hipertexto"),
    "sql": (short: "SQL", long: "linguagem de consulta estruturada"),
    "json": (short: "JSON", long: "notação de objetos JavaScript"),
    "xml": (short: "XML", long: "linguagem de marcação extensível"),
  ),
  symbols: (
    ([$Gamma$], [Letra grega Gama]),
    ([$Lambda$], [Lambda]),
    ([$zeta$], [Letra grega minúscula zeta]),
    ([$in$], [Pertence]),
  ),
)

= Introdução

#lorem(60)

A tabela 1 é um exemplo de como apresentar tabelas de acordo com essa norma. Veja mais detalhes no anexo A deste documento.

#ppgsi.table(
  caption: [Exemplo de título de tabela],
  source: ppgsi.myself,
  columns: (1in, 1in, 1in, 1in),
  align: left,
  header: ([Cabeçalho 1], [Cabeçalho 2], [Cabeçalho 3], [Cabeçalho 4]),
  ([Texto], [número], [número], [número]),
  ([Texto], [número], [número], [número]),
  ([Texto], [número], [número], [número]),
  ([Texto], [número], [número], [número]),
  ([Texto], [número], [número], [número]),
)

#lorem(30)

A figura 1 é um exemplo de como apresentar ilustrações de acordo com essa norma. A figura 1 também apresenta um exemplo de como incluir como "Fonte" algo que foi elaborado pelo próprio autor.

#ppgsi.figure(
  image("assets/figura-exemplo.png"),
  caption: [Exemplo de título de ilustração do tipo figura, incluindo como "Fonte:" o próprio autor],
  // sem "source": usa "Fonte – <author>, <date>" do thesis() automaticamente (próprio autor)
)

#lorem(30)

O quadro 1 é um exemplo de como apresentar quadros de acordo com essa norma. Observe as diferenças de formatação entre uma tabela (cf. tabela 1) e um quadro (cf. quadro 1).

#ppgsi.frame(
  caption: [Exemplo de título de quadro],
  source: ppgsi.myself,
  columns: (1in, 1in, 1in, 1in),
  align: left,
  header: ([Cabeçalho 1], [Cabeçalho 2], [Cabeçalho 3], [Cabeçalho 4]),
  ([Texto], [texto], [texto], [texto]),
  ([Texto], [texto], [texto], [texto]),
  ([Texto], [texto], [texto], [texto]),
  ([Texto], [texto], [texto], [texto]),
  ([Texto], [texto], [texto], [texto]),
)

== Uma seção secundária

#lorem(40)

=== Uma seção terciária

#lorem(40)

=== Outra seção terciária

#lorem(40)

=== Mais uma seção terciária

#lorem(40)

A figura 2 também apresenta um exemplo de como incluir em "Fonte:" uma citação para um trabalho já publicado. Nesse caso, use sempre o "prose".

#ppgsi.figure(
  image("assets/figura-exemplo.png"),
  caption: [Exemplo de título de ilustração do tipo figura, que pode ser maior para apresentar mais explicações sobre o conteúdo da figura, se for o caso; e com exemplo de citação a um trabalho já publicado, seja do próprio autor ou de outro autor],
  source: ppgsi.prose("teste3"),
)

== Outra seção secundária

#lorem(40)

== Mais uma seção secundária

#lorem(40)

= Outra seção primária

#lorem(50)

Atenção ao fazer citações a referências para garantir o uso da forma correta, considerando os seguintes exemplos:

- Se desejar que uma citação a uma referência apareça no final da frase, use com o comando "cite". Exemplo: "Tal coisa é muito melhor do que aquela outra coisa #ppgsi.cite("teste1", "teste2")".
- Se desejar que uma citação a uma referência apareça no meio da frase, como parte da própria frase, use o comando "prose". Exemplo: "De acordo com #ppgsi.prose("teste3"), tal coisa é muito melhor do que aquela outra coisa."
- *Atenção* - nunca usar o comando "cite" para citações a referências que aparecem no meio da frase, como parte da própria frase. Exemplo - nunca fazer assim: "De acordo com #ppgsi.cite("teste3"), tal coisa é muito melhor do que aquela outra coisa."

Citações diretas com mais de três linhas (citações longas) devem ser destacadas com recuo de 4 cm, fonte menor e espaçamento simples, sem aspas, com a citação ao final:

#ppgsi.quote(citation: ppgsi.prose("teste3"))[
  #lorem(45)
]

O algoritmo 1 é um exemplo de como apresentar ilustrações de acordo com essa norma.

#ppgsi.algorithm(
  caption: [Exemplo de título de ilustração do tipo algoritmo, que pode ser maior para apresentar mais explicações sobre o conteúdo do algoritmo, se for o caso],
  source: ppgsi.myself,
  [*procedure* #smallcaps[MyProcedure]],
  $#h(1em) p a s s o-1$,
  $#h(1em) p a s s o-2$,
  $#h(1em) p a s s o-3$,
  $#h(1em) .$,
  $#h(1em) .$,
  $#h(1em) p a s s o-n$,
  [*end procedure*],
)

== Uma seção secundária

#lorem(40)

As fórmulas 1 e 2 são exemplos de como apresentar fórmulas e equações destacadas do parágrafo normal do texto.

$ X + Y = Z $

$ (X - Y) \/ 5 = n $

=== Uma seção terciária

#lorem(40)

=== Outra seção terciária

#lorem(40)

=== Mais uma seção terciária

#lorem(40)

== Outra seção secundária

#lorem(40)

== Mais uma seção secundária

#lorem(40)

= Mais uma seção primária

#lorem(50)

== Uma seção secundária

#lorem(40)

=== Uma seção terciária

#lorem(40)

=== Outra seção terciária

#lorem(40)

=== Mais uma seção terciária

#lorem(40)

== Outra seção secundária

#lorem(40)

== Mais uma seção secundária

#lorem(40)

= Mais uma outra seção primária

#lorem(50)

== Uma seção secundária

#lorem(40)

=== Uma seção terciária

#lorem(40)

=== Outra seção terciária

#lorem(40)

=== Mais uma seção terciária

#lorem(40)

== Outra seção secundária

#lorem(40)

== Mais uma seção secundária

#lorem(40)

= Recursos de visualização e código

Este capítulo demonstra a integração do modelo com pacotes do ecossistema Typst. As siglas são gerenciadas pelo glossy: na primeira menção aparecem por extenso e, nas seguintes, apenas a forma curta. Por exemplo, a @svm é uma técnica de aprendizado supervisionado; a @svm também serve para regressão. Acesso a dados costuma envolver @api, @http e @sql.

== Gráficos com lilaq

A figura 3 apresenta um gráfico de dados gerado com o pacote lilaq, embutido em uma figura comum do modelo (com legenda e linha de fonte normais).

#ppgsi.figure(
  ppgsi.lq.diagram(
    width: 9cm,
    height: 5.5cm,
    xlabel: $x$,
    ylabel: $y$,
    ppgsi.lq.plot((0, 1, 2, 3, 4, 5), (0, 1, 4, 9, 16, 25), mark: "o", label: [medições]),
  ),
  caption: [Exemplo de gráfico de dados gerado com lilaq],
  source: ppgsi.myself,
)

== Diagramas com cetz

A figura 4 apresenta uma rede neural feedforward totalmente conectada, desenhada com cetz, o equivalente ao TikZ no Typst.

#ppgsi.figure(
  ppgsi.cetz.canvas({
    import ppgsi.cetz.draw: *
    let sizes = (3, 5, 2)
    let labels = ([Entrada], [Camada oculta], [Saída])
    let fills = (rgb("#cfe3f7"), rgb("#ececec"), rgb("#d6efd6"))
    let xgap = 3.4
    let ygap = 1.1
    let r = 0.34
    let pos(l, i, n) = (l * xgap, (i - (n - 1) / 2) * ygap)
    // conexões (atrás dos neurônios)
    for l in range(sizes.len() - 1) {
      for i in range(sizes.at(l)) {
        for j in range(sizes.at(l + 1)) {
          line(pos(l, i, sizes.at(l)), pos(l + 1, j, sizes.at(l + 1)), stroke: 0.4pt + luma(65%))
        }
      }
    }
    // neurônios
    for l in range(sizes.len()) {
      for i in range(sizes.at(l)) {
        circle(pos(l, i, sizes.at(l)), radius: r, fill: fills.at(l), stroke: 0.6pt)
      }
    }
    // rótulos das camadas
    for l in range(sizes.len()) {
      content((l * xgap, -3.1), text(size: 9pt, labels.at(l)))
    }
  }),
  caption: [Exemplo de rede neural feedforward desenhada com cetz],
  source: ppgsi.myself,
)

== Listagens de código com codly

O código 1 é um exemplo de listagem de código-fonte, estilizada automaticamente pelo codly (numeração de linhas e realce de sintaxe).

#ppgsi.code(
  caption: [Exemplo de listagem de código-fonte do tipo Código],
  source: ppgsi.myself,
)[```python
def reconstruir(pontos):
    """Reconstrução de superfície homeomórfica."""
    malha = alpha_shape(pontos)
    return malha.simplificar()
```]

== Listas de verificação com cheq

Listas de tarefas podem ser escritas com a sintaxe de caixas de seleção do cheq:

- [x] Definir o problema de pesquisa
- [x] Revisar a literatura
- [/] Coletar os dados
- [ ] Analisar os resultados

= Conclusão

#lorem(50)

== Uma seção secundária

#lorem(40)

=== Uma seção terciária

#lorem(40)

=== Outra seção terciária

#lorem(40)

=== Mais uma seção terciária

#lorem(40)

== Outra seção secundária

#lorem(40)

== Mais uma seção secundária

#lorem(40)

#ppgsi.references()

#ppgsi.appendix[Exemplo de apêndice]

#lorem(30)

#ppgsi.section[Exemplo de seção de apêndice não apresentada no sumário]

#lorem(30)

#ppgsi.subsection[Exemplo de subseção de apêndice não apresentada no sumário]

#lorem(30)

#ppgsi.appendix[Exemplo de apêndice]

#lorem(30)

#ppgsi.appendix[Exemplo de apêndice]

#lorem(30)

#ppgsi.annex[Resumo das normas]

Considerando a dificuldade para formatar um texto acadêmico sem conhecimento básico do conteúdo da norma NBR 14724 "Informação e documentação -- Trabalhos acadêmicos -- Apresentação", este anexo apresenta um resumo de alguns conceitos dessa norma, conforme publicada em julho de 2011. Sugere-se a leitura completa da norma para garantir que seu documento seja completamente aderente à mesma. Em alguns casos específicos, este anexo apresenta alguns ajustes da norma especificamente para o PPgSI.

#ppgsi.section[NBR 14724: estrutura e algumas descrições]

A estrutura de uma tese, dissertação ou qualquer outro trabalho acadêmico, deve compreender elementos pré-textuais, elementos textuais e elementos pós-textuais, que aparecem no texto na seguinte ordem:

#ppgsi.subsection[Elementos pré-textuais]

- Capa (obrigatório)
- Folha de rosto (obrigatório)
- Errata (opcional)
- Folha de aprovação (obrigatório)
- Dedicatória (opcional)
- Agradecimentos (opcional)
- Epígrafe (opcional)
- Resumo em língua vernácula (obrigatório)
- Resumo em língua estrangeira (obrigatório)
- Listas de ilustrações: lista de figuras, lista de algoritmos, lista de quadros etc. (opcional)
- Lista de tabelas (opcional)
- Lista de abreviaturas e siglas (opcional)
- Lista de símbolos (opcional)
- Sumário (obrigatório)

#ppgsi.subsection[Elementos textuais]

- Introdução
- Desenvolvimento
- Conclusão

#ppgsi.subsection[Elementos pós-textuais]

- Referências (obrigatório)
- Apêndice (opcional)
- Anexo (opcional)
- Glossário (opcional)

#ppgsi.section[Definições relacionadas a elementos pré-textuais]

A seguir, são apresentadas algumas definições contidas na norma relacionadas a elementos pré-textuais.

#ppgsi.subsection[Capa]

Elemento obrigatório, para proteção externa e sobre o qual se imprimem informações que ajudam na identificação e uso do trabalho, na seguinte ordem:

+ Nome completo do autor: responsável intelectual do trabalho.
+ Título principal do trabalho: deve ser claro e preciso, identificando o seu conteúdo e possibilitando a indexação e recuperação da informação.
+ Subtítulo (se houver): deve ser evidenciada sua subordinação ao título principal, precedido de dois pontos (:).
+ Número do volume (obrigatório apenas se houver mais de um volume, de forma que deve constar em cada capa a especificação do respectivo volume).
+ Local (cidade) da instituição de apresentação.
+ Ano do depósito (entrega).

#ppgsi.subsection[Folha de rosto (anverso)]

Os elementos do anverso da folha de rosto devem figurar na seguinte ordem:

+ Nome completo do autor: responsável intelectual do trabalho.
+ Título principal do trabalho: deve ser claro e preciso, identificando o seu conteúdo e possibilitando a indexação e recuperação da informação.
+ Subtítulo (se houver): deve ser evidenciada sua subordinação ao título principal, precedido de dois pontos (:).
+ Número do volume (obrigatório apenas se houver mais de um volume).
+ Natureza (tese, dissertação e outros) e objetivo (aprovação em disciplina, grau pretendido e outros); nome da instituição a que é submetido; área de concentração.
+ Nome do orientador e, se houver, do co-orientador.
+ Local (cidade) da instituição de apresentação.
+ Ano de depósito (entrega).

#ppgsi.subsection[Folha de rosto (verso)]

No verso da folha de rosto deve constar a ficha catalográfica, conforme o Código de Catalogação Anglo-Americano -- CCAA2.

#ppgsi.subsection[Folha de aprovação]

Elemento obrigatório, que contém autor, título por extenso e subtítulo, se houver, local e data de aprovação, nome e instituição dos membros componentes da banca examinadora.

#ppgsi.subsection[Dedicatória e agradecimentos]

Elementos opcionais. Os agradecimentos devem ser dirigidos apenas àqueles que contribuíram de maneira relevante à elaboração do trabalho.

#ppgsi.subsection[Resumo na língua vernácula]

Elemento obrigatório, que consiste na apresentação concisa dos pontos relevantes de um texto; constitui-se em uma sequência de frases concisas e objetivas, e não de uma simples enumeração de tópicos, não ultrapassando 500 palavras, seguido, logo abaixo, das palavras representativas do conteúdo do trabalho, isto é, palavras-chave e/ou descritores.

#ppgsi.subsection[Resumo em língua estrangeira]

Elemento obrigatório, que consiste em uma versão do resumo em idioma de divulgação internacional (em inglês Abstract, em castelhano Resumen, em francês Résumé, por exemplo). Deve ser seguido das palavras representativas do conteúdo do trabalho, isto é, palavras-chave e/ou descritores, na respectiva língua estrangeira.

#ppgsi.subsection[Lista de figuras e lista de tabelas]

Elementos opcionais, elaborados de acordo com a ordem apresentada no texto, com cada item acompanhado do respectivo número da página.

#ppgsi.subsection[Lista de abreviaturas e siglas]

Elemento opcional. Consiste na relação alfabética das abreviaturas e siglas usadas no texto, seguidas das palavras ou expressões correspondentes grafadas por extenso.

#ppgsi.subsection[Lista de símbolos]

Elemento opcional, elaborado de acordo com a ordem apresentada no texto, com o devido significado.

#ppgsi.subsection[Sumário]

Elemento obrigatório, que consiste na enumeração das principais divisões (seções e outras partes do trabalho) dos elementos textuais e pós-textuais, na mesma ordem e grafia em que a matéria nele sucede, acompanhado do respectivo número da página.

#ppgsi.section[Definições relacionadas a elementos textuais]

O autor deve criar quantas seções primárias (também chamadas informalmente de capítulos) desejar para tratar dos seguintes elementos textuais que são obrigatórios: introdução, desenvolvimento e conclusão. Normalmente, existe apenas uma seção primária para a introdução, uma ou mais seções primárias para o desenvolvimento, e apenas uma seção primária para a conclusão.

#ppgsi.section[Definições relacionadas a elementos pós-textuais]

A seguir, são apresentadas algumas definições contidas na norma relacionadas a elementos pós-textuais.

#ppgsi.subsection[Apêndice]

Elemento opcional, que consiste em um texto ou documento elaborado pelo próprio autor, a fim de complementar sua argumentação, sem prejuízo da unidade nuclear do trabalho. Um apêndice deve ser identificado por uma letra maiúscula, seguida por um hífen (entre caracteres de espaço), seguido pelo respectivo título. Os apêndices devem ser identificados por letras consecutivas, a partir da letra "A" (independentemente dos anexos).

#ppgsi.subsection[Anexo]

Elemento opcional, que consiste em um texto ou documento não elaborado pelo autor, a fim de fundamentar, comprovar ou ilustrar a argumentação do autor. Um anexo deve ser identificado por uma letra maiúscula, seguida por um hífen (entre caracteres de espaço), seguido pelo respectivo título. Os anexos devem ser identificados por letras consecutivas, a partir da letra "A" (independentemente dos apêndices).

#ppgsi.subsection[Glossário]

Elemento opcional, que consiste em uma lista em ordem alfabética de palavras ou de expressões técnicas de uso restrito ou de sentido obscuro, usadas no texto, acompanhadas das respectivas definições.

#ppgsi.section[Formas de apresentação]

A seguir, são apresentadas algumas definições contidas na norma relacionadas a formas de apresentação em geral.

#ppgsi.subsection[Formato]

O texto deve estar impresso em papel branco, formato A4 (21,0 cm 29,7 cm), apenas no anverso da folha (ou seja, na "frente" da folha), excetuando-se a folha de rosto que deve estar impressa tanto no anverso quanto no verso (com a ficha catalográfica).

#ppgsi.subsection[Projeto gráfico]

O projeto gráfico é de responsabilidade do autor.

#ppgsi.subsection[Fonte]

Usar sempre cor preta.

Usar sempre tamanho de fonte 12, com as seguintes exceções: tamanho de fonte 10 para citações longas (com mais de três linhas), notas de rodapé, legendas de ilustração e de tabela, fontes de ilustração e de tabela, números de página; e tamanho de fonte maiores para títulos de seção.

#ppgsi.subsection[Margens]

Todas as folhas devem apresentar margens esquerda e superior de 3 cm; e margens direita e inferior de 2 cm, considerando impressão apenas no anverso (ou seja, apenas na "frente").

Se a impressão precisar, por algum motivo especial, ser realizada em anverso e verso, neste caso, há que se configurar as margens de forma diferente, conforme detalhes da norma ABNT; por isso solicita-se não realizar impressão em frente e verso.

#ppgsi.subsection[Espaçamento entre linhas]

Usar sempre espaçamento entre linhas de 1,5 linhas, com as seguintes exceções: espaçamento entre linhas "simples" para citações longas (com mais de três linhas), notas de rodapé, referências, resumos (em vernáculo e em língua estrangeira), legendas de ilustração e de tabela, fontes de ilustração e de tabela, ficha catalográfica, natureza do trabalho, grau pretendido, nome da instituição a que é submetido, e área de concentração; e espaçamento entre linhas "duplo" para equações e fórmulas e para separação das referências entre si.

Os títulos das seções devem começar na margem superior da folha separados do texto que os sucede por um espaço em branco de 1,5 e, da mesma forma, os títulos das subseções devem ser separados do texto que os precede, ou que os sucede, por um espaço em branco de 1,5.

#ppgsi.subsection[Numeração das seções]

O indicativo numérico de uma seção precede seu título, alinhado à esquerda, separado por um espaço de caractere. Nos títulos sem indicativo numérico, como lista de ilustrações, sumário, resumo, referências e outros, devem ser centralizados.

Para evidenciar a sistematização do conteúdo do trabalho, deve-se adotar a numeração progressiva para as seções do texto. Os títulos das seções primárias (chamadas informalmente de capítulos), por serem as principais divisões do texto, devem iniciar em folha distinta. Títulos das seções e subseções devem ser destacados gradativamente, usando-se os recursos de negrito, itálico ou grifo e redondo, caixa alta ou versal.

#ppgsi.subsection[Paginação]

Todas as folhas do trabalho, a partir da folha de rosto (desconsiderando a capa, mas considerando a ficha catalográfica), devem ser contadas sequencialmente, mas não numeradas. A numeração é colocada, a partir da primeira folha da dos elementos textuais (ou seja, a partir da "Introdução"), em algarismos arábicos, no canto superior direito da folha, a 2 cm da borda superior, ficando o último algarismo a 2 cm da borda direita da folha.

Havendo apêndices e/ou anexos, suas folhas devem ser numeradas de maneira contínua e sua paginação deve dar seguimento à do texto principal, em algarismos arábicos.

No caso de o trabalho ser constituído de mais de um volume, deve-se manter uma única sequência de numeração das folhas, do primeiro ao último volume.

#ppgsi.subsection[Equações e fórmulas]

Equações e fórmulas devem aparecer destacadas no texto, para facilitar sua leitura.

Se as equações e fórmulas forem apresentadas na sequência normal do texto (ou seja, dentro do próprio parágrafo normal de texto), é permitido usar um espaçamento entre linhas duplo para comportar seus elementos (ou seja, expoentes, índices e outros).

Se as equações e fórmulas forem apresentadas fora do parágrafo, então elas devem ser centralizadas e, se necessário, devem ser numeradas. Quando fragmentadas em mais de uma linha, por falta de espaço, devem ser interrompidas antes do sinal de igualdade ou depois dos sinais de adição, subtração, multiplicação e divisão.

#ppgsi.subsection[Ilustrações]

Cada tipo de ilustração (tais como figura, gráfico, algoritmo, fotografia, quadro, esquema, desenhos, esquemas, fluxogramas, mapa, organograma, planta, retrato, entre outros) tem numeração independente e consecutiva.

Inserir a ilustração o mais próximo possível do parágrafo em que ela é citada pela primeira vez no texto; nunca inserir uma ilustração antes de ela ser citada pela primeira vez no texto. Toda ilustração inserida no trabalho deve ser citada pelo menos uma vez no texto.

Qualquer que seja o tipo da ilustração, ela deve obrigatoriamente ter uma identificação (ou seja, um título), que deve aparecer sempre na parte superior da ilustração, precedida pela palavra que identifica seu tipo, por exemplo "Figura", seguida de seu número de ordem de ocorrência no texto em algarismo arábico, e de um hífen entre caracteres de espaço (" -- "), em fonte com tamanho 12, sem negrito, sem itálico, com apenas a primeira letra da sentença maiúscula, sem ponto final, e em espaçamento simples. Exemplo: "Figura 1 -- Título da ilustração".

Para toda ilustração, deve ser apresentada também obrigatoriamente sua fonte (mesmo quando a fonte é o próprio autor do trabalho). A fonte deve apresentada na parte inferior da ilustração e ser informada no seguinte formato: palavra "Fonte", seguida pelo caractere dois pontos ":", seguido por um caractere de espaço, seguido pela citação de onde a ilustração foi obtida (conforme regras de citação da norma ABNT) ou seguido pelo nome completo do autor do trabalho, por uma vírgula e pelo ano de elaboração do trabalho, em fonte com tamanho 10, sem negrito, sem itálico, sem ponto final, e em espaçamento simples.

#ppgsi.subsection[Tabelas]

As tabelas têm numeração independente e consecutiva das ilustrações.

Inserir a tabela o mais próximo possível do parágrafo em que ela é citada pela primeira vez no texto; nunca inserir uma tabela antes de ela ser citada pela primeira vez no texto. Toda tabela inserida no trabalho deve ser citada pelo menos uma vez no texto.

Usar traços horizontais apenas para delimitar o cabeçalho da tabela e o início e o fim da tabela. Não usar traços horizontais para separar cada linha de conteúdo da tabela e também não usar traços verticais para separar cada coluna de conteúdo da tabela.

Não confundir "tabela" com "quadro". Uma tabela deve ter dados numéricos como informação central. Outros tipos de organização de informações devem ser apresentados em quadros, que é um dos tipos de ilustração. A formatação de um quadro é muito parecida a de uma tabela, porém todos os traços horizontais e verticais devem ser apresentados.

#ppgsi.section[Outras normas]

#ppgsi.subsection[Seções]

As seções primárias são as principais divisões do texto, denominadas informalmente de "capítulos". As seções primárias podem ser divididas em seções secundárias; e as secundárias em terciárias, em formatação distinta. Não divida o texto mais do que a terceira ordem; ou seja, evite criar seções de profundidade quatro ou cinco.

Todos títulos, de todas as seções, de todos os níveis, devem ter sempre tamanho 12. O que muda é a formatação, conforme segue abaixo. A formatação adotada para este _template_ em particular é a seguinte:

- Seções primárias: *negrito*.
- Seções secundárias: _itálico_.
- Seções terciárias: regular.
- Seções quartenárias: [não usar].
- Seções quinárias: [não usar].

São empregados algarismos arábicos na numeração. O "indicativo" de uma seção precede o título ou a primeira palavra do texto, se não houver título, separado por um espaço.

#ppgsi.subsection[Referências bibliográficas e citações às referências bibliográficas]

A norma é bastante complexa e extensa em relação às regras de referências bibliográficas e citações às referências bibliográficas, não sendo possível fazer um resumo aqui. Assim, é necessário fazer uma consulta às normas detalhadas.

As referências devem ser apresentadas em ordem alfabética, com as citações no texto obedecendo ao sistema autor-data. Todos os documentos relacionados nas Referências devem ser citados no texto, assim como todas as citações do texto devem constar nas Referências.

#ppgsi.annex[Exemplo de anexo]

#lorem(30)

#ppgsi.annex[Exemplo de anexo]

#lorem(30)
