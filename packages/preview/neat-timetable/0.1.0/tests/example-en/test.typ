#import "/template.typ": template, timetable
#show: template.with(group: "AB1-12")
#timetable(data: (
  "Monday": (
    ("Physical Education 6-145",),
    (
      "Theoretical Computer Science lecture 2-201",
      "Engineering Graphics lecture 5-118",
    ),
    ("Cultural Studies lecture 3-208",),
    ("High-Level Programming lab. II 4-158",),
  ),
  "Tuesday": (
    ("Foreign Language ex. 1-146",),
    ("Mathematical Analysis ex. 7-407",),
    (
      "High-Level Programming lab. II 4-158",
      "High-Level Programming lab. I 4-158",
    ),
    (
      "High-Level Programming lab. II 4-158",
      "High-Level Programming lab. I 4-158",
    ),
  ),
  "Wednesday": (
    (none,),
    ("Analytical Geometry ex. 6-511",),
    (
      "Theoretical Computer Science lab. I 5-322",
      "Theoretical Computer Science lab. II 5-322",
    ),
  ),
  "Thursday": (
    ("Cultural Studies ex. 2-203", none),
    ("Engineering Graphics ex. I 3-406 II 3-411",),
    ("Mathematical Analysis lecture 1-302",),
  ),
  "Friday": (
    ("High-Level Programming lab. I 4-258",),
    ("Analytical Geometry lecture 2-302",),
    ("Engineering Graphics lab. I 6-310 II 6-312",),
  ),
  "Saturday": (
    ("High-Level Programming lecture 5-232",),
    ("High-Level Programming ex. 3-162", none),
  ),
))
