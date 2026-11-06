// gentle-clues

// Title dict for all supported languages
#let title_dict = (
  abstract: (
    de: "Einführung", en: "Abstract", 
    fr: "Résumé", es: "Resumen"
  ),
  info: (
    de: "Info", en: "Info", 
    fr: "Info", es: "Info"
  ),
  question: (
    de: "Frage", en: "Question", 
    fr: "Question", es: "Pregunta"
  ),
  memo: (
    de: "Merke", en: "Memorize", 
    fr: "À retenir", es: "Recordatorio"
  ),
  task: (
    de: "Aufgabe", en: "Task", 
    fr: "Tâche", es: "Tarea"
  ),
  conclusion: (
    de: "Zusammenfassung", en: "Conclusion", 
    fr: "Conclusion", es: "Conclusión"
  ),
  tip: (
    de: "Tipp", en: "Tip", 
    fr: "Conseil", es: "Consejo"
  ),
  success: (
    de: "Erledigt", en: "Success", 
    fr: "Succès", es: "Éxito"
  ),
  warning: (
    de: "Achtung", en: "Warning", 
    fr: "Avertissement", es: "Advertencia"
  ),
  error: (
    de: "Fehler", en: "Error", 
    fr: "Erreur", es: "Error"
  ),
  example: (
    de: "Beispiel", en: "Example", 
    fr: "Exemple", es: "Ejemplo"
  ),
  quote: (
    de: "Zitat", en: "Quote", 
    fr: "Citation", es: "Cita"
  ),
)

// Global states
#let gc_header-title-lang = state("lang", "en")  // Keep for compatible reasons without underscore till 1.0.0
#let __gc_clues_breakable = state("breakable", false)
#let __gc_clues_headless = state("headless", false)
#let __gc_clue_width = state("clue-width", auto)
#let __gc_header_inset = state("header-inset", 0.5em)
#let __gc_content_inset = state("content-inset", 1em)
#let __gc_border_radius = state("border-radius", 2pt)
#let __gc_border_width = state("border-width", 0.5pt)
#let __gc_stroke_width = state("stroke-width", 2pt)

#let __gc_task-counter = counter("gc-task-counter")
#let gc_enable-task-counter = state("gc-task-counter", true)  // Keep for compatible reasons without underscore till 1.0.0


/* Config Init */
#let gentle-clues(
  lang: "en",
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
  // Check language
  assert(
    type(lang) == str, 
    message: "The lang parameter needs to be of type string."
  );
  assert(
    lang == "en" or 
    lang == "de" or
    lang == "es" or
    lang == "fr",
    message: "The defined language is not supported yet."
  )
  // Update title to lang parameter
  gc_header-title-lang.update(lang)  // keep without underscore for compatible reasons

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
  gc_enable-task-counter.update(show-task-counter);

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

#let get_base_color(val) = {
  if (type(_color) == color) { val }
}

#let get_colors(base_color) = {
  return (base_color, base_color.lighten(85%), base_color.lighten(70%))
}

/*
  Basic gentle-clue (clue) template
*/
#let clue(
  content, 
  title: auto, // string or none
  icon: emoji.magnify.l, // file or symbol
  _color: navy, // color
  width: auto, // length
  radius: auto, // length
  border-width: auto, // length
  content-inset: auto, // length
  header-inset: auto, // length
  breakable: auto,
) = {
  locate(loc => {
  // Set default color:
  let _stroke-color = luma(70);
  let _bg-color = _stroke-color.lighten(85%);
  let _border-color = _bg-color.darken(10%); // gray.lighten(20%);
  let _border-width = if-auto-then(border-width, __gc_border_width.at(loc));
  let _border-radius = if-auto-then(radius, __gc_border_radius.at(loc))
  let _stroke-width = if-auto-then(auto, __gc_stroke_width.at(loc))
  let _clip-content = true

  // setting bg and stroke color from color argument
  // TODO: refactor
  if (type(_color) == color) { 
    _stroke-color = _color;
    _bg-color = _color.lighten(85%);
    _border-color = _bg-color.darken(10%);
  } else if (type(_color) == dictionary) {
    if (_color.keys().contains("stroke")) {
      assert(type(_color.stroke) == color, message: "stroke must be of type color");
      _stroke-color = _color.stroke;
    }
    if (_color.keys().contains("bg")) {
      assert(type(_color.bg) == color, message: "bg must be of type color");
      _bg-color = _color.bg;
      _border-color = _bg-color.darken(10%);
    }
        if (_color.keys().contains("border")) {
      assert(type(_color.border) == color, message: "border must be of type color");
      _border-color = _color.border;
    }
  } else if (type(_color) == gradient) {
    _stroke-color = _color;
    _bg-color = _color;
  } else {
    panic("No valid color type. Use a gradient, color, or specify a dict with (stroke, bg)");
  }


  // Disable Heading numbering for those headings
  set heading(numbering: none, outlined: false, supplement: "Box")

  // Header Part
  let header = rect(
          fill: _bg-color,
          width: 100%,
          radius: (top-right: _border-radius),
          inset: if-auto-then(header-inset, __gc_header_inset.at(loc)),
          stroke: (right: _border-width + _bg-color )
        )[
            #grid(
              columns: (auto, auto),
              gutter: 1em,
              box(height: 1em)[
                #if type(icon) == "symbol" {
                    text(1em,icon)
                } else {
                  image(icon, fit: "contain")
                }
              ],
              align(left + horizon,strong(title))
            )
        ]

  // Content-Box
  let content-box(content) = block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.at(loc)),
      width: 100%,
      fill: white, 
      inset: if-auto-then(content-inset, __gc_content_inset.at(loc)), 
      radius: (
        top-left: 0pt,
        bottom-left: 0pt, 
        top-right: if (title != none){0pt} else {_border-radius},
        rest: _border-radius
      ),
    )[#content]
  
    // Wrapper-Block
    block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.at(loc)),
      width: if-auto-then(width, __gc_clue_width.at(loc)),
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
        if __gc_clues_headless.at(loc) == false and title != none {
          header
        },
      content-box(content)
      )
    ] // block end
  })
}


// Helpers for predefined gentle clues
#let get_title_for(clue) = {
  assert.eq(type(clue),str);
  locate(loc => {
    let lang = gc_header-title-lang.at(loc)
    return title_dict.at(clue).at(lang)
  })
}

#let increment_task_counter() = {
    locate(loc => {
    if (gc_enable-task-counter.at(loc) == true){
      __gc_task-counter.step()
    }
  })
}

#let get_task_number() = {
  locate(loc => {
    if (gc_enable-task-counter.at(loc) == true){
      " " + __gc_task-counter.display()
    }
  })
}

// Predefined gentle clues
/* info */
#let info(title: auto, icon: "assets/info.svg", ..args) = clue(
  _color: rgb(29, 144, 208), // blue
  title: if (title != auto) { title } else { get_title_for("info") }, 
  icon: icon, 
  ..args
)

/* success */
#let success(title: auto, icon: "assets/checkbox.svg", ..args) = clue(
  _color: rgb(102, 174, 62), // green
  title: if (title != auto) { title  } else { get_title_for("success") }, 
  icon: icon, 
  ..args
)

/* warning */
#let warning(title: auto, icon: "assets/warning.svg", ..args) = clue(
  _color: rgb(255, 145, 0), // orange 
  title: if (title != auto) { title  } else { get_title_for("warning") }, 
  icon: icon, 
  ..args
)

/* error */
#let error(title: auto, icon: "assets/crossmark.svg", ..args) = clue(
  _color: rgb(237, 32, 84),  // red 
  title: if (title != auto) { title  } else { get_title_for("error") },
  icon: icon, 
  ..args
)

/* task */
#let task(title: auto, icon: "assets/task.svg", ..args) = {
  increment_task_counter()
  clue(
    _color: maroon, // purple rgb(158, 84, 159)
    title: if (title != auto) { title  } else { get_title_for("task") + get_task_number()}, 
    icon: icon, 
    ..args
  )
}

/* tip */
#let tip(title: auto, icon: "assets/tip.svg", ..args) = clue(
  _color: rgb(0, 191, 165),  // teal 
  title: if (title != auto) { title  } else { get_title_for("tip") },
  icon: icon, 
  ..args
)

/* abstract */
#let abstract(title: auto, icon: "assets/abstract.svg", ..args) = clue(
  _color: olive, // rgb(124, 77, 255), // kind of purple
  title: if (title != auto) { title  } else { get_title_for("abstract") }, 
  icon: icon, 
  ..args
)

/* conclusion */
#let conclusion(title: auto, icon: "assets/lightbulb.svg", ..args) = clue(
  _color: rgb(255, 201, 23), // yellow
  title: if (title != auto) { title  } else { get_title_for("conclusion") }, 
  icon: icon, 
  ..args
)

/* memorize */
#let memo(title: auto, icon: "assets/excl.svg", ..args) = clue(
  _color: rgb(255, 82, 82), // kind of red 
  title: if (title != auto) { title  } else { get_title_for("memo") }, 
  icon: icon, 
  ..args
)

/* question */
#let question(title: auto, icon: "assets/questionmark.svg", ..args) = clue(
  _color: rgb("#7ba10a"), // greenish
  title: if (title != auto) { title  } else { get_title_for("question") }, 
  icon: icon, 
  ..args
)

/* quote */
// TODO: add source field.
#let quote(title: auto, icon: "assets/quote.svg", ..args) = clue(
  _color: eastern, 
  title: if (title != auto) { title  } else { get_title_for("quote") }, 
  icon: icon, 
  ..args
)

/* example */
#let example(title: auto, icon: "assets/example.svg", ..args) = clue(
  _color: orange, 
  title: if (title != auto) { title  } else { get_title_for("example") }, 
  icon: icon, 
  ..args
)
