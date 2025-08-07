#import "@preview/assn-report-monash:0.1.0": monash-report

#show: monash-report.with(
  [Sample Assignment],        // title (positional)
  "Your Name",               // author (positional)
  subtitle: "A subtitle for your assignment",
  student-id: "12345678",
  course-code: "ABC123",
  course-name: "Sample Course Name",
  assignment-type: "Assignment",
  tutor-name: "Dr. Sample Tutor",
  date: datetime.today(),
  word-count: 1500,
  despair-mode: false,
  show-typst-attribution: true,
  show-outline: true,
)

= Introduction

This is a sample assignment template for Monash University students.

== Sample Section

You can write your content here.

= Conclusion

This concludes the sample assignment.