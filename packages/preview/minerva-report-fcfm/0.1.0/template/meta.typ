#import "@preview/minerva-report-fcfm:0.1.0" as minerva

#let titulo = "Informe Minerva"
#let subtitulo = "Typst"
#let tema = "Aprendiendo a usar el template"

#let departamento = minerva.departamentos.dcc
#let curso = "CC4034 - Composición de Documentos"

#let fechas = ( // diccionario de fechas, si la portada no soporta
  realización: "14 de Mayo de 2024",
  entrega: minerva.formato-fecha(datetime.today())
)
#let lugar = "Santiago, Chile"

#let autores = ("Integrante1", "Integrante2")
#let equipo-docente = ( // diccionario con distintos valores soportados:
  Profesores: ("Profesor1", "Profesor2"), // arreglo de strings
  Auxiliar: "ÚnicoAuxiliar", // un único miembro como string
  Ayudante: [ // bloque de contenido
    Ayudante1 \
    Ayudante $1+1$
  ],
)
