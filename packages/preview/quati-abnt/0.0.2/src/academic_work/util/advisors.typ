// # Advisors. Orientadores.

#let get_advisor_role(
  gender: "masculine",
  is_co_advisor: false,
) = {
  if is_co_advisor {
    "co"
  }
  "orientador"
  if gender == "feminine" {
    "a"
  }
}
