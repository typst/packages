#let _description-state = state("description-state", ().to-dict() )

#let _on-stage = state("_on-stage", ().to-dict())
#let _theme = state("_stagehand-theme", none)
#let _blockage-indent = state("stagehand-blockage-indent", none)
#let _speaker-function = state("stagehand-speaker-function", none)
#let _using-presence = state("stagehand-presence", false)

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

#let centered(body) = align(center, par(hanging-indent: 0pt, body))

#let todo(body) = [#body<todo>]

#let enter(role: auto, body) = {
  _using-presence.update(true)
  if role == auto {
    role = body
  }
  role = to-string(role).replace(" ", sym.space.nobreak)
  context{
  if _on-stage.get().at(role, default: false) {
    todo[#role is already on stage when entering.]
  }}
  _on-stage.update(it => {
    let c = it.pairs().to-dict()
    c.insert(role, true)
    return c
  })
  [#metadata(role)<silent_speaker>]
  smallcaps(body)
}

#let exit(role: auto, body) =  {
  _using-presence.update(true)
  if role == auto {
    role = body
  }
  role = to-string(role).replace(" ", sym.space.nobreak)
  context{
  if not on-stage.get().at(role, default: false) {
    todo[#role is not on stage when exiting.]
  }}
  on-stage.update(it => {
    let c = it.pairs().to-dict()
    c.insert(role, false)
    return c
  })
  smallcaps(body)
}

#let exeunt-all() = {
  _using-presence.update(true)
  on-stage.update((:))
}

#let longest-speaker() = context{
  query(selector(<speaker>))
    .map(s => to-string(s))
    .fold("", (longest, current) =>
      if current.len() > longest.len() { current } else { longest }
    )

}

#let stage-direction(blocked: true, body) = context {
  let indent-width = calc.min((measure(
        _speaker-function.get()([#longest-speaker():])
      ).width + 1em).to-absolute(), _blockage-indent.get().to-absolute())

  if blocked {
    align(if _theme.get() == "blockage" {left} else {center}, box(width: if _theme.get() == "blockage" {90%} else {70%})[
      #block(spacing: (0.0em))[
        #align(left)[
          #par(justify: true, spacing: 0.0em)[
            #context{if _theme.get() == "blockage"  {h(indent-width)}}
            #body #label("_stage-direction")
            ]
          ]
        ]
      ]
    )
  } else {
    [#body #label("_stage-direction")]
  }
}



#let descriptions(..roles) = {
  let all-descriptions = ().to-dict()
  for role in roles.pos() {
    let name = role.at("name").replace(" ", sym.space.nobreak)
    all-descriptions.insert(name, role)
  }
  _description-state.update(all-descriptions)
}



#let stagehand(
  lang: "en",
  title: none,
  descriptor: none,
  authors: none,
  font: "Libertinus Serif",
  font-size:14pt,
  toc: true,
  dramatis-personae: true,
  props: true,
  todos: true,

  speaker-layout:"blockage",
  blockage-indent: 10em,
  speaker-function: smallcaps,
  break-size: 900,
  parentheses-mean-stage-directions: true,
  stage-direction-color: gray,
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
  assert(speaker-layout in ("fancy", "concise", "blockage"),
  message: "speaker-layout must be fancy, concise or blockage")
  assert(
    type(custom-localization) == dictionary or custom-localization == none,
    message: "A custom localization must be a dictionary or 'none'")
  assert(
    type(stage-direction-color) == color,
    message: "Stage direction color must be of type 'color' "
  )
  assert(type(speaker-function) == function,
    message: "Speaker function must be a function")
  _theme.update(speaker-layout)
  _blockage-indent.update(blockage-indent)
  _speaker-function.update(_ => speaker-function)

  let title-case(string) = {
    return string.replace(
      regex("[A-Za-z]+('[A-Za-z]+)?"),
      word => upper(word.text.first()) + lower(word.text.slice(1)),
    )
  }

  show <_stage-direction>: set text(style: "italic", stage-direction-color)

  let fallback_dicionary = (
    w-and: "and",
    w-by: "by",
    w-of: "of",
    prop-title: "Props",
    todo-title: "TODOs",
    dramatis-personae-title: "Dramatis Personae",
    act-title: "Act",
    scene-title: "Scene",
    appendix-title: "Appendix",
    already-on-stage: "Already on stage",
  )

  let primary_dictionary = {
    if lower(lang) == "de" {
      (
        w-and: "und",
        w-by: "von",
        w-of: "von",
        prop-title: "Requisiten",
        todo-title: "TODOs",
        dramatis-personae-title: "Figuren",
        act-title: "Akt",
        scene-title: "Szene",
        appendix-title: "Anhang",
        already-on-stage: "Bereits auf der Bühne",
      )
    } else if lower(lang) == "it" {
      (
        w-and: "e",
        w-by: "di",
        w-of: "di",
        prop-title: "Oggetti di scena",
        todo-title: "TODOs",
        dramatis-personae-title: "Personaggi",
        act-title: "Atto",
        scene-title: "Scena",
        appendix-title: "Appendice",
        already-on-stage: "Già sul palco"
      )
    } else if lower(lang) == "es" {
      (
        w-and: "y",
        w-by: "por",
        w-of: "de",
        prop-title: "Utilería",
        todo-title: "TODOs",
        dramatis-personae-title: "Personajes",
        act-title: "Acto",
        scene-title: "Escena",
        appendix-title: "Apéndice",
        already-on-stage: "Ya en el escenario"
      )
    } else if lower(lang) == "en" {
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

  let currently-on-stage() = {if _using-presence.final() {
    context[
        #stage-direction[
        #localization("already-on-stage")
        #{_on-stage.get().pairs()
          .filter(pair => pair.at(1))
          .map(pair => pair.at(0))
          .join(", ", last: " und ", default: "Niemand.")}
          \
          \
        ]
      ]
    } else {none}
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
          counter(page).display((a, b) => [#a #localization("w-of") #b], both:true)
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
                  par(justify: false, hanging-indent: 0em,
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
                      let tagged-speakers = query(selector(<tagged_speaker>)
                        .after(start_scene.location())
                        .before(end_scene.location()))
                        .map(s => s.value)
                        .flatten()
                        .map(s => to-string(s))
                        .dedup()
                      tagged-speakers.join(", ")
                      let silent-speakers = query(selector(<silent_speaker>)
                        .after(start_scene.location())
                        .before(end_scene.location()))
                        .map(s => s.value)
                        .flatten()
                        .map(s => to-string(s))
                        .filter(s => s not in tagged-speakers)
                        .dedup()
                      silent-speakers += _on-stage.at(start_scene.location())
                        .pairs()
                        .filter(pair => pair.at(1))
                        .map(pair => pair.at(0))
                        .filter(role => role not in tagged-speakers + silent-speakers)
                      if silent-speakers.len() > 0 [,
                       (#silent-speakers.join(", "))
                      ]
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
    } else if speaker-layout == "blockage"{
        let indent-width = calc.min(
          blockage-indent.to-absolute(),  (measure(
          speaker-function[#longest-speaker():]
        ).width + 1em).to-absolute()
        ) - measure(speaker-function[#it:]
        ).width - measure([:]).width

        speaker-function[

          #it:#h(calc.max(indent-width, 0pt))]
    }
  }

  show <parenthetical>: it => {
    if speaker-layout == "fancy" {
      align(center)[
        #block(sticky: true, below:0.65em)[
          #stage-direction(blocked: false)[(#it)]
        ]
      ]
    } else if speaker-layout == "concise" or speaker-layout == "blockage"{
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
      let rolenames = query(<tagged_speaker>)
            .map(t => t.value)
            .flatten()
            .dedup()
      if (rolenames.len() > 0) {
        page(header: none, footer: none)[
          #heading(numbering: none, localization("dramatis-personae-title"))
          \
          #{
            let groups = ().to-dict()

            for rolename in rolenames {
              let detailed-role = _description-state.get().at(rolename, default:(name:rolename))
              let group-name = detailed-role.at("group", default: "None")
              if group-name not in groups {
                groups.insert(group-name, ())
              }
              groups.at(group-name).push(detailed-role)
            }

            show table.cell.where(x: 1): align.with(center)
            show table.cell.where(x: 2): align.with(right)
            show table.cell.where(x: 1): it => emph(text(gray, it))

            for group-name in groups.keys() {
              align(center, strong(
                if group-name != "None" {group-name} else {none}
              ))
              let cells = ()
              for role in groups.at(group-name) {
                cells.push(role.name)
                cells.push(role.at("desc", default: none))
                cells.push(role.at("actor", default: none))
                //cells.push()
              }

              table(columns:(1fr, 1fr, 1fr), stroke:none,
                ..cells
              )
            }
          }
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

  show heading.where(level: 2): it => {
    let nums = counter(heading).get().at(1)
    it
    if (nums != 1 and _using-presence.final()) {
      text(font-size, weight: "regular", currently-on-stage())
    }
  }



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

  show <tagged_speaker>: it => if _using-presence.final() {context {
    for name in it.value {
      if not _on-stage.get().at(name, default: false) {
        todo[#name is not on stage.]
      }
    }
  }}

  context {
    let indent-width = (measure(
      speaker-function[#longest-speaker():]
    ).width + 1em).to-absolute()
    
    set par(
      justify: true,
      linebreaks: "optimized",
      hanging-indent: if speaker-layout == "blockage" { calc.min(blockage-indent.to-absolute(), indent-width) } else { 0em },
    )

    play
  }

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
      //todos-list.map(it => link(it.location(), to-string(it))).join("\n")
        if todos-list.len() > 0 [
            == #localization("todo-title"):
            #{
              todos-list.map(it => [#link(it.location(), to-string(it))
              #box(width: 1fr)[#line(length: 100%, stroke: (dash: "loosely-dotted"))]
              #numbering("1", counter(page).at(it.location()).first())
            ]).join("\n") + "\n"
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


