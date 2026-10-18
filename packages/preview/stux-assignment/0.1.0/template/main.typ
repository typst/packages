#import "@preview/stux-assignment:0.1.0": *

#show: assignment.with(
  title: "Assignment - 1",
  author: "Student Name",
  email: "email@example.com",
  roll: "123456",
  course: "Course Name",
  date: datetime.today().display("[month repr:long] [day], [year]"),
  theme: "teal", // available: "teal", "purple", "brown", "red", "gray"
  // font-size: 11pt,
  // font-family: "Linux Libertine",
)

#problem()[
  State your first problem here.
]

#solution[
  Write your solution here.
]

#problem(title: [— Bonus])[
  State your second problem here.
]

#solution[
  Write your solution here.
]
