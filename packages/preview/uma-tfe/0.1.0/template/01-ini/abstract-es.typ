#import "@preview/uma-tfe:0.1.0": *

#show heading: none
#heading(level: 1, numbering: none)[Resumen]
#v(-8pt)

#context [
  #align(center)[#fakesc("E.T.S. de Ingeniería de Telecomunicación, Universidad de Málaga")]

  #v(2.5em)
  #align(center)[
    #text(size: Large)[
      #set par(justify: false, leading: 0.7em)
      #strong[#fakesc(titlename.at(here()))]
    ]
  ]

  #v(2.5em)
  #block(width: 100%, inset: (left: 17.5pt))[
    #set par(first-line-indent: 0pt, spacing: 0pt)
    *Autor:* #author.at(here())
    #v(12pt)
    *Tutor:* #tutor.at(here())
    #v(12pt)
    *Departamento:* \<DEPARTAMENTO>
    #v(12pt)
    *Titulación:* Máster en #titulacion.at(here())
    #v(12pt)
    *Palabras clave:* Palabras clave (separadas por coma) que describen y caracterizan el tema del trabajo.
  ]
  #v(2.5em)

  #align(center)[*Resumen*]
  #v(9pt)
]

El resumen debe ser una breve descripción del contexto del proyecto,
sus objetivos y los resultados obtenidos. Se recomienda que no exceda
esta página.

#chapterend()
