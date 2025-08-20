# Minerva Report FCFM

Template para hacer tareas, informes y trabajos. Pensado para ser familiar para estudiantes y académicos de la Facultad de Ciencias Físicas y Matemáticas de la Universidad de Chile que han usado templates similares para LaTeX.

## Guía Rápida

### [Webapp](https://typst.app)
Si utilizas la webapp de Typst puedes presionar "Start from template" y buscar "minerva-report-fcfm" para crear un nuevo proyecto con este template.

### Typst CLI
Teniendo el CLI con la versión 0.11.0 o mayor, puedes realizar:
```sh
typst init @preview/minerva-report-fcfm:0.1.0
```
Esto va a descargar el template en la cache de typst y luego va a iniciar el proyecto en la carpeta actual.

## Configuración
La mayoría de la configuración se realiza a través del archivo `meta.typ`,
allí podrás elegir un título, indicar los autores, el equipo docente, entre otras configuraciones.

Todos los campos menos `autores` pueden recibir tanto strings `"string"` o directamente un bloque de contenido `[Contenido #emoji.smile]`.

La configuración `departamento` puede ser personalizada a cualquier organización pasandole un diccionario de esta forma:
```typ
#let departamento = (
  nombre: (
    "Pontificia Universidad Católica de Chile",
    "Facultad de Derecho",
  )
)
```

### Configuración Avanzada
Algunos aspectos más avanzados pueden ser configurados a través de la show rule que inicializa el documento `#show: minerva.report.with( ... )`, los parámetros opcionales que recibe la función `report` son los siguientes:

| nombre    | tipo              | descrición                                                                                                                                                                                |
|-----------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| portada   | (meta) => content | Una función que recibe el diccionario `meta.typ` y retorna una página.                                                                                                                    |
| header    | (meta) => content | Header a aplicarse a cada página.                                                                                                                                                         |
| footer    | (meta) => content | Footer a aplciarse a cada página.                                                                                                                                                         |
| showrules | bool              | El template aplica ciertas show-rules para que sea más fácil de utilizar. Si quires más personalización, es probable que necesites desactivarlas y luego solo utilizar las que necesites. |

# Changelog
# v0.1.0
- Primera versión
