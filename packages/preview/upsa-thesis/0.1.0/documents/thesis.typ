#import "@preview/upsa-thesis:0.1.0": back-matter, front-matter, main-matter, part, settings
#import "@preview/mitex:0.2.7": mitex
#import "@preview/cetz:0.5.3": canvas, draw

#let multi-part = false

#show: settings.with(
  author-name: "Jassiel Ovando",
  author-university-id: 2021123456,
  work-title: [El título de esta tesis es «Esperanza»],
  author-email: "a2021123456@upsa.edu.bo",
  supervisor: [Dr. Juan Pérez],
  degree-level: [Licenciatura],
  degree-program: [Ingeniería de Sistemas],
  faculty: [Facultad de Ingeniería],
  modality: [Proyecto de Grado],
  modality-acronym: [PG],
  faculty-acronym: [FAI],
  abstract: lorem(200),
  keywords: ("UPSA", "tesis"),
  date: datetime.today(),
  paper-size: "a4",
  multi-part: multi-part,
)

#front-matter(
  executive-summary: lorem(50),
  objective: lorem(30),
  problem: lorem(20),
)

#show: main-matter

#if multi-part { part[El comienzo] }

= Introducción <cap-introduccion>

Este documento combina contenido de demostración en español con texto de relleno para mostrar la composición de un trabajo de grado. El caso ilustrativo es un sistema de seguimiento de solicitudes de préstamo de equipos de laboratorio. No describe una implementación real ni resultados obtenidos en la Universidad.

== Planteamiento del problema

En el escenario ficticio, las solicitudes se registran en archivos separados, lo que dificulta consultar la disponibilidad de equipos y conocer el estado de cada préstamo. El proyecto propone centralizar el registro y mantener una secuencia identificable de solicitud, aprobación, entrega y devolución. Antes de usar este planteamiento en un trabajo real, el estudiante deberá sustituirlo por evidencia de su contexto y delimitar el problema con su asesor.

=== Alcance del ejemplo

La demostración comprende el registro de solicitudes y el seguimiento de sus estados. Se excluyen compras, facturación y mantenimiento físico de equipos. Los nombres de roles y las reglas siguientes son supuestos didácticos, no procedimientos institucionales.

+ El solicitante consulta equipos y registra una solicitud.
+ El responsable revisa disponibilidad y aprueba o rechaza la solicitud.
+ El encargado registra la entrega y la devolución del equipo.

Las tablas y referencias de este ejemplo muestran cómo vincular una necesidad con su comprobación posterior; su contenido debe adaptarse al proyecto de cada estudiante.

== Jerarquía de encabezamientos <sec-jerarquia>

Un capítulo se escribe con `=`, una sección con `==` y una subsección con `===`. El número de signos aumenta con cada nivel. Esta sección muestra los seis niveles, incluidos párrafo y subpárrafo; las partes se crean exclusivamente con `part()` cuando `multi-part` está activado.

=== Subsección: delimitación del ejemplo <subsec-delimitacion>

Este tercer nivel organiza un tema dentro de la @sec-jerarquia. La referencia `@sec-jerarquia` toma su número automáticamente; no se escribe el número a mano.

==== Subsubsección: criterios de revisión <subsubsec-criterios>

El cuarto nivel conserva la numeración decimal. Véanse la @subsec-delimitacion y la @subsubsec-criterios para comparar sus prefijos con los del índice general.

===== Párrafo: evidencia mínima <parrafo-evidencia>
El quinto nivel es un encabezamiento integrado al texto, sin número. Este párrafo explica que cada requisito debería vincularse con una evidencia observable. Su título se enlaza con `link` en lugar de atribuirle una numeración inexistente.

====== Subpárrafo: detalle de la evidencia <subparrafo-evidencia>
El sexto nivel añade un detalle al párrafo anterior. En esta demostración, la evidencia consiste en registrar el identificador, la acción realizada y el estado resultante de una solicitud.

Se puede volver al #link(<parrafo-evidencia>)[párrafo sobre evidencia] o al #link(<subparrafo-evidencia>)[subpárrafo de detalle] mediante enlaces internos. Los niveles de párrafo y subpárrafo siguen disponibles en los marcadores del PDF, aunque el índice impreso se limita a los cuatro primeros niveles.

=== Objetivos

#lorem(20)

==== Objetivo general

#lorem(100)

==== Objetivos específicos

#lorem(50)

+ #lorem(100)
+ #lorem(100)
+ #lorem(100)
+ #lorem(100)
+ #lorem(100)

= Desarrollo <cap-desarrollo>

== Análisis de requerimientos

#lorem(20)

=== Requerimientos funcionales

#lorem(300)

=== Requerimientos no funcionales

#lorem(500)

#figure(
  table(
    columns: 3,
    table.header([Caso de Uso], [Actor], [Descripción]),
    [CU-01], [Usuario], [El usuario inicia sesión en el sistema.],
    [CU-02], [Administrador], [El administrador gestiona los usuarios.],
    table.hline(),
  ),
  caption: [Tabla de Casos de Uso],
) <tabla-casos>

== Trazabilidad de requisitos <trazabilidad>

La @tabla-requisitos vincula los requisitos del caso ficticio con criterios observables. Los identificadores permiten referirse al mismo requisito durante el análisis, el diseño y las pruebas sin repetir su descripción completa.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    table.header([Identificador], [Requisito ilustrativo], [Criterio de aceptación]),
    [RF-01], [Registrar una solicitud.], [Con datos válidos se asigna un identificador y el estado pendiente.],
    [RF-02], [Resolver una solicitud.], [Solo el rol responsable puede aprobarla o rechazarla.],
    [RF-03], [Consultar el historial.], [Se muestran los cambios de estado y su fecha para una solicitud.],
    table.hline(),
  ),
  caption: [Matriz ilustrativa de requisitos y criterios de aceptación],
) <tabla-requisitos>

=== Diseño de la solución

Se propone separar la interfaz, las reglas de préstamo y la persistencia de datos. Esta división permite revisar cada responsabilidad y comprobar que una modificación visual no altere las reglas de aprobación. Para un proyecto real, la elección de arquitectura debe justificarse frente a sus restricciones y alternativas.

Cada solicitud contiene un identificador, el equipo, el solicitante y su estado. Las transiciones permitidas son de pendiente a aprobada o rechazada, de aprobada a entregada y de entregada a devuelta. Una solicitud rechazada no permite registrar una entrega. Un diagrama de estados puede complementar esta descripción cuando resulte útil.

== Pruebas

Las pruebas propuestas se derivan de los criterios de la @tabla-requisitos. La tabla siguiente es un plan de comprobación, no un registro de pruebas ejecutadas.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    table.header([Caso], [Acción], [Resultado esperado]),
    [CP-01],
    [Enviar una solicitud con todos los campos obligatorios.],
    [Se registra una solicitud pendiente con identificador único.],
    [CP-02], [Intentar aprobar con el rol solicitante.], [Se rechaza la operación y se conserva el estado anterior.],
    [CP-03], [Intentar entregar una solicitud rechazada.], [No se registra una entrega.],
    table.hline(),
  ),
  caption: [Plan ilustrativo de pruebas funcionales],
)

=== Presentación de resultados

En una investigación real, esta sección deberá indicar el entorno, la versión evaluada, los casos ejecutados y la evidencia de cada resultado. Una prueba pendiente no debe presentarse como aprobada. Las observaciones de usuarios se distinguirán de los resultados técnicos y se describirá cómo fueron recogidas.

Para mostrar una expresión matemática sencilla, puede definirse la proporción de casos aprobados como:

#math.equation(
  block: true,
  alt: "La proporción p es igual al número de casos aprobados dividido entre el número de casos ejecutados.",
  $p = n_a / n_e$,
) <eq-proporcion>

donde #math.equation(alt: "n subíndice a", $n_a$) es el número de casos aprobados y #math.equation(alt: "n subíndice e", $n_e$) el número de casos ejecutados, siempre que #math.equation(alt: "n subíndice e es mayor que cero", $n_e > 0$). Esta proporción resume únicamente los casos ejecutados y no demuestra por sí sola la calidad completa del sistema.

=== Código fuente <sec-codigo>

El @listado-go muestra un programa mínimo en Go. Los bloques con lenguaje explícito, como `go`, reciben resaltado de sintaxis; al envolverlos en `figure`, también obtienen un número y una entrada en el índice de listados.

#figure(
  ```go
  package main

  import "fmt"

  func main() {
      fmt.Println("Hello, World!")
  }
  ```,
  alt: "Hello World en Go",
  caption: [Ejemplo de código fuente en Go],
) <listado-go>

=== Verificación y validación

#lorem(30)

#figure(
  caption: [Recurrencia de complejidad algorítmica (Teorema Maestro) y entropía de Shannon],
  kind: math.equation,
  $
    T(n) & = a T(n/b) + f(n) \
    H(X) & = - sum_(i=1)^n p(x_i) log_2 p(x_i)
  $,
  alt: "Ecuación de complejidad algorítmica y entropía",
)

= Recursos de composición <cap-recursos>

== Matemática nativa de Typst <sec-matematica>

La @eq-proporcion se definió en el @cap-desarrollo. Una fórmula en línea puede escribirse entre signos de dólar, por ejemplo #math.equation(alt: "p igual a cero coma ocho", $p = 0.8$). Una ecuación en bloque admite etiqueta y referencia como cualquier otro elemento numerado.

// Escribimos el cuerpo en notación matemática de Typst y damos una
// descripción accesible al elemento math.equation.
#math.equation(
  block: true,
  alt: "El promedio de x es la suma de las observaciones x subíndice i, desde i igual a uno hasta n, dividida entre n.",
  $overline(x) = 1/n sum_(i=1)^n x_i$,
) <eq-promedio>

En la @eq-promedio, las observaciones pueden representar tiempos de atención. Para desarrollar varias igualdades, `&` alinea los términos y la barra invertida separa las líneas:

#math.equation(
  block: true,
  alt: "La varianza es el promedio de los cuadrados de las diferencias respecto de la media; también equivale al promedio de los cuadrados menos el cuadrado de la media.",
  $
    sigma^2 & = 1/n sum_(i=1)^n (x_i - overline(x))^2 \
            & = 1/n sum_(i=1)^n x_i^2 - overline(x)^2
  $,
) <eq-varianza>

La @eq-varianza ilustra la alineación de varias líneas dentro de una misma ecuación numerada.

== Ecuaciones LaTeX con MiTeX <sec-latex>

MiTeX permite reutilizar notación matemática de LaTeX dentro de Typst. El código fuente importa una versión concreta del paquete y pasa el texto LaTeX como contenido literal. El siguiente bloque muestra exactamente la expresión que se procesa:

```latex
\hat{p} = \frac{n_a}{n_e}, \qquad n_e > 0
```

// Los backticks conservan las barras de LaTeX sin escaparlas.
#mitex(
  `\hat{p} = \frac{n_a}{n_e}, \qquad n_e > 0`,
  numbering: "(1)",
  supplement: [Fórmula],
  alt: "La proporción estimada p es el cociente entre casos aprobados y ejecutados, con un número de casos ejecutados mayor que cero.",
) <eq-latex>

La @eq-latex comparte el contador de ecuaciones con la @eq-promedio. La sintaxis de LaTeX se limita aquí a las matemáticas: el documento, las figuras y las referencias siguen escritos en Typst. La documentación del #link("https://typst.app/universe/package/mitex/")[paquete MiTeX] contiene más ejemplos.

== Código fuente y referencias cruzadas <sec-listados>

El @listado-validacion desarrolla una regla del caso ficticio. `raw` conserva la sangría y `figure` proporciona el rótulo «Listado». La @tabla-requisitos define los requisitos que motivan esta regla y la @trazabilidad explica su relación con las pruebas.

#figure(
  ```python
  def aprobar(solicitud, rol):
      if rol != "responsable":
          raise PermissionError("Rol no autorizado")
      if solicitud["estado"] != "pendiente":
          raise ValueError("La solicitud ya fue resuelta")
      return {**solicitud, "estado": "aprobada"}
  ```,
  caption: [Regla ilustrativa de aprobación de una solicitud],
  alt: "Código Python que comprueba el rol responsable y el estado pendiente antes de devolver una solicitud aprobada.",
) <listado-validacion>

Para reproducir un ejemplo, se escribe una etiqueta como `<listado-validacion>` después de la figura y se la menciona con `@listado-validacion`. Lo mismo funciona para la @tabla-casos, la @eq-latex y el @cap-introduccion.

== Diagramas y gráficos con CeTZ <sec-graficos>

La @fig-estados es un grafo sencillo dibujado mediante coordenadas, líneas, círculos y texto. Su contenido se genera con CeTZ y se envuelve en una figura de tipo `image` para incluirlo en el índice de figuras. La descripción alternativa explica el gráfico a quien no pueda verlo.

#figure(
  canvas(length: 1cm, {
    import draw: *
    line((0, 0), (4, 0), (8, 0), stroke: 1pt)
    for (x, nombre) in ((0, [Pendiente]), (4, [Aprobada]), (8, [Entregada])) {
      circle((x, 0), radius: 0.24, fill: white, stroke: 1pt)
      content((x, -0.65), nombre)
    }
    content((2, 0.45), [Aprobar])
    content((6, 0.45), [Entregar])
  }),
  kind: image,
  caption: [Estados y transiciones del préstamo en el caso ficticio],
  alt: "Tres estados conectados de izquierda a derecha: pendiente, aprobada y entregada. La acción aprobar conecta los dos primeros; entregar conecta los dos últimos.",
) <fig-estados>

La @fig-tiempos usa los mismos elementos para representar una serie de datos. Los valores se declaran en el código y son exclusivamente ilustrativos; no corresponden a mediciones reales.

#figure(
  canvas(length: 1cm, {
    import draw: *
    line((0, 3.8), (0, 0), (8.5, 0), stroke: 0.8pt)
    for i in range(1, 5) {
      let x = i * 2
      line((x, -0.08), (x, 0.08))
      content((x, -0.4), [#i])
    }
    for minutos in (0, 5, 10, 15) {
      let y = minutos / 4
      line((-0.08, y), (0.08, y))
      content((-0.25, y), [#minutos], anchor: "east")
    }
    let puntos = ((2, 3), (4, 2.25), (6, 1.75), (8, 1.5))
    line(..puntos, stroke: 1.4pt)
    for punto in puntos {
      circle(punto, radius: 0.09, fill: black)
    }
    content((4.5, -0.95), [Iteración])
    content((0, 4.25), [Tiempo (min)], anchor: "west")
  }),
  kind: image,
  caption: [Tiempos de atención simulados por iteración],
  alt: "Gráfico de líneas con cuatro iteraciones. Los tiempos simulados son doce, nueve, siete y seis minutos, respectivamente. La serie desciende en cada iteración.",
) <fig-tiempos>

Se pueden modificar las coordenadas, el texto y los estilos sin exportar una imagen externa. El código de ambos ejemplos se encuentra junto a su figura en este archivo; la #link("https://cetz-package.github.io/docs/")[documentación de CeTZ] explica sus primitivas de dibujo.

== Citas bibliográficas y citas textuales <sec-citas>

Una etiqueta bibliográfica funciona de manera similar a una referencia interna: `@UMLDistilled3rd` produce una cita a un libro @UMLDistilled3rd. También se puede citar una página web @IBMCarbonDesign. El formato final depende del estilo seleccionado en `bibliography`, que en este ejemplo es IEEE.

Una cita con localizador puede escribirse como `#cite(<UMLDistilled3rd>, supplement: [cap. 1])`: #cite(<UMLDistilled3rd>, supplement: [cap. 1]). Este ejemplo muestra la sintaxis del localizador; al redactar el trabajo, debe indicarse el capítulo o la página efectivamente consultados.

Para demostrar una cita textual breve se reproduce una oración de la documentación oficial de Typst, en su idioma original:

#quote(attribution: <knuth1984texbook>)[With headings, you can structure your document into sections.]

El siguiente bloque contiene más de cuarenta palabras. Es un testimonio inventado para demostrar la composición de una cita extensa; no procede de una entrevista ni constituye evidencia del proyecto.

#quote(block: true, attribution: [Testimonio ficticio elaborado para esta plantilla])[
  Cuando solicitamos un equipo, necesitamos conocer si está disponible y quién debe autorizar su entrega. También queremos consultar el estado de la solicitud sin enviar mensajes adicionales. Un historial compartido nos permitiría identificar cuándo cambió cada estado, qué persona realizó la acción y si todavía falta registrar la devolución del equipo prestado.
]

El contenido de `quote` conserva una atribución explícita. Para una cita real se deben transcribir fielmente las palabras, comprobar la fuente y proporcionar el localizador que permita encontrarlas.

#if multi-part {
  part[El final]
}

= Conclusiones

== Conclusiones

#lorem(50)

=== #lorem(10)

#lorem(40)

=== #lorem(10)

#lorem(40)

=== #lorem(10)

#lorem(40)

=== #lorem(10)

#lorem(40)

=== #lorem(10)

#lorem(40)

== Recomendaciones

#lorem(500)

#show: back-matter.with()

#bibliography(
  ("bibliography/ref.haya.yaml", "bibliography/ref.bib"),
  style: "ieee",
  full: true,
)

// = Curriculum Vitae

// #image(
//   "cv.svg",
//   alt: "Curriculum Vitae",
//   height: 1fr,
// )

= Carta de Aprobación

#lorem(100)

= Presupuesto

#lorem(100)

== Herramientas

#lorem(50)
