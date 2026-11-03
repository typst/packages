#import "@preview/quill-assignment:0.1.0": *

#show: assignment.with(
  title: "Assignment Title",
  course: "Course Name",
  assignment: "Assignment 1",
  student: "Your Name",
  student-id: "12345678",
  university: "University Name",
  date: datetime.today(),
  cover-page: true,
)

= Question 1

#question(title: "Example Question")[
  Explain the concept in your own words.
]

#answer[
  Write your answer here.
]