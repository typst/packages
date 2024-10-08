#import "@preview/grotesk-cv:0.1.4": skill-entry
#import "@preview/fontawesome:0.4.0": *

#let meta = toml("../info.toml")
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons
#let accent-color = meta.layout.accent_color


= #if include-icon [#fa-screwdriver-wrench() #h(5pt)] #if language == "en" [Skills] else if language == "es" [Habilidades]

#v(0pt)

#if language == "en" [

  === Programming languages

  #skill-entry(
    accent-color,
    skills: (
      [C++],
      [Python],
      [Java],
    ),
  )

  === AI/ML

  #skill-entry(
    accent-color,
    skills: (
      [TensorFlow],
      [PyTorch],
      [OpenAI],
    ),
  )

  === DevOPS

  #skill-entry(
    accent-color,
    skills: (
      [Docker],
      [Kubernetes],
      [Jenkins],
      [Cloud Deployment],
    ),
  )

  === Robotics

  #skill-entry(
    accent-color,
    skills: (
      [ROS],
      [Gazebo],
      [URDF],
    ),
  )

  === Databases

  #skill-entry(
    accent-color,
    skills: (
      [SQL],
      [NoSQL],
      [MongoDB],
    ),
  )

  === Tools

  #skill-entry(
    accent-color,
    skills: (
      [Git],
      [Jira],
      [Confluence],
      [Slack],
    ),
  )

] else if language == "es" [

  === Lenguajes de programación

  #skill-entry(
    accent-color,
    skills: (
      [C++],
      [Python],
      [Java],
    ),
  )

  === IA/Aprendizaje automático

  #skill-entry(
    accent-color,
    skills: (
      [TensorFlow],
      [PyTorch],
      [OpenAI],
    ),
  )

  === DevOPS

  #skill-entry(
    accent-color,
    skills: (
      [Docker],
      [Kubernetes],
      [Jenkins],
      [Despliegue en la nube],
    ),
  )

  === Robótica

  #skill-entry(
    accent-color,
    skills: (
      [ROS],
      [Gazebo],
      [URDF],
    ),
  )

  === Bases de datos

  #skill-entry(
    accent-color,
    skills: (
      [SQL],
      [NoSQL],
      [MongoDB],
    ),
  )

  === Herramientas

  #skill-entry(
    accent-color,
    skills: (
      [Git],
      [Jira],
      [Confluence],
      [Slack],
    ),
  )

]
