#import "@preview/postgraduate-admission-cv:0.1.0": cv, cv-header, section, item, highlight-red

#show: cv.with(
  header-title: [*Postgraduate Admission CV*],
  footer: [
    #link("https://example.com")[example.com]
    #h(3em)
    applicant@example.com
  ],
)

#cv-header(
  [Applicant Name],
  [University · Major #h(1em) Expected graduation: 2027.06],
  [phone@example.com #h(1.5em) applicant@example.com #h(1.5em) portfolio.example.com],
)

#section("Education", "🎓")

#item([*Example University | Data Science | B.S.*], [2023.09–2027.06])

*GPA:* 3.80/4.00 #h(1em)
*Rank:* Top 10% #h(1em)
*Languages:* CET-6 520 / IELTS 7.0

*Core Courses:* Machine Learning, Statistics, Algorithms, Database Systems, Computer Networks.

#section("Research & Projects", text(font: "Consolas", weight: "bold")[<\/>])

- #item([*Multi-Agent Learning Platform* #h(0.6em) #text(fill: highlight-red)[Research Project]], [2025.03–2025.12])
  Designed evaluation workflows for multi-agent collaboration and wrote reproducible experiments for educational AI scenarios.

- #item([*Automated News Production System* #h(0.6em) #text(fill: highlight-red)[Innovation Project]], [2024.09–2025.06])
  Built a prototype pipeline integrating retrieval, generation, speech synthesis, and video rendering.

#section("Publications & IP", "💡")

- *Paper under review:* Example Paper Title, target journal or conference.
- *Patent application:* Example Method and System, application number pending.

#section("Awards & Honors", "🏆")

- Mathematical modeling contest, first prize.
- University scholarship and outstanding student recognition.

#section("Skills", "🔧")

*Programming:* Python, C/C++, SQL; familiar with NumPy, Pandas, Scikit-learn, and Matplotlib.

*AI Engineering:* LLM applications, agent systems, retrieval-augmented generation, and web prototyping.
