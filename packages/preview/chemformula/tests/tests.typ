#import "../src/chemformula.typ": *

#let bases = ("A", "Aa", "(Aa)", "[A(a)]", "Aa(Aa)")
#let exponents = ("2", "+", "-", "II")
#let positions = (
  "this*",
  "*this",
  "^this;*",
  "^this *",
  "_this *",
  "^this*",
  "_this*",
  "_this;*",
  "*^this",
  "*_this",
).map(p => p + "@")

#parsing-chem("Na+^3_3@"))
#position-chem("(Na2-)@")

// #for base in bases {
//   for exponent in exponents {
//     for position in positions {
//       let txt = position.replace("*", base).replace("this", exponent)
//       [

//         #txt:
//         #parsing-chem(txt):
//         #eval-chem(parsing-chem(txt))
//       ]
//     }
//   }
// }

#parsing-reaction("K3[Fe(CN)6](aq) + H2O(l) ->[D2O][CN] ^99_12 ACN  Fe^II <=> de alpha $alpha$")
#parsing-chem("K3[Fe(CN)6]")

// #eval-chem(parsing-chem("e^-@"))

#parsing-reaction("CuSO4.5H2O")

#parsing-chem("e^-@")
#parsing-chem("^99_200 Y")

#parsing-chem("+ 2 OH-")

#parsing-reaction("+ 2 OH^-")

#parse-arrow("<=>[Hello][It's Me]")
#parse-arrow("<=")


#parsing-reaction("CH3COOH(aq) $alpha\-$Ketoguterate OH-(aq) _200^99;Y")

#parsing-reaction("$e$- CO^*-")

#ch("CH3COOH(aq) + ZnSO4 v  NO3- CO^*- ")

#ch("K3[Fe(CN)6]")

#ch(`^4_2;He^2+ + ^1_0;n + $e$- <=>[+ 2 OH-][+ 2 H+]`)

#parsing-chem("Cu^^II;^2+")
#ch("(Cu^^II)")

#parsing-reaction("Cu^^II")

$ ch("Cu^^+II;^2+ + 2 OH-") $

#parsing-reaction("CuSO4 * 5H2O")
#parsing-reaction("->[\"de\"][]")


#parsing-reaction("fgh \"->[]\"")

#ch(`"->\[degsdfgdf\]"`)

Package CHemformula

#ch("CH $e$ mFor$mu$uLa_0.1.0")





#let test_parse(chem) = {
  let rules = (
    ("Arrow", regex("(<=>|<->|<-|->|<=|=>)(\[[^\]]*\]){0,2}"), 3),
    ("Elem", regex("[\^\_]*(\[[^\]]*\]|\([^\)]*\)|\{[^\}]*\})[\d\+\-\^\_]*"), 3),
    ("Math", regex("\$[^\$]*\$"), 3),
    ("Text", regex("\"[^\"]*\""), 3),
    ("Precipitation", regex("\ v[\s\@\;]"), 2),
    ("Gaseous", regex(" ^[\s\@\;]"), 2),
    ("Symbol", regex("\ [^A-Za-z\d\_\^]+[\s\@\;]"), 2),
    ("Space", regex("\s+"), 1),
    ("None", regex(".*"), 0),
  )

  _parse((chem,), rules: rules)
}

#test_parse("->[\"\"][] \"->[][]fewfg\" [] ^(d ) \"[]\" [\"\"]")

#"^(d ) ".match(regex("\([^\)]*\)"))

#parsing-reaction("->[\"ch(`de`)\"][]")
#ch("\"-ffag=>\$d\$\" ->[\"Desparate\"][Hello \"#ch(`D2J3^6+;de`)\"]", scope: (ch: ch))
#parsing-reaction("d v (aq) e_\"..\"")

#parsing-chem("^(aq)")
#let ch = ch.with(scope: (ch: ch))
$ ch("Zn^2+ (aq) $#ch(`e`)_\"..\"$ (aq)") $

$ #ch(`CH$e$m^F_O;R$mu$ uLa$""_"0.1.0"$`) $

#ch("H2SO4")

#ch("FeCl3")

#ch("NO3-")

#ch("SO4^2-")

#ch("SO_4;^2-")

#ch("K3Fe(CN)6")

#ch("OH-")

#ch("CuSO4 * 5H2O")

#ch(`^2003_34 E^2*- aq`)

#ch(`Cu^^+II + H__2 H^^2  $stretch(harpoons.rtlb, size: #150%)^"Federic"_"Lorenz"$`)

#ch("H2SO4O5S6")

#ch("AgNO3(aq) + KCl(aq) -> ")

#ch("NO3^-")

#ch("SO3^2-")

#ch("Fe(AlCl3)^+ (aq) [Al(CH3COO)2]+ + CH3")

#ch("Fe^II Cl3")

#ch("^99_33 Th+")

#ch("3H2(g) + N2(g) <=>[\"#h(1em)\"][\"de\"] 2NH3(g)")

#ch("_3^2;Th")

#ch("A + 4 B")

#ch("$alpha\"-Ketoguterate\"$(s) + 3 H2O(l) ->[$h nu$]")

#ch("_2^3+;Th + $space(a^2)$ (g) _3^4;H")


#ch("H2O + $limits(upright(C))^(\"+II\")$ + CH3^*")



#ch("K3[Fe(CN)6]  + 6H2O(aq) SO_4^2-")

#parsing-reaction("2 H2O A_$d$ SO_3^2-")
#position-chem("SO_4^2-")

#parsing-reaction("CuSO4.5H2O ->^Delta H^((alpha de)) e-")

#ch("2 NH3 + 3 H2O(l) ->[] A_$d$ SO_4^2- e- ->[Adf] H^((alpha))")

#ch("_0^1;n+ + ^4_2;He")

#ch(`
  Zn^2+;(aq) <=>[+ 2 OH-][+ 2 H+] $underbrace(#ch("Zn(OH)2 v"), "Solids")$ <=>[+ 2 OH-][+ 2 H+] $underbrace(#ch("[Zn(OH)4]^2-"), "Solution")$
`)

$ K = ch("[CH3COO-][H+]")/ch("CH3COOH") $

#parsing-reaction("K2Cr^^(+V);2O6 ^ Cr(OH)3(aq)")
#position-chem("Cr(OH)3(aq)")

#parsing-reaction("A -> B")
#parse-arrow("->")
$ ch("K2Cr^^(+VI)_2;O7(aq) + 2 C^^0;H2O(aq) -> CO2(g) ^  + 2 Cr^^+III;(OH)3(aq)") $
#parsing-reaction("(({}))")
#import "@preview/alchemist:0.1.8": skeletize, single, fragment
#let ch = ch.with(scope: (ch: ch, skeletize: skeletize, single: single))
$ [limits(#skeletize({
  single(angle: -1)
  single(angle: 1)
  fragment("CH_3")
}))]^(2+) $
#ch("K3[Fe(CN)6] SiO4;^2-")


#"(CH(AjJ)fkl) (AH)".matches(regex("\([^)(]*(?:\([^)(]*(?:\([^)(]*(?:\([^)(]*\)[^)(]*)*\)[^)(]*)*\)[^)(]*)*\)"))

#ch("G^((AF)3F)")

#parsing-reaction("^99_33    Th+")

#ch("^99_33 Th")



$ {a/b}_2 lr("{" d/3 #sym.paren.r) $

#type(sym.paren.l)

#type(")")

#parsing-reaction("(2*-)")



#parsing-reaction("((a2))3)4)5")

