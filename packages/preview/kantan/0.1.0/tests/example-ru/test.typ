#import "/lib.typ": *
#set page(width: 17cm, height: auto, margin: 2pt)

#let kanban-board(kanban-item) = kanban(
  font-size: 0.80em,
  font: "Liberation Sans",
  kanban-column("Backlog", color: red,
    kanban-item(stroke: rgb("#FF5733"))[41][высокий][Авторизация с проверкой данных],
    kanban-item(stroke: rgb("#33FF57"))[18][высокий][Интеграция API корзины],
    kanban-item(stroke: rgb("#8D33FF"))[18][средний][Выпадающее меню города],
    kanban-item(stroke: rgb("#FF33A1"))[7][средний][Динамическое число товаров в корзине],
    kanban-item(stroke: rgb("#33C1FF"))[5][средний][Прототип главной страницы],
    kanban-item(stroke: rgb("#33C1FF"))[5][средний][Страница "Контакты"],
    kanban-item(stroke: rgb("#FFC300"))[5][средний][Макет страницы "Новости"],
    kanban-item(stroke: rgb("#8D33FF"))[1][низкий][Олеся][Тесты для API корзины],
  ),
  kanban-column("Work in progress", color: yellow,
    kanban-item(stroke: rgb("#FF5733"))[7][средний][Иван][Оформление заказа],
    kanban-item(stroke: rgb("#FF0000"))[18][средний][Иван][Проверка наличия книг на складе],
    kanban-item(stroke: rgb("#33FF57"))[18][средний][Олеся][Тесты для добавления/удаления книг],
    kanban-item(stroke: rgb("#33C1FF"))[7][средний][Степан][Вёрстка страницы "О~нас"],
  ),
  kanban-column("Testing", color: aqua,
    kanban-item(stroke: rgb("#FF5733"))[18][высокий][Иван][API для добавления книг в корзину],
  ),
  kanban-column("Done", color: green,
    kanban-item(stroke: rgb("#FFC300"))[50][высокий][Михаил][База данных для книг],
    kanban-item(stroke: rgb("#FF33A1"))[32][высокий][Степан][Каталог книг с фильтрацией],
    kanban-item(stroke: rgb("#33FF57"))[1][низкий][Артём][Макет страницы "О~нас"],
  ),
)

// Light theme.
#kanban-board(kanban-item)

#set page(fill: black)
#set text(fill: white)
#let kanban-item = kanban-item.with(fill: black)

// Dark theme.
#kanban-board(kanban-item)
