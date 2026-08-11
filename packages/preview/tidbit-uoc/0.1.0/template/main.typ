#import "@preview/tidbit-uoc:0.1.0": template

#show: template.with(
    subject: "Herramientas HTML y CSS I",
    title: "PEC1: Desarrollo de una web",
    subtitle: "Iniciando la asignatura con un proyecto web",
    date: datetime(year: 2025, month: 6, day: 30),
    author: "Daniel Ramos Acosta",
)

= Introducción  

#lorem(700)

= Imágenes

Un tamaño recomendado es un ancho del 75 % de la línea de texto con una altura
proporcional a la primera. Todas las imágenes deben incluir una leyenda.

#figure(image("assets/logo.svg"), caption: [
    Leyenda de la figura.
])

= Código

Ejemplo de código.

#figure(caption: [Ejemplo de código.])[
    ```python
    def OrdenBurbuja(a):
        for i in range(len(a)-2):
            for j in range(len(a)-i-1):
                if a[j] > a[j+1]:
                    a[j],a[j+1] = a[j+1],a[j]
        return a
    ```
]

= Bibliografía y citas

La bibliografía debe incluirse mediante un archivo `.bib` con el mismo nombre que el archivo principal. El estilo bibliográfico a usar es APA séptima edición. Para las citas puede utilizar los siguientes comandos según sea adecuado:

- Cita completa entre paréntesis: #cite(<Bib06>)
- Cita completa sin paréntesis: #cite(<Bib06>, form: "prose")
- Cita de autor: #cite(<Bib06>, form: "author")
- Cita de año: #cite(<Bib06>, form: "year")
- Cita con opciones extras: #cite(<Bib06>, form: "full")

#bibliography("./references/example.bib")
