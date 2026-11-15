#import "@preview/minutely:0.1.0": *
#show: meeting.with(
  title: "Minutes of bestyrelsesmøde in Foreningen",
  date: datetime(year: 2026, month: 3, day: 12),
  time: "16:00", location: "Mødelokale 4",
  chair: "Simon Holm", minute-taker: "Anne Sofie",
  attendees: ("Simon Holm", "Daniel Nissen", "Anne Sofie"),
  author: "Simon Holm",
  lang: "en",
  logo: image("logo.png", width: 140%)
)
= Budget
== Nyt budget #resp("Daniel", "Anne")
- Vi mangler svar fra SDS #ansvar("Simon")
#vote(question: "Skal dette stemmes ind", agrees: 6, against: 32, abstain: 1, decision: true)
#vote(question: "Godkendelse af nyt budget",
  agrees: ("Simon Holm", "Anne Sofie"), against: ("Daniel Nissen",), abstain: "Victor", decision: true)
#proposal(no: 3)[Bestyrelsen kan … #vote(agrees: 14, against: 2, abstain: 1)]
#amendment(no: 31)[Stryg "kan" og skriv "skal".]
#amendment(no: 4, before: [kan], after: [skal])
#next-meeting(date: datetime(year: 2026, month: 4, day: 9), time: "16:00", location: "Mødelokale 4")
