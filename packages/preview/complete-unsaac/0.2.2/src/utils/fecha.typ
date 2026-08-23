/// Temp fix for 'lang: es' not working on datetime()
#let months = (
  "Enero",
  "Febrero",
  "Marzo",
  "Abril",
  "Mayo",
  "Junio",
  "Julio",
  "Agosto",
  "Septiembre",
  "Octubre",
  "Noviembre",
  "Diciembre",
)
#let get_mes(date) = {
  months.at(date.month() - 1)
}
#let fecha_str(date) = {
  [#get_mes(date) del #date.year()]
}
/// END Temp fix
