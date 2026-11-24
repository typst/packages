#import "@preview/minutely:0.1.0": *

#let WT = "W. Tarkin"
#let FP = "F. Piett"
#let OK = "O. Krennic"

#show: meeting.with(
  organisation: "The Empire",
  meeting-name: "board meeting",
  kind: "minutes",
  date: datetime(year: 2026, month: 3, day: 12),
  time: "16:00", location: "Conference room, deck 3",
  chair: WT, minute-taker: FP,
  attendees: (WT, OK, FP),
  logo: image("logo.png", width: 100%),
)

= Construction
== Station budget #resp(OK, FP)
#vote(question: "Approve the revised station budget?",
  agrees: (WT, FP), against: (OK,), abstain: 0)
#proposal(no: 3)[The board may approve design changes to the exhaust ports …]
#amendment(no: 4, before: [may], after: [shall])
#next-meeting(date: datetime(year: 2026, month: 4, day: 9), time: "16:00", location: "Conference room, deck 3")