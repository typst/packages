#import "@preview/dati-basati:0.1.0"
#import "@preview/zebraw:0.6.1": *
#import "@preview/catppuccin:1.0.1": *
#import "@preview/gentle-clues:1.3.0": *

#set page(
  footer: context {
    let page-num = counter(page).display()
    if calc.odd(int(page-num)) {
      align(right, page-num)
    } else {
      align(left, page-num)
    }
  },
)
#set text(font: "Barlow", hyphenate: true, size: 12pt)
#set par(justify: true, linebreaks: "optimized")
#set heading(numbering: "1.1.")
#show heading: it => {
  if it.level <= 3 {
    it + v(6pt)
  } else {
    it
  }
}
#set list(indent: 1em)
#set enum(indent: 1em)

#show: zebraw
#show: catppuccin.with(flavors.latte)
#show: gentle-clues.with(breakable: true)

#show ref: set text(fill: get-flavor("latte").colors.blue.rgb)
#show link: set text(fill: get-flavor("latte").colors.blue.rgb)
#show link: underline.with(offset: 1pt)

#let fun(code, columns: (auto, 1fr)) = {
  v(10pt)
  figure(
    grid(
      columns: columns,
      align: (left, right).map(e => e + horizon),
      raw(
        block: false,
        lang: code.lang,
        code.text,
      ),
      eval(
        mode: "markup",
        scope: (
          dati-basati: dati-basati,
          er-diagram: dati-basati.er-diagram,
          entity: dati-basati.entity,
          subentities: dati-basati.subentities,
          relation: dati-basati.relation,
        ),
        code.text,
      ),
    ),
  )
  v(10pt)
}

#align(
  center + horizon,
  {
    text(
      size: 3em,
      [`dati-basati`],
    )
    v(-0.5cm)
    text(style: "italic")[
      A Typst package to draw ER diagrams.
    ]
    parbreak()
    text(weight: "bold", style: "italic", size: 1.2em, {
      link("https://github.com/victuarvi/dati-basati")
      parbreak()
      "Version " + toml("../typst.toml").package.version
    })
    grid(
      columns: (1fr,) * 2,
      align: top,
      column-gutter: 1cm,
      outline(
        title: "Manual",
        target: selector(heading).before(<_manual-end>, inclusive: false),
      ),
      outline(
        title: "Documentation",
        depth: 2,
        target: selector(heading).after(<_manual-end>, inclusive: false),
      ),
    )
  },
)

#show heading.where(level: 1): it => pagebreak(weak: true) + it

= Import

Depending on your needs there are different types of imports:

- Import _all_ the functions (recommended#footnote("Since it's unlikely there will be conflicts with identically named functions.")):
  ```typ
  #import "@preview/dati-basati:0.1.0": *
  ```

- Import _only_ the functions you want to use:
  ```typ
  #import "@preview/dati-basati:0.1.0": er-diagram, entity, relation
  ```

- Import and (optionally) rename:
  ```typ
  #import "@preview/dati-basati:0.1.0" as renamed
  ```
  but your code would be more verbose, like in the following example:

  ```typ
  #renamed.er-diagram({
    renamed.entity(
      (0, 0),
      name: "entity0",
    )
  })
  ```
The package is designed to be as straightforward and intuitive as possible, so you should be able to just write diagrams without even needing to read the manual -- or at least that was the design goal.

= Basic usage

== Entities

A basic entity would appear like this:

#fun(
  ```typ
  #er-diagram({
    entity(
      // coordinates
      (0, 0),
      // the internal reference
      name: "entity",
      // the content label
      label: "Nice Name"
    )
  })
  ```,
)

=== Entity with attributes<attributes>

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        north: ("name", "surname"),
        east: ("mail",),
        west: ("address",),
        south: ("cellphone",),
      ),
    )
  })
  ```,
)

/ Primary key: Adding a single primary key:

#fun(
  ```typ
    #er-diagram({
      entity(
        (0, 0),
        name: "student",
        label: "student",
        attributes: (
          north: ("name", "surname"),
          east: ("mail",),
          west: ("address",),
          south: ("cellphone",),
        ),
        primary-key: "name"
      )
    })
  ```,
)

/ Composite primary key: Adding a composite primary key:

#fun(
  ```typ
    #er-diagram({
      entity(
        (0, 0),
        name: "student",
        label: "student",
        attributes: (
          north: ("mail",),
          east: ("name", "surname"),
          west: ("address",),
          south: ("cellphone",),
        ),
        primary-key: ("name", "surname")
      )
    })
  ```,
)

#info[
  The direction of the line will depend on the exact order you give the attributes:

  #fun(
    ```typ
    #er-diagram({
      entity(
        (0, 0),
        name: "student",
        label: "student",
        attributes: (
          north: ("mail",),
          east: ("name", "surname"),
          west: ("address",),
          south: ("cellphone",),
        ),
        primary-key: ("name", "surname").rev()
      )
    })
    ```,
  )
]

#pagebreak()

/ Composite attributes: You might want to group some attributes together:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        east: ("name", "surname"),
        south: (
          // instead of a string, the comp.
          // attr. is an array
          ("street", "street_number",
          "city", "country"),
        ),
      ),
      primary-key: ("name", "surname").rev()
    )
  })
  ```,
)

#info[
  The composite attributes is designed to be _the only attribute_ on its side, meaning that other attributes on the same side will NOT be drawn.
]

=== Subentities

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 4),
      name: "A",
      label: "car",
    )
    entity(
      (-2, 0),
      name: "B",
      label: "electric",
    )
    entity(
      (2, 0),
      name: "C",
      label: "gasoline",
    )
    subentities(
      entity: "A",
      subentities: ("B", "C"),
    )
  })
  ```,
)

#warning[
  *You can't* connect a subentity to an entity if that entity has not been drawn yet:
  ```typ
  // this will NOT work
  #er-diagram({
    subentities(
      entity: "A",
      subentities: ("B", "C"),
    )
    entity(
      (0, 0),
      name: "A",
      label: "entity1",
    )
    entity(
      (-2, 4),
      name: "B",
      label: "entity2",
    )
  })
  ```
]

// #pagebreak()

Although subentities generally tend to be below their superentity, you can place them wherever you like best:

#fun(
  // columns: (40%, 60%),
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "A",
      label: "book",
    )
    entity(
      (6, 2),
      name: "B",
      label: "paper",
    )
    entity(
      (6, -2),
      name: "C",
      label: "ebook",
    )
    subentities(
      hierarchy: "(p,o)",
      entity: "A",
      subentities: ("B", "C"),
    )
  })
  ```,
)

// #fun(
//   columns: (40%, 60%),
//   ```typ
//   #er-diagram({
//     entity(
//       (0, 0),
//       name: "A",
//       label: "book",
//     )
//     entity(
//       (-6, 2),
//       name: "B",
//       label: "paper",
//     )
//     entity(
//       (-6, -2),
//       name: "C",
//       label: "ebook",
//     )
//     subentities(
//       hierarchy: "(p,o)",
//       entity: "A",
//       subentities: ("B", "C"),
//     )
//   })
//   ```,
// )

// #pagebreak()

A more complex layout:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "A",
      label: "senior",
    )
    entity(
      (-2, 4),
      name: "B",
      label: "overseer",
    )
    entity(
      (2, 4),
      name: "C",
      label: "manager",
    )
    entity(
      (2, 8),
      name: "D",
      label: "health",
    )
    entity(
      (-2, 8),
      name: "E",
      label: "logistics",
    )
    subentities(
      entity: "A",
      subentities: ("B", "C"),
    )
    subentities(
      entity: "B",
      subentities: ("D", "E"),
    )
  })
  ```,
)

// #fun(
//   ```typ
//   #er-diagram({
//     entity(
//       (0, 0),
//       name: "A",
//       label: "entity1",
//     )
//     entity(
//       (-2, 4),
//       name: "B",
//       label: "entity2",
//     )
//     entity(
//       (2, 4),
//       name: "C",
//       label: "entity3",
//     )
//     entity(
//       (0, -4),
//       name: "D",
//       label: "entity4",
//     )
//     subentities(
//       hierarchy: "(t,s)",
//       entity: "A",
//       subentities: ("B", "C"),
//     )
//     relation(
//       coordinates: (0, -2),
//       entities: ("A", "D"),
//       cardinality: ("(1,n)", "(1,1)"),
//     )
//   })
//   ```,
// )

=== Attributes positioning<attributes-positioning>

Depending on what you are trying to achieve, the default placement could be wrong -- you can modify if with `attributes-position`:
```
attributes-position: (
  side: (
    alignment: left | center | right,
    dir: "ltr" | "rtl",               // left-to-right, right-to-left
    start: "from-short" | "from-long" // from shortest to longest
  ),
)
```

#pagebreak()

Default:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        north: ("name", "surname", "mail"),
      ),
    )
  })
  ```,
)

Mirrored:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        north: ("name", "surname", "mail"),
      ),
      attributes-position: (
        north: (alignment: right, dir: "rtl")
      ),
    )
  })
  ```,
)

#warning[
  You will find out _some combinations_ will lead to visual errors:
  #fun(
    ```typ
    #er-diagram({
      entity(
        (0, 0),
        name: "student",
        label: "student",
        attributes: (
          north: ("name", "surname", "mail"),
        ),
        attributes-position: (
          north: (alignment: right)
        )
      )
    })
    ```,
  )
  In the future this might be patched.
]

From high to low:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        north: ("name", "surname", "mail"),
      ),
      attributes-position: (
        north: (start: "from-long")
      )
    )
  })
  ```,
)

Mirrored:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "student",
      label: "student",
      attributes: (
        north: ("name", "surname", "mail"),
      ),
      attributes-position: (
        north: (
          start: "from-long",
          alignment: right,
          dir: "rtl"
        )
      )
    )
  })
  ```,
)

#pagebreak()

== Relations

Ideally the relation should be a straight line connecting two entities:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "child",
      label: "child",
    )
    entity(
      (0, 4),
      name: "parent",
      label: "parent",
    )
    relation(
      entities: ("parent", "child"),
      cardinality: ("(0,n)", "(1,1)"),
    )
  })
  ```,
)

With label:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "child",
      label: "child",
    )
    entity(
      (0, 4),
      name: "parent",
      label: "parent",
    )
    relation(
      label: "has",
      entities: ("parent", "child"),
      cardinality: ("(0,n)", "(1,1)"),
    )
  })
  ```,
)

#pagebreak()

With label outside:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "child",
      label: "child",
    )
    entity(
      (0, 4),
      name: "parent",
      label: "parent",
    )
    relation(
      label: ("has", "east"),
      entities: ("parent", "child"),
      cardinality: ("(0,n)", "(1,1)"),
    )
  })
  ```,
)

With an attribute (same API as entities, see @attributes):

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "user",
      label: "user",
    )
    entity(
      (0, -4),
      name: "subscription",
      label: "subscription",
    )
    relation(
      entities: ("user", "subscription"),
      cardinality: ("(1,n)", "(1,1)"),
      attributes: (east: ("date",)),
    )
  })
  ```,
)

#pagebreak()

Combined:
#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "user",
      label: "user",
    )
    entity(
      (0, -4),
      name: "subscription",
      label: "subscription",
    )
    relation(
      label: ("purchases", "east"),
      entities: ("user", "subscription"),
      cardinality: ("(1,n)", "(1,1)"),
      attributes: (east: ("date",)),
    )
  })
  ```,
)

#info[
  Relations *can't* have primary keys; also there is no such thing as a "weak relation" (see @weak-entities).
]

/ Manual placement#footnote[Since the relation attributes API is the same as entities, @attributes-positioning would apply as expected. Though remember the relations don't have... many anchors to draw from.]: If you need to manually specify where to place a relation you can:
#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "user",
      label: "user",
    )
    entity(
      (4, -4),
      name: "subscription",
      label: "subscription",
    )
    relation(
      coordinates: (4,0),
      label: ("purchases", "south-west"),
      entities: ("user", "subscription"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

= Formatting & customization

The package provides an handful of themes you can use by importing the corresponding module and applying the show rule:
```typ
#import "@preview/dati-basati:0.1.0" as db
#show: db.with(..db.themes.at("theme-name"))
```
Currently the themes are:
#context {
  let themes = list(..dati-basati.themes.keys())
  block(
    height: measure(themes).height / 2.7,
    columns(3, themes),
  )
}

// #info[
//   Themes also include the default attributes positioning (see @attributes-positioning).
// ]

The theme schema is as follows:
```typ
#let default-settings = (
  fill: (
    entities: none,
    relations: auto, // auto inherits entities
    primary-key: black,
    weak-entity: auto, // auto inherits primary-key
    cardinality: auto, // auto = page fill
    hierarchy: auto, // auto inherits cardinality
    composite-attributes: auto, // auto inherits cardinality
  ),
  stroke: (
    entities: black,
    relations: black, // auto inherits entities
    lines: auto, // auto inherits entities
    attributes: black,
    composite-attributes: auto, // auto inherits attributes
    primary-key: auto, // auto inherits attributes
    weak-entity: auto, // auto inherits primary-key
    cardinality: none,
    hierarchy: auto, // auto inherits cardinality
  ),
  radius: (
    entities: 0pt,
    cardinality: 0pt,
    hierarchy: auto, // auto inherits cardinality
  ),
  spacing: (
    in-between: (x: 1.2em, y: 1.2em), // spacing between attributes
    padding: 1.2em, // distance from the entity
  ),
  text: (
    entities: l => {
      set par(leading: 0.35em)
      text(
        top-edge: "bounds",
        size: 1.5em,
        weight: "bold",
        smallcaps(lower(l)),
      )
    },
    relations: l => l,
    attributes: l => l,
    cardinality: l => text(top-edge: "bounds", bottom-edge: "bounds", l),
    hierarchy: auto,
  ),
  attributes-position: (
    "north": (
      alignment: left,
      dir: "ltr",
      start: "from-short",
    ),
    "east": (
      alignment: center,
      dir: "ltr",
    ),
    "south": (
      alignment: right,
      dir: "rtl",
      start: "from-short",
    ),
    "west": (
      alignment: center,
      dir: "rtl",
    ),
  ),
  misc: (
    weak-entities-stroke: false, // double stroke weak entities
    relations-intersection: "|-",
  ),
)
```

You can override single settings:
```typ
#import "@preview/dati-basati:0.1.0" as db
#show: db.with(..db.themes.at("theme-name"),entities: (fill: green))
```

Or create new themes following the schema:
```typ
#import "@preview/dati-basati:0.1.0" as db
#import "@preview/catppuccin:1.0.1": *
#let palette = flavors.latte.colors
#show: db.with(
  fill: (
    cardinality: palette.flamingo.rgb,
    entities: palette.red.rgb,
    relations: palette.red.rgb,
    attributes: palette.red.rgb,
    primary-key: palette.maroon.rgb,
    weak-entity: palette.red.rgb,
  ),
  stroke: (
    cardinality: palette.surface0.rgb + 0.1pt,
    entities: black,
    relations: black,
    attributes: palette.rosewater.rgb,
    weak-entity: orange,
  ),
  text: (
    entities: l => text(
      fill: palette.surface0.rgb,
      weight: 500,
      size: 1.2em,
      smallcaps(l),
    ),
    cardinality: l => text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      fill: palette.surface0.rgb,
      l,
    ),
  ),
  radius: (
    entities: 6pt,
    cardinality: 6pt,
  ),
)
```

There are plenty of examples with each and every theme -- and corresponding source code -- in #link("https://github.com/victuarvi/dati-basati/blob/main/examples", `/examples`).

#tip[
  If you need different ER diagrams to have different themes, create a `.typ` file and then include that -- in this way, you can apply the `show` rule with the specific theme in the scope of the single file.

  In the future, the theming settings could be implemented per `er-diagram`.
]

= Advanced usage

== Weak entities<weak-entities>

Sometimes there is the need to express a weak costraint, such a carriage number _within the context_ of a train; in order to do so specify the weak entity argument with the `(attribute, strong-entity, direction)` format:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "train",
      label: "train",
    )
    entity(
      (0, -4),
      name: "carriage",
      label: "carriage",
      attributes: (west: ("num", )),
      weak-entity: ("num", "train")
    )
    relation(
      entities: ("train", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

Changing the direction -- now CCW, counter clockwise:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "train",
      label: "train",
    )
    entity(
      (0, -4),
      name: "carriage",
      label: "carriage",
      attributes: (west: ("num", )),
      weak-entity: ("num", "train", "CCW")
    )
    relation(
      entities: ("train", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

#warning[
  By default, you can't relate a weak entity to a strong entity _if the strong entity does not exist yet_ -- this behaviour mirrors how a possible SQL translation would work:
  ```sql
  create table train(
    id int primary key
  );
  create table carriage(
    id int primary key,
    foreign key(id) references train(id)
  )
  ```

  If you need to, you can specify the location of the strong entity via cardinal points:

  #fun(
    ```typ
    #er-diagram({
      entity(
        (0, 0),
        name: "carriage",
        label: "carriage",
        attributes: (south: ("num", )),
        weak-entity: ("num", "south")
      )
      entity(
        (0, -4),
        name: "train",
        label: "train",
      )
      relation(
        entities: ("train", "carriage"),
        cardinality: ("(1,n)", "(1,1)"),
      )
    })
    ```,
  )

  Note carriage and train have been swapped, so that the weak entity has been drawn _before_ its corresponding strong entity.
]

#pagebreak()

== Unorthodox relation position

Sometimes, due to the density of entities, the relations cannot be placed right above, left, right or below -- the package acknowledges this and automatically handles this situation:

#fun(
  ```typ
  #er-diagram({
    entity(
      (0, 0),
      name: "train",
      label: "train",
    )
    entity(
      (4, -4),
      name: "carriage",
      label: "carriage",
      attributes: (east: ("num", )),
    )
    relation(
      entities: ("train", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

/ Weak entity: It also automatically handles weak entities in such cases:

#fun(
  ```typ
  #er-diagram({
    entity(
      (3, 0),
      name: "train",
      label: "train",
    )
    entity(
      (0, -4),
      name: "carriage",
      label: "carriage",
      attributes: (east: ("num", )),
      weak-entity: ("num", "train", "CCW")
    )
    relation(
      entities: ("train", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

== Exceptions

For some reason, you might need to create a weak entity that involves two entities but can't -- or won't -- start from the semantically correct attribute; you can still use the cardinal points:
#fun(
  ```typ
  #er-diagram({
    entity(
      (6, 0),
      name: "carriage",
      label: "carriage",
      attributes: (south: ("num", )),
      attributes-position: (south: (alignment: left)),
      weak-entity: ("south", "west")
    )
    entity(
      (0, 0),
      name: "train",
      label: "train",
    )
    entity(
      (6,-4),
      name: "convoy",
      label: "convoy",
    )
    relation(
      entities: ("train", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
    relation(
      entities: ("convoy", "carriage"),
      cardinality: ("(1,n)", "(1,1)"),
    )
  })
  ```,
)

Also do note carriage _is the first entity to be drawn_.

#metadata(none)<_manual-end>

#import "@preview/tidy:0.4.3": *

#import "../src/dati-basati.typ"
#import "style.typ"

#let custom-show-module(module-name) = show-module(
  parse-module(
    read("../src/" + module-name + ".typ"),
    name: module-name,
    scope: (module-name: module-name),
    preamble: "#import " + module-name + ": *\n",
  ),
  style: style,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
  sort-functions: none,
)

= User functions

For _all_ the generated documentation, refer to #link("https://github.com/victuarvi/dati-basati/blob/main/docs/docs.pdf", `/docs/docs.pdf`).

#set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: "1.1")

#custom-show-module("dati-basati")
