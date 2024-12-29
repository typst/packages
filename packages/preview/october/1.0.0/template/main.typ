#import "@preview/october:1.0.0": calendar

#set page(
  "a4",
  flipped: true,
)

#show: calendar.with(
  year: datetime.today().year(),
)
