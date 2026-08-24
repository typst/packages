/**
== Draft Comments
:comment:
Insert editorial comments that became visible only in `#book(draft)` mode.
**/
#let comment(
  ..args, /// <- arguments
    /// Any arguments supported by~#univ("drafting") package. |
  type: auto /// <- auto | block | box
    /// Set comment type: marginalia, paragraph, or inline. |
) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/drafting:0.2.2"

  // Ignore when not #book(cfg.draft)
  if not storage.get("draft", true, namespace: "min-book") {return}
  
  storage.add("draft:comments", true, namespace: "min-book")  // Set #comment as being used
  
  set text(hyphenate:  true, size: text.size - 1pt)
  
  let pos = args.pos()
  let named = args.named()
  
  // Set default box stroke
  if not "stroke" in named.keys() {named.insert("stroke", gray.lighten(30%))}
  
  if type == auto {
    // Margin comments cannot be justified text due to lack of space
    drafting.margin-note(
      ..pos.map(arg => par(arg, justify: false)),
      ..named
    )
  }
  else if type in (block, box) {
    if type == box {named.insert("par-break", false)}
    
    drafting.inline-note(
      ..pos,
      ..named
    )
  }
  else {panic("Invalid comment type: " + repr(type))}
}


/**
== Draft Text Marker
```typ
#mark(background, data)
```
Insert text markings to highlight certain excerpts in `#book(draft)` mode. When using darker backgrounds, the text is automatically set to white.

background <- color
  Optional marker background color (defaults to gray).

data <- content
  The text to be highlithed.
**/
#let mark(..args) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "../utils.typ"
  
  let pos = args.pos()
  let named = args.named()
  let text-color = text.fill
  let luminance
  let components
  let background
  let data
  
  assert.eq(named, (:), message: "Invalid named arguments")
  assert(pos.len() <= 2, message: "Expected only 2 pisitional arguments")

  // Ignore when not #book(cfg.draft)
  if not storage.get("draft", true, namespace: "min-book") {return data}
  
  if pos.len() == 1 {
    luminance = utils.relative-luminance(text.fill)
    background = if luminance < 0.55 {gray.lighten(50%)} else {gray.darken(50%)}
    data = pos.at(0)
  }
  else {
    background = pos.at(0)
    data = pos.at(1)
  }
  
  luminance = utils.relative-luminance(background)
  
  // White text when using a dark background
  if luminance < 0.55 {text-color = white}
  
  set text(fill: text-color)
  
  box(data, fill: background, outset: (x: 1pt, y: 2pt))
}


/**
== Draft Event
:event:
Defines an event occurring in a section of the work.
**/
#let event(
  date: none, /// <- datetime | integer <required>
    /// Event date. For dates from fictional calendars, use integers. |
  alt: none, ///  <- content
    /// Defines an alternative event title when using dates from fictional calendars. |
  stroke: red, /// <- stroke
    /// Set event block stroke. |
  description, /// <- content <required>
    /// Event name and general description.
) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/heroic:0.1.2": hi

  // Ignore when not #book(cfg.draft)
  if not storage.get("draft", true, namespace: "min-book") {return}

  let alt = alt

  // Transform #datetime in readable date
  if type(date) == datetime {
    import "@preview/datify:1.0.0": custom-date-format
    
    alt = custom-date-format(date, pattern: "long", lang: text.lang)
  }

  assert.ne(date, none, message: "#event(date) required")
  assert.ne(alt, none, message: "#event(alt) required")

  // Set #event metadata
  [
    #metadata((
      description: description,
      date: date,
      alt: alt,
    )) <min-book:draft:event>
  ]

  set align(center)

  block(
    stroke: stroke,
    inset: 0.5em,
    hi("calendar") + " " + alt + linebreak() +
    description
  )
}


/**
== Draft Scene
:scene:
Defines a scene happening in the story.
**/
#let scene(
  pov: none, /// <- none | content
    /// Point of view, who tells the story. By default, define as a narrator (third person). |
  location: none, /// <- content <required>
    /// Where the scene takes place. |
  mood: none, /// <- content <required>
    /// The narrative atmosphere of the scene. |
  characters: none, /// <- content
    /// Characters involved in the scene. |
  stroke: red /// <- stroke
    /// Set scene block stroke. |
) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/heroic:0.1.2": hi
  import "@preview/transl:0.2.0": transl

  let pov = if pov == none {transl("narrator")} else {pov}

  // Ignore when not #book(cfg.draft)
  if not storage.get("draft", true, namespace: "min-book") {return}
  
  assert.ne(location, none, message: "#scene(location) required")
  assert.ne(mood, none, message: "#scene(mood) required")

  // Insert #scene metadata
  [
    #metadata((
      pov: pov,
      location: location,
      mood: mood,
      place: locate(here()),
      characters: characters,
    )) <min-book:draft:scene>
  ]
  
  set align(center)
  
  block(
    stroke: stroke,
    inset: 0.5em,
    {
      set align(left)
      
      hi("speaker-wave") + " " + pov + linebreak()
      hi("map-pin") + " " + location + linebreak()
      hi("sparkles") + " " + mood + linebreak()
      
      if characters != none {hi("users") + " " + characters + linebreak()}
    }
  )
}


// Generate timeline from #event metadata
#let event-timeline() = context {
  import "@preview/datify:1.0.0": custom-date-format
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/zeitline:0.1.1": timeline
  import "@preview/transl:0.2.0": transl
  
  let data = query(<min-book:draft:event>)
  let events = ()

  // Ignore when not #book(cfg.draft), or no #event queried
  if not storage.get("draft", true, namespace: "min-book") {return}
  if data == () {return}
  
  heading(transl("timeline"))

  timeline = timeline.with(theme: (colors: (accent: black, muted: gray.darken(50%), line: gray.darken(50%))))
  custom-date-format = custom-date-format.with(pattern: "long", lang: text.lang)

  // Sort by crescent dates
  data = data.sorted(
    key: e => e.value.date,
    by: (l, r) => if type(l) != type(r) {true} else {l <= r}
  )

  for event in data {
    event = event.value

    // Set readable date or alternative date
    event.date = if type(event.date) == datetime {custom-date-format(event.date)} else {event.alt}

    events.push((date: event.date, desc: event.description))
  }

  timeline(events)
}


// Generate list of book scenes from #scene metadata
#let scene-list() = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/heroic:0.1.2": hi
  import "@preview/transl:0.2.0": transl
  
  let scenes = query(<min-book:draft:scene>).map(e => e.value)
  let n = 0

  // Ignore when not #book(cfg.draft), or no #scene queried
  if not storage.get("draft", true, namespace: "min-book") {return}
  if scenes == () {return}
  
  heading(transl("scene", number: "plur"))

  for scene in scenes {
    n += 1  // scene number
    
    heading(level: 2, transl("scene", n: n))

    show: it => pad(it, left: 1em) // scene data left padding

    hi("speaker-wave") + " " + scene.pov + linebreak()
    hi("map-pin") + " " + scene.location + linebreak()
    hi("sparkles") + " " + scene.mood + linebreak()
    
    if scene.characters != none {hi("users") + " " + scene.characters + linebreak()}
  }
}


// Generate and outline of #comment
#let comment-list() = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "@preview/transl:0.2.0": transl
  import "@preview/drafting:0.2.2": note-outline

  // Ignore when not #book(cfg.draft), or no #comment used
  if not storage.get("draft", true, namespace: "min-book") {return}
  if not storage.final("draft:comments", false, namespace: "min-book") {return}
  
  note-outline(title: transl("comments"))
}