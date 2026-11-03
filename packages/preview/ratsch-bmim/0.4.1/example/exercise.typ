#import "./preamble.typ": *

#show: bmim.exercise(
  title: "Übung 1",
  course: ([VO Vertiefende Konzepte der Vorlesungstechnik],[VKV]),
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  show-solution: "inline",
  lang: "de",
  date: none,
)

#set math.equation(numbering: "(1.1)")

#task(
  label: <task:main>,
  [
    Das Eingangs-Ausgangsverhalten eines Systems wird durch die Übertragungsfunktion
    $
      G(s) & = frac(s + 2, 2 s^(2) - 2 s + 1)
    $
    beschrieben.
  ],
  (
    points: 10,
    label: <task:sub1>,
    description: [
      Geben Sie eine Realisierung der _Übertragungsfunktion_ in
      Regelungsnormalform an.
    ],
    solution: [
      Regelungsnormalform:
      $
        dot(bold(x))(t) & = mat(0, 1; -frac(1,2), 1) bold(x)(t) + mat(0; 1) u(t) \
        y(t) & = mat(1, frac(1, 2)) bold(x)(t)
      $
    ]
  ),
  (
    points: 30,
    label: <task:sub2>,
    description: [
      Ist die interne Dynamik des Systems stabil?
      *Begründen* Sie Ihre Antwort.
    ],
    solution: [
      Die Eigenwerte der internen Dynamik entsprechen den Zählernullstellen.
      Diese sind durch die Lösungen von $s + 2 = 0$ durch $s = -2$ gegeben und somit ist die interne Dynamik in Folge des negativen Realteils stabil.
    ]
  )
)

#task(
  [

    Betrachtet wird das System
    $
      dot(x)_1(t) = x_2(t), #h(5em)
      dot(x)_2(t) = x_3(t), #h(5em)
      dot(x)_3(t) = x_2(t) - x_3(t) + u(t)
    $
    mit dem Ausgang
    $
      y(t) & = x_1(t) + 2 x_2(t) + x_3(t).
    $

  ],
  (
    points: 20,
    description: [
      Wie heißt die spezielle Zustandsdarstellung in der das System gegeben ist?
    ],
    solution: [
      Das System liegt in Regelungsnormalform vor.
    ]
  ),
  (
    points: 20,
    description: [
      Welchen relativen Grad besitzt das System?
      Begründen Sie Ihre Antwort.
    ],
    solution: [
      Der relative Grad des Systems ist eins.
      Dies kann entweder direkt aus der Ausgangsmatrix $c^(sans(upright(T)))=(1,1,1)$ abgelesen werden oder aber durch Differentiation des
      Ausgangs:

      #set math.equation(numbering: none)
      $
        dot(y)(t) & = dot(x)_1(t) + 2 dot(x)_2(t) + dot(x)_3(t) = x_2(t) + 2 x_3(t) + x_2(t) - x_3(t) + u(t) = 2 x_2(t) + x_3(t) + u(t).
      $
    ]
  )
)

#task(
  points: 5,
  description: [ single points task description referencing @task:main and also
  @task:sub1],
  solution: [
    This is how to also reference from solution @task:sub2 and an additional equation
    $
      1 + 1 & = 2 thin s
    $
  ],
)

