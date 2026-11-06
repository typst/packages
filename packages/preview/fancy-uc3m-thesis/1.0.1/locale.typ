//! Localization information.


#let AUTHOR = (
  es: "Autor",
  en: "Author",
)

#let ADVISOR = (
  es: "Tutor",
  en: "Advisor",
)

#let ADVISORS = (
  es: "Tutores",
  en: "Advisors",
)

#let CC-LICENSE = (
  es: [
    Esta obra se encuentra sujeta a la licencia #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[Creative Commons\ *Reconocimiento -- No Comercial -- Sin Derivadas* 4.0
      International]
  ],
  en: [
    This work is licensed under #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[Creative Commons\ *Attribution -- Non Commercial -- No Derivatives* 4.0
      International]
  ],
)

#let DATE-FMT = (
  es: "[month repr:long] [year]",
  en: "[month repr:long] [year]",
)

#let MONTHS = (
  es: (
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ),
)

#let ACKNOWLEDGEMENTS = (
  es: "Agradecimientos",
  en: "Acknowledgements",
)

#let ABSTRACT = (
  es: "Resumen",
  en: "Abstract",
)

#let KEYWORDS = (
  es: "Palabras clave",
  en: "Keywords",
)

#let OUTLINE = (
  "contents": (
    es: "Tabla de contenidos",
    en: "Table of contents",
  ),
  "figures": (
    es: "Índice de figuras",
    en: "List of figures",
  ),
  "tables": (
    es: "Índice de tablas",
    en: "List of tables",
  ),
  "listings": (
    es: "Índice de listados",
    en: "List of listings",
  ),
)

#let THESIS-TYPE = (
  TFG: (
    es: "Trabajo de Fin de Grado",
    en: "Bachelor Thesis",
  ),
  TFM: (
    es: "Trabajo de Fin de Máster",
    en: "Master Thesis",
  ),
)

#let CHAPTER = (
  es: "Capítulo",
  en: "Chapter",
)

#let APPENDIX = (
  es: "Apéndice",
  en: "Appendix",
)

#let GLOSSARY = (
  es: "Glosario",
  en: "Glossary",
)

#let ABBREVIATIONS = (
  es: "Listado de abreviaciones",
  en: "List of abbreviations",
)


#let AFFIRMATION = (
  fancy: (
    es: "Sí",
    en: "Yes",
  ),
  clean: (
    es: "Sí",
    en: "Yes",
  ),
  strict: (
    es: "SI",
    en: "YES",
  ),
)

#let NEGATION = (
  fancy: (
    es: "No",
    en: "No",
  ),
  clean: (
    es: "No",
    en: "No",
  ),
  strict: (
    es: "NO",
    en: "NO",
  ),
)

#let AI-USAGE = (
  title: (
    es: "Declaración de uso de IA generativa",
    en: "Declaration of Use of Generative AI",
  ),
  affirmation: (
    es: "He utilizado IA generativa en este trabajo:",
    en: "I have used Generative AI in this work:",
  ),
  negation: (
    es: [El autor de esta tesis *no* ha usado ningún tipo de inteligencia
      artificial generativa durante el desarrollo del proyecto ni durante la
      redacción de este documento.],
    en: [The author of this thesis *has not* used any type of generative
      artificial intelligence during the development of the project or during
      the writing of this document.],
  ),
)


#let QUESTION = (
  es: "Pregunta",
  en: "Question",
)


#let PART = (
  es: "Parte",
  en: "Part",
)

#let AI-DATA-USAGE = (
  title: (
    es: "Reflexión sobre comportamiento legal, ético y responsable",
    en: "Reflection on legal, ethical and responsible behaviour",
  ),
  questions: (
    confidential: (
      prompt: (
        es: [En mi interacción con herramientas de Inteligencia Artificial
          Generativa he facilitado *datos de carácter confidencial* contando
          siempre con la debida autorización de los interesados.],
        en: [In my interactions with Generative AI tools, I have provided
          *confidential data*, always with the appropriate authorization of the
          data subjects.],
      ),
      answers: (
        yes: (
          es: [Sí, he usado estos datos con la autorización correspondiente.],
          en: [Yes, I have used this data with adequate authorization.],
        ),
        no: (
          es: [No, no he usado datos de carácter confidencial.],
          en: [No, I have not used confidential data.],
        ),
      ),
    ),
    copyright: (
      prompt: (
        es: [En mi interacción con herramientas de Inteligencia Artificial
          Generativa he facilitado *materiales protegidos por derechos de
          autoría* contando con la autorización respectiva.],
        en: [In my interaction with Generative AI tools, I have submitted
          *copyrighted materials* with the permission of those concerned.],
      ),
      answers: (
        yes: (
          es: [Sí, he usado estos materiales con autorización de los titulares
            de derechos de autor; o bien sin ella porque se ajustan a una de las
            excepciones o límites que permite la ley:
            - Obra en dominio público
            - Obra licenciada (licencias Creative Commons)
            - Uso de fragmentos con fines de investigación (derecho de cita)
          ],
          en: [Yes, I have used these materials with permission from the
            copyright holders, or without permission because they fall within
            one of the exceptions or limitations permitted by law:
            - Public domain work
            - Licensed work (Creative Commons licenses)
            - Use of excerpts for research purposes (fair use)
          ],
        ),
        no: (
          es: [No, no he usado materiales protegidos por derechos de autoría.],
          en: [No, I have not used copyrighted materials.],
        ),
      ),
    ),
    personal: (
      prompt: (
        es: [En mi interacción con herramientas de Inteligencia Artificial
          Generativa he facilitado *datos de carácter personal* con la debida
          autorización de los interesados.],
        en: [In my interaction with Generative AI tools, I have submitted
          *personal data* with the consent of the data subjects.],
      ),
      answers: (
        yes: (
          es: [Sí, he usado estos datos con autorización de los interesados y
            conforme a las instrucciones contenidas en la #link("https://docs.google.com/document/d/1YghVxFwo8a1VqdfnvJiZzlmAkfYepbDmD4g3hTOW9ro/edit?tab=t.0")[guía aprobada por la Universidad].],
          en: [Yes, I have used this data with the authorization of the
            interested parties and in accordance with the instructions contained
            in the #link("https://docs.google.com/document/d/1YghVxFwo8a1VqdfnvJiZzlmAkfYepbDmD4g3hTOW9ro/edit?pli=1&tab=t.0")[guide approved by the University].],
        ),
        no: (
          es: [No, no he usado datos de carácter personal.],
          en: [No, I have not used personal data.],
        ),
      ),
    ),
    tos: (
      prompt: (
        es: [Mi utilización de la herramienta de Inteligencia Artificial
          Generativa ha *respetado sus términos de uso*, así como los principios
          éticos esenciales, no orientándola de manera maliciosa a obtener un
          resultado inapropiado para el trabajo presentado.],
        en: [My use of the Generative AI tool has *respected its terms of use*,
          as well as the essential ethical principles, not being maliciously
          oriented to obtain an inappropriate result for the work presented.],
      ),
      answers: (
        yes: (
          es: [Sí],
          en: [Yes],
        ),
        no: (
          es: [No],
          en: [No],
        ),
      ),
    ),
  ),
)

#let AI-TECHNICAL-USAGE = (
  title: (
    es: "Declaración de uso técnico",
    en: "Declaration of technical use",
  ),
  tool-declaration: (
    es: "Declaro haber hecho uso del sistema de IAG",
    en: "I declare that I have made use of the Generative AI system",
  ),
  tool-declaration-suffix: (
    es: "para",
    en: "for",
  ),
  documentation-section: (
    es: "Documentación y redacción",
    en: "Documentation and drafting",
  ),
  specific-content-section: (
    es: "Desarrollar contenido específico",
    en: "Develop specific content",
  ),
  questions: (
    documentation: (
      es: "Soporte a la documentación y redacción del trabajo: generación de contenido textual para la elaboración de la memoria, así como apoyo en la documentación de los procesos seguidos durante el desarrollo del proyecto",
      en: "Support for documentation and drafting of the work: generation of textual content for the preparation of the report, as well as support in documenting the processes followed during the development of the project",
    ),
    reflection: (
      es: "Soporte a la reflexión en relación con el desarrollo del trabajo: proceso iterativo de análisis de alternativas y enfoques utilizando la IAG",
      en: "Supporting reflection in relation to the development of the work: iterative process of analysing alternatives and approaches using AI",
    ),
    review: (
      es: "Revisión o reescritura de párrafos redactados previamente",
      en: "Revision or rewriting of previously drafted paragraphs",
    ),
    research: (
      es: "Búsqueda de información o respuesta a preguntas concretas",
      en: "Search for information or answers to specific questions",
    ),
    references: (
      es: "Búsqueda de bibliografía",
      en: "Bibliography search",
    ),
    summary: (
      es: "Resumen de bibliografía consultada",
      en: "Summary of bibliography consulted",
    ),
    translation: (
      es: "Traducción de textos consultados",
      en: "Translation of texts consulted",
    ),
    assistance-coding: (
      es: "Asistencia en el desarrollo de líneas de código (programación)",
      en: "Assistance in the development of lines of code (programming)",
    ),
    generating-content: (
      es: "Generación de esquemas, imágenes, audios o vídeos",
      en: "Generation of diagrams, images, audios or videos",
    ),
    optimization: (
      es: "Procesos de optimización",
      en: "Optimisation processes",
    ),
    data-processing: (
      es: "Tratamiento de datos: recogida, análisis, cruce de datos…",
      en: "Data processing: collection, analysis, cross-checking of data...",
    ),
    idea-inspiration: (
      es: "Inspiración de ideas en el proceso creativo",
      en: "Inspiration of ideas in the creative process",
    ),
    other: (
      es: "Otros usos vinculados a la generación de puntos concretos del desarrollo específico del trabajo",
      en: "Other uses linked to the generation of specific points of the specific development of the work",
    ),
  ),
)

#let AI-USAGE-REFLECTION = (
  title: (
    es: "Reflexión sobre utilidad",
    en: "Reflection on utility",
  ),
)
