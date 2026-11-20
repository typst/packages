#import "@preview/hpi-math-homework:0.1.0": exercise, homework, solution

#show: homework.with(
  language: "de", // Set to "en" for English.
  names: "Max Mustermann",
  course: "Modul X",
  tutorium: "3",
  week: 1,
  // Uncomment this line if you don't want the default semester.
  // semester: [Wintersemester 2026/27],
)

#exercise(title: "Arithmetische Reihe")[
  Berechnen Sie die Summe der ganzen Zahlen von 1 bis 100.
]

#solution[
  Die Zahlenpaare $(1, 100), (2, 99), dots.c, (50, 51)$ haben jeweils die Summe 101. Für die 50 Paare ergibt sich insgesamt
  $ sum_(k=1)^100 k = 50 dot 101 = 5050. $
]

#exercise(title: "Bonus", numbered: false)[
  Welche Summe ergibt sich für die ersten $n$ positiven ganzen Zahlen?
]
