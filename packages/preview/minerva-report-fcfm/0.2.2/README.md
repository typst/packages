# Minerva Report FCFM

Template para hacer tareas, informes y trabajos, para estudiantes y académicos de la Facultad de Ciencias Físicas y Matemáticas de la Universidad de Chile que han usado templates similares para LaTeX.

## Guía Rápida

### [Webapp](https://typst.app)
Si utilizas la webapp de Typst puedes presionar "Start from template" y buscar "minerva-report-fcfm" para crear un nuevo proyecto con este template.

### Typst CLI
Teniendo el CLI con la versión 0.11.0 o mayor, puedes realizar:
```sh
typst init @preview/minerva-report-fcfm:0.2.2
```
Esto va a descargar el template en la cache de typst y luego va a iniciar el proyecto en la carpeta actual.

## Configuración
La mayoría de la configuración se realiza a través del archivo `meta.typ`,
allí podrás elegir un título, indicar los autores, el equipo docente, entre otras configuraciones.

El campo `autores` solo puede ser `string` o un `array` de strings.

La configuración `departamento` puede ser personalizada a cualquier organización pasandole un diccionario de esta forma:
```typ
#let departamento = (
  nombre: (
    "Universidad Técnica Federico Santa María",
  )
)
```

Las demás configuraciones pueden ser un `content` arbitrario, o un `string`.

### Configuración Avanzada
Algunos aspectos más avanzados pueden ser configurados a través de la show rule que inicializa el documento `#show: minerva.report.with( ... )`, los parámetros opcionales que recibe la función `report` son los siguientes:

| nombre    | tipo              | descrición                                                                                                                                                                                |
|-----------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| portada   | (meta) => content | Una función que recibe el diccionario `meta.typ` y retorna una página.                                                                                                                    |
| header    | (meta) => content | Header a aplicarse a cada página.                                                                                                                                                         |
| footer    | (meta) => content | Footer a aplicarse a cada página.                                                                                                                                                         |
| showrules | bool              | El template aplica ciertas show-rules para que sea más fácil de utilizar. Si quires más personalización, es probable que necesites desactivarlas y luego solo utilizar las que necesites. |

#### Show Rules
El template incluye show rules que pueden ser incluidas opcionalmente.
Todas estas show rules pueden ser activadas agregando:
```typ
#show: minerva.<nombre-función>
```
Justo después de la línea `#show minerva.report.with( ... )` reemplazando `<nombre-función>`
por el nombre de la show rule a aplicar.

##### primer-heading-en-nueva-pag (activada por defecto)
Esta show rule hace que el primer heading que tenga `outlined: true` se muestre en una
nueva página (con `weak: true`). Notar que al ser `weak: true` si la página ya de por
si estaba vacía, no se crea otra página adicional, pero para que la página realmente
se considere vacía no debe contener absolutamente nada, incluso tener elementos invisibles
va a causar que se agregue una página extra.

##### operadores-es (activada por defecto)
Cambia los operadores matemáticos que define Typst por defecto a sus contrapartes en 
español, esto es, cambia `lim` por `lím`, `inf` por `ínf` y así con todos.

##### formato-numeros-es
Cambia los números dentro de las ecuaciones para que usen coma decimal en vez
de punto decimal, como es convención en el español. Esta show rule no viene
activa por defecto.
