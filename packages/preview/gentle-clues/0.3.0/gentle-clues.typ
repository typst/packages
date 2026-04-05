// color profiles
#let color_profiles = (
  gray:   (border: luma(70),          bg: luma(230)),
  blue:   (border: rgb(29, 144, 208), bg: rgb(232, 246, 253)),
  green:  (border: rgb(102, 174, 62), bg: rgb(235, 244, 222)),
  red:    (border: rgb(237, 32, 84),  bg: rgb(255, 231, 236)),
  yellow: (border: rgb(255, 201, 23), bg: rgb(252, 243, 207)),
  purple: (border: rgb(158, 84, 159), bg: rgb(241, 230, 241)),
  teal:   (border: rgb(0, 191, 165),  bg: rgb(229, 248, 246)),
  orange: (border: rgb(255, 145, 0),  bg: rgb(255, 244, 229)),
  readish: (border: rgb(255, 82, 82),  bg: rgb(253, 228, 224)),
  blueish:(border: rgb(0, 184, 212),  bg: rgb(229, 248, 251)),
  grayish:(border: rgb(158, 158, 158),bg: rgb(245, 245, 245)),
  greenish:(border: rgb(0, 143, 115),bg: rgb(221, 243, 231)),
  purpleish: (border: rgb(124, 77, 255), bg: rgb(242, 237, 255)),
)

#let gc_header-title-lang = state("lang", "en")

#let title_dict = (
  abstract: (de: "Einführung", en: "Abstract"),
  info: (de: "Info", en: "Info"),
  question: (de: "Frage", en: "Question"),
  memo: (de: "Merke", en: "Memorize"),
  task: (de: "Aufgabe", en: "Task"),
  conclusion: (de: "Zusammenfassung", en:"Conclusion"),
  tip: (de: "Tipp", en: "tip"),
  success: (de: "Erledigt", en: "Success"),
  warning: (de: "Achtung", en: "Warning"),
  error: (de: "Fehler", en: "Error"),
  example: (de: "Beispiel", en: "Example"),
  quote: (de: "Zitat", en: "Quote"),
)

/*
  Basic gentle-clue (clue) template
*/
#let clue(
  content, 
  title: none, // string or none
  icon: "assets/flag.svg", // file or symbol
  _color: "gray", // color profile name
  width: auto, // length
  radius: 2pt, // length
  inset: 1em, // length
  header-inset: 0.5em, // length

) = {
  // Set default color:
  let stroke-color = color_profiles.at("gray").border;
  let bg-color = color_profiles.at("gray").bg;
  let border-color = luma(200);

  // setting bg and stroke color from color argument
  if (type(_color) == str) {
    assert(color_profiles.at(_color, default: none) != none, message: "No valid color value. See color-profiles for available options.")
    stroke-color = color_profiles.at(_color).border
    bg-color = color_profiles.at(_color).bg;
  } else if (type(_color) == color) { 
    stroke-color = _color;
    bg-color = _color.lighten(50%);
  } else if (type(_color) == dictionary) {
    if (_color.keys().contains("stroke")) {
      assert(type(_color.stroke) == color, message: "stroke must be of type color");
      stroke-color = _color.stroke;
    }
    if (_color.keys().contains("bg")) {
      assert(type(_color.bg) == color, message: "bg must be of type color");
      bg-color = _color.bg;
    }
  } else {
    panic("No valid color type. Use a color-profile string or specify a dict with (stroke, bg)");
  }

  // Disable Heading numbering for those headings
  set heading(numbering: none, outlined: false, supplement: "Box")

  let header = rect(
          fill: bg-color,
          width: 100%,
          radius: (top-right: radius),
          inset: header-inset,
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

  let content-box(content) = box(
      width: 100%,
      fill: white, 
      inset: inset, 
      radius: (bottom-left: 0pt, rest: radius)
    )[#content]
  
  box(
    width: width,
    inset: (left: 1pt),
    radius: (right: radius, ),
    stroke: (
      left: (thickness: 2pt, paint: stroke-color, cap: "butt"), 
      top: if (title != none){0.1pt + bg-color} else {0.1pt + border-color},
      rest: 0.1pt + border-color,
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


/* info, note */
#let info(title: auto, icon: "assets/info.svg", ..args) = clue(
  _color: blue,
  title: if (title != auto) { title  } else { get_title_for("info") }, 
  icon: icon, 
  ..args
)
#let note = info

/* success, check, done */
#let success(title: auto, icon: "assets/checkbox.svg", ..args) = clue(
  _color: "green", 
  title: if (title != auto) { title  } else { get_title_for("success") }, 
  icon: icon, 
  ..args
)
#let check = success
#let done = success

/* warning, attention, caution */
#let warning(title: auto, icon: "assets/warning.svg", ..args) = clue(
  _color: "orange", 
  title: if (title != auto) { title  } else { get_title_for("warning") }, 
  icon: icon, 
  ..args
)
#let attention = warning
#let caution = warning

/* error, failure */
#let error(title: auto, icon: "assets/crossmark.svg", ..args) = clue(
  _color: "red", 
  title: if (title != auto) { title  } else { get_title_for("error") },
  icon: icon, 
  ..args
)
#let failure = error

/* task */
#let task(title: auto, icon: "assets/task.svg", ..args) = clue(
  _color: "purple", 
  title: if (title != auto) { title  } else { get_title_for("task") }, 
  icon: icon, 
  ..args
)
#let todo = task

/* tip, hint, important */
#let tip(title: auto, icon: "assets/tip.svg", ..args) = clue(
  _color: "teal", 
  title: if (title != auto) { title  } else { get_title_for("tip") },
  icon: icon, 
  ..args
)
#let hint = tip
#let important = tip 

/* abstract, summary, tldr */
#let abstract(title: auto, icon: "assets/abstract.svg", ..args) = clue(
  _color: "purpleish", 
  title: if (title != auto) { title  } else { get_title_for("abstract") }, 
  icon: icon, 
  ..args
)

/* conclusion, idea */
#let conclusion(title: auto, icon: "assets/lightbulb.svg", ..args) = clue(
  _color: "yellow", 
  title: if (title != auto) { title  } else { get_title_for("conclusion") }, 
  icon: icon, 
  ..args
)
#let idea = conclusion

/* memorize, remember */
#let memo(title: auto, icon: "assets/excl.svg", ..args) = clue(
  _color: "readish", 
  title: if (title != auto) { title  } else { get_title_for("memo") }, 
  icon: icon, 
  ..args
)
#let remember = memo

/* question, faq, help */
#let question(title: auto, icon: "assets/questionmark.svg", ..args) = clue(
  _color: "greenish", 
  title: if (title != auto) { title  } else { get_title_for("question") }, 
  icon: icon, 
  ..args
)
#let faq = question
#let help = question

/* quote */
#let quote(title: auto, icon: "assets/quote.svg", ..args) = clue(
  _color: "gray", 
  title: if (title != auto) { title  } else { get_title_for("quote") }, 
  icon: icon, 
  ..args
)

/* example */
#let example(title: auto, icon: "assets/example.svg", ..args) = clue(
  _color: (bg: orange.lighten(50%), stroke: orange), 
  title: if (title != auto) { title  } else { get_title_for("example") }, 
  icon: icon, 
  ..args
)
