#import "@preview/fontawesome:0.1.0": *
#import "./styles.typ": *

//TODO Fix the distance between the elements
#let render-entry-icon-info(date: "", location: "") = {
    {
      if date.len() > 0{
        box({
          fa-hourglass-2()
          regular-text-style(date)
        })
      }
      h(10pt)
      if location.len() > 0{
        box({
          fa-location-dot()
          regular-text-style(location)
        })
      }
    }
} 

#let render-entry-header(  
  title, 
  company-or-university, 
  date, 
  location, 
) = {
  table(
      columns: (1fr),
      inset: 0pt,
      stroke: none,
      row-gutter: entry-style.margins.between-title-and-subtitle,
      align: auto,
      {
        black-topic-style(title)
        accent-subtopic-style(" @" + company-or-university)
      },
      render-entry-icon-info(date: date, location: location)
  )
}