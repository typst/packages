// gentle-clues

#let gc_header-title-lang = state("lang", "en")
#let gc_task-counter = counter("gc-task-counter")
#let gc_enable-task-counter = state("gc-task-counter", true)

#let title_dict = (
  abstract: (de: "Einführung", en: "Abstract", fr: "Résumé", es: "Resumen"),
  info: (de: "Info", en: "Info", fr: "Info", es: "Info"),
  question: (de: "Frage", en: "Question", fr: "Question", es: "Pregunta"),
  memo: (de: "Merke", en: "Memorize", fr: "À retenir", es: "Recordatorio"),
  task: (de: "Aufgabe", en: "Task", fr: "Tâche", es: "Tarea"),
  conclusion: (de: "Zusammenfassung", en: "Conclusion", fr: "Conclusion", es: "Conclusión"),
  tip: (de: "Tipp", en: "Tip", fr: "Conseil", es: "Consejo"),
  success: (de: "Erledigt", en: "Success", fr: "Succès", es: "Éxito"),
  warning: (de: "Achtung", en: "Warning", fr: "Avertissement", es: "Advertencia"),
  error: (de: "Fehler", en: "Error", fr: "Erreur", es: "Error"),
  example: (de: "Beispiel", en: "Example", fr: "Exemple", es: "Ejemplo"),
  quote: (de: "Zitat", en: "Quote", fr: "Citation", es: "Cita"),
)

/*
  Basic gentle-clue (clue) template
*/
#let clue(
  content, 
  title: none, // string or none
  icon: emoji.magnify.l, // file or symbol
  _color: navy, // color profile name
  width: auto, // length
  radius: 2pt, // length
  inset: 1em, // length
  header-inset: 0.5em, // length
  breakable: true,
) = {
  // Set default color:
  let stroke-color = luma(70);
  let bg-color = stroke-color.lighten(85%);
  let border-color = bg-color.darken(10%); // gray.lighten(20%);
  let border-width = 0.5pt;

  // setting bg and stroke color from color argument
  if (type(_color) == color) { 
    stroke-color = _color;
    bg-color = _color.lighten(85%);
    border-color = bg-color.darken(10%);
  } else if (type(_color) == dictionary) {
    if (_color.keys().contains("stroke")) {
      assert(type(_color.stroke) == color, message: "stroke must be of type color");
      stroke-color = _color.stroke;
    }
    if (_color.keys().contains("bg")) {
      assert(type(_color.bg) == color, message: "bg must be of type color");
      bg-color = _color.bg;
      border-color = bg-color.darken(10%);
    }
        if (_color.keys().contains("border")) {
      assert(type(_color.border) == color, message: "border must be of type color");
      border-color = _color.border;
    }
  } else if (type(_color) == gradient) {
    stroke-color = _color;
    bg-color = _color;
  } else {
    panic("No valid color type. Use a gradient, color, or specify a dict with (stroke, bg)");
  }


  // Disable Heading numbering for those headings
  set heading(numbering: none, outlined: false, supplement: "Box")

  let header = rect(
          fill: bg-color,
          width: 100%,
          radius: (top-right: radius),
          inset: header-inset,
          stroke: (right: border-width + bg-color )
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

  let content-box(content) = block(
      breakable: breakable,
      width: 100%,
      fill: white, 
      inset: inset, 
      radius: (
        top-left: 0pt,
        bottom-left: 0pt, 
        top-right: if (title != none){0pt} else {radius},
        rest: radius
      ),
    )[#content]
  
  block(
    breakable: breakable,
    width: width,
    inset: (left: 1pt),
    radius: (right: radius, left: 0pt),
    stroke: (
      left: (thickness: 2pt, paint: stroke-color, cap: "butt"),
      top: if (title != none){border-width + bg-color} else {border-width + border-color},
      rest: border-width + border-color,
    ),
  )[
    #set align(start)
    #stack(dir: ttb,
    if title != none { header; },
    content-box(content)
    )
  ]
}


// Predefined gentle clues
#let get_title_for(clue) = {
  assert.eq(type(clue),str);
  locate(loc => {
    let lang = gc_header-title-lang.at(loc)
    title_dict.at(clue).at(lang)
  })
}

#let increment_task_counter() = {
    locate(loc => {
    if (gc_enable-task-counter.at(loc) == true){
      gc_task-counter.step()
    }
  })
}

#let get_task_number() = {
  locate(loc => {
    if (gc_enable-task-counter.at(loc) == true){
      " " + gc_task-counter.display()
    }
  })
}


/* info */
#let info(title: auto, icon: "assets/info.svg", ..args) = clue(
  _color: rgb(29, 144, 208), // blue
  title: if (title != auto) { title  } else { get_title_for("info") }, 
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
