#import "/template.typ": template, timetable
#show: template.with(group: "D1-21")
#timetable(data: (
  "Monday": (
    ("PE 153",),
    (
      "Theoretical Computer Science lecture 201",
      "Engineering Graphics lecture 118",
    ),
    ("Cultural Studies lecture 3-208",),
  ),
  "Tuesday": (
    ("Foreign Language ex. 146",),
    ("Mathematical Analysis ex. 307",),
    (
      "High-Level Programming lab. II 158",
      "High-Level Programming lab. I 158",
    ),
  ),
  "Thursday": (
    ("Cultural Studies ex. 203", none),
    ("Mathematical Analysis lecture 1-302",),
  ),
  "Friday": (
    ("Analytical Geometry lecture 302",),
    ("Analytical Geometry ex. 111",),
  ),
))
