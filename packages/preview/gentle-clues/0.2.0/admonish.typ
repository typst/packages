// color profiles
#let colors = (
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


/*
  Basic gentle-clue (admonish) template
*/
#let admonish(
  content, 
  title: none, // string or none
  icon: "assets/flag.svg", // file or symbol
  color: "gray", // color profile name
  width: auto, // length
  radius: 2pt, // length
  inset: 1em, // length
  header-inset: 1em, // 

) = {
  // Set default color:
  let stroke-color = colors.at("gray").border;
  let bg-color = colors.at("gray").bg;
  let border-color = luma(200);

  // setting bg and stroke color from color argument
  if (type(color) == "string") {
    assert(colors.at(color, default: none) != none, message: "No valid color value. See color-profiles for available options.")
    stroke-color = colors.at(color).border
    bg-color = colors.at(color).bg;
  } else if (type(color) == "dictionary") {
    if (color.keys().contains("stroke")) {
      assert(type(color.stroke) == "color", message: "stroke must be of type color");
      stroke-color = color.stroke;
    }
    if (color.keys().contains("bg")) {
      assert(type(color.bg) == "color", message: "bg must be of type color");
      bg-color = color.bg;
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


/* info, note */
#let info(title: "Info", icon: "assets/info.svg", ..args) = admonish(color: "blue", title: title, icon: icon, ..args)
#let note = info

/* success, check, done */
#let success(title: "Success", icon: "assets/checkbox.svg", ..args) = admonish(color: "green", title: title, icon: icon, ..args)
#let check = success
#let done = success

/* warning, attention, caution */
#let warning(title: "Warning", icon: "assets/warning.svg", ..args) = admonish(color: "orange", title: title, icon: icon, ..args)
#let attention = warning
#let caution = warning

/* error, failure */
#let error(title: "Error", icon: "assets/crossmark.svg", ..args) = admonish(color: "red", title: title, icon: icon, ..args)
#let failure = error

/* task */
#let task(title: "Task", icon: "assets/task.svg", ..args) = admonish(color: "purple", title: title, icon: icon, ..args)
#let todo = task

/* tip, hint, important */
#let tip(title: "Tip", icon: "assets/tip.svg", ..args) = admonish(color: "teal", title: title, icon: icon, ..args)
#let hint = tip
#let important = tip 

/* abstract, summary, tldr */
#let abstract(title: "Abstract", icon: "assets/abstract.svg", ..args) = admonish(color: "purpleish", title: title, icon: icon, ..args)

/* conclusion, idea */
#let conclusion(title: "Conclusion", icon: "assets/lightbulb.svg", ..args) = admonish(color: "yellow", title: title, icon: icon, ..args)
#let idea = conclusion

/* memorize, remember */
#let memo(title: "Memo", icon: "assets/excl.svg", ..args) = admonish(color: "readish", title: title, icon: icon, ..args)
#let remember = memo

/* question, faq, help */
#let question(title: "Question", icon: "assets/questionmark.svg", ..args) = admonish(color: "greenish", title: title, icon: icon, ..args)
#let faq = question
#let help = question

/* quote */
#let quote(title: "Quote", icon: "assets/quote.svg", ..args) = admonish(color: "gray", title: title, icon: icon, ..args)

/* example */
#let example(title: "Example", icon: "assets/example.svg", ..args) = admonish(color: "purple", title: title, icon: icon, ..args)
