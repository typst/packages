#import "lib.typ": join
#import "../font-sizes.typ": *

#let fourthpage(
  faith,
  school,
  year,
  title,
  subtitle,
  authors,
  department,
  supervisor,
  advisor,
  examiner,
  city,
  typeset-with,
  cover-caption,
  printed-by,
) = {
  grid(
    rows: (1fr, auto),
    {
      let fmt-auth = if faith {
        upper
      } else {
        smallcaps
      }
      let vv = v(0.8cm)

      v(4.5cm)
      [
        #title\
        #subtitle\
        #authors.join(", ")
      ]
      vv
      [
        #sym.copyright #fmt-auth(authors.join(", ")), #year.
      ]
      vv
      if supervisor != none {
        [*Supervisor:* #linebreak()]
        [#supervisor.at(0), #supervisor.at(1) #linebreak()]
        vv
      }
      if advisor != none {
        [*Advisor:* #linebreak()]
        [#advisor.at(0), #advisor.at(1) #linebreak()]
        vv
      }
      if examiner != none {
        [*Examiner:* #linebreak()]
        [#examiner.at(0), #examiner.at(1) #linebreak()]
        vv
      }

      [
        Master's Thesis #year\
        #department\
        #join(school, " and ")\
        SE-412 96 Gothenburg\
        Telephone +46 31 772 1000
      ]
      vv
      [
        Acknowledgements, dedications, and similar personal statements in this thesis, reflect the author's own views.
      ]
      vv
      if cover-caption != none {
        [*Cover:* #cover-caption]
        vv
      }
      [
        Typeset in #typeset-with\
        #if printed-by != none {
          [Printed by #printed-by#linebreak()]
        }
        #city, #year
      ]
    },
  )
}
