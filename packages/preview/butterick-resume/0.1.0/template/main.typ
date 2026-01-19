#import "@preview/butterick-resume:0.1.0": *

#show: template

#set page(
  footer: {
    set align(center)
    set text(font: "Source Sans 3", size: 10pt, tracking: 0.1em)
    context upper[Argon Résumé --- Page #here().page() of #counter(page).final().first()]
  },
  footer-descent: 0.75in,
)

#introduction(
  name: [Trixie B. Argon],
  details: [
    5419 Hollywood Blvd Ste. C731, Los Angeles CA 90027 \
    #link("tel:+13235551435")[(323) 555 1435] #link("mailto:trixieargon@gmail.com")
  ],
)

= Education
#two-grid(
  left: [UCLA Anderson School of Management],
  right: [2011--13],
)
- Cumulative GPA: 3.98
- Academic interests: real-estate financing, criminal procedure, corporations
- Henry Murtaugh Award

#two-grid(
  left: [Hartford University],
  right: [2003--07],
)
- B.A. _summa cum laude_, Economics
- Extensive coursework in Astrophysics, Statistics
- Van Damme Scholarship

= Business experience
#two-grid(
  left: [Boxer Bedley & Ball Capital Advisors],
  right: [2008--11],
)
_Equity analyst_
- Performed independent research on numerous American industries, including:
- Steelmaking, croquet, semiotics, and butterscotch manufacturing
- Led company in equities analyzed in two quarters

= Other work experience
#two-grid(
  left: [Proximate Cause],
  right: [2007--08],
)
_Assistant to the director_
- Helped devise fundraising campaigns for this innovative nonprofit
- Handled lunch orders and general errands

#two-grid(
  left: [Hot Topic],
  right: [2004--06],
)
_ Retail-sales associate _
- Top in-store sales associate in seven out of eight quarters
- Inventory management
- Training and recruiting
