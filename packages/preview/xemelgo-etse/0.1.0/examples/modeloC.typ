#import "@preview/xemelgo-etse:0.1.0": apendices, modeloC

#show: modeloC.with(
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

Descripción del problema a resolver, objetivos generales, relación de la documentación que conforma
la memoria.

= Análisis detallado de las alternativas

Descripción en profundidad de las soluciones innovadoras o novedosas actuales. Justificación
fundamentada de las seleccionadas.

= Descripción detallada del proyecto

Necesidad/oportunidad percibida, descripción del producto o servicio prestado, equipo promotor,
principales impulsores de creación de valor.

= Análisis de la viabilidad del proyecto

La inclusión y detalle de los siguientes apartados dependerá del tipo de estudio. Viabilidad comercial
(estudio de mercado, indicando definición del producto/servicio, análisis de la competencia, etc.
Análisis DAFO). Viabilidad técnica, operativa. Viabilidad legal. Viabilidad económica (cuantificación
de la inversión necesaria ---presupuesto de capital--- para la puesta en marcha de la iniciativa, costes
e ingresos periódicos, estimación de los flujos de tesorería del proyecto, análisis de rentabilidad a
través de indicadores como el VAN y la TIR). Plan de financiación y viabilidad financiera. Análisis del
riesgo del proyecto bajo distintos escenarios.

#include "../template/ejemplos.typ"

= Conclusiones y posibles ampliaciones

Resumen de las principales aportaciones del trabajo, explicaciones de las suposiciones y limitaciones
del trabajo, y posibles vías de mejora.

#show: apendices

= Manuales técnicos

En función del tipo de Trabajo y metodología empleada, el contenido se podrá dividir en varios
documentos. En todo caso, en ellos se incluirá toda la información precisa para aquellas personas que
deseen repetir el estudio (por ejemplo planos, mediciones, presupuestos, pliego de condiciones,
prescripciones técnicas, etc.).

= Licencia

Si se quiere poner una licencia (GNU GPL, Creative Commons, etc.), el texto de la licencia va aquí.
