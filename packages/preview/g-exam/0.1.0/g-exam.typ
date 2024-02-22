#import "@preview/oxifmt:0.2.0": strfmt

#let __question-number = counter("question-number")
#let __question-point = state("question-point", 0)
#let __question-point-position-state = state("question-point-position", left)


#let __localization = state("localization")

#let __default-localization = (
    grade-table-queston: "Question",
    grade-table-total: "Total",
    grade-table-points: "Points",
    grade-table-calification: "Calification",
    point: "point",
    points: "points",
    page: "Page",
    page-counter-display: "1 of 1",
    family-name: "Surname",
    personal-name: "Name",
    group: "Group",
    date: "Date"
  )

#let __student-data(show-line-two: true) = {
    locate(loc => {
      [#__localization.final(loc).family-name: #box(width: 2fr, repeat[.]) #__localization.final(loc).personal-name: #box(width:1fr, repeat[.])]
      if show-line-two {
        v(1pt)
        align(right, [#__localization.final(loc).group: #box(width:2.5cm, repeat[.]) #__localization.final(loc).date: #box(width:3cm, repeat[.])])
      }
    }
  )
} 

#let __grade-table-header(decimal-separator: ".") = {
      locate(loc => {        
        let end-question-locations = query(<end-question-localization>, loc)
        let columns-number = range(0, end-question-locations.len() + 1)
      
        let question-row = columns-number.map(n => {
            if n == 0 {align(left + horizon)[#text(hyphenate: false,__localization.final(loc).grade-table-queston)]}
            else if n == end-question-locations.len() {align(left + horizon)[#text(hyphenate: false,__localization.final(loc).grade-table-total)]}
            else [ #n ]
          }
        )

        let total-point = 0
        if end-question-locations.len() > 0 { 
          total-point = end-question-locations.map(ql => __question-point.at(ql.location())).sum()
        }

        let points = ()
        if end-question-locations.len() > 0 {
          points =  end-question-locations.map(ql => __question-point.at(ql.location()))
        }
      
        let point-row = columns-number.map(n => {
            if n == 0 {align(left + horizon)[#text(hyphenate: false,__localization.final(loc).grade-table-points)]}
            else if n == end-question-locations.len() [
              #strfmt("{0:}", calc.round(total-point, digits:2), fmt-decimal-separator: decimal-separator)
            ]
            else {
              let point = points.at(n)
              [
                #strfmt("{0}", calc.round(point, digits: 2), fmt-decimal-separator: decimal-separator)
              ]
            }
          }
        )

        let calification-row = columns-number.map(n => 
          {
            if n == 0 {
              align(left + horizon)[#text(hyphenate: false, __localization.final(loc).grade-table-calification)]
            }
          }
        )

        align(center, table(
          stroke: 0.8pt + luma(80),
          columns: columns-number.map( n => 
          {
            if n == 0 {auto}
            else if n == end-question-locations.len() {auto}
            else {30pt}
          }),
          rows: (auto, auto, 30pt),
          ..question-row.map(n => n),
          ..point-row.map(n => n),
          ..calification-row.map(n => n),
        )
      )
    }
  )
}

#let __question-numbering(..args) = {
  let nums = args.pos()
  if nums.len() == 1 {
    numbering("1. ", nums.last())
  }
  else if nums.len() == 2 {
    numbering("(a) ", nums.last())
  }
  else if nums.len() == 3 {
    numbering("(i) ", nums.last())
  }
}

#let __paint-tab(point: none, loc: none) = {
  if point != none {
    let label-point = __localization.final(loc).points
    if point == 1 {
      label-point = __localization.final(loc).point
    }

    [(#emph[#strfmt("{0}", calc.round(point, digits: 2), fmt-decimal-separator: ",") #label-point])]
  }
}

#let g-question(point: none, body) = {
  __question-number.step(level: 1) 
  
  [#hide[]<end-question-localization>]
  __question-point.update(p => 
    {
      if point == none { 0 }
      else { point }
    })
  
  locate(loc => {
    let __question-point-position = __question-point-position-state.final(loc)
  
    if __question-point-position == left {
      v(0.1em)
      {
        __question-number.display(__question-numbering) 
        if(point != none) {
          __paint-tab(point:point, loc: loc) 
          h(0.2em)
        }
      }
      body 
    }
    else if __question-point-position == right {
      v(0.1em)
      if(point != none) {
        place(right, 
            dx: 12%,
            float: false,
            __paint-tab(point: point, loc: loc))
      }
      __question-number.display(__question-numbering) 
      body
    }
    else {
      v(0.1em)
      __question-number.display(__question-numbering) 
      body 
    }
  })
}

#let g-subquestion(point: none, body) = {
  __question-number.step(level: 2)

  let subquestion-point = 0
  if point != none { subquestion-point = point }
  __question-point.update(p => p + subquestion-point )

  locate(loc => {
      let question-point-position = __question-point-position-state.final(loc)
    
      if question-point-position == left {
        v(0.1em)
        {
          h(0.7em) 
          __question-number.display(__question-numbering) 
          if(point != none) {
            __paint-tab(point: point, loc:loc) 
            h(0.2em)
          }
        }
        body
      }
      else if question-point-position == right {
        v(0.1em)
        if(point != none) {
          place(right, 
              dx: 12%,
              float: false,
              __paint-tab(point: point, loc:loc)) 
        }
        {
          h(0.7em) 
          __question-number.display(__question-numbering) 
        }
        body
      }
      else {
        v(0.1em)
        {
          h(0.7em) 
          __question-number.display(__question-numbering) 
        }
        body
      }
    }
  )
}

#let __show_clarifications = (clarifications: none) => {
  if clarifications != none {
    let clarifications-content = []
    if type(clarifications) == "content" {
      clarifications-content = clarifications
    }
    else if type(clarifications) == "string" {
      clarifications-content = clarifications
    } 
    else if type(clarifications) == "array" {
      clarifications-content = [
        #for clarification in clarifications [
          - #clarification
        ]
      ]
    }
    else {
      panic("Not implementation clarificationso of type: '" + type(clarifications) + "'")
    }

    rect(
      width: 100%, 
      stroke: luma(120),
      inset:8pt,
      radius: 4pt,
      clarifications-content
    )
    
    v(5pt)
  }
}

#let g-exam(
  author: (
    name: "",
    email: none,
    watermark: none
  ),
  school: (
    name: none,
    logo: none,
  ),
  exam-info: (
    academic-period: none,
    academic-level: none,
    academic-subject: none,
    number: none,
    content: none,
    model: none
  ),
  localization: (
    grade-table-queston: none,
    grade-table-total: none,
    grade-table-points: none,
    grade-table-calification: none,
    point: none,
    points: none,
    page: none,
    page-counter-display: none,
    family-name: none,
    personal-name: none,
    group: none,
    date: none
  ),
  // date: none auto datetime,
  date: none,
  keywords: none,
  languaje: "en",
  clarifications: none,
  show-studen-data: "first-page",
  show-grade-table: true,
  decimal-separator: ".",
  question-point-position: left,
  body,
) = {
  
  assert(show-studen-data in (none, "first-page", "odd-pages"),
      message: "Invalid show studen data")

  assert(question-point-position in (none, left, right),
      message: "Invalid question point position")

  assert(decimal-separator in (".", ","),
      message: "Invalid decimal separator")

  let __show-watermark = (
      author: (
          name: "",
          email: none,
          watermark: none
        ),
        school: (
          name: none,
          logo: none,
        ),
        exam-info: (
          academic-period: none,
          academic-level: none,
          academic-subject: none,
          number: none,
          content: none,
          model: none
        ),
      ) => {
        place(
          top + right,
          float: true,
          clearance: 0pt,
          dx:72pt,
          dy:-115pt,
          rotate(270deg,
          origin: top + right,
            {
              if author.at("watermark", default: none) != none {
                text(size:7pt, fill:luma(90))[#author.watermark]
                h(35pt)
              }
              if exam-info.at("model", default: none) != none {
                text(size:8pt, luma(40))[#exam-info.model]
              }
            }
          )
        )
  }

  let __document-name = (
    exam-info: (
      academic-period: none,
      academic-level: none,
      academic-subject: none,
      number: none,
      content: none,
      model: none
    )) => {
      let document-name = ""
      if exam-info.at("name", default: none) != none { document-name += " " + exam-info.name }
      if exam-info.at("content", default: none) != none { document-name += " " + exam-info.content }
      if exam-info.at("number", default: none) != none { document-name += " " + exam-info.number }
      if exam-info.at("model", default: none) != none { document-name += " " + exam-info.model }

      return document-name
  }

  let __read-localization = (
    languaje: "en",
    localization: (
      grade-table-queston: none,
      grade-table-total: none,
      grade-table-points: none,
      grade-table-calification: none,
      point: none,
      points: none,
      page: none,
      page-counter-display: none,
      family-name: none,
      personal-name: none,
      group: none,
      date: none
    )) => {
      let __lang_data = toml("lang.toml")
      if(__lang_data != none) {
        let __read_lang_data = __lang_data.at(languaje, default: localization)

        if(__read_lang_data != none) {
          let __read-localization_value = (read_lang_data: none, field: "", localization: none) => {
            let __parameter_value = localization.at(field)
            if(__parameter_value != none) { return __parameter_value }

            let value = read_lang_data.at(field, default: __default-localization.at(field))
            if(value == none) { value = __default-localization.at(field)}
            
            return value
          }

          let __grade_table_queston = __read-localization_value(read_lang_data: __read_lang_data, field: "grade-table-queston", localization: localization)
          let __grade_table_total = __read-localization_value(read_lang_data: __read_lang_data, field: "grade-table-total", localization: localization)
          let __grade_table_points = __read-localization_value(read_lang_data: __read_lang_data, field: "grade-table-points", localization: localization)
          let __grade_table_calification = __read-localization_value(read_lang_data: __read_lang_data, field: "grade-table-calification", localization: localization)
          let __point = __read-localization_value(read_lang_data: __read_lang_data, field:"point", localization: localization)
          let __points = __read-localization_value(read_lang_data: __read_lang_data, field: "points", localization: localization)
          let __page = __read-localization_value(read_lang_data: __read_lang_data, field: "page", localization: localization)
          let __page-counter-display = __read-localization_value(read_lang_data: __read_lang_data, field: "page-counter-display", localization: localization)
          let __family_name = __read-localization_value(read_lang_data: __read_lang_data, field: "family-name", localization: localization)
          let __personal_name = __read-localization_value(read_lang_data: __read_lang_data, field: "personal-name", localization: localization)
          let __group = __read-localization_value(read_lang_data: __read_lang_data, field: "group", localization: localization)
          let __date = __read-localization_value(read_lang_data: __read_lang_data, field: "date", localization: localization)

          let __localization_lang_data = (
                grade-table-queston: __grade_table_queston,
                grade-table-total: __grade_table_total,
                grade-table-points: __grade_table_points,
                grade-table-calification: __grade_table_calification,
                point: __point,
                points: __points,
                page: __page,
                page-counter-display: __page-counter-display,
                family-name: __family_name,
                personal-name: __personal_name,
                group: __group,
                date: __date,
              )

          __localization.update(__localization_lang_data)
        }
      }
    }

  set document(
    title: __document-name(exam-info: exam-info).trim(" "),
    author: author.name
  )

  let margin-right = 2.5cm
  if (question-point-position == right) {
    margin-right = 3cm
  }

  set page(
    paper: "a4", 
    margin: (top: 5cm, right:margin-right),
    numbering: "1 / 1",
    number-align: right,
    header-ascent: 20%,
    header:locate(loc => {
        let page-number = counter(page).at(loc).first()
        if (page-number==1) { 
          align(right)[#box(
            width:108%,
            grid(
              columns: (auto, auto),
              gutter:0.7em,        
              align(left + top)[
                #if(school.at("logo", default : none) != none) {
                  if(type(school.logo) == "content") {
                    school.logo
                  }
                  else if(type(school.logo) == "bytes") {
                    image.decode(school.logo, height:2.5cm, fit:"contain")
                  }
                  else {
                    assert(type(school.logo) in (none, "content", "bytes") , message: "school.logo be of type content or bytes.")
                  }
                }
              ],
              grid(
                rows: (auto, auto, auto),
                gutter:1em,    
                  grid(
                    columns: (auto, 1fr, auto),
                    align(left  + top)[
                      #school.name \  
                      #exam-info.academic-period \
                      #exam-info.academic-level
                    ],
                    align(center + top)[
                    // #exam-info.number #exam-info.content \
                    ],
                    align(right + top)[
                      #exam-info.at("academic-subject", default: none)  \  
                      #exam-info.number \
                      #exam-info.content 
                    ],
                  ),
                  line(length: 100%, stroke: 1pt + gray),
                  if show-studen-data in ("first-page", "odd-pages") {
                    __student-data()
                  }
              )
          )
          )]
        }
        else if calc.rem-euclid(page-number, 2) == 1 {
            grid(
              columns: (auto, 1fr, auto),
              gutter:0.3em,
              align(left  + top)[
                #school.name \  
                #exam-info.academic-period \
                #exam-info.academic-level
              ], 
              align(center + top)[
                // #exam-info.number #exam-info.content \
              ],
              align(right + top)[
                #exam-info.at("academic-subject", default: none) \
                #exam-info.number \
                #exam-info.content 
              ]
            )
            line(length: 100%, stroke: 1pt + gray) 
            if show-studen-data == "odd-pages" {
              __student-data(show-line-two: false)
            }
        }
        else {
           grid(
              columns: (auto, 1fr, auto),
              gutter:0.3em,
              align(left  + top)[
                #school.name \  
                #exam-info.academic-period \
                #exam-info.academic-level
              ], 
              align(center + top)[
                // #exam-info.number #exam-info.content \
              ],
              align(right + top)[
                #exam-info.at("academic-subject", default: none) \
                #exam-info.number \
                #exam-info.content \
              ]
            )
            line(length: 100%, stroke: 1pt + gray) 
        }
      } 
    ),

    footer: locate(loc => {
        line(length: 100%, stroke: 1pt + gray) 
        align(right)[
            #__localization.final(loc).page
            #counter(page).display(__localization.final(loc).page-counter-display, both: true,
            )
        ]
        // grid(
        //   columns: (1fr, 1fr, 1fr),
        //   align(left)[#school.name],
        //   align(center)[#exam-info.academic-period],
        //   align(right)[
        //     Página 
        //     #counter(page).display({
        //       "1 de 1"},
        //       both: true,
        //     )
        //   ]
        // )

        __show-watermark(author: author, school: school, exam-info: exam-info)
      }
    )
  )

  set par(justify: true) 
  set text(font: "New Computer Modern")
  
  __read-localization(languaje: languaje, localization: localization)
  __question-point-position-state.update(u => question-point-position)

  set text(lang:languaje)

  if show-grade-table == true {
    __grade-table-header(
      decimal-separator: decimal-separator,
    )
    v(10pt)
  }
  
  // show heading.where(level: 1): it => {
  //   set block(above: 1.2em, below: 1em)
  //   set text(12pt, weight: "semibold")
  //   question(point: none)[#it.body]
  // }

  // show heading.where(level: 2): it => {
  //   set text(12pt, weight: "regular")
  //   subquestion(point: none)[#it.body]
  // }


  set par(justify: true) 

  if clarifications != none {
    __show_clarifications(clarifications: clarifications)
  }

  body
  
  [#hide[]<end-question-localization>]
  [#hide[]<end-exam>]
}

#let g-explanation(size:8pt, body) = { 
  text(size:size)[$(*)$ #body] 
}