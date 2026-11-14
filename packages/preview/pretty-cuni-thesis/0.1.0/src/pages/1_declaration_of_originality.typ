#import "../helpers.typ": *

//Declaration of originality
#let originality_sign(vars) = {
  pagebreak()
  align(bottom)[
    Odevzdáním této bakalářské práce na téma #vars.Title potvrzuji, že jsem ji vypracoval pod vedením vedoucího práce samostatně za použití v práci uvedených pramenů a literatury. Prohlašuji, že jsem při její tvorbě nepoužil nástrojů umělé inteligence jiným způsobem, než je uvedeno ve vyjádření, které je součástí textu práce. Dále potvrzuji, že tato práce nebyla využita k získání jiného nebo stejného titulu.
    ]
  v(10mm)
  [Praha, #vars.Date #vars.Year #h(0.5fr) Podpis autora #h(1fr)]
  v(20mm)
  pagebreak()
}