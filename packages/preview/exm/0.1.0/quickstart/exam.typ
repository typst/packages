#import "../../lib/exam.typ": *

#show: doc => exam(doc,
  courseid: "CourseID",
  coursename: "CourseName",
  school: "School",
  semester: "Semester",
  instructor: "",
  examtitle: "",
  date: "",
  length: "",
  instructions: "",
  blanks: ("Your Name", "Your Student ID", "Your Exam Room", "the Name of Person to your Left", "the Name of Person to your Right", "Your GSI's Name (Write N/A if in Self-Service)"),
  extra: "",
  sols: false
)

#docmode.update("screen")

#let section = section.with(number: true, points: true)

