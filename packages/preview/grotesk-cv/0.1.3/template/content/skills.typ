#import "@preview/grotesk-cv:0.1.3": skill-entry
#import "@preview/fontawesome:0.4.0": *

#let meta = toml("../info.toml")
#let language = meta.layout.language


== #fa-screwdriver-wrench() #h(5pt) #if language == "en" [Skills] else if language == "es" [Habilidades]

#v(0pt)

#if language == "en" [

  === Programming languages

  #skill-entry(skills: (
    [C++],
    [Python],
    [Java],
  ))

  === AI/ML

  #skill-entry(skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skill-entry(skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Cloud Deployment],
  ))

  === Robotics

  #skill-entry(skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Databases

  #skill-entry(skills: (
    [SQL],
    [NoSQL],
    [MongoDB],
  ))

  === Tools

  #skill-entry(skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

] else if language == "es" [

  === Lenguajes de programación

  #skill-entry(skills: (
    [C++],
    [Python],
    [Java],
  ))

  === IA/Aprendizaje automático

  #skill-entry(skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skill-entry(skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Despliegue en la nube],
  ))

  === Robótica

  #skill-entry(skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Bases de datos

  #skill-entry(skills: (
    [SQL],
    [NoSQL],
    [MongoDB],
  ))

  === Herramientas

  #skill-entry(skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

]
