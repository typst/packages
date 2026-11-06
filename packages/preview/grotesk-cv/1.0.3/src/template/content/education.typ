#let meta = toml("../info.toml")

#import "@preview/grotesk-cv:1.0.3": education-entry
#import meta.import.fontawesome: *

#let icon = meta.section.icon.education
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons


= #if include-icon [#fa-icon(icon) #h(5pt)] #if language == "en" [Education] else if language == "es" [Educación]

#v(5pt)

#education-entry(
  degree: [M.Sc. Artifical Intelligence],
  date: [2006 - 2008],
  institution: [California Institute of Technology],
)

#if language == "en" [

  - *Thesis:* _"Ethical Implications of Sentient AI: When Your Machine Gets Existential."_
  - *Research focus:* Autonomous systems, neural networks, and their applications in real-world scenarios (with a minor in Asimov's Laws of Robotics).

  #v(5pt)

  #education-entry(
    degree: [B.Sc. Computer Science],
    date: [2002 - 2006],
    institution: [University of California, Los Angeles],
    location: [Los Angeles, CA],
  )

  - Specialization in software architecture and machine learning.
  - Extracurriculars: Member of the campus Robotics Club and AI Ethics Society.

] else if language == "es" [

  - *Tesis:* _"Implicaciones éticas de la IA consciente: cuando tu máquina se vuelve existencial."_
  - *Enfoque de investigación:* Sistemas autónomos, redes neuronales y sus aplicaciones en escenarios del mundo real (con una especialización en las Leyes de la Robótica de Asimov).

  #v(5pt)

  #education-entry(
    degree: [Licenciatura en Ciencias de la Computación],
    date: [2002 - 2006],
    institution: [Universidad de California, Los Ángeles],
    location: [Los Ángeles, CA],
  )

  - Especialización en arquitectura de software y aprendizaje automático.
  - Actividades extracurriculares: Miembro del club de robótica del campus y de la Sociedad de Ética de la IA.

]



