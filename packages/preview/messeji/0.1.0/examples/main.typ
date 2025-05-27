#import "../messeji.typ": messeji, parse-json

#let mypath = "examples/output.example.json"
#set text(font: "Helvetica Neue")

#let parsed-data = parse-json(mypath)

= About

Build this document with `typst compile main.typ --root ..`


= Chat Example

#messeji(chat-data: parsed-data)

= Chat Data Structure without json

#let my-messages = (
  (
    date: "2024-01-01T12:00:00",
    msg: "This is defined directly in the Typst file.",
    from_me: false,
  ),
  (
    msg: "Nice!",
    from_me: true,
  ),
)
#messeji(chat-data: my-messages)

= Customization

Custom date-change and timestamp typesetting:

#messeji(
  chat-data: parsed-data,
  date-changed-format: "[year]/[month]/[day]",
  timestamp-format: "[hour]:[minute]",
)


