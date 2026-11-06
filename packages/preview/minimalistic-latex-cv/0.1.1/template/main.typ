#import "@preview/minimalistic-latex-cv:0.1.1": cv, entry

#show: cv.with(
  name: "Your Name",
  metadata: (
    email: "your@email.com",
    telephone: "+123456789",
  ),
  photo: image("photo.jpeg"),
  lang: "en",
)

= Professional Experience

#entry(
  title: "Job Title",
  name: "Company",
  date: "Start - End",
  location: "City, Country"
)
- *Keyword:* #lorem(25)

#entry(
  title: "Job Title",
  name: "Company",
  date: "Start - End",
  location: "City, Country"
)
- *Keyword:* #lorem(25)

#entry(
  title: "Job Title",
  name: "Company",
  date: "Start - End",
  location: "City, Country"
)
- *Keyword:* #lorem(25)

= Education

#entry(
  title: "Degree Title",
  name: "Institution"
)
- *Coursework:* #lorem(20)
- *Thesis title:* #lorem(6)

#entry(
  title: "Degree Title",
  name: "Institution"
)
- *Coursework:* #lorem(20)
- *Thesis title:* #lorem(6)

= Skills

*Skill 1:* #lorem(10)

*Skill 2:* #lorem(10)

*Skill 3:* #lorem(10)

= Languages

*Language 1:* #lorem(2)

*Language 2:* #lorem(2)
