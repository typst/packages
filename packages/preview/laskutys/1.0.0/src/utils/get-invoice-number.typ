/// -> str
#let get-invoice-number(date) = {
  date.display(
    "[year][month padding:zero][day padding:zero]1",
  )
}
