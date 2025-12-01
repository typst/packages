#import "@preview/basic-academic-letter:0.1.0": basic-academic-letter

#show: basic-academic-letter.with(
  main_color: rgb("#641C78"),
  logo_img: image("assets/logo.jpg", width: 80%),
  signature_img: image("assets/signature.png", height: 30pt),
  school: [School of Information Science and \ Technology,],
  university: [Tsinghua University],
  site: [FIT Building, Haidian District \ Beijing 100084, P.R.China],
  phone: [+86 10 62795873],
  website: [https://www.sist.tsinghua.edu.cn/],
  //date: datetime(day: 1, month: 12, year: 2025).display("[day] [month repr:long] [year]")
  per_name: "Dr XXX",
  per_homepage: "https://www.sist.tsinghua.edu.cn/sisten/Faculty.htm",
  per_title: "Professor",
  per_school: "School of Information Science and Technology",
  per_university: "Tsinghua University",
  per_email: "xxx@tsinghua.edu.cn",
  salutation: "To the Admission Committee,",
  closing: "Sincerely,"
)

It is my pleasure to recommend XXX for your doctoral programme. #lorem(90)

#lorem(70)

#lorem(90)

#lorem(30)

#lorem(50)

Please feel free to contact me if you require further information.
