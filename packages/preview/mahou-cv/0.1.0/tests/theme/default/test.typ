#import "/src/theme.typ": default-theme

#assert.eq(default-theme, (
  margin: 22pt,
  font: "libertinus serif",
  color: (
    accent: blue,
    body: black,
    header: none,
    main: none,
    aside: none,
  ),
  main-width: 5fr,
  aside-width: 3fr,
))
