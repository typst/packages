// Imports
#import "template.typ": *
#import "@preview/tidy:0.4.2"
#import "../messeji.typ"

#let typst-toml = toml("../typst.toml").at("package")

#show: project.with(
  title: typst-toml.at("name"),
  subtitle: typst-toml.at("description"),
  authors: typst-toml.at("authors"),
  abstract: "messēji (\"Message\" in Japanese) is a Typst package for
  typesetting chat histories in a modern, minimal design, inspired by popular
  messengers. No manual copying to your Typst document required, just pass in a
  JSON file.",
  date: datetime.today().display("[month repr:long] [day], [year]"),
  version: typst-toml.at("version"),
  url: typst-toml.at("repository"),
  note: [Build this document with `typst compile messeji-guide.typ --root ..` \
    Function reference generated with
    #link("https://github.com/Mc-Zen/tidy")[tidy].],
)


#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}

= Introduction

With _messēji_, you can easily typeset long chats by passing in your history as
a JSON file. No clutter in your Typst document, and you can focus on your actual
content. Main features of _messēji_ include:

- Support for quoted messages
- Image messages (with and without captions)
- Displaying timestamps between messages
- Simple data model to read from external files (JSON, YAML, ...) if you want to
  typeset very long chat histories
- Reacting to messages

Currently, it does not support:

- Group chats (only 1-on-1 chats)
- Displaying names / profile pictures next to the messages

These features are currently not planned to be implemented. However, if you need
them, #link("https://github.com/Tanikai/messeji/issues")[create an issue] and
I'll look into it (if I have the time).

= Usage

== Import

Add the following import statement to the top of your document:

```typ
#import "@preview/messeji:0.3.0": messeji
```

== Message Structure

The messages have to be in the following structure (dictionary formatted as
JSON):

```json5
{
  // Optional, can be combined with image
  "msg": "Actual Message",

  // Optional, can be combined with msg
  "image": "path_to_image.jpg",

  // Required, true for right, false for left
  "from_me": true,

  // Optional, in ISO 8601 format
  "date": "2026-12-25T09:41:00",

  // Optional
  "ref": "Previous message that is being quoted",

  // Optional, only single emojis are tested / supported
  "reaction": "❤️"
}
```

The order of the fields is not important. You can use other filetypes if you
want to, but the key names have to be the same, and the `date` value has to be
in ISO 8601 format.

== Basic example from JSON

```typ
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
#{
  set text(font: "Helvetica Neue")
  messeji.messeji(chat-data: parsed-data)
}
#v(1em)
#line(length: 100%)


== Basic example directly in Typst

```typ
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
#{
  set text(font: "Helvetica Neue")
  messeji.messeji(chat-data: my-messages)
}
#v(1em)
#line(length: 100%)


#pagebreak(weak: true)

== Messages with Images

As typst does not support directory walking
#footnote[#link("https://forum.typst.app/t/is-there-a-way-to-retrieve-the-current-file-name-list-files-etc-within-typst/155/3")],
loading messages with images from a JSON file is a bit more complicated.
Additionally, Typst packages cannot access the working directory of your
project, which means that you have to define the function that loads the images,
and pass them to messeji as parameters. However, there is still a way to do this
automatically.

In short, you just have to add a single function to your Typst document that
handles loading the images from your directory. The general workflow looks like
this:

1. Save all images in the same directory (e.g., `img`)
2. Import and use the `get-image-names` function from messeji to get all image
  names that are defined in your message list. It returns the image names in a
  dictionary, and still has to be filled with the loaded images.
3. Pass the image names to your own `load-images` function (see below) to load
  them into Typst.
4. Pass the loaded images to `messeji`.

In detail, add the following code to your document:

```typ
#import "@preview/messeji:0.3.0": messeji, get-image-names // import image name function

// this function has to be defined in your own document, as it accesses files
// located in your project directory (with the `image()` function).
#let load-images(
  directory, // with trailing slash!
  image-names,
) = {
  for img-name in image-names.keys() {
    image-names.insert(img-name, image(directory + img-name, fit: "contain"))
  }
  return image-names
}

#let chat-with-images = json("image.example.json") // Load chat data from JSON file

#let image-names = get-image-names(chat-with-images) // Load image names from loaded chat data

#let loaded-images = load-images("img/", image-names) // Load actual images into Typst

#messeji(
  chat-data: chat-with-images,
  images: loaded-images,
)
```

This produces the following chat:

#line(length: 100%)
#let load-images(
  directory, // with trailing slash!
  image-names,
) = {
  for img-name in image-names.keys() {
    image-names.insert(
      img-name,
      image(
        directory + img-name,
        fit: "contain",
      ),
    )
  }
  return image-names
}

#let chat-with-images = json("image.example.json")
#let image-names = messeji.get-image-names(chat-with-images)
#let loaded-images = load-images("img/", image-names)
#{
  set text(font: "Helvetica Neue")
  messeji.messeji(
    chat-data: chat-with-images,
    images: loaded-images,
  )
}
#v(1em)
#line(length: 100%)

= Customization

== Themes

You can customize the text colors, backgrounds, and font sizes. Currently, the
default theme has the following keys and values:

#raw("#let default-theme = " + repr(messeji.default-theme), lang: "typ", block: true)

If you want to change the theme, you just have to override the keys that you
need. Everything else that is undefined will be taken from the default theme:

```typ
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

#line(length: 100%)
#let custom-theme = (
  me-right: (
    background-color: green,
  ),
)
#{
  set text(font: "Helvetica Neue")
  messeji.messeji(
    chat-data: parsed-data,
    theme: custom-theme,
  )
}
#v(1em)
#line(length: 100%)

== Custom timestamp and date-change format

By default, every time a message has a `date` value, timestamps are displayed in
the format `YYYY-MM-DD HH:DD`. However, you can customize it by passing a format
string to `timestamp-format`
#link("https://typst.app/docs/reference/foundations/datetime/#format")[(Click
here for Typst documentation)].

If you want to highlight that a new day started, you can use
`date-changed-format`. By default, this is deactivated by setting it to `""`.

```typ
#messeji(
  chat-data: parsed-data,
  date-changed-format: "[year]/[month]/[day]",
  timestamp-format: "[hour]:[minute]",
)
```

#line(length: 100%)
#{
  set text(font: "Helvetica Neue")
  messeji.messeji(
    chat-data: parsed-data,
    date-changed-format: "[year]/[month]/[day]",
    timestamp-format: "[hour]:[minute]",
  )
}
#v(1em)
#line(length: 100%)

= Function Reference


#{
  let messeji-module = tidy.parse-module(
    read("../messeji.typ"),
    name: "Messeji",
    scope: (default-theme: messeji.default-theme),
  )
  set heading(numbering: none)
  show heading.where(level: 3): set text(1.5em)
  show heading.where(level: 4): it => {
    set text(1.4em)
    set align(center)
    set block(below: 1.2em)
    it
  }
  tidy.show-module(
    messeji-module,
    show-module-name: false,
    omit-private-definitions: true,
    first-heading-level: 3,
  )
}
