#import "./global.typ" : *

#let __g-student-data(
      page: [],  // first, odd, pair.
      show-student-data: "first-page",
      // show-student-data: (
      //   given-name: first-page,
      //   family-name: first-page,
      //   group: first-page,
      //   date: first-page
      // ),
      show-student-number: 1,
    ) = {
    
    let family-label = [
       #context __g-localization.final().family-name: #box(width: 2fr, repeat[.])
    ]

  let give-label = [
    #context __g-localization.final().given-name: #box(width:1fr, repeat[.])
  ]

  let group-label = [
    #context __g-localization.final().group: #box(width:2.5cm, repeat[.])
  ]

  let date-label = [
    #context __g-localization.final().date: #box(width:4cm, repeat[.])
  ]

  if type(show-student-data) != "dictionary" {
    if type(show-student-data) == "array" and page != "first" {
      return
    }

    if show-student-data == false {
      return
    }

    if show-student-data == "first-page" and page != "first" {
      return
    }

    if show-student-data == "odd-pages" and not(page == "first" or page == "odd") {
      return
    }
  }
  else {
    let family-name-value = show-student-data.at("family-name", default: "first-page")
    let give-name-value =  show-student-data.at("given-name", default: "first-page")
    let group-value = show-student-data.at("group", default: "first-page")
    let date-value = show-student-data.at("date", default: "first-page")

    if family-name-value == false or (family-name-value == "first-page" and page != "first") or (family-name-value == "odd-pages" and not(page == "first" or page == "odd")) {
      family-label =[]
    }

    if give-name-value == false or (give-name-value == "first-page" and page != "first") or (give-name-value == "odd-pages" and not(page == "first" or page == "odd")) {
      give-label =[]
    }

    if group-value == false or (group-value == "first-page" and page != "first") or (group-value == "odd-pages" and not(page == "first" or page == "odd")) {
      group-label =[]
    }

    if date-value == false or (date-value == "first-page" and page != "first") or (date-value == "odd-pages" and not(page == "first" or page == "odd")) {
      date-label =[]
    }
  }

  let i = show-student-number
  while i > 0 {
    family-label
    give-label
    v(1pt)
    i = i - 1
  }
  align(right, {
      group-label
      date-label
    }
  )
} 

#let __g-grade-table-header(decimal-separator: ".") = {        
  let end-g-question-locations = query(<end-g-question-localization>)
  let columns-number = range(0, end-g-question-locations.len() + 1)

  let question-row = columns-number.map(n => {
      if n == 0 {align(left + horizon)[#text(hyphenate: false, context __g-localization.final().grade-table-queston)]}
      else if n == end-g-question-locations.len() {align(left + horizon)[#text(hyphenate: false, context __g-localization.final().grade-table-total)]}
      else [ #n ]
    }
  )

  let total-point = 0
  if end-g-question-locations.len() > 0 { 
    total-point = end-g-question-locations.map(ql => __g-question-point.at(ql.location())).sum()
  }

  let points = ()
  if end-g-question-locations.len() > 0 {
    points =  end-g-question-locations.map(ql => __g-question-point.at(ql.location()))
  }

  let point-row = columns-number.map(n => {
      if n == 0 {align(left + horizon)[#text(hyphenate: false, context __g-localization.final().grade-table-points)]}
      else if n == end-g-question-locations.len() [
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

  let grade-row = columns-number.map(n => 
    {
      if n == 0 {
        align(left + horizon)[#text(hyphenate: false, context __g-localization.final().grade-table-grade)]
      }
    }
  )

  align(center, table(
      stroke: 0.8pt + luma(80),
      columns: columns-number.map( n => 
      {
        if n == 0 {auto}
        else if n == end-g-question-locations.len() {auto}
        else {30pt}
      }),
      rows: (auto, auto, 30pt),
      ..question-row.map(n => n),
      ..point-row.map(n => n),
      ..grade-row.map(n => n),
    )
  )
}

#let __g-scholl-header = () => {
  
}

#let __g-show_clarifications = (clarifications: none) => {
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

#let __document-name = (
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

#let __read-localization = (
  language: "en",
  localization: (
    grade-table-queston: none,
    grade-table-total: none,
    grade-table-points: none,
    grade-table-grade: none,
    point: none,
    points: none,
    page: none,
    page-counter-display: none,
    family-name: none,
    given-name: none,
    group: none,
    date: none,
    draft-label: none,
  )) => {
    let __lang_data = toml("./lang.toml")
    if(__lang_data != none) {
      let __read_lang_data = __lang_data.at(language, default: localization)

      if(__read_lang_data != none) {
        let __read-localization-value = (read_lang_data: none, field: "", localization: none) => {
          let __parameter_value = localization.at(field, default: none)
          if(__parameter_value != none) { return __parameter_value }

          let value = read_lang_data.at(field, default: __g-default-localization.at(field))
          if(value == none) { value = __g-default-localization.at(field)}
          
          return value
        }

        let __grade_table_queston = __read-localization-value(read_lang_data: __read_lang_data, field: "grade-table-queston", localization: localization)
        let __grade_table_total = __read-localization-value(read_lang_data: __read_lang_data, field: "grade-table-total", localization: localization)
        let __grade_table_points = __read-localization-value(read_lang_data: __read_lang_data, field: "grade-table-points", localization: localization)
        let __grade_table_grade = __read-localization-value(read_lang_data: __read_lang_data, field: "grade-table-grade", localization: localization)
        let __point = __read-localization-value(read_lang_data: __read_lang_data, field:"point", localization: localization)
        let __points = __read-localization-value(read_lang_data: __read_lang_data, field: "points", localization: localization)
        let __page = __read-localization-value(read_lang_data: __read_lang_data, field: "page", localization: localization)
        let __page-counter-display = __read-localization-value(read_lang_data: __read_lang_data, field: "page-counter-display", localization: localization)
        let __family_name = __read-localization-value(read_lang_data: __read_lang_data, field: "family-name", localization: localization)
        let __given_name = __read-localization-value(read_lang_data: __read_lang_data, field: "given-name", localization: localization)
        let __group = __read-localization-value(read_lang_data: __read_lang_data, field: "group", localization: localization)
        let __date = __read-localization-value(read_lang_data: __read_lang_data, field: "date", localization: localization)
        let __draft-label = __read-localization-value(read_lang_data: __read_lang_data, field: "draft-label", localization: localization)

        let __g-localization_lang_data = (
              grade-table-queston: __grade_table_queston,
              grade-table-total: __grade_table_total,
              grade-table-points: __grade_table_points,
              grade-table-grade: __grade_table_grade,
              point: __point,
              points: __points,
              page: __page,
              page-counter-display: __page-counter-display,
              family-name: __family_name,
              given-name: __given_name,
              group: __group,
              date: __date,
              draft-label: __draft-label
            )

        context __g-localization.update(__g-localization_lang_data)
      }
    }
}

#let __show-header = (
    page-number: 1,
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
    show-student-data: "first-page",
    // show-student-data: (
    //   given-name: true,
    //   family-name: true,
    //   group: true,
    //   date: true
    // ),
    show-student-number: 1,
  ) => {
      if (page-number==1) { 
        align(right)[#box(
          width:108%,
          grid(
            columns: (auto, auto),
            gutter:0.7em,        
            align(left + top)[
              #if type(school) == "dictionary" {
                if(school.at("logo", default : none) != none) {
                  set image(height:2.5cm, width: 2.7cm, fit:"contain")
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
              }
            ],
            grid(
              rows: (auto, auto, auto),
              gutter:1em,    
                grid(
                  columns: (auto, 1fr, auto),
                  align(left  + top)[
                    #if type(school) == "dictionary" [
                      #school.at("name", default : none) \
                    ]
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
                __g-student-data(
                  page: "first", 
                  show-student-data: show-student-data, 
                  show-student-number: show-student-number,
                )
            )
          )
        )]
      }
      else if calc.rem-euclid(page-number, 2) == 1 {
          grid(
            columns: (auto, 1fr, auto),
            gutter:0.3em,
            align(left  + top)[
              #if type(school) == "dictionary" [
                #school.at("name", default : none) \
              ]
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
          __g-student-data(
            page: "odd", 
            show-student-data: show-student-data, 
            show-student-number: show-student-number,
          )
      }
      else {
          grid(
            columns: (auto, 1fr, auto),
            gutter:0.3em,
            align(left  + top)[
              #if type(school) == "dictionary" [
                #school.at("name", default : none) \
              ] 
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
          __g-student-data(
            page: "pair", 
            show-student-data: show-student-data, 
            show-student-number:  show-student-number,
          )
        }
      } 
    }

#let __show-watermark = (
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
    question-points-position: left,
  ) => {
    let dx = if question-points-position == left { 58pt } else { 72pt }
    place(
      top + right,
      float: true,
      clearance: 0pt,
      // dx:72pt,
      dx:dx,
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

#let __show-draft = (
    draft: true
  ) => {
      if draft == false or draft == none {
        return
      }

      let draft-text = none

      if type(draft) == "string"{
        draft-text = draft
      }

      if type(draft) == "content"{
        draft-text = draft
      }

      if  draft-text == none {
        draft-text = context __g-localization.final().draft-label
      }

      if draft-text != none {
          place(
            center,
            clearance: 0pt,
            dx: -50pt,
            dy: 330pt,
            rotate(-45deg,
              origin: top + right,
              text(size:70pt, fill:silver)[
                #draft-text
              ]
            )
          )
        }
  }
