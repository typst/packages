#import "../core/colors.typ": kamk-old-bar, kamk-accent
#import "../core/utils.typ": format-authors

#let titlepage(
  title: "",
  authors: (),
  degree-title: "",
  degree-programme: "",
  date: datetime.today(),
  language: "fi",
  cover-image: none,
) = {
  
  // Determine semester (Spring: Jan-Jul, Autumn: Aug-Dec)
  let month = date.month()
  let year = date.year()
  let semester = if month < 8 {
    if language == "fi" { "Kevät " + str(year) } else { "Spring " + str(year) }
  } else {
    if language == "fi" { "Syksy " + str(year) } else { "Autumn " + str(year) }
  }

  grid(
    columns: (14.9cm, 6.1cm),
    rows: 100%,
    
    // --- LEFT COLUMN (White Side) ---
    box(height: 100%, width: 100%, [
      
      #place(top + left, dx: 2.3cm, dy: 9cm, block(width: 11.1cm)[
        #text(fill: kamk-accent, size: 11pt)[#format-authors(authors, language: language)]
        #v(0em)
        #text(fill: kamk-accent, size: 18pt, weight: "bold")[#title]
      ])
      
      // Render the custom image, or fallback to the default package asset
      #place(bottom + left, dx: 0cm, dy: 0cm, {
        set image(width: 100%)
        if cover-image == false {
          // No image at all; leave the left column blank
        } else if cover-image != none {
          cover-image
        } else {
          image("../../assets/cover_image.svg", alt: "Kajaani University of Applied Sciences logo")
        }
      })
    ]),
       
    // --- RIGHT COLUMN (Petrol Side) ---
    rect(
      width: 100%, height: 100%, fill: kamk-old-bar, stroke: none,
      [
        #place(top + right, dx: -0.9cm, dy: 20cm, align(right, text(fill: white, size: 10pt)[
          #degree-title \
          #degree-programme \
          #semester
        ]))
        
        #place(bottom + left, dx: 0.5cm, dy: -1.5cm, 
          image("../../assets/KAMK_white_copyrighted.svg", width: 85%, alt: "Kajaani University of Applied Sciences logo")
        )
      ]
    )
  )
}
