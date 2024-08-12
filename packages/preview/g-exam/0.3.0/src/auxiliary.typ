#import "./global.typ" : *

#let __g-student-data(show-line-two: true) = {
    locate(loc => {
      [#__g-localization.final(loc).family-name: #box(width: 2fr, repeat[.]) #__g-localization.final(loc).given-name: #box(width:1fr, repeat[.])]
      if show-line-two {
        v(1pt)
        align(right, [#__g-localization.final(loc).group: #box(width:2.5cm, repeat[.]) #__g-localization.final(loc).date: #box(width:3cm, repeat[.])])
      }
    }
  )
} 

#let __g-grade-table-header(decimal-separator: ".") = {
      locate(loc => {        
        let end-g-question-locations = query(<end-g-question-localization>, loc)
        let columns-number = range(0, end-g-question-locations.len() + 1)
      
        let question-row = columns-number.map(n => {
            if n == 0 {align(left + horizon)[#text(hyphenate: false,__g-localization.final(loc).grade-table-queston)]}
            else if n == end-g-question-locations.len() {align(left + horizon)[#text(hyphenate: false,__g-localization.final(loc).grade-table-total)]}
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
            if n == 0 {align(left + horizon)[#text(hyphenate: false,__g-localization.final(loc).grade-table-points)]}
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

        let calification-row = columns-number.map(n => 
          {
            if n == 0 {
              align(left + horizon)[#text(hyphenate: false, __g-localization.final(loc).grade-table-calification)]
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
          ..calification-row.map(n => n),
        )
      )
    }
  )
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
    given-name: none,
    group: none,
    date: none
  )) => {
    let __lang_data = toml("./lang.toml")
    if(__lang_data != none) {
      let __read_lang_data = __lang_data.at(languaje, default: localization)

      if(__read_lang_data != none) {
        let __read-localization_value = (read_lang_data: none, field: "", localization: none) => {
          let __parameter_value = localization.at(field)
          if(__parameter_value != none) { return __parameter_value }

          let value = read_lang_data.at(field, default: __g-default-localization.at(field))
          if(value == none) { value = __g-default-localization.at(field)}
          
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
        let __given_name = __read-localization_value(read_lang_data: __read_lang_data, field: "given-name", localization: localization)
        let __group = __read-localization_value(read_lang_data: __read_lang_data, field: "group", localization: localization)
        let __date = __read-localization_value(read_lang_data: __read_lang_data, field: "date", localization: localization)

        let __g-localization_lang_data = (
              grade-table-queston: __grade_table_queston,
              grade-table-total: __grade_table_total,
              grade-table-points: __grade_table_points,
              grade-table-calification: __grade_table_calification,
              point: __point,
              points: __points,
              page: __page,
              page-counter-display: __page-counter-display,
              family-name: __family_name,
              given-name: __given_name,
              group: __group,
              date: __date,
            )

        __g-localization.update(__g-localization_lang_data)
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
    question-point-position: left,
  ) => {
    let dx = if question-point-position == left { 58pt } else { 72pt }
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