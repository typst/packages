/// -> str
#let get_invoice_number(date) = {
  date.display(
    "[year][month padding:zero][day padding:zero]1",
  )
}
