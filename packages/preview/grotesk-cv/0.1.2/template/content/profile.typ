#import "@preview/fontawesome:0.2.1": *

#let meta = toml("../info.toml")
#let language = meta.personal.language


== #fa-icon("id-card") #h(5pt) #if language == "en" [Summary] else if language == "es" [Resumen]

#v(5pt)

#if language == "en" [

  Experienced Software Engineer specializing in artificial intelligence, machine learning, and robotics. Proficient in C++, Python, and Java, with a knack for developing sentient AI systems capable of complex decision-making. Passionate about ethical AI development and eager to contribute to groundbreaking projects in dynamic environments.

] else if language == "es" [

  Ingeniero de Software experimentado especializado en inteligencia artificial, aprendizaje automático y robótica. Competente en C++, Python y Java, con un talento para desarrollar sistemas de IA conscientes capaces de tomar decisiones complejas. Apasionado por el desarrollo ético de la IA y ansioso por contribuir a proyectos innovadores en entornos dinámicos.

]
