#import "@preview/sleek-university-assignment:0.1.0": assignment

#show: assignment.with(
  title: "Assignment 1",
  course: "CSXXXX: Cryptography",
  authors: (
    (
      name: "John Doe",
      email: "john.doe@example.com",
      student-no: "XX/123",
    ),
  ),

  // NOTE: Optionally specify this for a university logo on the first page.
  // university-logo: image("./images/uni-logo.svg"),
)

#lorem(1000)
