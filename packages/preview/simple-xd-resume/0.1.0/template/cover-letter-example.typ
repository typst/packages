#import "@preview/simple-xd-resume:0.1.0": make-cover-letter

#show: make-cover-letter.with(
  author-firstname: "Albert",
  author-lastname: "Einstein",
  author-email: "albert.einstein@example.com",
  author-phone: "+41 31 123 4567",
  author-headlines: (
    (name: "Theoretical Physicist", linkto: "ias"),
    (name: "Patent Clerk", linkto: "patent"),
  ),
  recipient-name: "Hiring Committee",
  recipient-company: "Princeton University",
  recipient-address: ("Department of Physics", "Princeton, New Jersey", "United States"),
  recipient-email: "physics@princeton.edu",
  date: datetime.today(),
  font: "Source Sans 3",
  margin: 1in,
)

#lorem(100)

#lorem(120)

#lorem(50)
