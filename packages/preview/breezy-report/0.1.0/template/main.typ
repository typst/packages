#import "@preview/breezy-report:0.1.0": *

#show: breezy.with(
  semester:"Semester 1 2026",
  course-code: "ENGE500",
  course-name: "Course Name",
  title: "Report Title: The purpose of the report",
  student-ID: "12345678",
  author: "Student Name",
)

= Section
#lorem(40)
- List item 1
- List item 2
  - List item sub 1
  - List item sub 2
- List item 3

#lorem(20)

== Subsection
#lorem(60)
#figure(
  table(
    columns:(1fr,1fr),
    [Heading 1],[Heading 2],
    [#lorem(10)],[#lorem(5)]
),
caption:"Caption for a table."
)
= Section
#lorem(40)

```c
#int main()
{
  int count = 0;

  while (1)
  {
    for (int i = 0; i < 5; i++)
    {
      printf(count);
      count++;
    }
  }
}

```
