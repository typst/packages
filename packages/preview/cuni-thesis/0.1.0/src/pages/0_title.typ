#import "../helpers.typ": *

//Title page of thesis
#let template_title(vars) = {
  let title_page(vars) = {
    Large[Univerzita Karlova]

    v(4mm)

    Large[Pedagogická fakulta]

    v(4mm)

    vars.Department

    v(1fr)

    Large[*BAKALÁŘSKÁ PRÁCE*]
    v(1fr)

    LARGE[*#vars.Title*]

    v(8mm)

    LARGE[*#vars.TitleEN*]

    v(15mm)

    LARGE[#vars.Author]

    v(1fr)
    
      $"Vedoucí bakalářské práce:" & #vars.Supervisor \
      "Studijní program:" & #vars.StudyPrograme \ 
      "Studijní obor:" & #vars.StudyField$ 

      v(1fr)

    [Praha #vars.Year]
  }

  align(center + horizon)[
      #title_page(vars)
  ]
}