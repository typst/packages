// gentle-clues
#import "@preview/linguify:0.3.1": *

// Global states
#let __gc_clues_breakable = state("breakable", false)
#let __gc_clues_headless = state("headless", false)
#let __gc_clue_width = state("clue-width", auto)
#let __gc_header_inset = state("header-inset", 0.5em)
#let __gc_content_inset = state("content-inset", 1em)
#let __gc_border_radius = state("border-radius", 2pt)
#let __gc_border_width = state("border-width", 0.5pt)
#let __gc_stroke_width = state("stroke-width", 2pt)

#let __gc_task-counter = counter("gc-task-counter")
#let __gc_enable-task-counter = state("gc-task-counter", true) 


#let lang_database = toml("lang.toml")

/// Config Init
#let gentle-clues(
  breakable: false,
  headless: false,
  header-inset: 0.5em,
  // default-title: auto, // string or none
  // default-icon: emoji.magnify.l, // file or symbol
  // default-color: navy, // color profile name
  width: auto, // length
  stroke-width: 2pt,
  border-radius: 2pt, // length
  border-width: 0.5pt, // length
  content-inset: 1em, // length
  show-task-counter: false, // [bool]
  body
) = {
  // Conf linguify to lang parameter
  // linguify_set_database(toml("lang.toml"));

  // Update breakability
  __gc_clues_breakable.update(breakable);

  // Update clues width
  __gc_clue_width.update(width);

  // Update headless state
  __gc_clues_headless.update(headless);

  // Update header inset
  __gc_header_inset.update(header-inset);

  // Update border radius
  __gc_border_radius.update(border-radius);

  // Update border width
  __gc_border_width.update(border-width);
  
  // Update stroke width
  __gc_stroke_width.update(stroke-width);

  // Update content inset
  __gc_content_inset.update(content-inset);

  // Update if task counter should be shown
  __gc_enable-task-counter.update(show-task-counter);

  body

  }

// Helper
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else { 
    val 
  }
}

// Basic gentle-clue (clue) template
#let clue(
  content, 
  title: auto, // string or none
  icon: emoji.magnify.l, // file or symbol
  accent-color: navy, // color
  border-color: auto, 
  header-color: auto,
  width: auto, // length
  radius: auto, // length
  border-width: auto, // length
  content-inset: auto, // length
  header-inset: auto, // length
  breakable: auto,
) = {
  context {
    // if not linguify_is_database_initialized() {
    //   linguify_set_database(toml("lang.toml"));
    // }
    // Set default color:
    let _stroke-color = luma(70);
    let _bg-color = _stroke-color.lighten(85%);
    let _border-color = _bg-color.darken(10%); 
    let _border-width = if-auto-then(border-width, __gc_border_width.get());
    let _border-radius = if-auto-then(radius, __gc_border_radius.get())
    let _stroke-width = if-auto-then(auto, __gc_stroke_width.get())
    let _clip-content = true

    // setting bg and stroke color from color argument
    assert(type(accent-color) in (color, gradient), message: "expected color or gradient, found " + type(accent-color));
    if (header-color != auto) {
      assert(type(header-color) in (color, gradient), message: "expected color or gradient, found " + type(header-color));
    }
    if (border-color != auto) {
      assert(type(border-color) == color, message: "expected color, found " + type(border-color));
    }

    if (type(accent-color) == color) { 
      _stroke-color = accent-color;
      _bg-color = if-auto-then(header-color, accent-color.lighten(85%));
      _border-color = if-auto-then(border-color, accent-color.lighten(70%));
    } else if (type(accent-color) == gradient) {
      _stroke-color = accent-color
      _bg-color = if-auto-then(header-color, accent-color);
      _border-color = if-auto-then(border-color, accent-color);
    }


    // Disable Heading numbering for those headings
    set heading(numbering: none, outlined: false, supplement: "Box")

    // Header Part
    let header = box(
            fill: _bg-color,
            width: 100%,
            radius: (top-right: _border-radius),
            inset: if-auto-then(header-inset, __gc_header_inset.get()),
            stroke: (right: _border-width + _bg-color )
          )[
              #grid(
                columns: (auto, auto),
                align: (horizon, left + horizon),
                gutter: 1em,
                box(height: 1em)[
                  #if type(icon) == symbol {
                      text(1em,icon)
                  } else {
                    image(icon, fit: "contain")
                  }
                ],
                strong(title)
              )
          ]

    // Content-Box
    let content-box(content) = block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.get()),
      width: 100%,
      fill: white, 
      inset: if-auto-then(content-inset, __gc_content_inset.get()), 
      radius: (
        top-left: 0pt,
        bottom-left: 0pt, 
        top-right: if (title != none){0pt} else {_border-radius},
        rest: _border-radius
      ),
    )[#content]
    
    // Wrapper-Block
    block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.get()),
      width: if-auto-then(width, __gc_clue_width.get()),
      inset: (left: 1pt),
      radius: (right: _border-radius, left: 0pt),
      stroke: (
        left: (thickness: _stroke-width, paint: _stroke-color, cap: "butt"),
        top: if (title != none){_border-width + _bg-color} else {_border-width + _border-color},
        rest: _border-width + _border-color,
      ),
      clip: _clip-content,
    )[
      #set align(start)
      #stack(dir: ttb,
        if __gc_clues_headless.get() == false and title != none {
          header
        },
        content-box(content)
      )
    ] // block end
  }
}

// Helpers for predefined gentle clues
#let get_title_for(clue) = {
  assert.eq(type(clue),str); 
  return linguify(clue, from: lang_database, default: linguify(clue, lang: "en", default: clue));
}

#let increment_task_counter() = {
    context {
    if (__gc_enable-task-counter.get() == true){
      __gc_task-counter.step()
    }
  }
}

#let get_task_number() = {
  context {
    if (__gc_enable-task-counter.get() == true){
      " " + __gc_task-counter.display()
    }
  }
}

// Predefined gentle clues
/* info */
#let info(title: auto, icon: "assets/info.svg", ..args) = clue(
  accent-color: rgb(29, 144, 208), // blue
  title: if-auto-then(title, get_title_for("info")), 
  icon: icon, 
  ..args
)

/* success */
#let success(title: auto, icon: "assets/checkbox.svg", ..args) = clue(
  accent-color: rgb(102, 174, 62), // green
  title: if-auto-then(title, get_title_for("success")), 
  icon: icon, 
  ..args
)

/* warning */
#let warning(title: auto, icon: "assets/warning.svg", ..args) = clue(
  accent-color: rgb(255, 145, 0), // orange 
  title: if-auto-then(title, get_title_for("warning")), 
  icon: icon, 
  ..args
)

/* error */
#let error(title: auto, icon: "assets/crossmark.svg", ..args) = clue(
  accent-color: rgb(237, 32, 84),  // red 
  title: if-auto-then(title, get_title_for("error")),
  icon: icon, 
  ..args
)

/* task */
#let task(title: auto, icon: "assets/task.svg", ..args) = {
  increment_task_counter()
  clue(
    accent-color: maroon,
    title: if-auto-then(title, get_title_for("task") + get_task_number()), 
    icon: icon, 
    ..args
  )
}

/* tip */
#let tip(title: auto, icon: "assets/tip.svg", ..args) = clue(
  accent-color: rgb(0, 191, 165),  // teal 
  title: if-auto-then(title, get_title_for("tip")),
  icon: icon, 
  ..args
)

/* abstract */
#let abstract(title: auto, icon: "assets/abstract.svg", ..args) = clue(
  accent-color: olive,
  title: if-auto-then(title, get_title_for("abstract")), 
  icon: icon, 
  ..args
)

/* conclusion */
#let conclusion(title: auto, icon: "assets/lightbulb.svg", ..args) = clue(
  accent-color: rgb(255, 201, 23), // yellow
  title: if-auto-then(title, get_title_for("conclusion")), 
  icon: icon, 
  ..args
)

/* memorize */
#let memo(title: auto, icon: "assets/excl.svg", ..args) = clue(
  accent-color: rgb(255, 82, 82), // kind of red 
  title: if-auto-then(title, get_title_for("memo")), 
  icon: icon, 
  ..args
)

/* question */
#let question(title: auto, icon: "assets/questionmark.svg", ..args) = clue(
  accent-color: rgb("#7ba10a"), // greenish
  title: if-auto-then(title, get_title_for("question")), 
  icon: icon, 
  ..args
)

/* quote */
#let quote(title: auto, icon: "assets/quote.svg", origin: none, content, ..args) = clue(
  accent-color: eastern, 
  title: if-auto-then(title, get_title_for("quote")), 
  icon: icon, 
  ..args
)[
  #content
  #align(end)[
    #set text(0.9em, style: "italic")
    #origin
    ]
]

/* example */
#let example(title: auto, icon: "assets/example.svg", ..args) = clue(
  accent-color: orange, 
  title: if-auto-then(title, get_title_for("example")), //if (title != auto) { title  } else { get_title_for("example") }, 
  icon: icon, 
  ..args
)
