// Modelo para Trabalhos Acadêmicos da UDESC
// Não é um projeto oficial!
// Criado por Lucas Vinícius Bublitz.
// Licença livre nos termos do GNU!
// Construído com base no Manual para Elaboração de Trabalhados Acadêmicos da Udesc, acessível em https://www.udesc.br/bu/manuais.

// AVISOS IMPORTANTES
// Atualemnte, o typst não fornece uma modo de alterar o código do template que está no @preview.
// Assim, caso seja necessário aditar os elementos de texto gerados internamente na função do template, 
// deve-se adicionar o arquivo .typ localmente, que pode ser obtido em https://github.com/lucas-bublitz/bellbird-udesc-paper/blob/main/src/lib.typ.
// As fontes Arial e Times New Roman não vêm, por padrão, junto ao compilador do typst, mesmo na versão web, assim é necessário adicioná-las por fora. Pelas diretrizes do 'pacakages', não se permite adicionar fontes externas a templates.
// No webapp, o typst reconhece automaticamente os arquivos de fontes presentes no projeto, localmente, entretanto, a fonte deve ser instalada no sistema para que seja possível sua utilização (no Windows, constumam vir por padrão).

#import "imports.typ": *

#show: codly-init.with()
#codly(languages: codly-languages)


// Definição da ordem de preferência das fontes (ignora as fontes não instaladas, porém gera um warning do compilador)
#set text(font: ("Arial", "Times New Roman", "STIX Two Text"))

// #import "@preview/bellbird-udesc-paper:0.0.1": bellbird-udesc-paper
#import "../src/lib.typ": bellbird-udesc-paper

#show: bellbird-udesc-paper.with(
  // ARGUMENTOS OBRIGATÓRIOS 
  campus: [Centro de Ciências Tecnológicas -- CCT],
  department: [Programa de Pós-Graduação em Engenharia Mecânica],
  abstract: lorem(100),
  keywords: ("Primeira", "Segunda", "Terceira"),
  foreign-abstract: lorem(100),
  foreign-keywords: ("First", "Second", "Third"),
  title : [Modelo de Trabalhos Acadêmicos da Udesc],
  subtitle: [em Typst!],
  city: "Joinville",
  date: (
    day: 01,
    month: "janeiro",
    year: 1970
  ),
  author : "Snoop Dog",
  obverse: [Artigo apresentado ao curso de graduação em alguma coisa do campous tal como requisito parcial para obtenção do título de Bacharel naquela coisa.],
  advisor: (
    name: "Manoel Gomes",
    titulation: "Dr.",
    institution: "Universidade do Estado de Santa Catarina"
  ),
  committee: (
    (
      name: "Stephen Timoshenko",
      titulation: "Dr.",
      institution: "Petersburg State Transport University"
    ),
    (
      name: "Willis Carrier",
      titulation: "Dr. h. c.",
      institution: "Cornell University"
    ),
    (
      name: "Leonhard Euler",
      titulation: "Dr.",
      institution: "University of Basel"
    )
  ),
  class: "Dissertação",
  // ARGUMENTOS OPCIONAIS
  // Estes argumentos quando omitidos fazem com que suas respectivas páginas também o sejam.
  dedication: [Aos alunos da Universidade do Estado de Santa Catarina, altissíssimo.], 
  acknowledgments : [Eu quero me agradecer por acreditar em mim mesmo, quero me agradecer por todo esse trabalho duro. Quero me agradecer por não tirar folgas. Quero me agradecer por nunca desistir. Quero me agradecer por ser generoso e sempre dar mais do que recebo. Quero me agradecer por tentar sempre fazer mais o certo do que o errado. Quero me agradecer por ser eu mesmo o tempo inteiro.],
  epigraph : [_Somos por essa causa, essa somente,\ perdidos, mas nossa pena é só esta:\ sem esperança, ansiar eternamente._\ \ (A Divina Comédia, Canto IV, 40-42, Dante Alighieri)],
  index-card: true
)


#include "chapters/1-introduction.typ"
#include "chapters/2-figures.typ"


// BIBLIOGRAFIA

#bibliography("bibliography.bib")  

// ANEXOS

#set heading(numbering: none)
