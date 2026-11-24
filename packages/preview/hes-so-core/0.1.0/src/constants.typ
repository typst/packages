//---------------------------
// ------ CONSTANTES --------
// Commonly used constants  -
//---------------------------



//-----------------------------------------
// -------------- FONTSIZES ---------------
// We keep fontsizes outside dictionaries -
// to keep short call of the fontsizes    -
//-----------------------------------------
#let tinyer  = 6pt
#let tiny    = 8pt
#let smaller = 9pt
#let small   = 10pt
#let normal  = 11pt
#let large   = 14pt
#let larger  = 16pt
#let huge    = 24pt
#let huger   = 36pt

// fontsize+
#let tinyer-p  = tinyer+5pt
#let tiny-p    = tiny+5pt
#let smaller-p = smaller+5pt
#let small-p   = small+5pt
#let normal-p  = normal+5pt
#let large-p   = large+5pt
#let larger-p  = larger+5pt
#let huge-p    = huge+5pt
#let huger-p   = huger+5pt

// fontsizes++
#let tinyer-pp  = tinyer+10pt
#let tiny-pp    = tiny+10pt
#let smaller-pp = smaller+10pt
#let small-pp   = small+10pt
#let normal-pp  = normal+10pt
#let large-pp   = large+10pt
#let larger-pp  = larger+10pt
#let huge-pp    = huge+10pt
#let huger-pp   = huger+10pt


//-------------------------------------------------------
// ----------------------- COLORS -----------------------
// Some colors are in dictionary to keep topic together -
// e.g. school colors are in sub-dictionaries           -
//-------------------------------------------------------
#let colors = (
  box: (
    border: rgb("#252525"),
  ),
  code: (
    bg:     rgb("#F5F5F5"),
    border: rgb("#F5F5F5").darken(10%),
  ),
  gray-80 : rgb("#000000").lighten(20%),
  gray-70 : rgb("#000000").lighten(30%),
  gray-60 : rgb("#000000").lighten(40%),
  gray-50 : rgb("#000000").lighten(50%),
  gray-40 : rgb("#000000").lighten(60%),
  gray-30 : rgb("#000000").lighten(70%),
  gray-20 : rgb("#000000").lighten(80%),
  gray-10 : rgb("#000000").lighten(90%),
  hes-so: (
    // https://www.hes-so.ch/medias-et-communication/logos
    blue: rgb("#00609c"),
    gray: rgb("#968b83")
  ),
  mse: (
    // Get from logo in img/logos
    red: rgb("#ea514a"),
    gray: rgb("#6d7a82")
  ),
  hei: (
    orange : rgb("#f36d21"),
    blue   : rgb("#0199d6"),
    pink   : rgb("#d41367"),
    yellow : rgb("#f3c300"),
    green  : rgb("#00945e"),
  ),
  heiafr: (
    // https://www.heia-fr.ch/en/university/press-and-communication/logo/
    blue: cmyk(100%, 23%, 0%, 18%),
    gray: cmyk(0%, 6%, 11%, 38%)
  ),
  heigvd: (
    red: rgb("#e1251b")
  ),
  hepia: (
    black: rgb("#000000"),
    red: rgb("#e2001a")
  ),
  spl: (
    green : rgb("#bed600").darken(20%),
    blue  : rgb("#00a9e0").darken(20%),
    pink  : rgb("#da0066").darken(20%),
  ),
  icon: (
    info      : rgb("#5b75a0ff"),
    idea      : rgb("#ffe082ff"),
    warning   : rgb("#ffce31ff"),
    important : rgb("#f44336ff"),
    fire      : rgb("#fc9502ff"),
    rocket    : rgb("#bc5fd3ff"),
    todo      : rgb("#F5F5F5").darken(10%),
    think     : rgb("#00925a").darken(20%),
    help      : rgb("#00925a").darken(20%),
  ),
)


//------------------
// ----- FONTS -----
//------------------

#let fonts = (
  default: (
    "Libertinus Serif",
    "Fira Sans",
  ),
  hei: "Corporative Sans",
)


//------------------
// ----- LOGOS -----
//------------------

#let logos = (
  hesso-logo        : path("img/logos/hesso-logo.svg"),
  hesso-full        : path("img/logos/hesso-full.svg"),
  mse               : path("img/logos/mse.svg"),
  swissuniversities : path("img/logos/swissuniversities.svg"),
  hei               : path("img/logos/hei.svg"),
  hevs              : path("img/logos/hevs.svg"),
  heiafr-short      : path("img/logos/heiafr-short.svg"),
  heiafr-full       : path("img/logos/heiafr-full.svg"),
  heigvd            : path("img/logos/heigvd.svg"),
  hepia             : path("img/logos/hepia.svg"),
)


// -----------------
// ----- ICONS -----
// -----------------

#let placeholder      = path("img/placeholder.svg")
#let icon             = path("img/icons/icon.svg")
#let condidential     = path("img/confidential.svg")

#let icons = (
  check-badge  : path("img/icons/check-badge.svg"),
  check-circle : path("img/icons/check-circle.svg"),
  check-square : path("img/icons/check-square.svg"),
  check        : path("img/icons/check.svg"),
  circle       : path("img/icons/circle.svg"),
  file         : path("img/icons/file.svg"),
  fire         : path("img/icons/fire.svg"),
  folder       : path("img/icons/folder.svg"),
  idea         : path("img/icons/idea.svg"),
  important    : path("img/icons/important.svg"),
  info         : path("img/icons/info.svg"),
  rocket       : path("img/icons/rocket.svg"),
  square       : path("img/icons/square.svg"),
  todo         : path("img/icons/todo.svg"),
  warning      : path("img/icons/warning.svg"),
  think        : path("img/icons/think.svg"),
  help         : path("img/icons/help.svg"),
  x-circle     : path("img/icons/x-circle.svg"),
  x-square     : path("img/icons/x-square.svg"),
  x            : path("img/icons/x.svg"),
)
