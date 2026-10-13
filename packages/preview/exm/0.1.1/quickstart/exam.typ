#import "@preview/exm:0.1.0": *

#show: doc => exam(doc,
  courseid: "CourseID",
  coursename: "CourseName",
  school: "School",
  semester: "Semester",
  instructor: "",
  examtitle: "Final",
  date: "8:00–11:00am  Monday, December 15th 2025",
  length: "180 Minutes",
  instructions: "",
  blanks: ("Your Name", "Your Student ID", "Your Exam Room", "the Name of Person to your Left", "the Name of Person to your Right", "Your GSI's Name (Write N/A if in Self-Service)"),
  extra: "",
  sols: false
)

#docmode.update("screen")

#let section = section.with(number: true, points: true)

