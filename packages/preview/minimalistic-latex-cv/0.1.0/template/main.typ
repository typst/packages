#import "@preview/minimalistic-latex-cv:0.1.0": cv, entry

#show: cv.with(
  name: "Your Name",
  metadata: (
    address: "1234 City, Example Street 1/A",
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
  name: "Institution",
  date: "Start - End",
  location: "City, Country"
)
- *Coursework:* #lorem(20)
- *Thesis title:* #lorem(6)

#entry(
  title: "Degree Title",
  name: "Institution",
  date: "Start - End",
  location: "City, Country"
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

*Language 3:* #lorem(2)

*Language 4:* #lorem(2)
