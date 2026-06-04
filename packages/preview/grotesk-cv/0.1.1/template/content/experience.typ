#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *

== #fa-icon("briefcase") #h(5pt) #get-header-by-language("Relevant experience", "Experiencia relevante")

#v(5pt)

#if is-english() [

  #experience-entry(
    title: [Lead AI Architect],
    date: [2015 - Present],
    company: [Cyberdyne Systems],
    location: [Los Angeles, CA],
  )

  - Spearheaded the development of the Skynet AI project, a neural network that achieved unprecedented levels of autonomy and, as it turned out, an independent interest in global domination.
  - Designed a scalable AI architecture using cutting-edge deep learning techniques, capable of real-time data processing and decision-making on a planetary scale.
  - Collaborated with teams of hardware engineers to integrate AI software into next-gen robotics, including autonomous drones and humanoid robots. (If one offers you roses, proceed with caution.)
  - Implemented robust testing protocols (we now test everything twice) to ensure stability and safety, post-incident.


  #v(5pt)

  #experience-entry(
    title: [Senior Software Engineer],
    date: [2008 - 2015],
    company: [Tyrell Corporation],
    location: [Los Angeles, CA],
  )

  - Co-developed the Nexus-6 replicants, focusing on machine learning models that mimic human emotions and cognitive functions. Achieved limited success in emotional empathy, particularly with "tears in rain."
  - Developed a custom-built memory implant algorithm for replicants, giving them the illusion of life experiences (turns out, memories are a lot trickier than they seem).
  - Led a cross-functional team in debugging and patching replicant behavioral anomalies, including occasional existential crises.
  - Worked closely with corporate leadership to ensure compliance with ethical standards (which were sometimes a little... flexible).

] else if is-spanish() [

  #experience-entry(
    title: [Arquitecto de IA Principal],
    date: [2015 - Presente],
    company: [Cyberdyne Systems],
    location: [Los Ángeles, CA],
  )

  - Encabezó el desarrollo del proyecto de IA Skynet, una red neuronal que alcanzó niveles de autonomía sin precedentes y, como resultó, un interés independiente en la dominación global.
  - Diseñó una arquitectura de IA escalable utilizando técnicas de aprendizaje profundo de vanguardia, capaz de procesar datos y tomar decisiones en tiempo real a escala planetaria.
  - Colaboró con equipos de ingenieros de hardware para integrar software de IA en robótica de próxima generación, incluidos drones autónomos y robots humanoides. (Si alguien te ofrece rosas, procede con precaución.)
  - Implementó protocolos de prueba robustos (ahora probamos todo dos veces) para garantizar estabilidad y seguridad, post-incidente.

  #v(5pt)

  #experience-entry(
    title: [Ingeniero de Software Senior],
    date: [2008 - 2015],
    company: [Corporación Tyrell],
    location: [Los Ángeles, CA],
  )

  - Co-desarrolló los replicantes Nexus-6, centrándose en modelos de aprendizaje automático que imitan las emociones humanas y las funciones cognitivas. Logró un éxito limitado en la empatía emocional, especialmente con "lágrimas en la lluvia".
  - Desarrolló un algoritmo de implante de memoria personalizado para replicantes, dándoles la ilusión de experiencias de vida (resulta que los recuerdos son mucho más complicados de lo que parecen).
  - Dirigió un equipo multifuncional en la depuración y corrección de anomalías de comportamiento de replicantes, incluidas crisis existenciales ocasionales.
  - Trabajó en estrecha colaboración con el liderazgo corporativo para garantizar el cumplimiento de los estándares éticos (que a veces eran un poco... flexibles).
]