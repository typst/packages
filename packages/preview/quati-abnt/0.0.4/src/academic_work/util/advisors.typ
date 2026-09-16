// # Advisors. Orientadores.

#let get_advisor_role(
  gender: "m",
  is_co_advisor: false,
) = {
  if is_co_advisor {
    "co"
  }
  "orientador"
  if gender == "f" {
    "a"
  }
}
