#import "../messeji.typ": messeji, default-theme

#set page("a4")
#set text(font: "Helvetica Neue")
#show link: underline

#v(20%)

#align(horizon + center)[

  #text(size: 24pt, [messēji])

  MIT License 2025 Kai Anter

]

#show outline.entry.where(level: 2): set block(above: 1.2em)

#outline()

Note: Build this document with `typst compile main.typ --root ..`

= Introduction

_messēji_ is a Typst package for typesetting chat histories in a modern, minimal
design, inspired by popular messengers.

Main features of _messēji_ include:

- Support for quoted messages
- Displaying timestamps between messages
- Simple data model to read from external files (JSON, YAML, ...) if you want to
  typeset very long chat histories

Currently, it does not support:

- Group chats (only 1-on-1 chats)
- Reactions to messages
- Images

These issues will likely be fixed in a future release.

#pagebreak(weak: true)

= Usage

== Import

Add the following import statement to the top of your document:

```typst
#import "@preview/messeji:0.2.0": messeji
```

== Message Structure

The messages have to be in the following structure (dictionary formatted as
JSON):

```json5
{
  // Required
  "msg": "Actual Message", 

  // Required, true for right, false for left
  "from_me": true,

  // Optional, in ISO 8601 format
  "date": "2026-12-25T09:41:00", 

  // Optional
  "ref": "Previous message that is being quoted", 
}
```

The order of the fields is not important. You can use other filetypes if you
want to, but the key names have to be the same, and the `date` value has to be
in ISO 8601 format.

== Basic example from JSON

```typst
#set text(font: "Helvetica Neue")
#let parsed-data = json("output.example.json") // list of messages
#messeji(chat-data: parsed-data)
```

The code snippet above assumes the following structure from the JSON file:

```json5
[
  {
    "date": "2026-12-25T09:41:00",
    "msg": "Merry Christmas! 🎄",
    "from_me": false
  },
  {
    "msg": "Thank you, you too! 😊",
    "ref": "Merry Christmas! 🎄",
    "from_me": true
  },
  //...
]
```

It then produces the following chat:

#line(length: 100%)
#let parsed-data = json("output.example.json")
#messeji(chat-data: parsed-data)
#line(length: 100%)


== Basic example directly in Typst

```typst
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
```

Produces the following chat:

#line(length: 100%)
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
#line(length: 100%)


#pagebreak(weak: true)

= Customization

== Themes

You can customize the text colors, backgrounds, and font sizes. Currently, the
default theme has the following keys and values:

#raw(repr(default-theme), lang: "typst")

If you want to change the theme, you just have to override the keys that you
need. Everything else that is undefined will be taken from the default theme:

```typst
#let custom-theme = (
  me-right: (
    background-color: green
  )
)
#messeji(
  chat-data: parsed-data,
  theme: custom-theme
)
```

Produces the following output:

#let custom-theme = (
  me-right: (
    background-color: green,
  ),
)
#messeji(
  chat-data: parsed-data,
  theme: custom-theme,
)

== Custom timestamp and date-change format

By default, every time a message has a `date` value, timestamps are displayed in
the format `YYYY-MM-DD HH:DD`. However, you can customize it by passing a format
string to `timestamp-format`
#link("https://typst.app/docs/reference/foundations/datetime/#format")[(Click
here for Typst documentation)].

If you want to highlight that a new day started, you can use
`date-changed-format`. By default, this is deactivated by setting it to `""`.

```typst
#messeji(
  chat-data: parsed-data,
  date-changed-format: "[year]/[month]/[day]",
  timestamp-format: "[hour]:[minute]",
)
```

#line(length: 100%)
#messeji(
  chat-data: parsed-data,
  date-changed-format: "[year]/[month]/[day]",
  timestamp-format: "[hour]:[minute]",
)
#line(length: 100%)

