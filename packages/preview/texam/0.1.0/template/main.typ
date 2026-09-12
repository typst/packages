#import "@preview/texam:0.1.0": texam, exam-question
#import "@preview/taskize:0.2.5": tasks

#show: texam.with(
  school: "Nom de l'école",
  course-code: "3M",
  title: "Évaluation de mathématiques",
  date: "1 janvier 2026",
  teacher: "Prénom Nom",
  teacher-initials: "PN",
  duration: "45 minutes",
  allowed-materials: "Aucun",
  pnf-points: 2,
  // Extra rows in the evaluation table. Default: PNF worth 2 points.
  // Customize: extras: ((label: "Présentation", points: 1), (label: "Conventions", points: 1))
  // Remove: extras: ()
  brouillon: true,
)

// ─── Questions ────────────────────────────────────────────────────────────────
// #exam-question(number, points, content)
// Use #tasks[+ ...] for horizontal sub-item lists.

#exam-question(1, 4, [
  Factoriser les expressions suivantes.

  #tasks[
    + $x^2 - 5x + 6$
    + $4x^2 - 9$
  ]
])

#pagebreak()

#exam-question(2, 6, [
  Résoudre dans $RR$ les équations suivantes.

  #tasks[
    + $2x^2 - 7x + 3 = 0$
    + $|3x - 1| = 5$
  ]
])

#pagebreak()

#exam-question(3, 3, [
  Soit $f(x) = x^3 - 3x$.

  #tasks(columns: 3)[
    + Calculer $f'(x)$.
    + Étudier le signe de $f'(x)$.
    + En déduire les variations de $f$.
  ]
])
