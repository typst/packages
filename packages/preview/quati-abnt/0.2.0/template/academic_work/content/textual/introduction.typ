#import "../../components.typ": *
#import "../../packages.typ": *


= Introdução <capítulo:introdução>

Este projeto visa a fornecer um modelo para redação de trabalhos acadêmicos por meio da ferramenta Typst @typst:2025:typst segundo as @nbr:pl da @abnt.
As normas a seguir são contempladas.

#let nbr = glossarium.gls-short("nbr")

#terms(
  terms.item[
    #nbr 6022:2018
  ][
    Informação e documentação — Artigo em publicação periódica técnica e/ou científica — Apresentação
  ],
  terms.item[
    #nbr 6023:2025
  ][
    Informação e documentação — Referências — Elaboração
  ],
  terms.item[
    #nbr 6024:2012
  ][
    Informação e documentação — Numeração progressiva das seções de um documento — Apresentação
  ],
  terms.item[
    #nbr 6027:2012
  ][
    Informação e documentação — Sumário — Apresentação
  ],
  terms.item[
    #nbr 6028:2021
  ][
    Informação e documentação — Resumo, resenha e recensão — Apresentação
  ],
  terms.item[
    #nbr 6029:2023
  ][
    Informação e documentação — Livros e folhetos — Apresentação
  ],
  terms.item[
    #nbr 6034:2004
  ][
    Informação e documentação — Índice — Apresentação
  ],
  terms.item[
    #nbr 10520:2023
  ][
    Informação e documentação — Citações em documentos — Apresentação
  ],
  terms.item[
    #nbr 10719:2025
  ][
    Informação e documentação — Relatório técnico e/ou científico — Apresentação
  ],
  terms.item[
    #nbr 14724:2024
  ][
    Informação e documentação — Trabalhos acadêmicos — Apresentação
  ],
  terms.item[
    #nbr 15287:2025
  ][
    Informação e documentação — Projeto de pesquisa — Apresentação
  ],
)


== Requisitos

É necessário instalar as seguintes fontes para que o modelo funcione corretamente.
Caso utilize a ferramenta Typst via web, elas já estarão disponíveis.

/ Liberation Sans: para títulos e demais componentes de destaque em fonte sem serifa.
/ Liberation Serif: para o corpo do texto com fonte serifada.
/ Liberation Mono: para trechos de código e texto em destaque com fonte mono-espaçada.
/ New Computer Modern: para texto em blocos de equações matemáticas.
/ New Computer Modern Math: para fórmulas e equações matemáticas.

Se preferir, você pode alterar essas fontes por quaisquer outras que desejar ao modificar o bloco de abertura do modelo no arquivo `/main.typ`.


== Ficha catalográfica

A ficha catalográfica gerada por esse modelo é apenas um exemplo.
Sua instituição provavelmente fornecerá uma página em PDF para ser anexada ao projeto.

Nesse caso, coloque a página dentro da pasta `/academic_work/assets/documents`.
Em seguida,
+ edite o arquivo `/academic_work/content/pre_textual.typ`
+ de forma a não usar o comando `include_cataloging_in_publication`,
+ mas sim o comando `include_custom_cataloging_in_publication`
+ com o caminho referente à página a incluir.


== Referências a outros capítulos

É comum encerrar a introdução fazendo uma descrição da estrutura do projeto.
Para isso, você pode definir e chamar os rótulos (ou #foreign_text[labels]) dos capítulos e das seções.
Esses indicativos são determinados pela @abnt @nbr 6024:2012 @abnt:2012:nbr_6024_2012.

Um rótulo é aberto com o símbolo `<` e fechado com o símbolo `>`.
Após definir o título de um capítulo ou seção, utilize os símbolos `<>` e escreve o nome do rótulo entre eles.

Então, você pode utilizar o símbolo `@` para incluir uma referência para o capítulo ou seção no texto.

Por exemplo, este capítulo de introdução é o @capítulo:introdução.
Já o capítulo de fundamentação teórica é o @capítulo:fundamentação.
