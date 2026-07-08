#import "../../components.typ": *
#import "../../packages.typ": *

= Resultados <capítulo:resultados>


== Alíneas

Alíneas são uma forma de dividir um parágrafo em diferentes itens em uma lista.
A @abnt determina que o texto anterior a uma alínea, que apresenta o seu contexto, deve ser finalizado com o sinal de "dois pontos", `:`.

A forma mais simples de utilizar alíneas é digitar o símbolo `+` antes de cada uma das linhas, como apresentado a seguir:

+ as alíneas devem ser iniciadas em letra minúscula;
+ cada linha deve ser finalizada em "ponto e vírgula";
+ este é um exemplo de uma alínea muito longa; o texto das próximas linhas que se formam fica alinhado exatamente abaixo da primeira letra do texto da linha superior;
+ A última linha deve ser finalizada em "ponto final".

Uma linha pode apresentar subalíneas.
A alínea que apresentará o contexto da subalínea deve finalizar em "dois pontos", como mostrado a seguir:

+ alínea 1:
  + subalínea 1;
  + subalínea 2;
+ alínea 2.


== Notas de rodapé

Para incluir uma nota de rodapé, utilize o comando `footnote`.
Basta então descrever o conteúdo dentro dos colchetes.
A nota aparecerá no rodapé da página em que for inclusa.

Um uso frequente para notas de rodapé é citar páginas na web.
//
Por exemplo, citemos a página do Typst
#footnote[
  Typst é uma ferramenta para criação de documentos similar ao LaTeX.
  Acesso em:
  #link("https://typst.app/").
].
//
Também podemos utilizar notas de rodapé para descrever com mais detalhes um assunto citado
#footnote[
  Vamos incluir uma nota com várias linhas.
  #lorem(50)
].


== Texto mono-espaçado

Para inserir texto mono-espaçado, abra um bloco usando o caractere ``` ` ``` três vezes, como a seguir: ```` ``` ````.

```
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
sed do eiusmod tempor incididunt ut labore et dolore magnam
aliquam quaerat voluptatem.
```
