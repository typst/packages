
#import "@preview/yaes:0.1.0": *

#show: exercise-sheet.with(
    department-info: ("University Name", "Department Name", "Chair Name"),
    teachers: ("Prof. First Name Last Name", "M. Sc. First Name Last Name"),
    course: "Course Title",
    semester: "Summer Term 2026",
    number: 7
)

= Homework:

#problem[
    This is the first problem.
    It does not have a title.
]

#solution[
    This is the solution.
]

= In-class:

#problem(title: "Title of the problem")[
    This is the second problem.
    It does have a title.
]

#solution(student: false)[
    The students will not see this solution.
]
