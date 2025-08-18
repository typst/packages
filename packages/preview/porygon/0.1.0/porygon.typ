#import "@preview/fontawesome:0.6.0": fa-icon

#let __document_lang = state("document_lang", "en")

#let __translate(val) = {
  if type(val) == dictionary {
    let is_val = val.at(__document_lang.get(), default: none)
    if is_val != none {
      str(val.at(__document_lang.get()))
    }
  } else {
    str(val)
  }
}

#let __render-text(val) = {
  let val = __translate(val)
  let render_text_str(val) = {
    let parse_url(value) = {
      let regex_full_url = regex("(.*)\\\href\{([^\{]*?)\}\{(.*)\}(.*)")
      let matched = value.match(regex_full_url)
      if matched == none {
        return value
      }
      let captures = matched.captures
      let before = captures.at(0)
      let url = captures.at(1)
      let (url_link, after) = (captures.at(2), captures.at(3))
      let url_link = render_text_str(url_link)
      return before + "#link(\"" + url + "\")[" + url_link + "]" + after
    }
    let parse_textbf(val) = {
      let regex_bf = regex("(.*)\\\\textbf\{([^\{]*?)\}(.*)")
      let mat = val.match(regex_bf)
      if mat == none {
        return val
      }
      return mat.captures.at(0) + " *" + mat.captures.at(1) + "* " + mat.captures.at(2)
    }
    let remove_new_line(val_li) = {
      return val_li.replace("\\newline", " #linebreak() ")
    }
    let text = remove_new_line(val)
    let text = parse_url(text)
    let text = parse_textbf(text)
    return text
  }
  let final_text = render_text_str(val)
  eval(final_text, mode: "markup")
}

#let __show-title(title) = {
  let value = __translate(title)
  grid(
    columns: (auto, 1fr),
    align: (auto, horizon),
    gutter: 5pt,
    heading(value), align(horizon, line(length: 100%)),
  )
}

#let __show-title-bar(title) = {
  let value = __translate(title)
  stack(
    dir: ttb,
    [ == #value ],
    v(0.5em),
    line(length: 95%),
  )
}

#let __filter-by-lang(data_list, field) = {
  let filter_lang(one_e) = {
    if type(one_e.at(field)) == str {
      return true
    } else if one_e.at("optional", default: none) == true {
      return false
    } else if one_e.at(field).keys().contains(__document_lang.get()) {
      return true
    }
    return false
  }
  data_list.filter(filter_lang)
}

#let __show-contact(data) = {
  align(center, [
    #set text(15pt)
    *#data.firstname #data.lastname*
    #linebreak()
  ])
  if __document_lang.get() == "en" {
    align(center, __translate(data.bio))
  } else {
    align(center, [
      #circle(height: 4.5cm, inset: -18pt, outset: 0pt)[
        #set align(center + horizon)
        #block(
          clip: true,
          radius: 50%,
          image(data.picture, height: 6cm),
        )
      ]
    ])
  }
  __show-title-bar(data.sidebar)
  let spacing = 0.4em
  align(right, stack(
    link("mailto:" + data.mail)[#data.mail],
    v(spacing),
    [
      #__translate(data.location)
      #fa-icon("location-dot")
    ],
    v(spacing),
    link("tel:" + data.phone)[#data.phone #fa-icon("phone")],
    v(spacing),
    [
      #__translate(data.driving)
      #fa-icon("wpforms")
    ],
    v(spacing),
    link(data.website)[#data.website #fa-icon("home")],
    v(spacing),
    link(data.linkedin.link)[#data.linkedin.name #fa-icon("linkedin")],
    v(spacing),
    link(data.github.link)[#data.github.name #fa-icon("github")],
  ))
}

#let __show-work((title, data)) = {
  __show-title(title)
  let render_element((date, description, name)) = {
    let name = __render-text(name)
    (
      align(top, __translate(date)),
      block([#underline(name)#linebreak() #__render-text(description)#v(0.5em)]),
    )
  }
  let content = __filter-by-lang(data, "date").map(render_element).flatten()
  let rows = __filter-by-lang(data, "date").map(e => auto)
  grid(
    columns: (0.20fr, 0.8fr),
    rows: rows,
    column-gutter: 10pt,
    row-gutter: 3pt,
    align: (x, _) => if x == 0 { right } else { left },
    ..content,
  )
}

#let __show-personal((title, data), (list_ident,)) = {
  __show-title(title)
  let content = __filter-by-lang(data, "description").map(e => {
    __render-text(e.description)
  })
  list(
    marker: [--],
    indent: list_ident,
    ..content,
  )
}

#let __show-irl-langs((title, data), (row_gutter,)) = {
  __show-title-bar(title)
  let content = data
    .map(e => {
      (
        block(strong(__translate(e.name))),
        block([
          #set text(10pt)
          #__render-text(e.level)
        ]),
      )
    })
    .flatten()
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    rows: rows,
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    ..content,
  )
}

#let __show-project((title, data), (list_ident,)) = {
  __show-title(title)
  let content = __filter-by-lang(data, "description").map(e => {
    __render-text(e.description)
  })
  list(
    marker: [--],
    indent: list_ident,
    ..content,
  )
}

#let __show-languages((title, data), (row_gutter)) = {
  __show-title-bar(title)
  let content = data.map(e => [
    #e.name
  ])
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    ..content,
  )
}


#let __show-tools((title, data), (row_gutter)) = {
  __show-title-bar(title)
  let content = data.map(e => [
    #e.name
  ])
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    inset: 0pt,
    ..content,
  )
}

#let __show-school((title, data)) = {
  __show-title(title)
  for (date, name, location, description) in data [
  ]
  let data = __filter-by-lang(data, "date")
  let nb_item = data.len()
  let render_element((idx, (date, name, location, description))) = {
    (
      align(top, __translate(date)),
      stack(
        dir: ttb,
        strong(__render-text(name)),
        v(0.2em),
        [#fa-icon("location-dot")#h(0.2em)#__translate(location)],
        v(0.7em),
        __render-text(
          description,
        ),
        if idx != (nb_item - 1) { v(0.5em) },
      ),
    )
  }
  let content = data.enumerate().map(render_element).flatten()
  let rows = __filter-by-lang(data, "date").map(e => auto)
  grid(
    columns: (0.20fr, 0.80fr),
    rows: rows,
    column-gutter: 10pt,
    row-gutter: 3pt,
    align: (x, _) => if x == 0 { right } else { left },
    ..content,
  )
}

#let __interest(hobby) = {
  let (ico, name) = hobby
  let ico = lower(ico.slice(3))
  let label = __translate(name)
  align(center)[
    #stack(
      dir: ttb,
      circle(radius: 0.5cm, fill: rgb("4a90d9"))[
        #set align(center + horizon)
        #text(size: 1em, fill: white)[#fa-icon(ico)]
      ],
      v(0.4em),
      align(center, [#text(size: 0.7em)[#label]]),
    )
  ]
}

#let __show-hobbies((title, data)) = {
  __show-title-bar(title)
  block(
    width: 100%,
    [
      #grid(
        columns: (1fr, 1fr),
        align: horizon,
        __interest(data.at(0)), __interest(data.at(1)),
      )
      #align(center)[
        #__interest(data.at(2))
      ]
    ],
  )
}


#let __show-page-title(data) = {
  align(
    center,
    stack(
      dir: ttb,
      block[
        #set text(15pt)
        = #__translate(data.title)
      ],
      v(0.8em),
      __translate(data.subtitle),
    ),
  )
}

/// show-cv function build the complete cv from the data
/// - data (dictionary): Structure that contains the cv data
#let show-cv(data, lang: "en") = {
  let doc_lang = sys.inputs.at("CV_LANG", default: lang)
  __document_lang.update(x => doc_lang)

  set document(
    title: "CV - " + data.me.firstname + " " + data.me.lastname,
    author: data.me.firstname
      + " "
      + data.me.lastname
      + " (created with https://github.com/Its-Just-Nans/curriculum-vitae)",
    description: "Curriculum Vitae of " + data.me.firstname + " " + data.me.lastname,
    keywords: data.me.keywords,
    date: datetime.today(),
  )


  set text(
    font: "Chivo",
  )

  let list_ident = 20pt
  let row_gutter = 8pt
  let white_smoke = rgb("#f5f5f5")
  let light_gray = rgb("#d3d3d3")

  set page(margin: (
    top: eval(data.margin.top),
    bottom: eval(data.margin.bottom),
    right: 0.8cm,
    left: 0.8cm,
  ))

  set par(
    leading: 0.55em,
  )


  grid(
    columns: (0.27fr, 4pt, 0.6fr),
    rows: 100%,
    column-gutter: 5pt,
    context {
      set text(
        size: 12pt,
      )
      align(horizon, [
        #__show-contact(data.me)
        #__show-languages(data.languages, (row_gutter,))
        #__show-tools(data.tools, (row_gutter,))
        #__show-irl-langs(data.langs, (row_gutter,))
        #__show-hobbies(data.hobbies)
      ])
    },
    align(center + horizon, [
      #line(end: (00%, 90%), stroke: 4pt + white_smoke)
    ]),
    context {
      set text(
        size: 10pt,
      )
      align(horizon, [
        #__show-page-title(data.me)
        #__show-school(data.school)
        #__show-work(data.work)
        #__show-project(data.project, (row_gutter,))
        #__show-personal(data.personal, (list_ident,))
      ])
    },
  )
}