#let noun(it) = [#text(features: ("smcp", ), tracking: 0.025em)[#it]] //small caps with proper tracking
#let versal(it) = [#text(tracking: 0.125em, number-type: "lining")[#upper[#it]]] //all caps with proper tracking
#let lang(it, content) = [#text(lang: it, style: "italic")[#content]] //change the language for a word or two or a longer period for language appropriate smartquotes and stuff. Also italicises the foreign text

#let minutes(
  body-name: none,
  event-name: none,
  date: none,
  present: (),
  not-voting: (),
  chairperson: none,
  secretary: none,

  awareness: none,
  translation: none,
  cosigner: none,
  cosigner-name: none,

  logo: none,
  custom-header: auto,
  custom-footer: auto,
  custom-background: auto,
  custom-head-section: auto,
  custom-name-format: (first-name, last-name, numbered) => [
    #if (numbered) [#first-name #last-name] else [
      #if (last-name != none) [#last-name, ]#first-name
    ]
  ],
  custom-name-style: (name) => name,
  item-numbering: none,
  time-format: none,
  date-format: none,
  timestamp-margin: 10pt,
  line-numbering: 5,
  fancy-decisions: false,
  fancy-dialogue: false,
  hole-mark: true,
  separator-lines: true,
  signing: true,
  locale: "en",
  translation-overrides: (:),
  custom-royalty-connectors: (),
  title-page: false,
  number-present: false,
  show-arrival-time: true,

  display-all-warnings: false,
  hide-warnings: false,
  warning-color: red,
  enable-help-text: false,
  
  body
) = {
  // Constants
  let status-present = "present"
  let status-away = "away"
  let status-away-perm = "away-perm"
  let status-none = "none"
  
  // Variables
  let warnings = state("warnings", (:))
  let all = state("all", ())
  let pres = state("pres", ())
  let away = state(status-away, ())
  let away-perm = state(status-away-perm, ())
  let hours = state("hours", none)
  let last-time = state("last-time", none)
  let start-time = state("start-time", none)

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
      if (x.contains(id)) {
        _ = x.remove(x.position(x => x == id))
      }
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
      #let time-string = time-string
      
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

      #if (last-time.get() != none and int(time-string) < int(last-time.get()) and hours-manual == none) {
        add-warning(four-digits-to-time(time-string) + " is logged after " + four-digits-to-time(str(last-time.get())))
      }
      #if (hours-manual == none) {
        last-time.update(time-string)
        if (start-time.get() == none) {
          start-time.update(time-string)
        }
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

  let royalty-connectors = custom-royalty-connectors + (
    "von der",
    "von",
    "de"
  )
  let royalty-connectors = royalty-connectors.dedup()

  let name-format(name) = {
    let first-name = name
    let last-name = none
    let numbered = false

    if (name.starts-with("%esc%")) {
      return custom-name-style(name.slice(5))
    }

    if (name.contains(", ")) {
      let split = name.split(", ")
      first-name = split.at(1)
      last-name = split.at(0)
      numbered = split.at(0).match(regex("[0-9]+")) != none
    }

    return box[
      #show "???": set text(fill: red)
      #custom-name-style(custom-name-format(first-name, last-name, numbered))
    ]
  }

  let format-name-no-context(name) = {
    // flip names at ","
    if (not name.contains(",") and name.contains(" ")) {
      let name-parts = name.split(" ")

      if (name-parts.any(x => royalty-connectors.contains(x))){
        let connector = name-parts.filter(x => royalty-connectors.contains(x)).first()
        let position = name-parts.position(x => x == connector)
        return name-parts.slice(position).join(" ") + ", " + name-parts.slice(0, position).join(" ")
      }
      
      name = name-parts.at(-1) + ", " + name-parts.slice(0, -1).join(" ")
    }
    return name
  }

  let pretty-name-connect(names) = {
    if names.len() == 1 {
      return name-format(format-name-no-context(names.at(0)))
    } else {
      names.slice(0,-1).map(x => name-format(format-name-no-context(x))).join(custom-name-style(", ")) + custom-name-style(" & ") + name-format(format-name-no-context(names.at(-1)))
    }
  }

  let format-name(name) = {
    if (name.starts-with("-")) {
      return "%esc%" + name.slice(1)
    }
    
    if (not name.contains(",")) {
      let all = all.final()

      // compare with single names
      if (all.contains(name)) {
        return name
      }
      // compare single initials
      let names = all.map(x => {
        return x.at(0)
      })
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          return name + "???"
        }
        return all.at(names.position(x => x == name))
      }
      
      all = all.filter(x => x.contains(", "))

      // compare first name abbreviations
      let names = all.map(x => {
        let split = x.split(", ")
        return split.at(1).at(0)
      })
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          return name + "???"
        }
        return all.at(names.position(x => x == name))
      }

      // compare with full names (without ",")
      let names = all.map(x => {
        let split = x.split(", ")
        return split.at(1) + " " + split.at(0)
      })
      if (names.contains(name)) {
        return all.at(names.position(x => x == name))
      }
      // compare with first names
      let names = all.map(x => x.split(", ").at(1))
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          return "???, " + name
        }
        return all.at(names.position(x => x == name))
      }
      // compare with last names
      let names = all.map(x => x.split(", ").at(0))
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          return name + ", ???"
        }
        return all.at(names.position(x => x == name))
      }
      // compare with last name abbreviations
      let names = all.map(x => {
        let split = x.split(", ")
        let last-name = split.at(0)
        for royalty-connector in royalty-connectors {
          last-name = last-name.replace(royalty-connector + " ", "")
        }
        return split.at(1) + " " + last-name.slice(0, 1)
      })
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          let split = name.split(" ")
          return split.at(-1) + "???, " + split.slice(0,-1).join(" ")
        }
        return all.at(names.position(x => x == name))
      }
      // compare with first name abbreviations
      let names = all.map(x => {
        let split = x.split(", ")
        return split.at(1).slice(0, 1) + " " + split.at(0)
      })
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          let split = name.split(" ")
          return split.slice(1).join(" ") + ", " + split.at(0) + "???"
        }
        return all.at(names.position(x => x == name))
      }
      // compare with initials
      let names = all.map(x => {
        let split = x.split(", ")
        let last-name = split.at(0)
        for royalty-connector in royalty-connectors {
          last-name = last-name.replace(royalty-connector + " ", "")
        }
        return split.at(1).slice(0, 1) + last-name.slice(0, 1)
      })
      if (names.contains(name)) {
        if (names.filter(x => x == name).len() > 1) {
          return name.slice(1) + "???, " + name.at(0) + "???"
        }
        return all.at(names.position(x => x == name))
      }

      name = format-name-no-context(name)
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

  let without-not-voting(list) = {
    return list.filter(x => not (not-voting.map(x => format-name-no-context(x)).contains(x)))
  }
  
  // Inline functions
  let join(time, name, long: false) = [
    #context [
      #let name = format-name(name)

      #let status = get-status(name)
      #if (long) {
        if (status == status-away) {
          add-warning("\"" + name-format(name) + "\" joined (++), but was just gone for a while (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name-format(name) + "\" joined (++), but already left permanently (--)")
        }
        
        pres.update(x => {
          if (not x.contains(name)) {
            x.push(name)
          }
          return x
        })
      } else {
        if (status == status-away-perm) {
          add-warning("\"" + name-format(name) + "\" joined (+), but already left permanently (--)")
        } else if (status == status-none) {
          add-warning("\"" + name-format(name) + "\" joined (+), but is unaccounted for")
        } else if (status != status-away) {
          add-warning("\"" + name-format(name) + "\" joined (+), but was never away (-)")
        }
        
        away.update(x => {
          if (x.contains(name)) {
            _ = x.remove(x.position(x => x == name))
          }
          return x
        })
        pres.update(x => {
          if (not x.contains(name)) {
            x.push(name)
          }
          return x
        })
      }
    ]
    #context [
      #let name = format-name(name)
      #let statement = [
        _#name-format(name) #translate("JOIN" + if (long) {"_LONG"}, str(without-not-voting(pres.get()).len()), str(without-not-voting(pres.get()).len() + without-not-voting(away.get()).len()))_
      ]

      #if (time == none) {
        statement
      } else {
        timed(time)[
          #statement
        ]
      }
    ]
  ]
  
  let leave(time, name, long: false) = [
    #context [
      #let name = format-name(name)

      #let status = get-status(name)
      #if (long) {
        if (status == status-away-perm) {
          add-warning("\"" + name-format(name) + "\" left (--), but already left permanently (--)")
        } else if (status != status-present) {
          add-warning("\"" + name-format(name) + "\" left (--), but was not present (+)")
        } else if (status == status-none) {
          add-warning("\"" + name-format(name) + "\" left (--), but is unaccounted for")
        }
        
        away.update(x => {
          if (x.contains(name)) {
            _ = x.remove(x.position(x => x == name))
          }
          return x
        })
        pres.update(x => {
          if (x.contains(name)) {
            _ = x.remove(x.position(x => x == name))
          }
          return x
        })
        away-perm.update(x => {
          if (not x.contains(name)) {
            x.push(name)
          }
          return x
        })
      } else {
        if (status == status-away) {
          add-warning("\"" + name-format(name) + "\" left (-), but was away anyways (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name-format(name) + "\" left (-), but already left permanently (--)")
        } else if (status != status-present) {
          add-warning("\"" + name-format(name) + "\" left (-), but was not present (+)")
        } else if (status == status-none) {
          add-warning("\"" + name-format(name) + "\" left (-), but is unaccounted for")
        }
        
        pres.update(x => {
          if (x.contains(name)) {
            _ = x.remove(x.position(x => x == name))
          }
          return x
        })
        away.update(x => {
          if (not x.contains(name)) {
            x.push(name)
          }
          return x
        })
      }
    ]
    #context [  
      #let name = format-name(name)
      #let statement = [
        _#name-format(name) #translate("LEAVE" + if (long) {"_LONG"}, str(without-not-voting(pres.get()).len()), str(without-not-voting(pres.get()).len() + without-not-voting(away.get()).len()))_
      ]

      #if (time == none) {
        statement
      } else {
        timed(time)[
          #statement
        ]
      }
    ]
  ]

  let dec(time, content, args) = [
    #set par.line(
      number-clearance: 200pt
    )
    #let values = ()
    #if (args.values().all(x => type(x) == array)) {
      values = args.keys().map(x => (
          name: x,
          value: int(args.at(x).at(0)),
          color: args.at(x).at(1),
        )
      )
    } else {
      values = args.keys().map(x => (
          name: x,
          value: int(args.at(x).at(0)),
        )
      )
    }
    #block(breakable: false)[
      #if (time == none) {
        [
          ===== #translate("DECISION")
        ]
      } else {
        timed(time)[
          ===== #translate("DECISION")
        ]
      }
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
        #if (total != without-not-voting(pres.get()).len()) {
          add-warning(str(total) + " people voted, but " + str(without-not-voting(pres.get()).len()) + " were present", display: true)
        }
      ]
    ]
  ]

  let end(time) = [
    #set par.line(
      number-clearance: 200pt
    )
    #linebreak()
    #if (time == none) [==== #translate("END")] else {
      timed(time)[==== #translate("END")]
      last-time.update(time)
    }
  ]

  // Regex
  let non-name-characters = " .:;?!"
  let regex-time-format = "[0-9]{1,4}"
  let regex-name-format = "-?(" + royalty-connectors.join(" |") + " )?(\p{Lu})[^" + non-name-characters + "]*( " + royalty-connectors.join("| ") + ")?( (\p{Lu}|[0-9]+)[^" + non-name-characters + "]*)*"
  let default-format = regex-time-format + "/[^\n]*"
  let optional-time-format = "(" + regex-time-format + "/)?[^\n]*"

  let default-regex(keyword, function, body, time-optional: false) = [
    #show regex("^" + keyword.replace("+", "\+") + if (time-optional) {optional-time-format} else {default-format}): it => [
      #let text = it.text.slice(keyword.len())
      #let time = text.split("/").at(0)
      #let string = text.split("/").slice(1).join("/")

      #if (time-optional and time.match(regex("^" + regex-time-format + "$")) == none) {
        string = time
        time = none
      }
    
      #function(time, string)
    ]

    #body
  ]

  show: default-regex.with("+", join, time-optional: true)
  show: default-regex.with("-", leave, time-optional: true)
  show: default-regex.with("−", leave, time-optional: true)
  show: default-regex.with("++", join.with(long: true), time-optional: true)
  show: default-regex.with("–", leave.with(long: true), time-optional: true)
  show: default-regex.with("", timed)

  show regex("^/(" + regex-time-format + "|end)"): it => {
    let time = it.text.slice(1)
    if (time == "end") {
      context {
        end(last-time.get())
      }
    } else {
      end(time)
    }
  }

  show regex("^!(" + regex-time-format + "/)?.*[^-]/(.*(|.*)?[0-9]+){2,}"): it => [
    #let text = it.text.replace("-/", "%slash%").slice(1)
    #let time = text.split("/").at(0)

    #let args-slice = 2

    #if (time.match(regex("^" + regex-time-format + "$")) == none) {
      time = none
      args-slice = 1
    }

    #let args = text.split("/").slice(args-slice).enumerate().fold((:), (args, x) => {
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
      
      label = label.replace("%slash%", "/")
      if (color-string != none) {
        args.insert(label, (value, eval(color-string)))
      } else {
        args.insert(label, value)
      }
      
      return args;
    })
    
    #let text = text.split("/").at(args-slice - 1).replace("%slash%", "/")

    #if (args.len() == 3
      and args.keys().enumerate()
        .all(x => str(x.at(0) + 1) == x.at(1))
      and args.values()
        .all(x => type(x) != array)
    ) {
      let yes = args.values().at(0)
      let no = args.values().at(1)
      let abst = args.values().at(2)
      dec(time, text, (translate("YES"): (yes, green), translate("NO"): (no, red), translate("ABST"): (abst, blue)))
    } else {
      dec(time, text, args)
    }
  ]

  show regex("(.)?/" + regex-name-format): it => {
    context {
      let text = if (it.text.starts-with("\u{200b}")) {
        it.text.slice(3)
      } else {
        it.text
      }
      if (not (text.at(0) == "/" or text.slice(0, 2) == " /")) {
        it
        return
      }

      let name = text.slice(if (text.at(0) == "/") {1} else {2})
    
      name = format-name(name)
      
      if (text.at(0) != "/") {
        text.at(0)
      }
      name-format(name)
    
      let status = get-status(name)
      if (status == status-away) {
        add-warning("\"" + name-format(name) + "\" was mentioned, but was away (-)")
      } else if (status == status-away-perm) {
        add-warning("\"" + name-format(name) + "\" was mentioned, but left (--)")
      } else if (status == status-none) {
        add-warning("\"" + name-format(name) + "\" was mentioned, but is unaccounted for")
      }
    }
  }

  // Setup
  set page(
    header: {
      let formatted-date = if (date == none) {
        [XX.XX.XXXX]
        add-warning("date is missing", id: "DATE")
      } else if (date == auto) {
        [#datetime.today().display(date-format)]
      }  else if (type(date) == datetime) {
        [#date.display(date-format)]
      } else {[#date]}

      let formatted-body-name = if (body-name == none) {
        [MISSING]
        add-warning("body-name is missing", id: "BODY")
      } else {[#body-name]}

      let formatted-event-name = if (event-name == none) {
        [MISSING]
        add-warning("event-name is missing", id: "EVENT")
      } else {[#event-name]}

      if (custom-header == auto) {
        grid(
          columns: if (logo != none) {(auto, 1fr)} else {(1fr)},
          gutter: 1em,
          if (logo != none) {
            set image(
              height: 3em,
              fit: "contain",
            )
            logo
          },
          [
            #formatted-date\
            #formatted-body-name: #formatted-event-name\
          ]
        )
      } else if (custom-header != none) {
        custom-header(formatted-date, formatted-body-name, formatted-event-name, logo, translate)
      }
    },
    footer: context {
      let current-page = here().page()
      let page-count = counter(page).final().first() - if (warnings.final().len() > 0 and show-warnings) {1} else {0}
      if (custom-footer == auto) {
        align(center, [#translate("PAGE", current-page, page-count)])
      } else if (custom-footer != none) {
        custom-footer(current-page, page-count, translate)
      }
    },
    margin: (
      left: 4cm,
      right: 2cm,
      top: 3cm,
      bottom: 6cm,
    ),
    background: 
      if (custom-background == auto) {
        if (hole-mark) {
          place(left + top, dx: 5mm, dy: 100% / 2, line(
            length: 4mm,
            stroke: 0.25pt + black
          ))
        }
      } else if (custom-background != none) {
        custom-background(hole-mark)
      }
    ,
  )
  
  set text(
    10pt,
    lang: locale,
  )

  set par(justify: true)

  set heading(outlined: false, numbering: (..nums) => {
    nums = nums.pos()
    nums = nums.map(x => int(x / 2))
    item-numbering(..nums)
  })
  show heading: set text (12pt)
  show heading: it => {
    let text = if (it.body.has("children")) {
      it.body.children.map(i => if (i.has("text")) {i.text} else {" "}).join()
    } else {
      it.body.text
    }

    if (text.starts-with("\u{200B}")) {
      [#it]
      return
    }

    let (time, title) = if (text.match(regex(regex-time-format + "/")) != none) {
      (text.split("/").at(0), text.split("/").slice(1).join("/"))
    } else {
      (none, text)
    }
    title = heading("\u{200B}" + title, level: it.level, outlined: it.level != 4 and text != translate("SCHEDULE"), numbering: if (it.level >= 4) {none} else {it.numbering})
    
    let heading = if (time == none) {
      title
    } else {
      timed(time, title)
    }
    [
      #if (separator-lines and (it.level == 1 or it.level == 4)) {
        grid(
          columns: (auto, 1fr),
          align: horizon,
          gutter: 1em,
          heading,
          line(length: 100%, stroke: 0.2pt),
        )
      } else {
        heading
      }
      #v(0.5em)
    ]
  }

  // Protokollkopf
  
  let old-present = present
  let present = present + not-voting
  let present = present.map(x => format-name-no-context(x))
  let present = present.sorted(key: x => upper(x))
  if (awareness != none) {
    if (type(awareness) == "string") {
      awareness = format-name-no-context(awareness)
      if (not present.contains(awareness)) {
        present.insert(0, awareness)
      }
    } else {
      for person in awareness {
        person = format-name-no-context(person)
        if (not present.contains(person)) {
          present.insert(0, person)
        }
      }
    }
  }
  if (secretary != none) {
    secretary = format-name-no-context(secretary)
    if (type(secretary) == "string") {
      if (not present.contains(secretary)) {
        present.insert(0, secretary)
      }
    } else {
      for person in secretary {
        person = format-name-no-context(person)
        if (not present.contains(person)) {
          present.insert(0, person)
        }
      }
    }
  }
  if (chairperson != none) {
    chairperson = format-name-no-context(chairperson)
    if (type(chairperson) == "string") {
      if (not present.contains(chairperson)) {
        present.insert(0, chairperson)
      }
    } else {
      for person in chairperson {
        person = format-name-no-context(person)
        if (not present.contains(person)) {
          present.insert(0, person)
        }
      }
    }
  }

  let formatted-chairperson = if (chairperson == none) [
    #custom-name-style("MISSING")
    #add-warning("chairperson is missing")
  ] else if (type(chairperson) == "string") {
    [#name-format(format-name-no-context(chairperson))]
  } else { 
    [#pretty-name-connect(chairperson)]
  }

  let formatted-secretary = if (secretary == none) [
    #custom-name-style("MISSING")
    #add-warning("secretary is missing")
  ] else if (type(secretary) == "string") {
    [#name-format(format-name-no-context(secretary))]
  } else { 
    [#pretty-name-connect(secretary)]
  }

  let formatted-awareness = if (awareness == none) {
    none
  } else {
    if (type(awareness) == "string") {
      [#name-format(format-name-no-context(awareness))]
    } else { 
      [#pretty-name-connect(awareness)]
    }
  }

  let formatted-translation = if (translation == none) {
    none
  } else {
    if (type(translation) == "string") {
      [#name-format(format-name-no-context(translation))]
    } else { 
      [#pretty-name-connect(translation)]
    }
  }
  
  let formatted-present = [
    #let body-string = body.children.map(i => {
      let body = if (i.has("body")) {i.body} else {i}
      
      return if (body.has("text")) {body.text} else {""}
    }).join("\n")
    #if (body-string == none) {
      body-string = ""
    }
    
    #let join-long-regex = "\n++" + optional-time-format

    #let matches = body-string.matches(regex(join-long-regex.replace("+", "\+")))
    #let time-matches = body-string.matches(regex(regex-time-format + "/")).filter(x => x.text.len() >= 4)
    
    #context[
      #all.update(present)
      #let arrives-later = (:)
      #for match in matches {
        
        let split = match.text.split("/")

        if (split.len() == 1) {
          let time = none
          let name = format-name(split.at(0).slice(3))
          arrives-later.insert(name, time)
        } else {
          let time = split.at(0).slice(3)
          let hours = ""
          if (time.len() > 2) {
            hours = time.slice(0, 2)
          } else {
            let last-time = time-matches.filter(x => x.end < match.start).last().text.slice(0, -1)

            hours = last-time.slice(0, 2)
          }
          let time = format-time(split.at(0).slice(3), hours-manual: hours)

          let name = format-name(split.at(1))
          arrives-later.insert(name, time)
        }
      }
      
      #let filtered = present.filter(x => not 
      arrives-later.keys().contains(x))
      #pres.update(filtered)
      #grid(
        columns: calc.min(2, calc.ceil(present.len() / 10)) * (1fr,),
        row-gutter: 0.65em,
        ..present.map(x => {
          name-format(x)
          if (show-arrival-time and arrives-later.keys().contains(x)) {
            if (arrives-later.at(x) == none) {
              [ (#translate("DURING_EVENT"))]
            } else {
              [ (#translate("SINCE") #box[#arrives-later.at(x)])]
            }
          }
          if (not-voting.map(x => format-name-no-context(x)).contains(x)) {
            [ (#translate("NOT_VOTING"))]
          }
        })
      )
    ]
    
    #if (present.dedup().len() != present.len()) {
      add-warning("multiple people with the same name are present")
    }

    #if (old-present == ()) {
      add-warning("present not set")
    }
  ]

  let formatted-present-count = if (number-present) {
    present.len()
  } else {
    none
  }

  if (custom-head-section == auto) {
    [
      *#translate("CHAIR")*: #formatted-chairperson\
      *#translate("PROTOCOL")*: #formatted-secretary
      #if formatted-awareness != none [
        \ *#translate("AWARENESS")*: #formatted-awareness
      ]
      #if formatted-translation != none [
        \ *#translate("TRANSLATION")*: #formatted-translation
      ] \
      
      
      *#translate("PRESENT")*:
      #v(-0.5em)

      #pad(left: 1em)[
        #formatted-present
      ]
      
      #if (formatted-present-count != none) [
        *#translate("PRESENT_COUNT")*: #formatted-present-count\
      ]

      #context {
        let start-time = start-time.final()
        if (start-time != none) [*#translate("START")*: #four-digits-to-time(start-time)\ ]
        
        let end-time = last-time.final()
        if (end-time != none) [*#translate("END")*: #four-digits-to-time(end-time)]
      }
    ]

    pad(y: 1.5em)[
      #show outline.entry.where(level: 1): it => {
        v(0em)
        it
      }
      #outline(title: translate("SCHEDULE"), indent: 1em)
    ]
  } else if (custom-head-section != none) {
    custom-head-section(
      formatted-chairperson,
      formatted-secretary,
      formatted-awareness,
      formatted-translation,
      formatted-present,
      formatted-present-count,
      start-time,
      last-time,
      translate,
      four-digits-to-time,
    )
  }

  if (title-page) {
    pagebreak()
  }
  context {
    let start-time = start-time.final()
    if (start-time == none) {
      timed([], [==== #translate("START")])
    } else {
      timed([#four-digits-to-time(start-time)], [==== #translate("START")])
    }
  }
  
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

  //Hauptteil
  {
    show regex("(.)?" + regex-name-format + "[^-]: [^\n]*"): it => {
      context {
        let break-line = it.text.at(0) == " "
        let text = it.text.slice(if (break-line) {1} else {0})
        let name = text.split(": ").at(0)
        let text = text.split(": ").slice(1).join(": ")
        
        name = format-name(name)
        
        if (not fancy-dialogue) {
          [#name-format(name): ]
        } else {
          if (break-line) {
            [\ ]
          }
          
          name-format(name) + ": "
        }
        text
        
        let status = get-status(name)
        if (status == status-away) {
          add-warning("\"" + name-format(name) + "\" spoke, but was away (-)")
        } else if (status == status-away-perm) {
          add-warning("\"" + name-format(name) + "\" spoke, but left (--)")
        } else if (status == status-none) {
          add-warning("\"" + name-format(name) + "\" spoke, but is unaccounted for")
        }
      }
    }

    show regex("-:"): it => {
      [:]
    }
  
    body
  }
  
  //Schluss
  set par.line(
    number-clearance: 200pt
  )
  context {
    let count-away = away.get().len()
    if (count-away > 0) {
      add-warning(str(count-away) + " people are still away (-), but the document ended")
    }
  }
  
  help-text()
  
  if (signing) {
    block(breakable: false)[
      #v(3cm)
      #translate("SIGNATURE_PRE"):
      
      #v(1cm)
      #grid(
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
          if (chairperson == none) {
            name-format("MISSING")
          } else if (type(chairperson) == "string") {
            name-format(chairperson)
          } else { 
            chairperson.map(x => name-format(x)).join("\n")
          }
        } else {
          name-format(
            if (cosigner-name == none) {
              "MISSING"
              add-warning("cosigner-name is missing")
            } else {
              cosigner-name
            }
          )
        },
        if (secretary == none) {
          name-format("MISSING")
        } else if (type(secretary) == "string") {
          name-format(secretary)
        } else { 
          secretary.map(x => name-format(x)).join("\n")
        },
      )
    ]
  }

  //Hinweise
  context {
    if (warnings.get().len() > 0) {
      set page(header: none, footer: none, margin: 2cm, numbering: none)
      render-warnings()
    }
  }
}