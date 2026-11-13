# Accesibilidad

Esta plantilla tiene como uno de sus objetivos facilitar la elaboración de documentos académicos accesibles, estructurados y aptos para su preservación a largo plazo.

Se busca que los trabajos de grado puedan ser consultados por la mayor cantidad posible de personas, incluidas aquellas que utilizan tecnologías de asistencia, y que su contenido pueda recuperarse, interpretarse y conservarse adecuadamente en repositorios digitales.

## Estándares de accesibilidad y preservación

Se recomienda que los documentos elaborados con esta plantilla se exporten utilizando los siguientes estándares:

- **PDF/UA-1 (ISO 14289-1):** establece requisitos de accesibilidad para documentos PDF, incluyendo su estructura semántica y compatibilidad con tecnologías de asistencia.
- **PDF/A-2a (ISO 19005-2):** establece requisitos para la preservación de documentos PDF a largo plazo, incluyendo información sobre su estructura lógica.
- **PDF/A-3a (ISO 19005-3):** ofrece capacidades similares a PDF/A-2a y permite incorporar archivos adjuntos, como el código fuente del documento o sus referencias bibliográficas.

Se recomienda combinar PDF/UA-1 con PDF/A-2a o PDF/A-3a, según las necesidades de cada documento y los requisitos de presentación establecidos por la universidad.

Estos estándares tienen propósitos complementarios: **PDF/UA se orienta a la accesibilidad, mientras que PDF/A se orienta a la preservación digital.** Cumplir uno de ellos no implica necesariamente cumplir el otro.

## Responsabilidad de los autores

La plantilla proporciona una estructura y herramientas orientadas a facilitar la creación de documentos accesibles. Sin embargo, la accesibilidad del documento final también depende de su contenido y de las decisiones de sus autores.

Se recomienda:

- Mantener una jerarquía lógica de títulos y secciones.
- Proporcionar descripciones alternativas para imágenes, gráficos y otros elementos visuales que transmitan información.
- Utilizar tablas, fórmulas y otros elementos semánticos cuando corresponda.
- Mantener un contraste adecuado y evitar transmitir información exclusivamente mediante colores.
- Comprobar que el contenido pueda interpretarse correctamente mediante tecnologías de asistencia.

Para conocer estas prácticas en mayor detalle, consultá la [guía oficial de accesibilidad de Typst](https://typst.app/docs/guides/accessibility/).

## Verificación de los documentos

Typst permite seleccionar estándares de exportación y comprobar automáticamente determinados requisitos durante la compilación.

Para una verificación adicional (opcional), se pueden utilizar herramientas especializadas, como:

- [PAC](https://pac.pdf-accessibility.org/), para evaluar la accesibilidad de documentos PDF en términos de conformidad con PDF/UA y WCAG.
- [veraPDF](https://verapdf.org/), para comprobar la conformidad con estándares PDF/A y PDF/UA (en menor medida que PAC).

La superación de las comprobaciones automáticas no garantiza, por sí sola, que un documento sea completamente accesible. También se recomienda realizar revisiones manuales del contenido y su interpretación mediante tecnologías de asistencia.

## Limitaciones y mejoras

La plantilla busca facilitar el cumplimiento de los estándares mencionados, pero no garantiza que todos los documentos generados sean conformes con ellos.

Algunas limitaciones pueden depender de la versión de Typst, de las características del documento o de las herramientas utilizadas para su validación.

La accesibilidad se considera un criterio permanente de desarrollo y mantenimiento de este proyecto.

## Reportar problemas de accesibilidad

Si encontrás dificultades para utilizar la plantilla con tecnologías de asistencia, problemas en la estructura de los documentos exportados o incumplimientos de accesibilidad, podés [abrir un reporte en GitHub Issues](https://github.com/FAI-UPSA/thesis-template/issues).

Se agradecen especialmente los ejemplos reproducibles que permitan identificar y corregir estas dificultades.
