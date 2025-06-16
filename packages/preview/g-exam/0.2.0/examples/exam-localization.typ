#import "../g-exam.typ": g-exam, g-question, g-subquestion

#show: g-exam.with(
  localization: (
    grade-table-queston: [Number of *questions*],
    grade-table-total: [Total _poinst_],
    grade-table-points: [#text(fill: red)[Points]],
    grade-table-calification: [#text(fill: gradient.radial(..color.map.rainbow))[Grades obtained]],
    point: [point],
    points: [Points],
    page: [],
    page-counter-display: "1 - 1",
    family-name: "*Family* _name_",
    personal-name: "*Personal* _name_",
    group: [*Classroom*],
    date: [*Date* of exam]
  ),
)

#g-question(point: 2)[Question 1]

#g-question(point: 1)[Question 2]

#g-question(point: 1.5)[Question 3]