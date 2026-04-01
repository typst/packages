#let stage-direction(blocked: true, body) = {
  if blocked {
    align(center, box(width: 70%)[
      #block(spacing: (0.0em))[
        #align(left)[
          #par(justify: true, spacing: 0.0em)[
            #text(style: "italic", gray)[#body]
            ]
          ]
        ]
      ]
    )
  } else {
    text(style: "italic", gray)[#body]
  }
}

#let to-string(it) = {
  if it == none {
    none
  }
  else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    ""
  }
}

#let stagehand(
  lang:"en",
  title: none,
  descriptor: none,
  authors: none,
  font: "Libertinus Serif",
  font-size:14pt,
  toc: true,
  dramatis-personae: true,
  props: true,
  todos: true,

  speaker-layout:"fancy",
  speaker-function: smallcaps,
  break-size: 900,
  parentheses-mean-stage-directions: true,
  has-header:true,
  has-footer: true,
  speakers-in-header: true,
  custom-localization: none,
  chapter-settings: (
    (title: auto, numbering: "I", pagebreak:true),
    (title: auto, numbering: "1", pagebreak: true),
  ),
  play
) = {
  assert(speaker-layout in ("fancy", "concise"),
  message: "speaker-layout must be fancy or concise")
  assert(
    type(custom-localization) == dictionary or custom-localization == none,
    message: "A custom localization must be a dictionary or 'none'")

  let title-case(string) = {
    return string.replace(
      regex("[A-Za-z]+('[A-Za-z]+)?"),
      word => upper(word.text.first()) + lower(word.text.slice(1)),
    )
  }

  let fallback_dicionary = (
    w-and: "and",
    w-by: "by",
    prop-title: "Props",
    todo-title: "TODOs",
    dramatis-personae-title: "Dramatis Personae",
    act-title: "Act",
    scene-title: "Scene",
    appendix-title: "Appendix"
  )

  let primary_dictionary = {
    if lang == "de" {
      (
        w-and: "und",
        w-by: "von",
        prop-title: "Requisiten",
        todo-title: "TODOs",
        dramatis-personae-title: "Figuren",
        act-title: "Akt",
        scene-title: "Szene",
        appendix-title: "Anhang"
      )
    } else if lang == "it" {
      (
        w-and: "e",
        w-by: "di",
        prop-title: "Oggetti di scena",
        todo-title: "TODOs",
        dramatis-personae-title: "Personaggi",
        act-title: "Atto",
        scene-title: "Scena",
        appendix-title: "Appendice",
      )
    } else if lang == "en" {
      fallback_dicionary
    } else {
      fallback_dicionary
    }
  }

  if type(custom-localization) == dictionary {
    primary_dictionary += custom-localization
  }

  let localization(key) = {
    if primary_dictionary.keys().contains(key) {
      return primary_dictionary.at(key)
    } else {
      return fallback_dicionary.at(key)
    }
  }

  let pretty_print_heading(level, c) = {
    assert(level <= chapter-settings.len(),
      message:"There is no chapter title defined for level " + str(level))
    let nums = c.at(level - 1, default: none)
    let title_name = chapter-settings.at(level - 1).at("title", default: auto)
    if title_name == auto {
      if level == 1 {
        title_name = localization("act-title")
      } else if level == 2 {
        title_name = localization("scene-title")
      } else {
        title_name = none
      }
    }
    if nums != none and nums > 0 {
      return [
        #title_name
        #numbering(chapter-settings.at(level - 1).at("numbering", default: "1"), nums)
      ]
    }
  }

  if title != none {
    set document(title: title)
  }

  set page(
    margin: (top:if has-header {7.5em} else {5em}, rest:1in),
    footer: if has-footer {
      context{
        [
          #line(length:100%)
          #label("page_end" + str(here().page()))
        ]
        align(
          center,
          counter(page).display((a, b) => [#a von #b], both:true)
        )
      }
    },
      header: if has-header {
        context {
          grid(columns:(1fr,2fr, 1fr),
            align(left + bottom,
              pretty_print_heading(1,
                counter(heading).at(
                  label("page_end" + str(here().page()))
                )
              )
            ),
            if speakers-in-header {
              pad(bottom:-8pt,
                align(center + top,
                  par(justify: false,
                    text(size: 11pt, hyphenate:false, {
                      let end_scene
                      let start_scene
                      let next_scene = query(heading.where(level: 2).after(here()))
                      if next_scene.len() > 0 {
                        if next_scene.first().location().page() == here().page() {
                          if next_scene.len() > 1 {
                            end_scene = next_scene.at(1)
                          }
                        } else {
                            end_scene = next_scene.first()
                          }
                      }
                      if end_scene == none {
                        end_scene = query(<end_of_play>).first()
                        start_scene = query(heading.where(level: 2)
                          .before(end_scene.location(), inclusive: false)
                        ).at(-1, default: none)
                      } else {
                        start_scene = query(heading.where(level: 2)
                          .before(end_scene.location(), inclusive: false)
                        ).at(-1, default: none)
                      }
                      if start_scene == none {
                        start_scene = query(<start_of_play>).first()
                      }
                      query(selector(<tagged_speaker>)
                        .after(start_scene.location())
                        .before(end_scene.location()))
                        .map(s => s.value)
                        .flatten()
                        .map(s => to-string(s))
                        .dedup().join(", ")
                    })
                  )
                )
              )
            },
            align(right,
              pretty_print_heading(2,
              counter(heading).at(
                label("page_end" + str(here().page()))
              )
            )
          )
        )
        line(length: 100%)
      }
    } else {
      none
    },
  )

  set text(
    font: font,
    size: font-size,
    lang: lang,
  )

  set heading(numbering: "I - 1")

  show heading: set align(center)

  //TODO Nur unterstes Level outlinen
  //show heading.where(level:1): set heading(outlined: false)



  show <speaker>: it => {
    if speaker-layout == "fancy" {
      align(center)[
        #block(sticky: true, below:0.65em,
          speaker-function[#it]
        )
      ]
    } else if speaker-layout == "concise"{
      speaker-function[

        #it:]
    }
  }

  show <parenthetical>: it => {
    if speaker-layout == "fancy" {
      align(center)[
        #block(sticky: true, below:0.65em)[
          #stage-direction(blocked: false)[(#it)]
        ]
      ]
    } else if speaker-layout == "concise" {
      stage-direction(blocked: false)[(#it)]
    }
  }

  show <todo>: it => {
    if todos {
      box(fill:yellow, inset: 5pt, stroke: stroke(paint: red, thickness:2pt))[
        _#it _
      ]
    }
  }

  //if parentheses-mean-stage-directions {
  show regex("\\([^)]+\\)"): it => {
    if parentheses-mean-stage-directions {
      stage-direction(blocked: false, it)
    } else {it}
  }


  //Title page
  if title != none or descriptor != none or authors != none {
    page(numbering: none, header: none, footer: none)[
      #set text(size:16pt)
      #align(center)[
        #context {
          v(15%)
          if (title != none) {
            let title-box = box(text(size:25pt, smallcaps(title)))
            title-box
            let title-size = measure(title-box)
            let descriptor-size = measure(descriptor)
            let size = calc.max(title-size.width, descriptor-size.width)
            line(length: size + 50pt)
          }

          emph(descriptor)

          if (authors != none) {
            block(width: 50%)[
              #title-case(localization("w-by"))
              #if type(authors) == str {
                authors
              } else {
                authors.join(", ", last: [ #localization("w-and") ])
              }
            ]
          }
        }
      ]
    ]
  }
  if toc {
    context {
      if query(heading).len() > 0 {
        page(header: none, footer:none, {
          set text(size: 13pt)
          show heading: it => it.body
          outline()
        })
      }
    }
  }

  if dramatis-personae {
    context {
      let roles = query(<tagged_speaker>)
            .map(t => t.value)
            .flatten()
            .dedup()
      if (roles.len() > 0) {
        page(header: none, footer: none)[
          #heading(numbering: none, localization("dramatis-personae-title"))
          \
          #list(..roles)
        ]
      }
    }
  }

  show heading: it => underline({
    assert(it.level <= chapter-settings.len(),
      message:"There is no chapter title defined for level " + str(it.level))

      let nums = counter(heading).get().at(it.level - 1)
      if chapter-settings.at(it.level - 1).at("pagebreak", default: false) {
        if nums > 1 {
          pagebreak(weak:true)
        }
      }

      block(sticky: true, {
        pretty_print_heading(it.level, counter(heading).get())
        if to-string(it.body) != none {
          [ -- #it.body]
        }
      })
    }
  )



  set par(justify: true, linebreaks: "optimized",)

  show par: it => {
    let content = to-string(it.body)
    let characters = 0
    if type(content) == str{
      characters = content.len()
    }
    block(breakable: characters > break-size)[#it]
  }

  [#v(0pt)<start_of_play>]
  play

  [#v(0pt)<end_of_play>]
  set page(header: none, footer: none)
  show heading: it => {
    context{
    if it.level == 1 or counter(heading).get().at(1) > 1 {
      pagebreak()
    }
    }
    it.body
  }


  if props or todos {
    context {
      let props-list = query(selector(<prop>).before(<end_of_play>))
      let todos-list = query(selector(<todo>).before(<end_of_play>))
      if props-list.len() > 0 or todos-list.len() > 0 {[
        = #localization("appendix-title")
      ]
      if props {
        if props-list.len() > 0 [
            == #localization("prop-title"):
            #{
              props-list.map(it => [#link(it.location())[#it]
              #box(width: 1fr)[#line(length: 100%, stroke: (dash: "loosely-dotted"))]
              #numbering("1", counter(page).at(it.location()).first())
            ]).join("\n") + "\n"
            }
          ]
        }
      }
      if todos {
        if todos-list.len() > 0 [
          == #localization("todo-title"):
          #{
            todos-list.map(it => link(it.location())[#it]).join("\n")
          }
        ]
      }
    }
  }
}



#let speaker(name, p: none, t: auto) = {
  if t != false {
    if t == auto {
      t = name
    }
    if type(t) == content {
      t = to-string(t)
    }
    if type(t) == str {
      t = (t.replace(" ", sym.space.nobreak), )
    } else {
      t = t.map(it => {
        if type(it) == content {
          it = to-string(it)
        }
        return it.replace(" ", sym.space.nobreak)
      })
    }
  }
  [
    #name<speaker>
    #if t != false [#metadata(t)<tagged_speaker>]
    #if(p != none) [
        #p<parenthetical>
    ]
  ]
}


#let prop(body) = [#body<prop>]

#let todo(body) = [#body<todo>]
