# UTFPR TCC (unofficial)

* [English](#quick-start)
* [Portuguese](#início-rápido)

---

<h2 align="center">English</h2>

<center>
  UTFPR TCC template made by students for students
</center>

### Important info

The template content is in portuguese because the target audience is UTFPR students, a brazillian university.

## Quick start

```typst
#import "@local/utfpr-tcc-unofficial:0.1.0": * 

#show: template.with(  
  title: [the title],
  title-foreign: [the title in the foreign language],

  lang: "pt",
  lang-foreign: "en",
  
  author: [your full name],
  city: [city],
  year: [year],

  description: [That little block on the second page.],

  keywords: ([word 1], [word 2], [word 3]),
  keywords-foreign: ([palavra 1], [palavra 2], [palavra 3]),
  
// ↓↓↓ OPTIONAL ELEMENTS ↓↓↓ //
  outline-figure: true,
  outline-table: true,
  abbreviations: (
    [ABNT], [Associação Brasileira de Normas Técnicas],
    [Coef.], [Coeficiente], 
    [IBGE], [Instituto Brasileiro de Geografia e Estatística],
    [NBR], [Normas Brasileiras], 
    [UTFPR], [Universidade Tecnológica Federal do Paraná],
  ),
  symbols: (
    [Ca], [Calcium],
    [Mg], [Magnesium], 
    [T], [Temperature],
    [V], [Volume], 
    [P], [Pressure],
  ),
// ↑↑↑ OPTIONAL ELEMENTS ↑↑↑ //
)
```

## Description 

A Template for UTFPR TCC (Trabalho de Conclusão de Curso) 
made by students for students to facilitate TCC production in typst. 
Be aware that this is an unofficial template, prone to errors. 
It's an open source project designed for anyone that wants to contribute
be able to, especially if the standard gets updated, 
some feature is incorrect or missing.

## Additional Functions

This template contains additional functions for specific content that can or should be used in your document:

- `#abstract[content]` for the abstract.

- `#abstract-foreign[content]` for the abstract in a foreign language.

- `#dedication[content]` for the dedication.

- `#acknowledgments[content]` for the acknowledgments.

- `#epigraph(attribution: [@citation])[content]` for the epigraph.


---

<h2 align="center">Portuguese</h2>

<center>
  Modelo UTFPR TCC criado por estudantes para estudantes
</center>

## Início rápido

Todos os argumentos abaixo possuem valores padrão, portanto, opcionais.

```typst
#import "@local/utfpr-tcc-unofficial:0.1.0": * 

#show: template.with(  
  title: [título],
  title-foreign: [título na linguagem estrangeira],

  lang: "pt",
  lang-foreign: "en",
  
  author: [seu nome completo],
  city: [cidade],
  year: [ano],

  description: [Aquele pequeno bloco na contra-capa.],

  keywords: ([palavra 1], [palavra 2], [palavra 3]),
  keywords-foreign: ([word 1], [word 2], [word 3]),
  
// ↓↓↓ ELEMENTOS OPCIONAIS ↓↓↓ //
  outline-figure: true,
  outline-table: true,
  abbreviations: (
    [ABNT], [Associação Brasileira de Normas Técnicas],
    [Coef.], [Coeficiente], 
    [IBGE], [Instituto Brasileiro de Geografia e Estatística],
    [NBR], [Normas Brasileiras], 
    [UTFPR], [Universidade Tecnológica Federal do Paraná],
  ),
  symbols: (
    [Ca], [Cálcio],
    [Mg], [Magnésio], 
    [T], [Temperatura],
    [V], [Volume], 
    [P], [Pressão],
  ),
// ↑↑↑ ELEMENTOS OPCIONAIS ↑↑↑ //
)
```

## Descrição

Um modelo para TCC (Trabalho de Conclusão de Curso) UTFPR
criado por estudantes para estudantes, com o objetivo de facilitar a produção de TCCs no Typst.
Este é um modelo não oficial, sujeito a erros.
Trata-se de um projeto de código aberto, criado para que qualquer pessoa que 
deseje contribuir possa fazê-lo, especialmente se o padrão for atualizado,
alguma funcionalidade estiver incorreta ou ausente.

## Funções adicionais

Essa template contém funções adicionais para conteúdos específicos
que podem ou devem ser usados no seu documento:

- `#abstract[ content ]` para o resumo.

- `#abstract-foreign[ content ]` para o resumo em língua estrangeira.

- `#dedication[ content ]` para a dedicação.

- `#acknowledgments[ content ]` para os agradecimentos.

- `#epigraph(attribution: [@citacao])[ content ]` para o epígrafo.
