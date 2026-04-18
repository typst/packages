#import "../SETUP/ELEMENTS.typ": ELEM

#show outline: set heading(outlined: true)

#set text(..ELEM.text.normal)

#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)

#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)

#outline(
  title: [List of Equations],
  target: math.equation,
)

#outline(
  title: [List of Exhibits],
  target: figure.where(kind: "exhibit"),
)
