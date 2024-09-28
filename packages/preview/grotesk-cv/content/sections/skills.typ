#import "../../lib.typ": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("screwdriver-wrench") #h(5pt) #getHeaderByLanguage("Skills", "Habilidades")

#v(0pt)

#if isEnglish() [

  === Programming languages

  #skillEntry(skills: (
    [C++],
    [Python],
    [Java],
  ))

  === AI/ML

  #skillEntry(skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skillEntry(skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Cloud Deployment],
  ))

  === Robotics

  #skillEntry(skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Databases

  #skillEntry(skills: (
    [SQL],
    [NoSQL],
    [MongoDB],
  ))

  === Tools

  #skillEntry(skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

] else if isSpanish() [

  === Lenguajes de programación

  #skillEntry(skills: (
    [C++],
    [Python],
    [Java],
  ))

  === IA/Aprendizaje automático

  #skillEntry(skills: (
    [TensorFlow],
    [PyTorch],
    [OpenAI],
  ))

  === DevOPS

  #skillEntry(skills: (
    [Docker],
    [Kubernetes],
    [Jenkins],
    [Despliegue en la nube],
  ))

  === Robótica

  #skillEntry(skills: (
    [ROS],
    [Gazebo],
    [URDF],
  ))

  === Bases de datos

  #skillEntry(skills: (
    [SQL],
    [NoSQL],
    [MongoDB],
  ))

  === Herramientas

  #skillEntry(skills: (
    [Git],
    [Jira],
    [Confluence],
    [Slack],
  ))

]
