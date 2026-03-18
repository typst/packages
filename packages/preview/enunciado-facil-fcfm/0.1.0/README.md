# enunciado-facil-fcfm

Template de Typst para documentos de la FCFM (auxiliares, controles, pautas)

## Ejemplo de uso

### En [typst.app](https://typst.app)

Si utilizas la aplicación web oficial, puedes presionar "Start from template" y buscar "enunciado-facil-fcfm" para crear un proyecto ya inicializado con el template.

### En CLI

Si usas Typst de manera local, puedes ejecutar:
```sh
typst init @preview/enunciado-facil-fcfm:0.1.0
```
lo cual inicializará un proyecto usando el template en el directorio actual.

### Manualmente

Basta crear un archivo con el siguiente contenido para usar el template:

```typ
#import "@preview/enunciado-facil-fcfm:0.1.0" as template

#show: template.conf.with(
  titulo: "Auxiliar 1",
  subtitulo: "Typst",
  titulo-extra: (
    [*Profesora*: Ada Lovelace],
    [*Auxiliares*: Grace Hopper y Alan Turing],
  ),
  departamento: template.departamentos.dcc,
  curso: "CC4034 - Composición de documentos",
)

...el resto del documento comienza acá
```

Puedes ver un ejemplo más completo en [main.typ](template/main.typ). Para aprender la sintáxis de Typst existe la [documentación oficial](https://typst.app/docs). Si vienes desde LaTeX, te recomiendo la [guía para usuarios de LaTeX](https://typst.app/docs/guides/guide-for-latex-users/).

## Configuración

La función `conf` importada desde el template recibe los siguientes parámetros:

| Parámetro      | Descripción                                                                                                                                          |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `titulo`       | Título del documento                                                                                                                                 |
| `subtitulo`    | Subtítulo del documento                                                                                                                              |
| `titulo-extra` | Arreglo con bloques de contenido adicionales a agregar después del título. Útil para mostrar los nombres del equipo docente.                         |
| `departamento` | Diccionario que contiene el nombre (`string`) y el logo del departamento (`content`). El template viene con uno ya creado para cada departamento bajo `template.departamentos`. Valor por defecto: `template.departamentos.dcc`|
| `curso`        | Código y/o nombre del curso.          |
| `page-conf`    | Diccionario con parámetros adicionales (tamaño de página, márgenes, etc) para pasarle a la función [page](https://typst.app/docs/reference/layout/page/).|

## FAQ

### Cómo cambiar el logo del departamento

El parámetro `departamento` solamente es un diccionario de Typst con las llaves `nombre` y `logo`. Puedes crear un diccionario con un logo personalizado y pasárselo al template:

```typ
#import "@preview/enunciado-facil-fcfm:0.1.0" as template

#let mi-departamento = (
  nombre: "Mi súper departamento personalizado",
  logo: image("mi-super-logo.png"),
)

#show: template.conf.with(
  titulo: "Documento con logo personalizado",
  departamento: mi-departamento,
  curso: "CC4034 - Composición de documentos",
)
```

### Cómo cambiar márgenes, tamaño de página, etcétera

Para cambiar la configuración de la página hay que interceptar la [set rule](https://typst.app/docs/reference/styling/#set-rules) que se hace sobre `page`. Para ello, el template expone el parámetro `page-conf` que permit sobreescribir la configuración de página del template. Por ejemplo, para cambiar el tamaño del papel a A4:

```typ
#import "@preview/enunciado-facil-fcfm:0.1.0" as template

#show: template.conf.with(
  titulo: "Documento con tamaño A4",
  departamento: template.departamentos.dcc,
  curso: "CC4034 - Composición de documentos",
  page-conf: (paper: "a4")
)
```

### Cómo cambiar la fuente, headings, etc

Usando [show y set rules](https://typst.app/docs/reference/styling/) puedes personalizar mucho más el template. Por ejemplo, para cambiar la fuente:

```typ
#import "@preview/enunciado-facil-fcfm:0.1.0" as template

// En este caso hay que cambiar la fuente
// antes de que se configure el template
// para que se aplique en el título y encabezado
#set text(font: "New Computer Modern")

#show: template.conf.with(
  titulo: "Documento con la fuente de LaTeX",
  departamento: template.departamentos.dcc,
  curso: "CC4034 - Composición de documentos",
)
```
