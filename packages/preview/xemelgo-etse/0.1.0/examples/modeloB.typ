#import "@preview/xemelgo-etse:0.1.0": apendices, modeloB

#show: modeloB.with(
  title: [Título del Trabajo de Fin de Grado],
  // subtitle: [Subtítulo del Trabajo de Fin de Grado],
  authors: (
    (name: "Nombre de la autora o del autor"),
    (name: "Nombre de la tutora o del tutor"),
    (name: "Nombre de la cotutora o del cotutor"),
    // (name: "...", department: "Departamento de ..."),
  ),
  // logo: none, // hide the USC logo, or pass your own image(..)
  // date: datetime(year: 2027, month: 3, day: 1),
  // lang: "gl",
  // certification: false,
  // blank-pages: false,
  acknowledgements: [Si se quiere poner algún agradecimiento, este va aquí.],
  abstract: [Breve resumen de las principales contribuciones del trabajo.],
  bibliography: bibliography("../template/refs.bib"),
)

= Introducción

Objetivos generales, relación de la documentación que conforma la memoria, descripción del sistema,
información adicional de interés (métodos, técnicas o arquitecturas utilizadas, justificación de su
elección, etc.).

= Especificación de requisitos

Especificación de los requisitos más relevantes del sistema, junto con la información que este debe
almacenar y las interfaces con otros sistemas, sean hardware o software, y otros requisitos
(rendimiento, seguridad, etc.).

= Diseño

Debe describirse cómo se realiza el sistema, la división de este en diferentes componentes y la
comunicación entre ellos. Asimismo, se determinará el equipamiento hardware y software necesario,
justificando su elección en el caso de que no fuese un requisito previo. Debe aportarse un nivel
suficiente de detalle que permita comprender la totalidad de la estructura del producto desarrollado,
utilizando en lo posible representaciones gráficas.

= Pruebas

Plan de pruebas (con evidencias) que verifica la funcionalidad y corrección global del sistema, y cómo
se lleva a cabo.

#include "../template/ejemplos.typ"

= Conclusiones y posibles ampliaciones

El trabajo describe el grado de cumplimiento de los objetivos. Posibles vías de mejora.

#show: apendices

= Manuales técnicos

En función del tipo de Trabajo y metodología empleada, el contenido se podrá dividir en varios
documentos. En todo caso, en ellos se incluirá toda la información precisa para aquellas personas que
se vayan a encargar del desarrollo y/o modificación del sistema (por ejemplo código fuente, recursos
necesarios, operaciones necesarias para modificaciones y pruebas, posibles problemas, etc.). El código
fuente se podrá entregar en soporte informático en formatos PDF o postscript.

= Manuales de usuario

Incluirán toda la información precisa para aquellas personas que utilicen el sistema: instalación,
utilización, configuración, mensajes de error, etc. La documentación del usuario debe ser
autocontenida, es decir, para su entendimiento el usuario final no debe precisar de la lectura de otro
manual técnico.

= Licencia

Si se quiere poner una licencia (GNU GPL, Creative Commons, etc.), el texto de la licencia va aquí.
