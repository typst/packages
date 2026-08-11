#import "/lib.typ": *
#set page(width: 16cm, height: auto, margin: 2pt)

#let kanban-board(kanban-item) = kanban(
  font-size: 0.80em,
  font: "Liberation Sans",
  kanban-column("Backlog", color: red,
    kanban-item(stroke: rgb("#FF5733"))[41][high][Authorization and data validation],
    kanban-item(stroke: rgb("#33FF57"))[18][high][Cart API integration],
    kanban-item(stroke: rgb("#8D33FF"))[18][medium][City dropdown menu],
    kanban-item(stroke: rgb("#FF33A1"))[7][medium][Dynamic cart item count],
    kanban-item(stroke: rgb("#33C1FF"))[5][medium][Main page prototype],
    kanban-item(stroke: rgb("#8D33FF"))[1][low][Tests for cart API],
  ),
  kanban-column("Work in progress", color: yellow,
    kanban-item(stroke: rgb("#FF5733"))[7][medium][John][Checkout page],
    kanban-item(stroke: rgb("#FF0000"))[18][medium][John][Stock availability check],
    kanban-item(stroke: rgb("#33FF57"))[18][medium][Olivia][Add/remove book tests],
    kanban-item(stroke: rgb("#33C1FF"))[7][medium][Stephen]["About Us" page layout],
  ),
  kanban-column("Testing", color: aqua,
    kanban-item(stroke: rgb("#FF5733"))[18][high][John][Add-to-cart API],
    kanban-item(stroke: rgb("#33C1FF"))[5][medium][Emily]["Contact Us" page],
    kanban-item(stroke: rgb("#FFC300"))[5][medium][Alex]["News" page mockup],
  ),
  kanban-column("Done", color: green,
    kanban-item(stroke: rgb("#FFC300"))[50][high][Michael][Books database],
    kanban-item(stroke: rgb("#FF33A1"))[32][high][Stephen][Books catalog with filters],
    kanban-item(stroke: rgb("#33FF57"))[1][low][Arthur]["About Us" page mockup],
  ),
)

// Light theme.
#kanban-board(kanban-item)

#set page(fill: black)
#set text(fill: white)
#let kanban-item = kanban-item.with(fill: black)

// Dark theme.
#kanban-board(kanban-item)
