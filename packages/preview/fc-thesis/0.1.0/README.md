# fc-thesis template

Este es un template para tesis de la facultad de ciencias,
en la Universidad Nacional Autónoma de México (UNAM).

This is a thesis template for the Science Faculty at Universidad Nacional Autónoma de México (UNSM) based on my thesis.

## Uso/Usage

En la aplicación web de Typst da click en "Start from template" y busca `fc-thesis`.

In the Typst web app simply click "Start from template" on the dashboard and search for `fc-thesis`.

Si estas usando la versión de teminal usa el comando:
From the CLI you can initialize the project with the command:

```bash
typst init @preview/fc-thesis:0.1.0
```

## Configuración/Configuration

Para configurar tu tesis puedes hacerlo con estas lineas al
inicio de tu archivo principal.

To set the thesis template, you can use the following lines
in your main file.

```typ
#import "@preview/fc-thesis:0.1.0": thesis

#show: thesis.with(
  ttitulo: [Titulo],
  grado: [Licenciatura],
  autor: [Autor],
  asesor: [Asesor],
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: bibliography("references.bib"),
)

// Tu tesis va aquí
```

Tambien puedes utilizar estas lineas para crear capítulos con bibliografía,
si deseas crear un pdf solomente para el capítulo.

You could also create a pdf for just a chapter with bibliography, by using the following lines.

```typ
#import "@preview/fc-thesis:0.1.0": chapter

// completamente opcional cargar la bibliografía, compilar el capítulo
#show: chapter.with(bibliography: bibliography("references.bib"))

// Tu capítulo va aquí
```

Si quieres crear pdf aun mas cortos, puedes utilizar estas lineas para crear un pdf solo para el sección de tu capítulo.

You could even create a pdf for just a section of a chapter.

```typ
#import "@preview/fc-thesis:0.1.0": section

// completamente opcional cargar la bibliografía, compilar el sección
#show: section.with(bibliography: bibliography("references.bib"))

// Tu sección va aquí
```
