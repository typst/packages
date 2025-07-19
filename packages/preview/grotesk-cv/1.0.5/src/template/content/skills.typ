#let meta = toml("../info.toml")

#import "@preview/grotesk-cv:1.0.5": skill-entry
#import meta.import.fontawesome: *

#let icon = meta.section.icon.skills
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons
#let accent-color = meta.layout.accent_color
#let multicol = true
#let alignment = center


= #if include-icon [#fa-icon(icon) #h(5pt)] #if language == "en" [Skills] else if language == "es" [Habilidades]

#v(0pt)

#if language == "en" [

  === Programming languages

  #skill-entry(accent-color, multicol, alignment, skills: (
    [C++],
    [Python],
    [Java],
    [Rust],
  ))

  === AI/ML

  #skill-entry(accent-color, multicol, alignment, skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skill-entry(accent-color, multicol, alignment, skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Cloud],
  ))

  === Robotics

  #skill-entry(accent-color, multicol, alignment, skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Tools

  #skill-entry(accent-color, multicol, alignment, skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

] else if language == "es" [

  === Lenguajes de programación

  #skill-entry(accent-color, multicol, alignment, skills: (
    [C++],
    [Python],
    [Java],
  ))

  === IA/Aprendizaje automático

  #skill-entry(accent-color, multicol, alignment, skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skill-entry(accent-color, multicol, alignment, skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Despliegue en la nube],
  ))

  === Robótica

  #skill-entry(accent-color, multicol, alignment, skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Herramientas

  #skill-entry(accent-color, multicol, alignment, skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

]
