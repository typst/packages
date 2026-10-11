#import "@preview/xemelgo-etse:0.1.0": apendices, modeloA

// Models: modeloA (research), modeloB (software system), modeloC (project / business study)
#show: modeloA.with(
  title: [Título del Trabajo de Fin de Grado],
  // subtitle: [Subtítulo del Trabajo de Fin de Grado],
  authors: (
    (name: "Nombre de la autora o del autor"),
    (name: "Nombre de la tutora o del tutor"),
    (name: "Nombre de la cotutora o del cotutor"),
    // (name: "...", department: "Departamento de ..."),
  ),
  // USC logo (not included): download it from https://www.usc.gal/gl/usc/institucional/imaxe-corporativa
  // logo: image("logo_usc.pdf"),
  // date: datetime(year: 2027, month: 3, day: 1),
  // lang: "gl", // "es", "gl" or "en"
  // i18n: (es: (abstract: [Sinopsis])), // change any fixed text
  // code-style: "wired", // code blocks as in the wired-ieee package
  // code-numbers: true, // line numbers, with code-style: "wired"
  // certification: false,
  // blank-pages: false,
  acknowledgements: [Si se quiere poner algún agradecimiento, este va aquí.],
  abstract: [Breve resumen de las principales contribuciones del trabajo.],
  bibliography: bibliography("refs.bib"),
)

= Introducción

Descripción del problema a resolver, hipótesis a testar, objetivo general del trabajo, objetivos
concretos, contrastables y descritos correctamente.

= Estado del conocimiento del problema a abordar

Descripción breve de los métodos, técnicas o herramientas actuales similares al trabajo presentado.
Similitudes y diferencias con el trabajo presentado.

= Metodología

Materiales, equipos, procedimientos, diseño experimental, descripción de los métodos
matemáticos/estadísticos usados en el trabajo. Justificaciones de las elecciones realizadas.

= Pruebas

Plan de pruebas (con evidencias) que verifica la funcionalidad y corrección global del experimento,
resultados del plan de pruebas.

= Discusión de los resultados

Comprobación de la(s) hipótesis de partida del trabajo. Comparativa con alguna de las soluciones
similares presentadas en el estado del conocimiento, resaltando por qué el trabajo presentado mejora
las soluciones anteriores.

#include "ejemplos.typ"

= Conclusiones y posibles ampliaciones

Resumen de las principales aportaciones del trabajo, explicaciones de las suposiciones y limitaciones
del trabajo, y posibles vías de mejora.

#show: apendices

= Manuales técnicos

En función del tipo de Trabajo y metodología empleada, el contenido se podrá dividir en varios
documentos. En todo caso, en ellos se incluirá toda la información precisa para aquellas personas que
deseen repetir el experimento (por ejemplo código fuente, recursos necesarios, operaciones necesarias
para modificaciones y pruebas, posibles problemas, etc.). El código fuente se podrá entregar en soporte
informático en formatos PDF o postscript.

= Manuales de usuario

Incluirán toda la información precisa para aquellas personas que repliquen el experimento:
instalación, utilización, configuración, mensajes de error, etc. La documentación del usuario debe ser
autocontenida, es decir, para su entendimiento el usuario final no debe precisar de la lectura de otro
manual técnico.

= Licencia

Si se quiere poner una licencia (GNU GPL, Creative Commons, etc.), el texto de la licencia va aquí.
