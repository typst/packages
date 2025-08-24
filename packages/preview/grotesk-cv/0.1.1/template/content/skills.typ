//#import "../lib.typ": *
#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("screwdriver-wrench") #h(5pt) #get-header-by-language("Skills", "Habilidades")

#v(0pt)

#if is-english() [

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

] else if is-spanish() [

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
