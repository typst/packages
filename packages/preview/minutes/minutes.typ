#let noun(it) = [#text(features: ("smcp", ), tracking: 0.025em)[#it]] //small caps with proper tracking
#let versal(it) = [#text(tracking: 0.125em, number-type: "lining")[#upper[#it]]] //all caps with proper tracking
#let lang(it, content) = [#text(lang: it, style: "italic")[#content]] //change the language for a word or two or a longer period for language appropriate smartquotes and stuff. Also italicises the foreign text

#let minutes(
  body-name: none, // Name of the body holding the protocolled meeting
  event-name: none, // Name of the meeting
  date: none, // Date of the meeting (auto for current date, datetime for formatted date)
  present: (), // Dictionary with names of present people
  chairperson: none, // Name of the person chairing the meeting // More then one person possible?
  secretary: none, // Name of the person taking minutes // More then one person possible?
  awareness: none, // Name of the person responsible for awareness // More then one person possible?
  translation: none, // Name of the person responsible for translating // More then one person possible?

  cosigner: none, // Position of the Person signing the protocoll, should they differ from the chairperson. Aditionally to the secretary.
  cosigner-name: none, // Name of the person signing the protocoll, should they differ from the chairperson. Aditionally to the secretary.

  name-format: (name) => [#name], // Format of names in the document
  item-numbering: none,
  time-format: none,
  date-format: none,

  timestamp-margin: 10pt,

  display-all-warnings: false, // shows all warnings directly beneath their occurence
  hide-warnings: false,
  line-numbering: 5, // none for no line numbering, int for every xth line numbered
  fancy-decisions: false, // draws a diagram underneath decisions
  fancy-dialogue: false, // splits dialogue up into paragraphs
  hole-mark: true, // Mark for the alignment of a hole punch
  separator-lines: true, // lines next to the titles
  signing: true, // Do people have to sign this document
  warning-color: red, // Color warnings are displayed in
  enable-help-text: false, // should a help/debug text with state info be shown
  title-page: false, // should the actual protocol start after a pagebreak
  number-present: false, // should the number of people present be shown
  show-arrival-time: true,
  
  locale: "en",
  translation-overrides: (:),
  
  body
) = {
  // Constants
  let status-present = "present"
  let status-away = "away"
  let status-away-perm = "away-perm"
  let status-none = "none"
  
  // Variables
  let warnings = state("warnings", (:))
  let pres = state("pres", ())
  let away = state(status-away, ())
  let away-perm = state(status-away-perm, ())
  let hours = state("hours", none)
  let last-time = state("last-time", none)
  let start-time = state("start-time", none)
  let arrival-times = state("arrival-times", (:))

  let help-text() = if (enable-help-text) {context[
    #set text(fill: blue)
    #block(breakable: false)[
      last-time: #last-time.get()

      #grid(columns: 3 * (1fr,),
        [
          present: #pres.get().len()\
          #pres.get().map(x => "    " + x).join("\n")\
        ],
        [
          away: #away.get().len()\
          #away.get().map(x => "    " + x).join("\n")\
        ],
        [
          gone: #away-perm.get().len()\
          #away-perm.get().map(x => "    " + x).join("\n")\
        ]
      )
    ]
  ]}

  // Localization
  let lang = json("lang.json")

  let translate(key, ..args) = {
    let translation = lang.at(key).at(locale)

    if (translation-overrides.keys().contains(key)) {
      translation = translation-overrides.at(key)
    }

    for arg in args.pos().enumerate() {
      translation = translation.replace("[" + str(arg.at(0)) + "]", str(arg.at(1)))
    }
    
    return translation
  }

  // Defaults
  if (item-numbering == none) {
    item-numbering = (..nums) => [#translate("ITEM") #numbering(translate("DEFAULT_ITEM_NUMBERING"), ..nums)]
  }
  if (time-format == none) {
    time-format = translate("DEFAULT_TIME_FORMAT")
  }
  if (date-format == none) {
    date-format = translate("DEFAULT_DATE_FORMAT")
  }

  // Helpers
  let render-warnings(list: none) = {
    if (hide-warnings) {
      return
    }
    let end-list = list == none
    context {
      let list = if (list != none) {
        list
      } else {
        warnings.get().values()
      }
      if (list.len() < 1) {return}
      align(center)[
        #set par.line(
          number-clearance: 200pt
        )
        #if (end-list) [
          #set text(fill: warning-color)
          Warnings:
        ]
        #block(stroke: warning-color, inset: 1em, radius: 1em, fill: warning-color.transparentize(80%))[
          #set align(left)
          #grid(
            row-gutter: 1em,
            ..list.map(x => link(x.at(1), if (end-list) {
              [Page #str(x.at(1).page())/*, Line #x.at(1).line()*/: ]
            } + x.at(0)))
          )
        ]
      ]
    }
  }
  
  let add-warning(text, id: none, display: false) = [
    #context [
      #let location = here()
      #warnings.update(x => {
        let id = if (id == none) {str(x.len())} else {id}
        if (not x.keys().contains(id)) {
          x.insert(id, (text, location))
        }
        return x
      })
      #if (display or display-all-warnings) [
        #render-warnings(list: ((text, location),))
      ]
    ]
  ]

  let remove-warning(id) = [
    #warnings.update(x => {
      x.remove(x.position(x => x == id))
      return x
    })
  ]

  let four-digits-to-time(time-string, error: true) = {
    if (int(time-string.slice(0, 2)) > 24 or int(time-string.slice(2)) > 60) {
      [#time-string.slice(0, 2):#time-string.slice(2)]
      if (error) {
        add-warning(four-digits-to-time(time-string, error: false) + " is not a valid time")
      }
    } else {
      let time = datetime(hour: int(time-string.slice(0, 2)), minute: int(time-string.slice(2)), second: 0)
      [#time.display(time-format)]
    }
  }
  
  let format-time(time-string, display: true, hours-manual: none) = [
    #context [
      #let time-string = time-string.replace(" ", "").replace(":", "")
      
      #assert(time-string.match(regex("[0-9]+")) != none, message: "Invalid Time Format \"" + time-string + "\"")
      
      #if (time-string.len() == 1) {
        time-string = if (hours-manual == none) {hours.get()} else {hours-manual} + "0" + time-string
      } else if (time-string.len() == 2) {
        time-string = if (hours-manual == none) {hours.get()} else {hours-manual} + time-string
      } else {
        if (time-string.len() == 3) {
          time-string = "0" + time-string
        }
        
        assert(time-string.len() == 4, message: "Invalid Time Format \"" + time-string + "\"")
        
        hours.update(time-string.slice(0, 2))
      }

      #if (display) {
        four-digits-to-time(time-string)
      }

      #if (last-time.get() != none and int(time-string) < int(last-time.get()) and hours-manual != none) {
        add-warning(four-digits-to-time(time-string) + " is logged after " + four-digits-to-time(str(last-time.get())))
      }
      #last-time.update(time-string)

      #if (start-time.get() == none) {
        start-time.update(time-string)
      }
    ]
  ]
  
  let timed(time, it) = [
    #if (it == "") {
      format-time(time, display: false)
    } else {
      set par.line(
        number-clearance: 200pt
      )
      block(
        width: 100%,
        inset: (left: -2cm-timestamp-margin),
      )[
        #grid(
          columns: (2cm, 1fr),
          column-gutter: timestamp-margin,
          align(right)[
            #v(0.05em)
            #text(10pt, weight: "regular")[
              #if (type(time) == content) [
                #time
              ] else [
                #format-time(time)
              ]
            ]
          ],
          it
        )
      ]
    }
  ]

  let format-name-no-context(name) = {
    if (not name.contains(",") and name.contains(" ")) {
      let name_parts = name.split(" ")
      name = name_parts.at(-1) + ", " + name_parts.slice(0, -1).join(" ")
    }
    return name
  }

  let format-name(name) = {
    if (not name.contains(",") and name.contains(" ")) {
      let all = pres.at(<end-time>) + away.at(<end-time>) + away-perm.at(<end-time>)
      all.filter(x => x.contains(", "))
      
      let names = all.map(x => x.split(", ").at(1))
      if (names.contains(name)) {
        return all.at(names.position(x => x == name))
      }
      let names = all.map(x => {
        let split = x.split(", ")
        return split.at(1) + " " + split.at(0)
      })
      
      if (names.contains(name)) {
        return all.at(names.position(x => x == name))
      }
      
      let name_parts = name.split(" ")
      name = name_parts.at(-1) + ", " + name_parts.slice(0, -1).join(" ")
    }
    return name
  }

  let get-status(name) = {
    if (pres.get().contains(name)) {
      return status-present
    } else if (away.get().contains(name)) {
      return status-away
    } else if (away-perm.get().contains(name)) {
      return status-away-perm
    }
    return status-none
  }
  
  // Inline functions
  let join(time, name, long: false) = [
    #context [
      #let name = format-name(name)
      
      #timed(time)[
        #let x-of-y = "(" + str(pres.get().len() + 1) + " / " + str(pres.get().len() + 1 - away.get().len() + if (long) {0} else {1}) + ")"
        _#name-format(name) #translate("JOIN" + if (long) {"_LONG"}, x-of-y)_
      ]

      #let status = get-status(name)
      #if (long) {
        if (status == status-away) {
          add-warning("\"" + name + "\" joined (++), but was just gone for a while (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name + "\" joined (++), but already left permanently (--)")
        } else {
          pres.update(x => {
            x.push(name)
            return x
          })
          let hours-manual = hours.get()
          arrival-times.update(x => {
            x.insert(name, format-time(time, hours-manual: hours-manual))
            return x
          })
        }
      } else {
        if (status != status-away) {
          add-warning("\"" + name + "\" joined (+), but was never away (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name + "\" joined (+), but already left permanently (--)")
        } else if (status == status-none) {
          add-warning("\"" + name + "\" joined (+), but is unaccounted for")
        } else {
          away.update(x => {
            x.remove(x.position(x => x == name))
            return x
          })
          pres.update(x => {
            x.push(name)
            return x
          })
        }
      }
    ]
  ]
  
  let leave(time, name, long: false) = [
    #context [
      #let name = format-name(name)
      
      #timed(time)[ 
        #let x-of-y = "(" + str(pres.get().len() - 1) + " / " + str(pres.get().len() - 1 + away.get().len() + if (long) {0} else {1}) + ")"
        _#name-format(name) #translate("LEAVE" + if (long) {"_LONG"}, x-of-y)_
      ]

      #let status = get-status(name)
      #if (long) {
        if (status == status-away) {
          away.update(x => {
            x.remove(x.position(x => x == name))
            return x
          })
          away-perm.update(x => {
            x.push(name)
            return x
          })
        } else if (status == status-away-perm) {
          add-warning("\"" + name + "\" left (--), but already left permanently (--)")
        } else if (status != status-present) {
          add-warning("\"" + name + "\" left (--), but was not present (+)")
        } else if (status == status-none) {
          add-warning("\"" + name + "\" left (--), but is unaccounted for")
        } else {
          pres.update(x => {
            if (x.contains(name)) {
              x.remove(x.position(x => x == name))
            }
            return x
          })
          away-perm.update(x => {
            x.push(name)
            return x
          })
        }
      } else {
        if (status == status-away) {
          add-warning("\"" + name + "\" left (-), but was away anyways (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name + "\" left (-), but already left permanently (--)")
        } else if (status != status-present) {
          add-warning("\"" + name + "\" left (-), but was not present (+)")
        } else if (status == status-none) {
          add-warning("\"" + name + "\" left (-), but is unaccounted for")
        } else {
          pres.update(x => {
            if (x.contains(name)) {
              x.remove(x.position(x => x == name))
            }
            return x
          })
          away.update(x => {
            x.push(name)
            return x
          })
        }
      }
    ]
  ]

  let dec(time, content, ..args) = [
    #set par.line(
      number-clearance: 200pt
    )
    #let values = ()
    #if (args.named().values().all(x => type(x) == array)) {
      values = args.named().keys().map(x => (
          name: x,
          value: int(args.named().at(x).at(0)),
          color: args.named().at(x).at(1),
        )
      )
    } else {
      values = args.named().keys().map(x => (
          name: x,
          value: int(args.named().at(x).at(0)),
        )
      )
    }
    #block(breakable: false)[
      #timed(time)[
        ===== #translate("DECISION")
      ]
      #content
      #let total = values.map(x => x.value).sum(default: 1)
        
      #if (fancy-decisions and values.at(0).keys().contains("color")) [
        #grid(
          gutter: 2pt,
          columns: values.map(x => 
            calc.max(if (x.value > 0) {0.2fr} else {0fr}, 1fr * (x.value / total))
          ),
          ..values.map(x =>
            grid.cell(
              fill: x.color.transparentize(80%),
              inset: 0.5em
            )[
              #if (x.value > 0) [*#x.name* #x.value]
            ]
          ),
        )
      ] else [
        #values.map(x => [*#x.name*: #str(x.value)]).join([, ])
      ]
      #context [
        #if (total != pres.get().len()) {
          add-warning(str(total) + " people voted, but " + str(pres.get().len()) + " were present", display: true)
        }
      ]
    ]
  ]

  let end(time) = [
    #set par.line(
      number-clearance: 200pt
    )
    #linebreak()
    #timed(time, [==== #translate("END")])
    #last-time.update(time)
    <end-time>
    #context {
      let count-away = away.get().len()
      if (count-away > 0) {
        add-warning(str(count-away) + " people are still away (-), but the document ended")
      }
    }
  ]

  // Regex
  let regex-time-format = "[0-9]{1,5}"
  let regex-name-format = "\p{Lu}[^ ]*( \p{Lu}[^ ]*)*"
  let default-format = regex-time-format + "/[^\n]*"

  let default-regex(keyword, function, body) = [
    #show regex(keyword.replace("+", "\+") + default-format): it => [
      #let text = it.text.slice(keyword.len())
      #let time = text.split("/").at(0)
      #let string = text.split("/").slice(1).join("/")
    
      #function(time, string)
    ]

    #body
  ]

  show: default-regex.with("+", join)
  show: default-regex.with("−", leave)
  show: default-regex.with("++", join.with(long: true))
  show: default-regex.with("–", leave.with(long: true))
  show: default-regex.with("", timed)

  show regex("/" + regex-time-format): it => {
    end(it.text.slice(1))
  }

  show regex("!" + regex-time-format + "/.*/(.*(|.*)?[0-9]+){2,}"): it => [
    #let text = it.text.slice(1)
    #let time = text.split("/").at(0)

    #let args = text.split("/").slice(2).enumerate().fold((:), (args, x) => {
      let label = x.at(1).replace(regex("[0-9]"), "")
      let value = x.at(1).replace(label, "")

      if (label != "" and label.at(-1) == " ") {
        label = label.slice(0,-1)
      }
      
      let color-string = none
      if (label.contains("|")) {
        color-string = label.split("|").at(1)
        label = label.replace("|" + color-string, "")
      }

      if (label == "") {
        label = str(x.at(0) + 1)
      }
      
      if (color-string != none) {
        args.insert(label, (value, eval(color-string)))
      } else {
        args.insert(label, value)
      }
      
      return args;
    })
    
    #let text = text.split("/").at(1)

    #if (args.len() == 3
      and args.keys().enumerate()
        .all(x => str(x.at(0) + 1) == x.at(1))
      and args.values()
        .all(x => type(x) != array)
    ) {
      let yes = args.values().at(0)
      let no = args.values().at(1)
      let abst = args.values().at(2)
      dec(time, text, Dafür: (yes, green), Dagegen: (no, red), Enthaltung: (abst, blue))
    } else {
      dec(time, text, ..args)
    }
  ]

  // Setup
  
  set page(
    header: [
      #if (date == none) {
        [XX.XX.XXXX]
        add-warning("date is missing", id: "DATE")
      } else if (date == auto) {
        [#datetime.today().display(date-format)]
      }  else if (type(date) == datetime) {
        [#date.display(date-format)]
      }else {date}\
      #if (body-name == none) {
        [MISSING]
        add-warning("body-name is missing", id: "BODY")
      } else {body-name}: #if (event-name == none) {
        [MISSING]
        add-warning("event-name is missing", id: "EVENT")
      } else {event-name}\
    ],
    footer: align(center, context {
      let current-page = here().page()
      let page-count = counter(page).final().first() - 1
      [#translate("PAGE", current-page, page-count)]
    }),
    margin: (
      left: 4cm,
      right: 2cm,
      top: 3cm,
      bottom: 6cm,
    ),
    background: (
      if (hole-mark) {
        place(left + top, dx: 5mm, dy: 100% / 2, line(
          length: 4mm,
          stroke: 0.25pt + black
        ))
      }
    ),
  )
  
  set text(
    10pt,
    lang: locale,
  )

  set par(justify: true)

  set heading(outlined: false, numbering: (..nums) => {
    nums = nums.pos()
    nums.at(0) = int(nums.at(0) / 2)
    item-numbering(..nums)
  })
  show heading: set text (12pt)
  show heading: it => [
    // #if (it.body.has("children")) [
    //   #let it-text = it.body.children.map(i => i.text).join()
    //   #if (it-text.contains("/")) [
    //     #let time = it-text.split("/").at(0)
    //     #let title = it-text.split("/").at(1)
    //     #timed(time , heading(level: it.level, title))
    //   ] else [
    //     #it-text
    //   ]
    // ] else 
    #if (it.body.text.contains("/")) [
      #let time = it.body.text.split("/").at(0)
      #let title = it.body.text.split("/").at(1)
      #timed(time , heading(level: it.level, title))
    ] else if (it.body.text.at(0) == "\u{200B}") [
      #if (separator-lines and (it.level == 1 or it.level == 4)) {
        grid(
          columns: (auto, 1fr),
          align: horizon,
          gutter: 1em,
          it,
          line(length: 100%, stroke: 0.2pt),
        )
      } else {
        it
      }
    ] else [
      #set heading(outlined: it.level != 4 and it.body.text != translate("SCHEDULE"), numbering: if (it.level >= 4) {none} else {it.numbering})
      #heading(level: it.level, "\u{200B}" + it.body.text)
      #v(0.5em)
    ]
  ]

  // Protokollkopf
  let start-time-string = context four-digits-to-time(start-time.at(<end-time>))
  let end-time-string = context four-digits-to-time(last-time.at(<end-time>))
  [
    *#translate("CHAIR")*: #name-format(if (chairperson == none) {
      [MISSING]
      add-warning("chairperson is missing")
    } else {[#chairperson]})\
    *#translate("PROTOCOL")*: #name-format(if (secretary == none) {
      [MISSING]
      add-warning("secretary is missing")
    } else {[#secretary]})
    #if awareness != none [
      \ *#translate("AWARENESS")*: #name-format(awareness)
    ]
    #if translation != none [
      \ *#translate("TRANSLATION")*: #name-format(translation)
    ] \
    
    #let old-present = present
    #let present = present.map(x => format-name-no-context(x))
    #if (awareness != none and not present.contains(awareness)) {
      present.insert(0, awareness)
    }
    #if (secretary != none and not present.contains(secretary)) {
      present.insert(0, secretary)
    }
    #if (chairperson != none and not present.contains(chairperson)) {
      present.insert(0, chairperson)
    }
    #context[
      #let keys = arrival-times.at(<end-time>).keys()
      #let filtered = present.filter(x => not keys.contains(x))
      #pres.update(filtered)
    ]
    #if (present.dedup().len() != present.len()) {
      add-warning("multiple people with the same name are present")
    }
    *#translate("PRESENT")*:
    #v(-0.5em)
    #grid(
      columns: calc.min(2, calc.ceil(present.len() / 10)) * (1fr,),
      row-gutter: 0.65em,
      inset: (left: 1em),
      ..present.map(x => {
        name-format(x)
        context {
          if (show-arrival-time and arrival-times.at(<end-time>).keys().contains(x)) {
            [ (#translate("SINCE") #box[#arrival-times.at(<end-time>).at(x)])]
          }
        }
      })
    )
    #if (old-present == ()) {
      add-warning("present not set")
    }
    #if (number-present) [
      *#translate("PRESENT_COUNT")*: #present.len()
    ]
  
    *#translate("START")*: #start-time-string\
    *#translate("END")*: #end-time-string
  ]

  pad(y: 2em)[
    #show outline.entry.where(level: 1): it => {
      v(0em)
      it
    }
    #outline(title: translate("SCHEDULE"), indent: 1em)
  ]
  if (title-page) {
    pagebreak()
  }
  timed(start-time-string, [==== #translate("START")])
  
  set par.line(
    numbering: x => {
      if (
        line-numbering != none
        and calc.rem(x, line-numbering) == 0
      ) {text(size: 0.8em)[#x]}
    },
    number-clearance: timestamp-margin,
    numbering-scope: "page"
  )

  show regex("(.)?" + regex-name-format + ": "): it => {
    context {
      if (it.text == " Sitzung: ") {
        it.text
        return
      }
      
      let name = it.text.slice(0,-2)

      
      name = format-name(name)
      
      if (not fancy-dialogue) {
        [#name-format(name): ]
      } else {
        if (name.at(0) == " ") {
          name = name.slice(1)
          [\ ]
        }
        
        name-format(name)[: ]
      }
      
      let status = get-status(name)
      if (status == status-away) {
        add-warning("\"" + name + "\" spoke, but was away (-)")
      } else if (status == status-away-perm) {
        add-warning("\"" + name + "\" spoke, but left (--)")
      } else if (status == status-none) {
        add-warning("\"" + name + "\" spoke, but is unaccounted for")
      }
    }
  }

  show regex("/" + regex-name-format): it => {
    context {
      let name = it.text.slice(1)
    
      name = format-name(name)
      
      name-format(name)
    
      let status = get-status(name)
      if (status == status-away) {
        add-warning("\"" + name + "\" was mentioned, but was away (-)")
      } else if (status == status-away-perm) {
        add-warning("\"" + name + "\" was mentioned, but left (--)")
      } else if (status == status-none) {
        add-warning("\"" + name + "\" was mentioned, but is unaccounted for")
      }
    }
  }

  //Hauptteil
  body
  
  //Schluss
  set par.line(
    number-clearance: 200pt
  )
  
  help-text()
  
  if (signing) {
    v(3cm)
    [#translate("SIGNATURE_PRE"):]
    
    v(1cm)
    grid(
      columns: (1fr, 1fr, 1fr),
      align: center,
      gutter: 0.65em,
      line(length: 100%, stroke: 0.5pt),
      line(length: 100%, stroke: 0.5pt),
      line(length: 100%, stroke: 0.5pt),
      [#translate("PLACE_DATE")],
      [#translate("SIGNATURE") #if (cosigner == none) [#translate("CHAIR")] else [#cosigner]],
      [#translate("SIGNATURE") #translate("PROTOCOL")],
      [],
      if (cosigner == none) {
        name-format(
          if (chairperson == none) [MISSING] else [#chairperson]
        )
      } else {
        name-format(
          if (cosigner-name == none) {
            [MISSING]
            add-warning("cosigner-name is missing")
          } else [#cosigner-name]
        )
      },
      name-format(if (secretary == none) [MISSING] else [#secretary]),
    ) 
  }

  //Hinweise
  context {
    if (warnings.get().len() > 0) {
      set page(header: none, footer: none, margin: 2cm, numbering: none)
      render-warnings()
    }
  }
}

//#import "minutes.typ": *

/*#show: minutes.with(
  date: auto,
  
  fancy-decisions: true,
  fancy-dialogue: true,
  //line-numbering: none
  //hide-warnings: true

  chairperson: "Vorsitz, Ender",
  secretary: "Protokoll, Antin",
  cosigner: "Vereinsvorstand",
  cosigner-name: "Unter-Schrei, Bender",

  //locale: "de"
)

100/

= 1302/Hallo
++7/Vivi

#lorem(220)

Vivi: #lorem(20)
Tami: #lorem(20)

7/blablabla/lol

--8/Vivi

-8/MISSING

+87/MISSING

== 13/Moin

aioeghiwegoiwsegioen

!55/Joa doch!/5/1/1

!55/Joa doch!/|green5/|red 1/|green 1/2|blue/|green 3

=== 56/servus

= 58/Höhö

/1400